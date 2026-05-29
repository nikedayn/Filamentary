import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import 'package:filamentary/core/database/database.dart' as db;
import 'package:filamentary/features/printers/data/printers_repository.dart'; 
import 'package:filamentary/features/printers/domain/models/app_printer.dart'; 
import 'package:filamentary/core/network/printer_client_interface.dart'; 
import 'package:filamentary/core/network/klipper_client.dart'; 
import 'package:filamentary/core/network/bambu_client.dart'; 
import 'package:filamentary/core/constants/app_constants.dart'; 
import 'package:filamentary/core/di/injection.dart'; 

// ==========================================
// СТАНІ (STATES)
// ==========================================
abstract class PrintersState extends Equatable {
  const PrintersState();
  @override
  List<Object?> get props => [];
}

class PrintersLoading extends PrintersState {}

class PrintersLoaded extends PrintersState {
  final List<AppPrinter> printers;
  final Map<String, PrinterTelemetry> telemetryMap; 

  const PrintersLoaded(this.printers, {this.telemetryMap = const {}});
  
  PrintersLoaded copyWith({
    List<AppPrinter>? printers,
    Map<String, PrinterTelemetry>? telemetryMap,
  }) {
    return PrintersLoaded(
      printers ?? this.printers,
      telemetryMap: telemetryMap ?? this.telemetryMap,
    );
  }

  @override
  List<Object?> get props => [printers, telemetryMap];
}

class PrintersFailure extends PrintersState {
  final String error;
  const PrintersFailure(this.error);
  @override
  List<Object?> get props => [error];
}

// ==========================================
// ПОДІЇ (EVENTS)
// ==========================================
abstract class PrintersEvent extends Equatable {
  const PrintersEvent();
  @override
  List<Object?> get props => [];
}

class WatchPrintersEvent extends PrintersEvent {}

class UpdatePrintersTelemetryEvent extends PrintersEvent {
  final Map<String, PrinterTelemetry> telemetryMap;
  const UpdatePrintersTelemetryEvent(this.telemetryMap);
  @override
  List<Object?> get props => [telemetryMap];
}

class AddPrinterEvent extends PrintersEvent {
  final String name;
  final String ipAddress;
  final int port;
  final String manufacturer;
  final String model;
  final String? apiKey;
  final int slotsCount;
  final String? imageUrl; 

  const AddPrinterEvent({
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.manufacturer,
    required this.model,
    this.apiKey,
    required this.slotsCount,
    this.imageUrl, 
  });
}

class UpdatePrinterEvent extends PrintersEvent {
  final AppPrinter printer;
  const UpdatePrinterEvent(this.printer);
}

class DeletePrinterEvent extends PrintersEvent {
  final String printerId;
  const DeletePrinterEvent(this.printerId);
}

// ==========================================
// БІЗНЕС-ЛОГІКА (BLOC IMPLEMENTATION)
// ==========================================
@injectable
class PrintersBloc extends Bloc<PrintersEvent, PrintersState> {
  final PrintersRepository _printersRepository;
  final db.AppDatabase _db;
  final _uuid = const Uuid();
  
  Timer? _pollingTimer;
  List<AppPrinter> _currentPrintersCache = [];
  
  // ФІКС ПОМИЛКИ: Кеш тепер зберігає строгий енам PrinterState замість динамічних Strings
  final Map<String, PrinterState> _lastStateCache = {};

  PrintersBloc(this._printersRepository, this._db) : super(PrintersLoading()) {
    
    // 1. РЕАКТИВНИЙ СТРІМ СПИСКУ ПРИНТЕРІВ З БАЗИ ДАНИХ
    on<WatchPrintersEvent>((event, emit) async {
      _startTelemetryPolling();

      await emit.forEach<List<AppPrinter>>(
        _printersRepository.watchPrinters(),
        onData: (printersList) {
          _currentPrintersCache = printersList;
          if (state is PrintersLoaded) {
            return (state as PrintersLoaded).copyWith(printers: printersList);
          }
          return PrintersLoaded(printersList);
        },
        onError: (error, stackTrace) => PrintersFailure(error.toString()),
      );
    });

    // 2. ОНОВЛЕННЯ КАРТИ ТЕЛЕМЕТРІЇ ПРИНТЕРІВ
    on<UpdatePrintersTelemetryEvent>((event, emit) {
      if (state is PrintersLoaded) {
        final currentState = state as PrintersLoaded;
        emit(currentState.copyWith(telemetryMap: event.telemetryMap));
      }
    });

    // 3. ДОДАВАННЯ НОВОГО ПРИНТЕРА З ПЕРВИННИМ ЛОГУВАННЯМ
    on<AddPrinterEvent>((event, emit) async {
      try {
        final String printerId = _uuid.v4();
        final String transactionId = _uuid.v4();

        final companion = db.PrintersCompanion(
          id: drift.Value(printerId),
          name: drift.Value(event.name),
          ipAddress: drift.Value(event.ipAddress),
          port: drift.Value(event.port),
          manufacturer: drift.Value(event.manufacturer),
          model: drift.Value(event.model),
          apiKey: drift.Value(event.apiKey),
          slotsCount: drift.Value(event.slotsCount),
          imageUrl: drift.Value(event.imageUrl), 
          activeSlotsJson: const drift.Value('{}'), 
          version: const drift.Value(1),
          timestamp: drift.Value(DateTime.now()),
          isDeleted: const drift.Value(false),
        );
        await _db.insertPrinterWithLog(companion, transactionId);
      } catch (_) {}
    });

    // 4. ОНОВЛЕННЯ ДАНИХ ПРИНТЕРА (МАТЕМАТИЧНА ВЕРСІЙНІСТЬ П. 4 ТЗ)
    on<UpdatePrinterEvent>((event, emit) async {
      try {
        final String transactionId = _uuid.v4();
        final Map<String, dynamic> slotsMap = {};
        for (int i = 0; i < event.printer.slots.length; i++) {
          slotsMap['slot_${i + 1}'] = event.printer.slots[i].linkedMaterialId;
        }
        final String activeSlotsJson = jsonEncode(slotsMap);

        final driftPrinter = db.Printer(
          id: event.printer.id,
          name: event.printer.name,
          ipAddress: event.printer.ipAddress,
          port: event.printer.port,
          manufacturer: event.printer.manufacturer,
          model: event.printer.model,
          apiKey: event.printer.apiKey,
          slotsCount: event.printer.slotsCount,
          activeSlotsJson: activeSlotsJson,
          imageUrl: event.printer.imageUrl,
          isDeleted: false,
          version: event.printer.version + 1, // Інкремент версії об'єкта
          timestamp: DateTime.now(),
        );
        await _db.updatePrinter(driftPrinter, transactionId);
      } catch (e) {
        print('Помилка оновлення принтера в БД: $e');
      }
    });

    // 5. М'ЯКЕ ВІДПОВІДНЕ ВИДАЛЕННЯ ПРИНТЕРА
    on<DeletePrinterEvent>((event, emit) async {
      try {
        final String transactionId = _uuid.v4();
        _lastStateCache.remove(event.printerId);
        await _db.softDeletePrinter(event.printerId, transactionId);
      } catch (_) {}
    });
  }

  // ==========================================================
  // ПЕТЛЯ ФОНОГО ПОЛІНГУ МЕРЕЖІ ТА АВТО-ФІКСАЦІЇ ДРУКУ KLIPPER
  // ==========================================================
  void _startTelemetryPolling() {
    _pollingTimer?.cancel();
    
    _pollingTimer = Timer.periodic(AppConstants.printerPollingInterval, (timer) async {
      if (_currentPrintersCache.isEmpty) return;

      final Map<String, PrinterTelemetry> updatedTelemetry = {};

      await Future.wait(
        _currentPrintersCache.map((printer) async {
          try {
            PrinterTelemetry telemetry;

            if (printer.manufacturer.toLowerCase().contains('bambu')) {
              final bambuClient = getIt<BambuClient>();
              telemetry = await bambuClient.getStatus(
                printer.ipAddress, 
                printer.port, 
                printer.apiKey,
              );
            } else {
              final klipperClient = getIt<KlipperClient>(instanceName: 'KlipperClient');
              telemetry = await klipperClient.getStatus(
                printer.ipAddress, 
                printer.port, 
                printer.apiKey,
              );
            }

            updatedTelemetry[printer.id] = telemetry;

            // --------------------------------------------------------
            // АВТОМАТИЧНА ФІКСАЦІЯ ЗАВЕРШЕНОГО ДРУКУ (Пункт 3.1 ТЗ)
            // --------------------------------------------------------
            final PrinterState? oldState = _lastStateCache[printer.id];

            // ФІКС ПОМИЛКИ: Перевіряємо перехід станів за допомогою строгого енаму
            if (oldState == PrinterState.printing && telemetry.state == PrinterState.standby) {
              await _processAutomaticKlipperWriteOff(printer, telemetry);
            }

            // Зберігаємо поточний стан в кеш
            _lastStateCache[printer.id] = telemetry.state;

          } catch (e) {
            _lastStateCache[printer.id] = PrinterState.offline;
            updatedTelemetry[printer.id] = PrinterTelemetry.offline('Системна помилка Блоку: $e');
          }
        }),
      );

      if (!isClosed) {
        add(UpdatePrintersTelemetryEvent(updatedTelemetry));
      }
    });
  }

  // ==========================================================
  // ВНУТРІШНІЙ МЕТОД АВТО-СПИСАННЯ ЧЕРЕЗ РЕГІСТРАТОР БАЗЫ ДАНИХ
  // ==========================================================
  Future<void> _processAutomaticKlipperWriteOff(AppPrinter printer, PrinterTelemetry telemetry) async {
    try {
      String? targetMaterialId;

      // 1. Скануємо слоти принтера з валідацією наявності QR-коду в реальній локальній базі матеріалів
      for (var slot in printer.slots) {
        if (slot.linkedMaterialId != null && slot.linkedMaterialId!.isNotEmpty) {
          
          final localMaterial = await (_db.select(_db.materials)
                ..where((tbl) => tbl.id.equals(slot.linkedMaterialId!)))
              .getSingleOrNull();

          // Якщо котушка є валідною в нашому інвентарі, вибираємо її для списання пластику
          if (localMaterial != null && !localMaterial.isDeleted) {
            targetMaterialId = slot.linkedMaterialId;
            break; 
          }
        }
      }

      // Захист від примарних QR-кодів: якщо котушка відсутня в інвентарі, автозапис блокується
      if (targetMaterialId == null) return;

      // 2. Валідуємо вагу філаменту, отриману з метаданих Moonraker API
      final double consumedWeight = telemetry.filamentWeightTotal > 0 ? telemetry.filamentWeightTotal : 0.0;
      if (consumedWeight <= 0) return; 

      final String printJobId = _uuid.v4();
      final String transactionId = _uuid.v4();
      
      final List<Map<String, dynamic>> materialsLogStructure = [
        {
          'slotIndex': 1,
          'materialId': targetMaterialId,
          'spentWeight': consumedWeight,
        }
      ];

      // 3. АРХІТЕКТУРНИЙ ФІКС: Замість роздутого коду використовуємо наш єдиний чистий метод бд
      await _db.registerPrintJobInDatabase(
        id: printJobId,
        printerId: printer.id,
        modelName: telemetry.filename.isNotEmpty ? telemetry.filename : 'Klipper_Auto_Print.gcode',
        status: 'Успішно',
        spentWeight: consumedWeight,
        usedMaterialsLogJson: jsonEncode(materialsLogStructure),
        startTime: DateTime.now().subtract(Duration(seconds: telemetry.totalPrintTime > 0 ? telemetry.totalPrintTime : 60)),
        duration: telemetry.totalPrintTime > 0 ? telemetry.totalPrintTime : 60,
        transactionId: transactionId,
      );

    } catch (_) {
      // Будь-яка помилка безпечно перехоплюється, Drift гарантує атомарність транзакції
    }
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}