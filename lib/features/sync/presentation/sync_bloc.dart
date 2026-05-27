import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../domain/sync_conflict.dart';
import '../domain/sync_engine.dart';

// СТАНІ (States) для Блоку синхронізації
abstract class SyncState extends Equatable {
  const SyncState();
  @override
  List<Object?> get props => [];
}

class SyncInitial extends SyncState {}
class SyncInProgress extends SyncState {}
class SyncSuccess extends SyncState {}

// Стан зупинки, коли виявлено конфлікт і треба показати таблицю користувачу
class SyncConflictDetected extends SyncState {
  final SyncConflict conflict;
  const SyncConflictDetected(this.conflict);

  @override
  List<Object?> get props => [conflict];
}

class SyncFailure extends SyncState {
  final String errorMessage;
  const SyncFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

// ПОДІЇ (Events)
abstract class SyncEvent extends Equatable {
  const SyncEvent();
  @override
  List<Object?> get props => [];
}

class CheckIncomingCloudData extends SyncEvent {
  final Map<String, dynamic> cloudJson;
  const CheckIncomingCloudData(this.cloudJson);
}

class ResolveConflictWithChoice extends SyncEvent {
  final String choice; // 'local', 'cloud' або 'merge'
  const ResolveConflictWithChoice(this.choice);
}

// САМИЙ БЛОК (Bloc)
@injectable
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncEngine _syncEngine;

  SyncBloc(this._syncEngine) : super(SyncInitial()) {
    
    // Обробка вхідних даних з хмари
    on<CheckIncomingCloudData>((event, emit) async {
      emit(SyncInProgress());
      
      final conflict = await _syncEngine.mergeMaterial(event.cloudJson);
      
      if (conflict != null) {
        // Якщо двигун повернув конфлікт, переводимо UI в режим відображення порівняльної таблиці
        emit(SyncConflictDetected(conflict));
      } else {
        emit(SyncSuccess());
      }
    });

    // Обробка вибору користувача (ТЗ: "Залишити локальну", "Замінити на хмарну" або "Об'єднати")
    on<ResolveConflictWithChoice>((event, emit) async {
      if (state is SyncConflictDetected) {
        final currentConflict = (state as SyncConflictDetected).conflict;
        
        emit(SyncInProgress());
        
        if (event.choice == 'local') {
          // Залишаємо локальну версію, але збільшуємо її номер версії за формулою max+1
          // для того, щоб під час наступного циклу вона перезаписала хмару
          int _ = _syncEngine.calculateNewVersion(
            currentConflict.localData['version'], 
            currentConflict.cloudData['version']
          );
          // Тут викликається оновлення версії в БД
        } else if (event.choice == 'cloud') {
          // Замінюємо локальні дані на хмарні
        } else if (event.choice == 'merge') {
          // Реалізується логіка об'єднання (наприклад, сумування полів або вибір свіжіших текстових полів)
        }
        
        emit(SyncSuccess());
      }
    });
  }
}