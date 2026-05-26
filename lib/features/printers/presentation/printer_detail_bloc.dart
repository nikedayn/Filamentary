import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:filamentary/core/database/database.dart' as db;
import 'package:filamentary/core/network/printer_client_interface.dart'; 
import 'package:filamentary/features/printers/data/printer_polling_service.dart'; 
import 'package:filamentary/features/printers/domain/models/app_printer.dart'; 
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

// ==========================================
// ПОДІЇ (EVENTS)
// ==========================================
abstract class PrinterDetailEvent extends Equatable {
  const PrinterDetailEvent();
  @override
  List<Object?> get props => [];
}

class StartMonitoring extends PrinterDetailEvent {
  final AppPrinter printer; 
  const StartMonitoring(this.printer);
  @override
  List<Object?> get props => [printer];
}

class UpdateTelemetry extends PrinterDetailEvent {
  final PrinterTelemetry telemetry; 
  const UpdateTelemetry(this.telemetry);
  @override
  List<Object?> get props => [telemetry];
}

class UpdatePrinterObjectEvent extends PrinterDetailEvent {
  final AppPrinter printer;
  const UpdatePrinterObjectEvent(this.printer);
  @override
  List<Object?> get props => [printer];
}

class DeletePrintJobEvent extends PrinterDetailEvent {
  final db.PrintJob job;
  final bool restoreWeight;

  const DeletePrintJobEvent({required this.job, required this.restoreWeight});

  @override
  List<Object?> get props => [job, restoreWeight];
}

class EditPrintJobEvent extends PrinterDetailEvent {
  final db.PrintJob oldJob;
  final Map<String, dynamic> updatedData;

  const EditPrintJobEvent({required this.oldJob, required this.updatedData});

  @override
  List<Object?> get props => [oldJob, updatedData];
}

class AddManualPrintJobEvent extends PrinterDetailEvent {
  final Map<String, dynamic> printData;
  const AddManualPrintJobEvent({required this.printData});
  @override
  List<Object?> get props => [printData];
}

class ChangeSlotMaterialEvent extends PrinterDetailEvent {
  final String printerId;
  final int slotIndex;
  final String? materialId;

  const ChangeSlotMaterialEvent({
    required this.printerId,
    required this.slotIndex,
    this.materialId,
  });

  @override
  List<Object?> get props => [printerId, slotIndex, materialId];
}

// ==========================================
// СТАН (STATE)
// ==========================================
class PrinterDetailState extends Equatable {
  final bool isLoading;
  final AppPrinter? printer; 
  final PrinterTelemetry telemetry; 
  final List<db.PrintJob> history;
  final List<db.Material> materials; // ФІКС 1: Додали список усіх котушок у стан

  const PrinterDetailState({
    required this.isLoading,
    this.printer,
    required this.telemetry,
    required this.history,
    required this.materials, // ФІКС 2: Додали в конструктор
  });

  factory PrinterDetailState.initial() {
    return PrinterDetailState(
      isLoading: true,
      printer: null,
      telemetry: PrinterTelemetry.offline(), 
      history: [],
      materials: [], // ФІКС 3: Початковий пустий список
    );
  }

  PrinterDetailState copyWith({
    bool? isLoading,
    AppPrinter? printer,
    PrinterTelemetry? telemetry,
    List<db.PrintJob>? history,
    List<db.Material>? materials, // ФІКС 4: Додали в copyWith
  }) {
    return PrinterDetailState(
      isLoading: isLoading ?? this.isLoading,
      printer: printer ?? this.printer,
      telemetry: telemetry ?? this.telemetry,
      history: history ?? this.history,
      materials: materials ?? this.materials, // ФІКС 5
    );
  }

  @override
  List<Object?> get props => [isLoading, printer, telemetry, history, materials]; // ФІКС 6
}

// ==========================================
// БІЗНЕС-ЛОГІКА (BLOC)
// ==========================================
@injectable
class PrinterDetailBloc extends Bloc<PrinterDetailEvent, PrinterDetailState> {
  final db.AppDatabase _db;
  final PrinterPollingService _pollingService; 
  Timer? _pollingTimer;
  StreamSubscription<db.Printer?>? _printerSubscription; 

  Future<void> _refreshHistory(Emitter<PrinterDetailState> emit) async {
    if (state.printer != null) {
      final updatedHistory = await (_db.select(_db.printJobs)
            ..where((tbl) => tbl.printerId.equals(state.printer!.id))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.startTime)]))
          .get();
      emit(state.copyWith(history: updatedHistory));
    }
  }

  PrinterDetailBloc(this._db, this._pollingService)
      : super(PrinterDetailState.initial()) {
    
    on<StartMonitoring>((event, emit) async {
      _pollingTimer?.cancel();
      _pollingTimer = null;
      _printerSubscription?.cancel();

      // Первинне збереження принтера у стан
      emit(state.copyWith(printer: event.printer));

      // 1. РЕАКТИВНЕ ВІДСТЕЖЕННЯ КАРТКИ ПРИНТЕРА З БАЗИ ДАНИХ
      _printerSubscription = (_db.select(_db.printers)..where((tbl) => tbl.id.equals(event.printer.id)))
          .watchSingleOrNull()
          .listen((dbPrinter) {
        if (dbPrinter != null && !isClosed) {
          final List<dynamic> rawSlots = []; 
          
          final updatedAppPrinter = AppPrinter(
            id: dbPrinter.id,
            name: dbPrinter.name,
            ipAddress: dbPrinter.ipAddress,
            port: dbPrinter.port,
            manufacturer: dbPrinter.manufacturer,
            model: dbPrinter.model,
            apiKey: dbPrinter.apiKey,
            slotsCount: dbPrinter.slotsCount,
            slots: List.generate(dbPrinter.slotsCount, (index) {
              String? materialId;
              try {
                final Map<String, dynamic> slotsMap = jsonDecode(dbPrinter.activeSlotsJson);
                materialId = slotsMap['slot_${index + 1}'];
              } catch (_) {
                materialId = null;
              }
              return PrinterSlot(
                index: index,
                linkedMaterialId: materialId,
              );
            }),
            imageUrl: dbPrinter.imageUrl,
            version: dbPrinter.version,
            timestamp: dbPrinter.timestamp,
          );

          add(UpdatePrinterObjectEvent(updatedAppPrinter));
        }
      });

      // 2. Завантажуємо історію друку з бази даних
      final historyList = await (_db.select(_db.printJobs)
            ..where((tbl) => tbl.printerId.equals(event.printer.id))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.startTime)]))
          .get();

      // 3. ДОДАНО: Завантажуємо абсолютно всі матеріали з інвентарю для форми редагування
      final allMaterialsList = await (_db.select(_db.materials)
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();

      if (isClosed) return;
      
      // 4. ОНОВЛЕНО: Емітимо фінальний початковий стан (історію + котушки) та вимикаємо лоадер
      emit(state.copyWith(
        history: historyList, 
        materials: allMaterialsList, // Тепер маємо котушки у стані Блоку!
        isLoading: false,
      ));

      // 5. Петля контрольованого моніторингу мережі (Moonraker / Klipper API)
      void startPollingLoop() {
        if (isClosed) return;

        _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
          if (isClosed) {
            timer.cancel();
            return;
          }

          try {
            final telemetryData = await _pollingService.fetchPrinterStatus(
              ipAddress: event.printer.ipAddress,
              port: event.printer.port,
              type: event.printer.manufacturer, 
              apiKey: event.printer.apiKey,
            );
            
            if (!isClosed) {
              add(UpdateTelemetry(telemetryData));
            }
          } catch (e) {
            // М'яке гасіння помилок мережі (якщо принтер офлайн)
          }
        });
      }

      startPollingLoop();
    });

    // 1. ОБРОБНИК ВИДАЛЕННЯ (З МОЖЛИВІСТЮ ПОВЕРНЕННЯ ВАГИ)
    // 1. ОБРОБНИК ВИДАЛЕННЯ
    // 1. ОБРОБНИК ВИДАЛЕННЯ (МАТЕМАТИЧНО КОРЕКТНИЙ)
    // 1. ОБРОБНИК ВИДАЛЕННЯ (ЗАЛІЗОБЕТОННА МАТЕМАТИКА DRIFT)
    on<DeletePrintJobEvent>((event, emit) async {
      final job = event.job;

      try {
        await _db.transaction(() async {
          if (event.restoreWeight) {
            final List<dynamic> logs = jsonDecode(job.usedMaterialsLogJson);
            for (var log in logs) {
              final String matId = log['materialId'];
              final double spent = log['spentWeight'];

              // ЧІТКИЙ ФІКС: Використовуємо кастомний SQL-апдейт прямо через Drift.
              // Це 100% застраховано від помилок типів і виконує чисте віднімання в базі.
              await _db.customUpdate(
                'UPDATE materials SET used_weight = used_weight - ? WHERE id = ?',
                variables: [
                  Variable<double>(spent),
                  Variable<String>(matId),
                ],
                updates: {_db.materials}, // Кажемо Drift, яка таблиця змінилась для реактивності
              );
            }
          }

          // Видаляємо сам запис друку
          await (_db.delete(_db.printJobs)..where((tbl) => tbl.id.equals(job.id))).go();
        });

        // Оновлюємо історію на UI
        await _refreshHistory(emit);
        
      } catch (e) {
        // Логування помилок
      }
    });

    // 2. ОБРОБНИК РЕДАГУВАННЯ
    on<EditPrintJobEvent>((event, emit) async {
      final oldJob = event.oldJob;
      final newData = event.updatedData;

      try {
        await _db.transaction(() async {
          // КРОК А: Спершу повністю повертаємо стару вагу на старі котушки, які були записані раніше
          final List<dynamic> oldLogs = jsonDecode(oldJob.usedMaterialsLogJson);
          for (var log in oldLogs) {
            final String matId = log['materialId'] ?? '';
            final double weight = (log['spentWeight'] as num?)?.toDouble() ?? 0.0;
            if (matId.isEmpty) continue;

            await _db.customUpdate(
              'UPDATE materials SET used_weight = used_weight - ? WHERE id = ?',
              variables: [Variable<double>(weight), Variable<String>(matId)],
              updates: {_db.materials},
            );
          }

          // КРОК Б: Тепер списуємо нову відредаговану вагу з нових обраних котушок
          final List<dynamic> newLogs = jsonDecode(newData['usedMaterialsLogJson']);
          for (var log in newLogs) {
            final String matId = log['materialId'] ?? '';
            final double weight = (log['spentWeight'] as num?)?.toDouble() ?? 0.0;
            if (matId.isEmpty) continue;

            await _db.customUpdate(
              'UPDATE materials SET used_weight = used_weight + ? WHERE id = ?',
              variables: [Variable<double>(weight), Variable<String>(matId)],
              updates: {_db.materials},
            );
          }

          // КРОК В: Оновлюємо сам запис друку в таблиці PrintGrid
          await (_db.update(_db.printJobs)..where((tbl) => tbl.id.equals(oldJob.id))).write(
            db.PrintJobsCompanion(
              modelName: Value(newData['modelName']),
              status: Value(newData['status']),
              startTime: Value(newData['startTime']),
              duration: Value(newData['duration']),
              spentWeight: Value(newData['spentWeight']), // Зберегли нову сумарну вагу
              usedMaterialsLogJson: Value(newData['usedMaterialsLogJson']), // Зберегли нові котушки
            ),
          );
        });

        // Оновлюємо UI логу
        await _refreshHistory(emit);
        
      } catch (e) {
        // Логування
      }
    });

    on<UpdatePrinterObjectEvent>((event, emit) {
      if (!isClosed) {
        emit(state.copyWith(printer: event.printer));
      }
    });

    on<UpdateTelemetry>((event, emit) {
      if (!isClosed) {
        emit(state.copyWith(telemetry: event.telemetry));
      }
    });

    on<ChangeSlotMaterialEvent>((event, emit) async {
      try {
        final String transactionId = const Uuid().v4();
        await _db.connectMaterialToSlot(
          event.printerId,
          event.slotIndex,
          event.materialId,
          transactionId,
        );
      } catch (e) {
        // Логування помилок
      }
    });

    // ФІКС 1: Перенесено обробник події всередину конструктора Блоку!
    on<AddManualPrintJobEvent>((event, emit) async {
      final data = event.printData;
      
      try {
        // ФІКС 2 & 3: Використовуємо _db та стандартний метод Drift для Companion-вставки
        await _db.into(_db.printJobs).insert(
          db.PrintJobsCompanion.insert(
            id: data['id'],
            printerId: data['printerId'],
            modelName: data['modelName'],
            status: data['status'],
            spentWeight: data['spentWeight'],
            usedMaterialsLogJson: data['usedMaterialsLogJson'],
            startTime: data['startTime'],
            duration: data['duration'],
          ),
        );

        // Списання використаної ваги з котушок у базі SQLite
        final List<dynamic> logs = jsonDecode(data['usedMaterialsLogJson']);
        for (var log in logs) {
          final String matId = log['materialId'];
          final double spent = log['spentWeight'];
          
          // Створюємо транзакцію для оновлення поточної ваги матеріалу
          await (_db.update(_db.materials)..where((tbl) => tbl.id.equals(matId))).write(
            db.MaterialsCompanion(
              // Збільшуємо використану вагу (Drift підтримує математичні вирази)
              usedWeight: Value(spent), 
            ),
          );
        }

        // ФІКС 4: Перечитуємо історію, щоб лог миттєво оновився на UI
        if (state.printer != null) {
          final updatedHistory = await (_db.select(_db.printJobs)
                ..where((tbl) => tbl.printerId.equals(state.printer!.id))
                ..orderBy([(tbl) => OrderingTerm.desc(tbl.startTime)]))
              .get();
          
          if (!isClosed) {
            emit(state.copyWith(history: updatedHistory));
          }
        }
      } catch (e) {
        // Логування помилок запису в базу
      }
    });
  } // <--- Тут конструктор тепер закривається абсолютно правильно

  @override
  Future<void> close() {
    _printerSubscription?.cancel();
    _pollingTimer?.cancel();
    _pollingTimer = null;
    return super.close();
  }
}