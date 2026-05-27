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
// EVENTS
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
  const ChangeSlotMaterialEvent({required this.printerId, required this.slotIndex, this.materialId});
  @override
  List<Object?> get props => [printerId, slotIndex, materialId];
}

// ==========================================
// STATE
// ==========================================
class PrinterDetailState extends Equatable {
  final bool isLoading;
  final AppPrinter? printer; 
  final PrinterTelemetry telemetry; 
  final List<db.PrintJob> history;
  final List<db.Material> materials; 

  const PrinterDetailState({
    required this.isLoading,
    this.printer,
    required this.telemetry,
    required this.history,
    required this.materials, 
  });

  factory PrinterDetailState.initial() {
    return PrinterDetailState(
      isLoading: true,
      printer: null,
      telemetry: PrinterTelemetry.offline(), 
      history: [],
      materials: [], 
    );
  }

  PrinterDetailState copyWith({
    bool? isLoading,
    AppPrinter? printer,
    PrinterTelemetry? telemetry,
    List<db.PrintJob>? history,
    List<db.Material>? materials, 
  }) {
    return PrinterDetailState(
      isLoading: isLoading ?? this.isLoading,
      printer: printer ?? this.printer,
      telemetry: telemetry ?? this.telemetry,
      history: history ?? this.history,
      materials: materials ?? this.materials, 
    );
  }

  @override
  List<Object?> get props => [isLoading, printer, telemetry, history, materials]; 
}

// ==========================================
// BLOC
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

      emit(state.copyWith(printer: event.printer));

      // 1. РЕАКТИВНЕ ВІДСТЕЖЕННЯ З БАЗИ
      _printerSubscription = (_db.select(_db.printers)..where((tbl) => tbl.id.equals(event.printer.id)))
          .watchSingleOrNull()
          .listen((dbPrinter) {
        if (dbPrinter != null && !isClosed) {
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
              return PrinterSlot(index: index, linkedMaterialId: materialId);
            }),
            imageUrl: dbPrinter.imageUrl,
            version: dbPrinter.version,
            timestamp: dbPrinter.timestamp,
          );

          add(UpdatePrinterObjectEvent(updatedAppPrinter));
        }
      });

      // 2. Завантаження історії та інвентарю матеріалів
      final historyList = await (_db.select(_db.printJobs)
            ..where((tbl) => tbl.printerId.equals(event.printer.id))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.startTime)]))
          .get();

      final allMaterialsList = await (_db.select(_db.materials)
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();

      if (isClosed) return;
      
      emit(state.copyWith(
        history: historyList, 
        materials: allMaterialsList, 
        isLoading: false,
      ));

      // 3. Петля фонового пулінгу мережі
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
          // 🛠️ ФІКС ТУТ: Перехоплюємо помилки сервісу опитування й примусово кидаємо
          // об'єкт офлайну разом із текстом винятку, щоб запрацювала червона плашка!
          if (!isClosed) {
            String errorMsg = e.toString();
            
            // Якщо це Bambu Lab, підказуємо конкретні причини
            if (event.printer.manufacturer.toLowerCase().contains('bambu')) {
              if (errorMsg.contains('Timeout')) {
                errorMsg = 'Таймаут з\'єднання! Перевір Wi-Fi мережу або AP Isolation роутера.';
              } else if (errorMsg.contains('Password') || errorMsg.contains('auth')) {
                errorMsg = 'Неправильний Access Code! Перевір f07ed541 на екрані принтера.';
              } else if (errorMsg.contains('Socket')) {
                errorMsg = 'Помилка сокета Android. ПеревірusesCleartextTraffic у маніфесті.';
              }
            }
            
            add(UpdateTelemetry(PrinterTelemetry.offline(errorMsg)));
          }
        }
      });
    });

    on<DeletePrintJobEvent>((event, emit) async {
      final job = event.job;
      try {
        await _db.transaction(() async {
          if (event.restoreWeight) {
            final List<dynamic> logs = jsonDecode(job.usedMaterialsLogJson);
            for (var log in logs) {
              final String matId = log['materialId'];
              final double spent = log['spentWeight'];

              await _db.customUpdate(
                'UPDATE materials SET used_weight = used_weight - ? WHERE id = ?',
                variables: [Variable<double>(spent), Variable<String>(matId)],
                updates: {_db.materials},
              );
            }
          }
          await (_db.delete(_db.printJobs)..where((tbl) => tbl.id.equals(job.id))).go();
        });
        await _refreshHistory(emit);
      } catch (_) {}
    });

    on<EditPrintJobEvent>((event, emit) async {
      final oldJob = event.oldJob;
      final newData = event.updatedData;

      try {
        await _db.transaction(() async {
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

          await (_db.update(_db.printJobs)..where((tbl) => tbl.id.equals(oldJob.id))).write(
            db.PrintJobsCompanion(
              modelName: Value(newData['modelName']),
              status: Value(newData['status']),
              startTime: Value(newData['startTime']),
              duration: Value(newData['duration']),
              spentWeight: Value(newData['spentWeight']),
              usedMaterialsLogJson: Value(newData['usedMaterialsLogJson']),
            ),
          );
        });
        await _refreshHistory(emit);
      } catch (_) {}
    });

    on<UpdatePrinterObjectEvent>((event, emit) {
      if (!isClosed) emit(state.copyWith(printer: event.printer));
    });

    on<UpdateTelemetry>((event, emit) {
      if (!isClosed) emit(state.copyWith(telemetry: event.telemetry));
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
      } catch (_) {}
    });

    on<AddManualPrintJobEvent>((event, emit) async {
      final data = event.printData;
      try {
        await _db.transaction(() async {
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

          final List<dynamic> logs = jsonDecode(data['usedMaterialsLogJson']);
          for (var log in logs) {
            final String matId = log['materialId'];
            final double spent = log['spentWeight'];
            
            await _db.customUpdate(
              'UPDATE materials SET used_weight = used_weight + ? WHERE id = ?',
              variables: [Variable<double>(spent), Variable<String>(matId)],
              updates: {_db.materials},
            );
          }
        });

        await _refreshHistory(emit);
      } catch (_) {}
    });
  }

  @override
  Future<void> close() {
    _printerSubscription?.cancel();
    _pollingTimer?.cancel();
    _pollingTimer = null;
    return super.close();
  }
}