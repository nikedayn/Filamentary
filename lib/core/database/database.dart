import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables.dart';
import 'dart:convert';

part 'database.g.dart';

@LazySingleton()
@DriftDatabase(tables: [Printers, Materials, PrintJobs, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // ПУНКТ 1: Піднімаємо версію до 4
  @override
  int get schemaVersion => 4; 

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(materials, materials.diameter);
            await m.addColumn(materials, materials.imageUrl);
          }
          if (from < 3) {
            await m.addColumn(printers, printers.manufacturer);
            await m.addColumn(printers, printers.model);
            await m.addColumn(printers, printers.port);
            await m.addColumn(printers, printers.apiKey);
            await m.addColumn(printers, printers.activeSlotsJson);
            await m.addColumn(printers, printers.slotsCount);
            await m.addColumn(printJobs, printJobs.spentWeight);
            await m.addColumn(printJobs, printJobs.usedMaterialsLogJson);
          }
          // МІГРАЦІЯ НА ВЕРСІЮ 4: Безпечно додаємо поле фото, не чіпаючи існуючі принтери
          if (from < 4) {
            await m.addColumn(printers, printers.imageUrl);
          }
        },
      );

  Stream<List<Material>> watchActiveMaterials() {
    return (select(materials)..where((tbl) => tbl.isDeleted.equals(false))).watch();
  }

  Future<void> insertMaterialWithLog(MaterialsCompanion material, String transactionId) async {
    await transaction(() async {
      await into(materials).insert(material);
      await into(transactions).insert(
        TransactionsCompanion.insert(
          id: transactionId,
          entityId: material.id.value,
          changeValue: Value(material.initialWeight.value),
          type: 'Refill',
        ),
      );
    });
  }

  Future<void> updateMaterialWeight(String id, double usedDelta, String transactionId) async {
    await transaction(() async {
      final current = await (select(materials)..where((tbl) => tbl.id.equals(id))).getSingle();
      double newUsedWeight = current.usedWeight + usedDelta;
      await (update(materials)..where((tbl) => tbl.id.equals(id))).write(
        MaterialsCompanion(usedWeight: Value(newUsedWeight), version: Value(current.version + 1), timestamp: Value(DateTime.now())),
      );
      await into(transactions).insert(
        TransactionsCompanion.insert(id: transactionId, entityId: id, changeValue: Value(-usedDelta), type: 'WriteOff'),
      );
    });
  }

  Future<void> softDeleteMaterial(String id) async {
    await (update(materials)..where((tbl) => tbl.id.equals(id))).write(
      MaterialsCompanion(isDeleted: const Value(true), timestamp: Value(DateTime.now())),
    );
  }

  Stream<List<Printer>> watchActivePrinters() {
    return (select(printers)..where((tbl) => tbl.isDeleted.equals(false))).watch();
  }

  Future<void> softDeletePrinter(String id) async {
    await (update(printers)..where((tbl) => tbl.id.equals(id))).write(
      PrintersCompanion(isDeleted: const Value(true), timestamp: Value(DateTime.now())),
    );
  }

  Future<void> updatePrinterSlotsCount(String printerId, int newSlotsCount) async {
    await transaction(() async {
      // 1. Отримуємо поточний принтер
      final current = await (select(printers)..where((tbl) => tbl.id.equals(printerId))).getSingle();
      
      // 2. Створюємо чистий JSON під нову кількість слотів
      final Map<String, dynamic> newSlots = {};
      for (int i = 1; i <= newSlotsCount; i++) {
        newSlots['slot_$i'] = null; // Порожні слоти за замовчуванням
      }

      // 3. Оновлюємо принтер у базі
      await (update(printers)..where((tbl) => tbl.id.equals(printerId))).write(
        PrintersCompanion(
          slotsCount: Value(newSlotsCount),
          activeSlotsJson: Value(jsonEncode(newSlots)),
          timestamp: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> connectMaterialToSlot(String printerId, int slotIndex, String? materialId) async {
    await transaction(() async {
      // 1. Отримуємо поточний стан принтера
      final current = await (select(printers)..where((tbl) => tbl.id.equals(printerId))).getSingle();
      
      // 2. Декодуємо поточні слоти з JSON
      final Map<String, dynamic> slots = jsonDecode(current.activeSlotsJson);
      
      // 3. Оновлюємо потрібний слот (індексація для користувача з 1, тому slot_1, slot_2...)
      slots['slot_$slotIndex'] = materialId;
      
      // 4. Записуємо оновлений JSON назад у базу
      await (update(printers)..where((tbl) => tbl.id.equals(printerId))).write(
        PrintersCompanion(
          activeSlotsJson: Value(jsonEncode(slots)),
          timestamp: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> updatePrinter(Printer printer) async {
    await (update(printers)..where((tbl) => tbl.id.equals(printer.id))).write(
      PrintersCompanion(
        name: Value(printer.name),
        ipAddress: Value(printer.ipAddress),
        port: Value(printer.port),
        slotsCount: Value(printer.slotsCount),
        // Якщо ми змінюємо кількість слотів, треба також оновити JSON-структуру
        activeSlotsJson: Value(printer.activeSlotsJson),
        timestamp: Value(DateTime.now()),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // ЗАЛІЗОБЕТОННИЙ ФІКС: path_provider сам знайде легальну папку:
    // на Android це буде /data/user/0/com.example.filamentary/app_flutter
    // на Windows це буде папка в AppData/Roaming
    final dbFolder = await getApplicationDocumentsDirectory();
    
    // Створюємо чистий файл бази даних всередині дозволеної папки
    final file = File(p.join(dbFolder.path, 'filamentary_db.sqlite'));
    
    return NativeDatabase.createInBackground(file);
  });
}