import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart'; 
import 'tables.dart';

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
        final current = await (select(materials)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
        if (current == null) continue;

        await (update(materials)..where((tbl) => tbl.id.equals(id))).write(
          MaterialsCompanion(
            manufacturer: Value(manufacturer),
            type: Value(type),
            color: Value(color),
            diameter: Value(diameter),
            version: Value(current.version + 1), 
            timestamp: Value(DateTime.now()),
          ),
        );
      }

      await into(transactions).insert(
        TransactionsCompanion.insert(
          id: transactionId,
          entityId: materialIds.join(','), 
          changeValue: const Value(null),
          type: 'UpdateGroupMaterials',
        ),
      );
    });
  }

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
          changeValue: const Value(0.0), 
          type: 'DeleteMaterial',
        ),
      );
    });
  }

  // ==========================================
  // ОПЕРАЦІЇ З ПРИНТЕРАМИ (LOCAL-FIRST)
  // ==========================================

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
          changeValue: const Value(0.0), 
          type: 'DeletePrinter',
        ),
      );
    });
  }

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
          changeValue: Value(newSlotsCount.toDouble()), 
          type: 'UpdateSlotsCount',
        ),
      );
    });
  }

  Future<void> insertPrinterWithLog(PrintersCompanion companion, String transactionId) async {
    await transaction(() async {
      await into(printers).insert(companion);

      await into(transactions).insert(
        TransactionsCompanion.insert(
          id: transactionId,
          entityId: companion.id.value, 
          changeValue: const Value(null),
          type: 'InsertPrinter',
        ),
      );
    });
  }

  /// КАСКАДНА ПРИВ'ЯЗКА КОТУШКИ (УЗГОДЖЕННЯ ФОРМАТУ КЛЮЧІВ П. 2.1 ТЗ)
  Future<void> connectMaterialToSlot(String printerId, int slotIndex, String? materialId, String transactionId) async {
    await transaction(() async {
      final current = await (select(printers)..where((tbl) => tbl.id.equals(printerId))).getSingle();
      
      Map<String, dynamic> slotsMap = {};
      try {
        slotsMap = jsonDecode(current.activeSlotsJson);
      } catch (_) {}
      
      // СИНХРОНІЗАЦІЙНИЙ ФІКС КЛЮЧА: Формуємо "slot_1", "slot_2" на основі нульового індексу
      final String slotKey = 'slot_${slotIndex + 1}';
      
      if (materialId != null) {
        // Захист від примарних QR-кодів (Перевірка наявності UUID в інвентарі)
        final matCheck = await (select(materials)..where((tbl) => tbl.id.equals(materialId))).getSingleOrNull();
        if (matCheck == null) {
          throw Exception('Котушки з ID $materialId не існує в локальній базі матеріалів! Зв\'язування скасовано.');
        }
        slotsMap[slotKey] = materialId;
      } else {
        slotsMap.remove(slotKey);
      }

      await (update(printers)..where((tbl) => tbl.id.equals(printerId))).write(
        PrintersCompanion(
          activeSlotsJson: Value(jsonEncode(slotsMap)),
          version: Value(current.version + 1),
          timestamp: Value(DateTime.now()),
        ),
      );

      await into(transactions).insert(
        TransactionsCompanion.insert(
          id: transactionId,
          entityId: printerId,
          changeValue: const Value(null), 
          type: 'ConnectSlot',
        ),
      );
    });
  }

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
          changeValue: const Value(null), 
          type: 'UpdatePrinterDetails',
        ),
      );
    });
  }

  Future<void> registerPrintJobInDatabase({
    required String id,
    required String printerId,
    required String modelName,
    required String status,
    required double spentWeight,
    required String usedMaterialsLogJson,
    required DateTime startTime,
    required int duration,
    required String transactionId,
  }) async {
    await transaction(() async {
      await into(printJobs).insert(
        PrintJobsCompanion.insert(
          id: id,
          printerId: printerId,
          modelName: modelName,
          status: status,
          spentWeight: spentWeight,
          usedMaterialsLogJson: usedMaterialsLogJson,
          startTime: startTime,
          duration: duration,
          version: const Value(1),
          timestamp: Value(DateTime.now()),
        ),
      );

      final List<dynamic> logs = jsonDecode(usedMaterialsLogJson);
      for (var log in logs) {
        final String matId = log['materialId'] ?? '';
        final double spent = (log['spentWeight'] as num?)?.toDouble() ?? 0.0;
        
        if (matId.isEmpty || spent <= 0) continue;

        final currentMat = await (select(materials)..where((tbl) => tbl.id.equals(matId))).getSingleOrNull();
        
        if (currentMat != null) {
          final double newUsedWeight = currentMat.usedWeight + spent;
          
          await (update(materials)..where((tbl) => tbl.id.equals(matId))).write(
            MaterialsCompanion(
              usedWeight: Value(newUsedWeight),
              version: Value(currentMat.version + 1), 
              timestamp: Value(DateTime.now()),
            ),
          );

          await into(transactions).insert(
            TransactionsCompanion.insert(
              id: const Uuid().v4(), 
              entityId: matId,
              changeValue: Value(-spent),
              type: 'WriteOff',
              timestamp: Value(DateTime.now()),
            ),
          );
        }
      }
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