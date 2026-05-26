import 'package:injectable/injectable.dart';
import 'package:filamentary/core/database/database.dart';
import 'package:filamentary/core/database/database_mappers.dart';
import 'package:filamentary/features/inventory/domain/models/filament_material.dart';

@lazySingleton
class InventoryRepository {
  final AppDatabase _db;

  InventoryRepository(this._db);

  /// Повертає реактивний стрім чистих моделей матеріалів, повністю сховавши Drift
  Stream<List<FilamentMaterial>> watchMaterials() {
    return _db.watchActiveMaterials().map((driftList) =>
        driftList.map((driftItem) => driftItem.toDomain()).toList());
  }
}