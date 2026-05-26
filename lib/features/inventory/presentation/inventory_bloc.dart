import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:filamentary/core/database/database.dart' as db; // Для Сompions при додаванні
import 'package:filamentary/features/inventory/data/inventory_repository.dart'; // Наш новий репозиторій
import 'package:filamentary/features/inventory/domain/models/filament_material.dart'; // Чиста модель даних
import 'package:drift/drift.dart' as drift;

// ==========================================
// СТАНІ (STATES)
// ==========================================
abstract class InventoryState extends Equatable {
  const InventoryState();
  @override
  List<Object?> get props => [];
}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<FilamentMaterial> materials; 
  
  const InventoryLoaded(this.materials);

  @override
  List<Object?> get props => [materials];
}

class InventoryFailure extends InventoryState {
  final String error;
  const InventoryFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// ==========================================
// ПОДІЇ (EVENTS)
// ==========================================
abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
  @override
  List<Object?> get props => [];
}

class WatchInventory extends InventoryEvent {}

class AddMaterialEvent extends InventoryEvent {
  final String manufacturer;
  final String type;
  final String color;
  final String diameter;
  final double initialWeight;
  final String? imageUrl;

  const AddMaterialEvent({
    required this.manufacturer,
    required this.type,
    required this.color,
    required this.diameter,
    required this.initialWeight,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [manufacturer, type, color, diameter, initialWeight, imageUrl];
}

class DeleteMaterialEvent extends InventoryEvent {
  final String materialId;
  const DeleteMaterialEvent(this.materialId);

  @override
  List<Object?> get props => [materialId];
}

/// ФІКС ПОМИЛКИ: Створили пропущену подію масового редагування групи котушок
class UpdateGroupMaterialsEvent extends InventoryEvent {
  final List<String> materialIds;
  final String manufacturer;
  final String type;
  final String color;
  final String diameter;

  const UpdateGroupMaterialsEvent({
    required this.materialIds,
    required this.manufacturer,
    required this.type,
    required this.color,
    required this.diameter,
  });

  @override
  List<Object?> get props => [materialIds, manufacturer, type, color, diameter];
}

// ==========================================
// БІЗНЕС-ЛОГІКА (BLOC)
// ==========================================
@injectable
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _inventoryRepository; 
  final db.AppDatabase _db; 
  final _uuid = const Uuid();

  InventoryBloc(this._inventoryRepository, this._db) : super(InventoryLoading()) {
    
    // Опитування інвентаря через стрім репозиторія
    on<WatchInventory>((event, emit) async {
      await emit.forEach<List<FilamentMaterial>>(
        _inventoryRepository.watchMaterials(),
        onData: (materialsList) => InventoryLoaded(materialsList),
        onError: (error, stackTrace) => InventoryFailure(error.toString()),
      );
    });

    // Додавання нового матеріалу
    on<AddMaterialEvent>((event, emit) async {
      try {
        final String materialId = _uuid.v4();
        final String transactionId = _uuid.v4();

        final companion = db.MaterialsCompanion.insert(
          id: materialId,
          manufacturer: event.manufacturer,
          type: event.type,
          color: event.color,
          diameter: drift.Value(event.diameter),
          initialWeight: event.initialWeight,
          imageUrl: drift.Value(event.imageUrl),
        );

        await _db.insertMaterialWithLog(companion, transactionId);
      } catch (e) {
        // М'яке логування помилок
      }
    });

    // Видалення матеріалу
    on<DeleteMaterialEvent>((event, emit) async {
      try {
        final String transactionId = _uuid.v4();
        await _db.softDeleteMaterial(event.materialId, transactionId);
      } catch (e) {
        // Обробка винятків
      }
    });

    // ФІКС ПОМИЛКИ: Зареєстрували обробник для події оновлення групи матеріалів
    on<UpdateGroupMaterialsEvent>((event, emit) async {
      try {
        final String transactionId = _uuid.v4();
        
        // Викликаємо транзакційний метод бази даних
        await _db.updateGroupMaterials(
          materialIds: event.materialIds,
          manufacturer: event.manufacturer,
          type: event.type,
          color: event.color,
          diameter: event.diameter,
          transactionId: transactionId,
        );
      } catch (e) {
        // Обробка винятків
      }
    });
  }
}