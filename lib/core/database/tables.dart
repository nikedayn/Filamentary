import 'package:drift/drift.dart';

class Printers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get ipAddress => text()();
  
  // Чисті нові поля керування
  TextColumn get manufacturer => text()();
  TextColumn get model => text()();
  IntColumn get port => integer().withDefault(const Constant(80))();
  TextColumn get apiKey => text().nullable()();
  
  TextColumn get activeSlotsJson => text()(); 
  IntColumn get slotsCount => integer()();

  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
  TextColumn get imageUrl => text().nullable()();
}

class Materials extends Table {
  TextColumn get id => text()();
  TextColumn get manufacturer => text()();
  TextColumn get type => text()();
  TextColumn get color => text()();
  TextColumn get diameter => text().withDefault(const Constant('1.75mm'))(); 
  TextColumn get imageUrl => text().nullable()();
  
  RealColumn get initialWeight => real()();
  RealColumn get usedWeight => real().withDefault(const Constant(0.0))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class PrintJobs extends Table {
  TextColumn get id => text()();
  TextColumn get printerId => text().references(Printers, #id)();
  TextColumn get modelName => text()(); // Назва gcode файлу
  TextColumn get status => text()(); // Успішно, Скасовано, Збій
  
  // ПУНКТ 3: Характеристики виконаної операції друку
  RealColumn get spentWeight => real()(); // Скільки грам списано
  TextColumn get usedMaterialsLogJson => text()(); // Які саме котушки (ID та назви) брали участь
  
  DateTimeColumn get startTime => dateTime()(); // Дата та час
  IntColumn get duration => integer()(); // Тривалість друку в секундах
  
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get entityId => text()();
  RealColumn get changeValue => real().nullable()();
  TextColumn get type => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}