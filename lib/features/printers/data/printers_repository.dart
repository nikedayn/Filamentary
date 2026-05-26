import 'package:injectable/injectable.dart';
import 'package:filamentary/core/database/database.dart';
import 'package:filamentary/core/database/database_mappers.dart';
import 'package:filamentary/features/printers/domain/models/app_printer.dart';

@lazySingleton
class PrintersRepository {
  final AppDatabase _db;

  PrintersRepository(this._db);

  /// Повертає реактивний стрім чистих моделей пристроїв
  Stream<List<AppPrinter>> watchPrinters() {
    return _db.watchActivePrinters().map((driftList) =>
        driftList.map((driftItem) => driftItem.toDomain()).toList());
  }
}