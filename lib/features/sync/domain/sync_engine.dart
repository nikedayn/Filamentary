import 'dart:math';
import 'package:injectable/injectable.dart';
import 'package:drift/drift.dart' as drift;
import 'package:filamentary/core/database/database.dart';
import 'package:filamentary/core/utils/app_logger.dart';
import 'sync_conflict.dart';

@LazySingleton()
class SyncEngine {
  final AppDatabase _db;

  SyncEngine(this._db);

  int calculateNewVersion(int localVersion, int cloudVersion) {
    return max(localVersion, cloudVersion) + 1;
  }

  /// ГОЛОВНИЙ ОРКЕСТРАТОР ЗЛИТТЯ БЕКАПУ (Вирішує костиль №3)
  Future<List<SyncConflict>> mergeCloudBackup(Map<String, dynamic> backupPayload) async {
    final List<SyncConflict> conflicts = [];
    
    AppLogger.i('Синхронізація: Початок процесу безпечного злиття хмарних даних...');

    // Тимчасово вимикаємо перевірку Foreign Keys для повної ізоляції від каскадних помилок
    await _db.customStatement('PRAGMA foreign_keys = OFF;');

    try {
      // КРИТИЧНА ЧЕРГОВІСТЬ ТАБЛИЦЬ: Матеріали -> Принтери -> Логи друку
      
      // 1. Злиття матеріалів (Materials)
      if (backupPayload.containsKey('materials')) {
        final List<dynamic> cloudMaterials = backupPayload['materials'];
        for (var rawJson in cloudMaterials) {
          final conflict = await mergeMaterial(Map<String, dynamic>.from(rawJson));
          if (conflict != null) conflicts.add(conflict);
        }
      }

      // 2. Злиття принтерів (Printers)
      if (backupPayload.containsKey('printers')) {
        final List<dynamic> cloudPrinters = backupPayload['printers'];
        for (var rawJson in cloudPrinters) {
          final conflict = await mergePrinter(Map<String, dynamic>.from(rawJson));
          if (conflict != null) conflicts.add(conflict);
        }
      }

      // 3. Злиття логів друку (PrintJobs)
      if (backupPayload.containsKey('print_jobs')) {
        final List<dynamic> cloudJobs = backupPayload['print_jobs'];
        for (var rawJson in cloudJobs) {
          await mergePrintJob(Map<String, dynamic>.from(rawJson));
        }
      }

    } catch (e, stack) {
      AppLogger.e('Критична помилка під час злиття хмари: $e', stack);
    } finally {
      // ОБОВ'ЯЗКОВО вмикаємо перевірку Foreign Keys назад
      await _db.customStatement('PRAGMA foreign_keys = ON;');
      AppLogger.i('Синхронізація: Перевірку зв’язків бази даних відновлено.');
    }

    return conflicts;
  }

  // ==========================================
  // ЛОГІКА ЗЛИТТЯ ДЛЯ МАТЕРІАЛІВ
  // ==========================================
  Future<SyncConflict?> mergeMaterial(Map<String, dynamic> cloudJson) async {
    final String id = cloudJson['id'];
    final int cloudVersion = cloudJson['version'];
    final DateTime cloudTimestamp = DateTime.parse(cloudJson['timestamp']);

    final localRecord = await (_db.select(_db.materials)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    final companion = MaterialsCompanion(
      id: drift.Value(id),
      manufacturer: drift.Value(cloudJson['manufacturer']),
      type: drift.Value(cloudJson['type']),
      color: drift.Value(cloudJson['color']),
      diameter: drift.Value(cloudJson['diameter']),
      initialWeight: drift.Value((cloudJson['initial_weight'] as num).toDouble()),
      usedWeight: drift.Value((cloudJson['used_weight'] as num).toDouble()),
      imageUrl: drift.Value(cloudJson['image_url']),
      isDeleted: drift.Value(cloudJson['is_deleted'] ?? false),
      version: drift.Value(cloudVersion),
      timestamp: drift.Value(cloudTimestamp),
    );

    if (localRecord == null) {
      AppLogger.i('Синхронізація: Чистий імпорт матеріалу з хмари (ID: $id)');
      await _db.into(_db.materials).insert(companion, mode: drift.InsertMode.insertOrReplace);
      return null;
    }

    if (localRecord.version == cloudVersion) return null;

    if (cloudVersion > localRecord.version && cloudTimestamp.isAfter(localRecord.timestamp)) {
      AppLogger.i('Синхронізація: Локальне оновлення матеріалу на новішу хмарну версію');
      await _db.into(_db.materials).insert(companion, mode: drift.InsertMode.insertOrReplace);
      return null;
    }

    if (localRecord.version > cloudVersion) {
      AppLogger.i('Синхронізація: Хмара відстає від локального матеріалу. Залишаємо локальний.');
      return null;
    }

    return SyncConflict(
      entityId: id,
      entityType: 'Material',
      localData: {
        'id': localRecord.id,
        'manufacturer': localRecord.manufacturer,
        'type': localRecord.type,
        'color': localRecord.color,
        'version': localRecord.version,
        'timestamp': localRecord.timestamp.toIso8601String(),
      },
      cloudData: cloudJson,
    );
  }

  // ==========================================
  // ЛОГІКА ЗЛИТТЯ ДЛЯ ПРИНТЕРІВ
  // ==========================================
  Future<SyncConflict?> mergePrinter(Map<String, dynamic> cloudJson) async {
    final String id = cloudJson['id'];
    final int cloudVersion = cloudJson['version'];
    final DateTime cloudTimestamp = DateTime.parse(cloudJson['timestamp']);

    final localRecord = await (_db.select(_db.printers)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    final companion = PrintersCompanion(
      id: drift.Value(id),
      name: drift.Value(cloudJson['name']),
      ipAddress: drift.Value(cloudJson['ip_address']),
      port: drift.Value(cloudJson['port'] as int),
      manufacturer: drift.Value(cloudJson['manufacturer']),
      model: drift.Value(cloudJson['model']),
      apiKey: drift.Value(cloudJson['api_key']),
      slotsCount: drift.Value(cloudJson['slots_count'] as int),
      activeSlotsJson: drift.Value(cloudJson['active_slots_json']),
      imageUrl: drift.Value(cloudJson['image_url']),
      isDeleted: drift.Value(cloudJson['is_deleted'] ?? false),
      version: drift.Value(cloudVersion),
      timestamp: drift.Value(cloudTimestamp),
    );

    if (localRecord == null) {
      AppLogger.i('Синхронізація: Чистий імпорт принтера з хмари (ID: $id)');
      await _db.into(_db.printers).insert(companion, mode: drift.InsertMode.insertOrReplace);
      return null;
    }

    if (localRecord.version == cloudVersion) return null;

    if (cloudVersion > localRecord.version && cloudTimestamp.isAfter(localRecord.timestamp)) {
      AppLogger.i('Синхронізація: Локальне оновлення принтера на новішу хмарну версію');
      await _db.into(_db.printers).insert(companion, mode: drift.InsertMode.insertOrReplace);
      return null;
    }

    if (localRecord.version > cloudVersion) return null;

    return SyncConflict(
      entityId: id,
      entityType: 'Printer',
      localData: {
        'id': localRecord.id,
        'name': localRecord.name,
        'version': localRecord.version,
        'timestamp': localRecord.timestamp.toIso8601String(),
      },
      cloudData: cloudJson,
    );
  }

  // ==========================================
  // ЛОГІКА ЗЛИТТЯ ДЛЯ ЛОГІВ ДРУКУ (Append-Only)
  // ==========================================
  Future<void> mergePrintJob(Map<String, dynamic> cloudJson) async {
    final String id = cloudJson['id'];

    final existingJob = await (_db.select(_db.printJobs)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    
    if (existingJob == null) {
      AppLogger.i('Синхронізація: Додавання відсутнього запису історії друку (ID: $id)');
      
      // СУВОРО ТИПІЗОВАНИЙ КОМПАНЬЙОН НА ОСНОВІ ТВОГО TABLES.DART
      final companion = PrintJobsCompanion(
        id: drift.Value(id),
        printerId: drift.Value(cloudJson['printer_id']),
        modelName: drift.Value(cloudJson['model_name'] ?? cloudJson['filename'] ?? 'unknown'), // Безпечний мапінг назви файлу
        status: drift.Value(cloudJson['status']),
        spentWeight: drift.Value((cloudJson['spent_weight'] as num).toDouble()),
        usedMaterialsLogJson: drift.Value(cloudJson['used_materials_log_json']),
        startTime: drift.Value(DateTime.parse(cloudJson['start_time'])),
        duration: drift.Value(cloudJson['duration'] as int? ?? 0), // Парсимо тривалість в секундах
        version: drift.Value(cloudJson['version'] as int? ?? 1),
        timestamp: drift.Value(cloudJson['timestamp'] != null ? DateTime.parse(cloudJson['timestamp']) : DateTime.now()),
        isDeleted: drift.Value(cloudJson['is_deleted'] ?? false),
      );

      await _db.into(_db.printJobs).insert(companion, mode: drift.InsertMode.insertOrReplace);
    }
  }
}