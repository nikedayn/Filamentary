import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:filamentary/core/database/database.dart' as db;
import 'package:filamentary/features/printers/data/printers_repository.dart'; 
import 'package:filamentary/features/printers/domain/models/app_printer.dart'; 
import 'package:filamentary/core/network/printer_client_interface.dart'; 
import 'package:filamentary/core/network/klipper_client.dart'; 
import 'package:filamentary/core/network/bambu_client.dart'; 
import 'package:drift/drift.dart' as drift;
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
  // ФІКС 1: Зберігаємо повну телеметрію (разом із текстом помилок), а не тільки статус
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

// ФІКС 2: Подiя тепер переносить повнi об'єкти телеметрiї
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
// БІЗНЕС-ЛОГІКА (BLOC)
// ==========================================
@injectable
class PrintersBloc extends Bloc<PrintersEvent, PrintersState> {
  final PrintersRepository _printersRepository;
  final db.AppDatabase _db;
  final _uuid = const Uuid();
  
  Timer? _pollingTimer;
  List<AppPrinter> _currentPrintersCache = [];

  PrintersBloc(this._printersRepository, this._db) : super(PrintersLoading()) {
    
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

    on<UpdatePrintersTelemetryEvent>((event, emit) {
      if (state is PrintersLoaded) {
        final currentState = state as PrintersLoaded;
        emit(currentState.copyWith(telemetryMap: event.telemetryMap));
      }
    });

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
        );
        await _db.insertPrinterWithLog(companion, transactionId);
      } catch (_) {}
    });

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
          version: event.printer.version, 
          timestamp: DateTime.now(),
        );
        await _db.updatePrinter(driftPrinter, transactionId);
      } catch (e) {
        print('Помилка оновлення принтера в БД: $e');
      }
    });

    on<DeletePrinterEvent>((event, emit) async {
      try {
        final String transactionId = _uuid.v4();
        await _db.softDeletePrinter(event.printerId, transactionId);
      } catch (_) {}
    });
  }

  // МЕТОД ФОНОВОГО ОПИТУВАННЯ МЕРЕЖІ
  void _startTelemetryPolling() {
    _pollingTimer?.cancel();
    
    _pollingTimer = Timer.periodic(AppConstants.printerPollingInterval, (timer) async {
      if (_currentPrintersCache.isEmpty) return;

      // ФІКС 3: Мапа тепер збирає об'єкти PrinterTelemetry повністю
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

            // Зберігаємо об'єкт цілком (зі статусом Квітка/Друк і повідомленням про помилку)
            updatedTelemetry[printer.id] = telemetry;
          } catch (e) {
            // ФІКС 4: Якщо сталася системна помилка у самому Блоці — прокидаємо її опис
            updatedTelemetry[printer.id] = PrinterTelemetry.offline('Системна помилка Блоку: $e');
          }
        }),
      );

      if (!isClosed) {
        add(UpdatePrintersTelemetryEvent(updatedTelemetry));
      }
    });
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}