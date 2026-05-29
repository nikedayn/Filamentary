import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:filamentary/core/database/database.dart' as db;
import 'package:filamentary/core/network/printer_client_interface.dart'; 
import 'package:filamentary/features/printers/data/printer_polling_service.dart'; 
import 'package:filamentary/features/printers/domain/models/app_printer.dart'; 

// ==========================================
// EVENTS (ПОДІЇ)
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

class ClearSnackBarMessageEvent extends PrinterDetailEvent {}

// ==========================================
// STATE (СТАН - ПОВЕРНУТО ТА ВИПРАВЛЕНО ЧЕРГОВІСТЬ)
// ==========================================
class PrinterDetailState extends Equatable {
  final bool isLoading;
  final AppPrinter? printer; 
  final PrinterTelemetry telemetry; 
  final List<db.PrintJob> history;
  final List<db.Material> materials; 
  final String? snackBarMessage; // Повідомлення про помилки сканування неіснуючих QR

  const PrinterDetailState({
    required this.isLoading,
    this.printer,
    required this.telemetry,
    required this.history,
    required this.materials, 
    this.snackBarMessage,
  });

  factory PrinterDetailState.initial() {
    return PrinterDetailState(
      isLoading: true,
      printer: null,
      telemetry: PrinterTelemetry.offline(), 
      history: [],
      materials: [], 
      snackBarMessage: null,
    );
  }

  PrinterDetailState copyWith({
    bool? isLoading,
    AppPrinter? printer,
    PrinterTelemetry? telemetry,
    List<db.PrintJob>? history,
    List<db.Material>? materials, 
    String? snackBarMessage, 
  }) {
    return PrinterDetailState(
      isLoading: isLoading ?? this.isLoading,
      printer: printer ?? this.printer,
      telemetry: telemetry ?? this.telemetry,
      history: history ?? this.history,
      materials: materials ?? this.materials, 
      snackBarMessage: snackBarMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, printer, telemetry, history, materials, snackBarMessage]; 
}

// ==========================================
// BLOC IMPLEMENTATION
// ==========================================
@injectable
class PrinterDetailBloc extends Bloc<PrinterDetailEvent, PrinterDetailState> {
  final db.AppDatabase _db;
  final PrinterPollingService _pollingService; 
  
  Timer? _pollingTimer;
  StreamSubscription<db.Printer?>? _printerSubscription; 
  PrinterState? _lastCachedState;

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
      _lastCachedState = null;

      emit(state.copyWith(printer: event.printer));

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
          
          if (isClosed) return;

          if (_lastCachedState == PrinterState.printing && telemetryData.state == PrinterState.standby) {
            await _handleAutomaticKlipperPrintCompletion(telemetryData);
            
            final updatedHistory = await (_db.select(_db.printJobs)
                  ..where((tbl) => tbl.printerId.equals(event.printer.id))
                  ..orderBy([(tbl) => OrderingTerm.desc(tbl.startTime)]))
                .get();
            final updatedMaterials = await (_db.select(_db.materials)
                  ..where((tbl) => tbl.isDeleted.equals(false)))
                .get();
                
            emit(state.copyWith(history: updatedHistory, materials: updatedMaterials));
          }

          _lastCachedState = telemetryData.state;
          add(UpdateTelemetry(telemetryData));

        } catch (e) {
          if (!isClosed) {
            _lastCachedState = PrinterState.offline;
            String errorMsg = e.toString();
            
            final isRealBambu = event.printer.manufacturer.toLowerCase().contains('bambu');
            if (isRealBambu) {
              if (errorMsg.contains('Timeout')) {
                errorMsg = 'Таймаут з\'єднання! Перевір Wi-Fi мережу або AP Isolation роутера.';
              } else if (errorMsg.contains('Password') || errorMsg.contains('auth')) {
                errorMsg = 'Неправильний Access Code! Перевір f07ed541 на екрані принтера.';
              } else if (errorMsg.contains('Socket')) {
                errorMsg = 'Помилка сокета Android. Перевір usesCleartextTraffic у маніфесті.';
              }
            } else {
              if (errorMsg.contains('Connection refused') || errorMsg.contains('SocketException')) {
                errorMsg = 'Не вдалося підключитися до Moonraker API. Перевірте IP-адресу та порт пристрою.';
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
              final double spent = (log['spentWeight'] as num).toDouble();

              final existingMat = await (_db.select(_db.materials)..where((tbl) => tbl.id.equals(matId))).getSingleOrNull();
              if (existingMat == null) continue; 

              final double targetUsedWeight = existingMat.usedWeight - spent;

              await (_db.update(_db.materials)..where((tbl) => tbl.id.equals(matId))).write(
                db.MaterialsCompanion(
                  usedWeight: Value(targetUsedWeight < 0 ? 0.0 : targetUsedWeight),
                  version: Value(existingMat.version + 1),
                  timestamp: Value(DateTime.now()),
                ),
              );
            }
          }
          await (_db.delete(_db.printJobs)..where((tbl) => tbl.id.equals(job.id))).go();
        });
        await _refreshHistory(emit);
        final allMaterialsList = await (_db.select(_db.materials)..where((tbl) => tbl.isDeleted.equals(false))).get();
        emit(state.copyWith(materials: allMaterialsList, snackBarMessage: null));
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
            if (matId.isEmpty || weight <= 0) continue;

            final existingMat = await (_db.select(_db.materials)..where((tbl) => tbl.id.equals(matId))).getSingleOrNull();
            if (existingMat == null) continue;

            await (_db.update(_db.materials)..where((tbl) => tbl.id.equals(matId))).write(
              db.MaterialsCompanion(
                usedWeight: Value((existingMat.usedWeight - weight) < 0 ? 0.0 : existingMat.usedWeight - weight),
                version: Value(existingMat.version + 1),
                timestamp: Value(DateTime.now()),
              ),
            );
          }

          final List<dynamic> newLogs = jsonDecode(newData['usedMaterialsLogJson']);
          for (var log in newLogs) {
            final String matId = log['materialId'] ?? '';
            final double weight = (log['spentWeight'] as num?)?.toDouble() ?? 0.0;
            if (matId.isEmpty || weight <= 0) continue;

            final existingMat = await (_db.select(_db.materials)..where((tbl) => tbl.id.equals(matId))).getSingleOrNull();
            if (existingMat == null) continue;

            await (_db.update(_db.materials)..where((tbl) => tbl.id.equals(matId))).write(
              db.MaterialsCompanion(
                usedWeight: Value(existingMat.usedWeight + weight),
                version: Value(existingMat.version + 1),
                timestamp: Value(DateTime.now()),
              ),
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
              version: Value(oldJob.version + 1),
              timestamp: Value(DateTime.now()),
            ),
          );
        });
        
        await _refreshHistory(emit);
        final allMaterialsList = await (_db.select(_db.materials)..where((tbl) => tbl.isDeleted.equals(false))).get();
        emit(state.copyWith(materials: allMaterialsList, snackBarMessage: null));
      } catch (_) {}
    });

    on<UpdatePrinterObjectEvent>((event, emit) {
      if (!isClosed) emit(state.copyWith(printer: event.printer, snackBarMessage: null));
    });

    on<UpdateTelemetry>((event, emit) {
      if (!isClosed) emit(state.copyWith(telemetry: event.telemetry));
    });

    // ==========================================================
    // ЗМІНА КОТУШКИ В СЛОТІ ЧЕРЕЗ QR КОД (ФІНАЛЬНЕ УЗГОДЖЕННЯ З БАЗОЮ)
    // ==========================================================
    on<ChangeSlotMaterialEvent>((event, emit) async {
      if (state.printer == null) return;
      
      // Очищуємо старі SnackBar повідомлення перед виконанням операції
      emit(state.copyWith(snackBarMessage: null));
      
      try {
        final String transactionId = const Uuid().v4();
        
        if (event.materialId != null) {
          // Валідація наявності: перевіряємо чи існує котушка у нашому інвентарі
          final bool materialExists = state.materials.any((m) => m.id == event.materialId);
          if (!materialExists) {
            emit(state.copyWith(snackBarMessage: 'Котушки з відсканованим ID не існує в інвентарі!'));
            return;
          }
        }

        await _db.connectMaterialToSlot(
          event.printerId,
          event.slotIndex, 
          event.materialId,
          transactionId,
        );
      } catch (e) {
        emit(state.copyWith(snackBarMessage: 'Помилка бази даних: ${e.toString()}'));
      }
    });

    on<AddManualPrintJobEvent>((event, emit) async {
      final data = event.printData;
      try {
        final String transactionId = const Uuid().v4();
        
        await _db.registerPrintJobInDatabase(
          id: data['id'],
          printerId: data['printerId'],
          modelName: data['modelName'],
          status: data['status'],
          spentWeight: data['spentWeight'],
          usedMaterialsLogJson: data['usedMaterialsLogJson'],
          startTime: data['startTime'],
          duration: data['duration'],
          transactionId: transactionId,
        );

        await _refreshHistory(emit);
        final allMaterialsList = await (_db.select(_db.materials)..where((tbl) => tbl.isDeleted.equals(false))).get();
        emit(state.copyWith(materials: allMaterialsList, snackBarMessage: null));
      } catch (_) {}
    });

    on<ClearSnackBarMessageEvent>((event, emit) {
      emit(state.copyWith(snackBarMessage: null));
    });
  }

  Future<void> _handleAutomaticKlipperPrintCompletion(PrinterTelemetry telemetry) async {
    if (state.printer == null) return;

    try {
      final currentPrinter = state.printer!;
      String? activeMaterialId;
      
      for (var slot in currentPrinter.slots) {
        if (slot.linkedMaterialId != null && slot.linkedMaterialId!.isNotEmpty) {
          final bool materialExists = state.materials.any((m) => m.id == slot.linkedMaterialId);
          if (materialExists) {
            activeMaterialId = slot.linkedMaterialId;
            break; 
          }
        }
      }

      if (activeMaterialId == null) return;
      final String safeMaterialId = activeMaterialId;

      final double totalSpentWeight = telemetry.filamentWeightTotal > 0 ? telemetry.filamentWeightTotal : 0.0;
      if (totalSpentWeight <= 0) return;

      final String printJobId = const Uuid().v4();
      final String transactionId = const Uuid().v4();
      
      final List<Map<String, dynamic>> generatedMaterialsLog = [
        {
          'slotIndex': 1,
          'materialId': safeMaterialId,
          'spentWeight': totalSpentWeight,
        }
      ];

      await _db.registerPrintJobInDatabase(
        id: printJobId,
        printerId: currentPrinter.id,
        modelName: telemetry.filename.isNotEmpty ? telemetry.filename : 'Klipper_Auto_Print.gcode',
        status: 'Успішно',
        spentWeight: totalSpentWeight,
        usedMaterialsLogJson: jsonEncode(generatedMaterialsLog),
        startTime: DateTime.now().subtract(Duration(seconds: telemetry.totalPrintTime > 0 ? telemetry.totalPrintTime : 60)),
        duration: telemetry.totalPrintTime > 0 ? telemetry.totalPrintTime : 60,
        transactionId: transactionId,
      );
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _printerSubscription?.cancel();
    _pollingTimer?.cancel();
    _pollingTimer = null;
    return super.close();
  }
}