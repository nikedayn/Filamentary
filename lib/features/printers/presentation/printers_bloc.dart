import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:filamentary/core/database/database.dart' as db;
import 'package:filamentary/features/printers/data/printers_repository.dart'; 
import 'package:filamentary/features/printers/domain/models/app_printer.dart'; 
import 'package:drift/drift.dart' as drift;

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
  
  const PrintersLoaded(this.printers);

  @override
  List<Object?> get props => [printers];
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

// Знайти у файлі printers_bloc.dart цей клас події і замінити його:
class AddPrinterEvent extends PrintersEvent {
  final String name;
  final String ipAddress;
  final int port;
  final String manufacturer;
  final String model;
  final String? apiKey;
  final int slotsCount;
  final String? imageUrl; // ФІКС: Додали поле посилання на фото

  const AddPrinterEvent({
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.manufacturer,
    required this.model,
    this.apiKey,
    required this.slotsCount,
    this.imageUrl, // ФІКС: Конструктор тепер приймає посилання
  });

  @override
  List<Object?> get props => [name, ipAddress, port, manufacturer, model, apiKey, slotsCount, imageUrl];
}

class DeletePrinterEvent extends PrintersEvent {
  final String printerId;
  const DeletePrinterEvent(this.printerId);

  @override
  List<Object?> get props => [printerId];
}

// ==========================================
// БІЗНЕС-ЛОГІКА (BLOC)
// ==========================================
@injectable
class PrintersBloc extends Bloc<PrintersEvent, PrintersState> {
  final PrintersRepository _printersRepository;
  final db.AppDatabase _db;
  final _uuid = const Uuid();

  PrintersBloc(this._printersRepository, this._db) : super(PrintersLoading()) {
    
    // Реактивне відстеження стріму репозиторія
    on<WatchPrintersEvent>((event, emit) async {
      await emit.forEach<List<AppPrinter>>(
        _printersRepository.watchPrinters(),
        onData: (printersList) => PrintersLoaded(printersList),
        onError: (error, stackTrace) => PrintersFailure(error.toString()),
      );
    });

    // Додавання принтера з local-first логуванням транзакцій
    // Знайти всередині конструктора PrintersBloc обробник додавання принтера і замінити його:
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
          imageUrl: drift.Value(event.imageUrl), // ФІКС: Передаємо фото в базу даних!
          activeSlotsJson: const drift.Value('{}'), 
          version: const drift.Value(1),
          timestamp: drift.Value(DateTime.now()),
        );

        await _db.insertPrinterWithLog(companion, transactionId);
      } catch (e) {
        // Логування винятків сховища
      }
    });

    // М'яке видалення
    on<DeletePrinterEvent>((event, emit) async {
      try {
        final String transactionId = _uuid.v4();
        await _db.softDeletePrinter(event.printerId, transactionId);
      } catch (e) {
        // Логування помилок бази даних
      }
    });
  }
}