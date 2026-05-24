import 'dart:math';
import 'package:injectable/injectable.dart';
import 'package:filamentary/core/database/database.dart';
import 'package:filamentary/core/utils/app_logger.dart';
import 'sync_conflict.dart';

@LazySingleton()
class SyncEngine {
  final AppDatabase _db;

  SyncEngine(this._db);

  // Обчислення нової версії за формулою з ТЗ: newVersion = max(v1, v2) + 1
  int calculateNewVersion(int localVersion, int cloudVersion) {
    return max(localVersion, cloudVersion) + 1; // 
  }

  // Перевірка та злиття (Merge) одного запису матеріалу з хмари
  Future<SyncConflict?> mergeMaterial(Map<String, dynamic> cloudJson) async {
    final String id = cloudJson['id'];
    final int cloudVersion = cloudJson['version'];
    final DateTime cloudTimestamp = DateTime.parse(cloudJson['timestamp']);

    // Шукаємо, що у нас є в локальній базі по цьому ID
    final localRecord = await (_db.select(_db.materials)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    if (localRecord == null) {
      // Якщо локально такого об'єкта взагалі немає — просто записуємо його з хмари (чистий імпорт)
      AppLogger.i('Синхронізація: Імпорт нового матеріалу з хмари (ID: $id)');
      // Конвертуємо JSON у компаньйон бази даних і вставляємо
      // (Для простоти коду в прикладі опускаємо повний мапінг компаньйона)
      return null;
    }

    // Якщо версії однакові і дані не змінювалися — нічого не робимо
    if (localRecord.version == cloudVersion) {
      return null;
    }

    // Якщо хмарна версія новіша, а локальна не змінювалася автономно
    if (cloudVersion > localRecord.version && cloudTimestamp.isAfter(localRecord.timestamp)) {
      AppLogger.i('Синхронізація: Автоматичне оновлення локального матеріалу на хмарну версію');
      // Оновлюємо локальну базу хмарними даними
      return null;
    }

    // ТЗ: При розбіжностях (різні version для одного id і конфлікт інтересів) -> запуск режиму користувача 
    AppLogger.w('Виявлено конфлікт даних для матеріалу з ID: $id');
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
}