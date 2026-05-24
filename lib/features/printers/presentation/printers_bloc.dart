import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart'; // Додано для використання класу Value та Constant
import 'package:filamentary/core/database/database.dart' as db;

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
  final List<db.Printer> printers;
  const PrintersLoaded(this.printers);

  @override
  List<Object?> get props => [printers];
}

// ==========================================
// ПОДІЇ (EVENTS)
// ==========================================
abstract class PrintersEvent extends Equatable {
  const PrintersEvent();
  @override
  List<Object?> get props => [];
}

class WatchPrinters extends PrintersEvent {}

// Подія
class AddPrinterEvent extends PrintersEvent {
  final String name;
  final String ipAddress;
  final String manufacturer;
  final String model;
  final int port;
  final String? apiKey;
  final int slotsCount;
  final String? imageUrl; // <--- Перевірте наявність тут

  const AddPrinterEvent({
    required this.name,
    required this.ipAddress,
    required this.manufacturer,
    required this.model,
    required this.port,
    this.apiKey,
    required this.slotsCount,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, ipAddress, manufacturer, model, port, apiKey, slotsCount, imageUrl];
}

class UpdatePrinter extends PrintersEvent {
  final db.Printer printer;
  const UpdatePrinter(this.printer);
  @override
  List<Object> get props => [printer];
}

class DeletePrinterEvent extends PrintersEvent {
  final String printerId;
  const DeletePrinterEvent(this.printerId);
}

// ==========================================
// БЛОК (BLOC)
// ==========================================
@injectable
class PrintersBloc extends Bloc<PrintersEvent, PrintersState> {
  final db.AppDatabase _db;
  final _uuid = const Uuid();

  PrintersBloc(this._db) : super(PrintersLoading()) {
    
    on<WatchPrinters>((event, emit) async {
      await emit.forEach<List<db.Printer>>(
        _db.watchActivePrinters(),
        onData: (printersList) => PrintersLoaded(printersList),
      );
    });

    // ФІКС: Безпечне неблокуюче додавання через Companions
    on<AddPrinterEvent>((event, emit) async {
      final String printerId = _uuid.v4();

      final Map<String, String?> slotsMap = {};
      for (int i = 1; i <= event.slotsCount; i++) {
        slotsMap['slot_$i'] = null;
      }
      final String activeSlotsJson = jsonEncode(slotsMap);

      // Використовуємо чистого компаньйона таблиці для інсерту
      final companion = db.PrintersCompanion.insert(
        id: printerId,
        name: event.name,
        ipAddress: event.ipAddress,
        manufacturer: event.manufacturer,
        model: event.model,
        port: Value(event.port),
        apiKey: Value(event.apiKey),
        activeSlotsJson: activeSlotsJson,
        slotsCount: event.slotsCount,
        imageUrl: Value(event.imageUrl),
      );

      // Викликаємо метод вставки через Into-билдер компаньйона
      await _db.into(_db.printers).insert(companion);
    });

    on<UpdatePrinter>((event, emit) async {
      await _db.updatePrinter(event.printer);
      // Оскільки у нас працює WatchPrinters(), UI оновиться автоматично
    });

    on<DeletePrinterEvent>((event, emit) async {
      await _db.softDeletePrinter(event.printerId);
    });
  }
}