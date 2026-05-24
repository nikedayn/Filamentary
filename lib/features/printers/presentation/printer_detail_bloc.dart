import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:filamentary/core/database/database.dart' as db;
import 'package:filamentary/core/network/moonraker_client.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

// Події
abstract class PrinterDetailEvent extends Equatable {
  const PrinterDetailEvent();
  @override
  List<Object?> get props => [];
}

class StartMonitoring extends PrinterDetailEvent {
  final db.Printer printer;
  const StartMonitoring(this.printer);
  @override
  List<Object?> get props => [printer];
}

class UpdateTelemetry extends PrinterDetailEvent {
  final Map<String, dynamic> telemetry;
  const UpdateTelemetry(this.telemetry);
  @override
  List<Object?> get props => [telemetry];
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

// Стан
class PrinterDetailState extends Equatable {
  final bool isLoading;
  final Map<String, dynamic> telemetry;
  final List<db.PrintJob> history;

  const PrinterDetailState({
    required this.isLoading,
    required this.telemetry,
    required this.history,
  });

  factory PrinterDetailState.initial() {
    return const PrinterDetailState(
      isLoading: true,
      telemetry: {},
      history: [],
    );
  }

  PrinterDetailState copyWith({
    bool? isLoading,
    Map<String, dynamic>? telemetry,
    List<db.PrintJob>? history,
  }) {
    return PrinterDetailState(
      isLoading: isLoading ?? this.isLoading,
      telemetry: telemetry ?? this.telemetry,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [isLoading, telemetry, history];
}

@injectable
class PrinterDetailBloc extends Bloc<PrinterDetailEvent, PrinterDetailState> {
  final db.AppDatabase _db;
  final MoonrakerClient _client;
  Timer? _pollingTimer;

  PrinterDetailBloc(this._db, this._client)
    : super(PrinterDetailState.initial()) {
    on<StartMonitoring>((event, emit) async {
      // 1. Скасовуємо будь-який старий таймер, якщо він дивом залишився
      _pollingTimer?.cancel();
      _pollingTimer = null;

      // 2. Завантажуємо історію друку з бази
      final historyList = await (_db.select(_db.printJobs)
            ..where((tbl) => tbl.printerId.equals(event.printer.id))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.startTime)]))
          .get();

      if (isClosed) return;
      emit(state.copyWith(history: historyList, isLoading: false));

      // 3. ЗАЛІЗОБЕТОННИЙ РЕКУРСИВНИЙ ПУЛІНГ
      // Замість періодичного таймера запускаємо контрольовану функцію-петлю
      Future<void> poll() async {
        // Якщо Блок закрили — миттєво зупиняємо рекурсію і виходимо
        if (isClosed) return;

        try {
          final telemetry = await _client.getPrinterStatus(
            event.printer.ipAddress,
            event.printer.port,
            event.printer.apiKey,
          );
          
          if (!isClosed) {
            add(UpdateTelemetry(telemetry));
          }
        } catch (e) {
          // Якщо мережа відвалилася — додаток не впаде
          // Можна додати логування помилки, якщо треба
        }

        // Чекаємо 3 секунди ПЕРЕД наступним запитом, ТІЛЬКИ якщо Блок ще живий
        if (!isClosed) {
          _pollingTimer = Timer(const Duration(seconds: 3), poll);
        }
      }

      // Запускаємо першу ітерацію пулінгу
      await poll();
    });

    on<UpdateTelemetry>((event, emit) {
      if (!isClosed) {
        emit(state.copyWith(telemetry: event.telemetry));
      }
    });

    on<ChangeSlotMaterialEvent>((event, emit) async {
      await _db.connectMaterialToSlot(
        event.printerId,
        event.slotIndex,
        event.materialId,
      );
      // База даних Drift сама оновить UI через реактивний стрім на головній,
      // тут більше нічого примусово викликати не потрібно.
    });
  }

  @override
  Future<void> close() {
    // Тотальне зачищення при виході з екрана
    _pollingTimer?.cancel();
    _pollingTimer = null;
    return super.close();
  }
}
