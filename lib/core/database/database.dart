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
          if (from < 4) {
            await m.addColumn(printers, printers.imageUrl);
          }
        },
      );

  // ==========================================
  // РЕЖИМ ЧИТАННЯ (STREAMS)
  // ==========================================

  Stream<List<Material>> watchActiveMaterials() {
    return (select(materials)..where((tbl) => tbl.isDeleted.equals(false))).watch();
  }

  Stream<List<Printer>> watchActivePrinters() {
    return (select(printers)..where((tbl) => tbl.isDeleted.equals(false))).watch();
  }

  // ==========================================
  // ОПЕРАЦІЇ З МАТЕРІАЛАМИ (LOCAL-FIRST)
  // ==========================================

  /// Створення нового матеріалу з первинним логом
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

  /// МАСОВЕ ОНОВЛЕННЯ ГРУПИ МАТЕРІАЛІВ: Оновлює характеристики для кількох ID разом
  Future<void> updateGroupMaterials({
    required List<String> materialIds,
    required String manufacturer,
    required String type,
    required String color,
    required String diameter,
    required String transactionId,
  }) async {
    await transaction(() async {
      for (final id in materialIds) {
        // 1. Отримуємо поточний стан котушки для збільшення її версії
        final current = await (select(materials)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
        if (current == null) continue;

        // 2. Оновлюємо характеристики котушки, піднімаємо версію та фіксуємо час
        await (update(materials)..where((tbl) => tbl.id.equals(id))).write(
          MaterialsCompanion(
            manufacturer: Value(manufacturer),
            type: Value(type),
            color: Value(color),
            diameter: Value(diameter),
            version: Value(current.version + 1), // Критично для хмари!
            timestamp: Value(DateTime.now()),
          ),
        );
      }

      // 3. Записуємо одну загальну транзакцію про зміну групи у журнал
      await into(transactions).insert(
        TransactionsCompanion.insert(
          id: transactionId,
          entityId: materialIds.join(','), // Зберігаємо список ID через кому
          changeValue: const Value(null),
          type: 'UpdateGroupMaterials',
        ),
      );
    });
  }

  /// Оновлення ваги матеріалу (списання пластику під час друку)
  Future<void> updateMaterialWeight(String id, double usedDelta, String transactionId) async {
    await transaction(() async {
      final current = await (select(materials)..where((tbl) => tbl.id.equals(id))).getSingle();
      double newUsedWeight = current.usedWeight + usedDelta;
      
      await (update(materials)..where((tbl) => tbl.id.equals(id))).write(
        MaterialsCompanion(
          usedWeight: Value(newUsedWeight), 
          version: Value(current.version + 1), 
          timestamp: Value(DateTime.now()),
        ),
      );
      
      await into(transactions).insert(
        TransactionsCompanion.insert(
          id: transactionId, 
          entityId: id, 
          changeValue: Value(-usedDelta), 
          type: 'WriteOff',
        ),
      );
    });
  }

  /// БЕЗПЕЧНЕ ВИДАЛЕННЯ МАТЕРІАЛУ: Фіксує транзакцію та інкрементує версію
  Future<void> softDeleteMaterial(String id, String transactionId) async {
    await transaction(() async {
      final current = await (select(materials)..where((tbl) => tbl.id.equals(id))).getSingle();
      
      await (update(materials)..where((tbl) => tbl.id.equals(id))).write(
        MaterialsCompanion(
          isDeleted: const Value(true), 
          version: Value(current.version + 1),
          timestamp: Value(DateTime.now()),
        ),
      );

      await into(transactions).insert(
        TransactionsCompanion.insert(
          id: transactionId,
          entityId: id,
          changeValue: const Value(0.0), // Фіксовано: передаємо Value(0.0) замість null
          type: 'DeleteMaterial',
        ),
      );
    });
  }

  // ==========================================
  // ОПЕРАЦІЇ З ПРИНТЕРАМИ (LOCAL-FIRST)
  // ==========================================

  /// БЕЗПЕЧНЕ ВИДАЛЕННЯ ПРИНТЕРА: Фіксує транзакцію та інкрементує версію
  Future<void> softDeletePrinter(String id, String transactionId) async {
    await transaction(() async {
      final current = await (select(printers)..where((tbl) => tbl.id.equals(id))).getSingle();

      await (update(printers)..where((tbl) => tbl.id.equals(id))).write(
        PrintersCompanion(
          isDeleted: const Value(true), 
          version: Value(current.version + 1),
          timestamp: Value(DateTime.now()),
        ),
      );

      await into(transactions).insert(
        TransactionsCompanion.insert(
          id: transactionId,
          entityId: id,
          changeValue: const Value(0.0), // Фіксовано: передаємо Value(0.0) замість null
          type: 'DeletePrinter',
        ),
      );
    });
  }

  /// Зміна кількості слотів принтера з логуванням версії
  Future<void> updatePrinterSlotsCount(String printerId, int newSlotsCount, String transactionId) async {
    await transaction(() async {
      final current = await (select(printers)..where((tbl) => tbl.id.equals(printerId))).getSingle();
      
      final Map<String, dynamic> newSlots = {};
      for (int i = 1; i <= newSlotsCount; i++) {
        newSlots['slot_$i'] = null;
      }

      await (update(printers)..where((tbl) => tbl.id.equals(printerId))).write(
        PrintersCompanion(
          slotsCount: Value(newSlotsCount),
          activeSlotsJson: Value(jsonEncode(newSlots)),
          version: Value(current.version + 1),
          timestamp: Value(DateTime.now()),
        ),
      );

      await into(transactions).insert(
        TransactionsCompanion.insert(
          id: transactionId,
          entityId: printerId,
          changeValue: Value(newSlotsCount.toDouble()), // Чітке приведення до double
          type: 'UpdateSlotsCount',
        ),
      );
    });
  }

  /// Додавання нового принтера з логуванням первинної транзакції
  Future<void> insertPrinterWithLog(PrintersCompanion companion, String transactionId) async {
    await transaction(() async {
      // 1. Вставляємо сам принтер у базу даних
      await into(printers).insert(companion);

      // 2. Фіксуємо транзакцію в журналі змін
      await into(transactions).insert(
        TransactionsCompanion.insert(
          id: transactionId,
          entityId: companion.id.value, // Беремо ID створеного принтера
          changeValue: const Value(null),
          type: 'InsertPrinter',
        ),
      );
    });
  }

  /// Прив'язка котушки матеріалу до конкретного слоту принтера з логуванням версії
  Future<void> connectMaterialToSlot(String printerId, int slotIndex, String? materialId, String transactionId) async {
    await transaction(() async {
      final current = await (select(printers)..where((tbl) => tbl.id.equals(printerId))).getSingle();
      
      final Map<String, dynamic> slots = jsonDecode(current.activeSlotsJson);
      slots['slot_$slotIndex'] = materialId;
      
      await (update(printers)..where((tbl) => tbl.id.equals(printerId))).write(
        PrintersCompanion(
          activeSlotsJson: Value(jsonEncode(slots)),
          version: Value(current.version + 1),
          timestamp: Value(DateTime.now()),
        ),
      );

      await into(transactions).insert(
        TransactionsCompanion.insert(
          id: transactionId,
          entityId: printerId,
          changeValue: const Value(null), // ФІКС ПОМИЛКИ: використовуємо const Value(null) замість чистого null
          type: 'ConnectSlot',
        ),
      );
    });
  }

  /// Повне редагування параметрів принтера користувачем з логуванням версії
  Future<void> updatePrinter(Printer printer, String transactionId) async {
    await transaction(() async {
      final current = await (select(printers)..where((tbl) => tbl.id.equals(printer.id))).getSingle();

      await (update(printers)..where((tbl) => tbl.id.equals(printer.id))).write(
        PrintersCompanion(
          name: Value(printer.name),
          ipAddress: Value(printer.ipAddress),
          port: Value(printer.port),
          manufacturer: Value(printer.manufacturer),
          model: Value(printer.model),
          apiKey: Value(printer.apiKey),
          slotsCount: Value(printer.slotsCount),
          activeSlotsJson: Value(printer.activeSlotsJson),
          imageUrl: Value(printer.imageUrl),
          version: Value(current.version + 1),
          timestamp: Value(DateTime.now()),
        ),
      );

      await into(transactions).insert(
        TransactionsCompanion.insert(
          id: transactionId,
          entityId: printer.id,
          changeValue: const Value(null), // ФІКС ПОМИЛКИ: використовуємо const Value(null) замість чистого null
          type: 'UpdatePrinterDetails',
        ),
      );
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'filamentary_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}