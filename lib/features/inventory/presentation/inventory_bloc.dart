import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:filamentary/core/database/database.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();
  @override
  List<Object?> get props => [];
}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<Material> materials;
  const InventoryLoaded(this.materials);

  @override
  List<Object?> get props => [materials];
}

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
  @override
  List<Object?> get props => [];
}

class WatchInventory extends InventoryEvent {}

class AddMaterialEvent extends Equatable implements InventoryEvent {
  final String manufacturer;
  final String type;
  final String color;
  final double weight;
  final String diameter;  // Нове поле
  final String imageUrl;  // Нове поле

  const AddMaterialEvent({
    required this.manufacturer,
    required this.type,
    required this.color,
    required this.weight,
    this.diameter = '1.75mm',
    this.imageUrl = '',
  });

  @override
  List<Object?> get props => [manufacturer, type, color, weight, diameter, imageUrl];

  @override
  bool? get stringify => true;
}

// В inventory_bloc.dart переконайся, що є цей клас:
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

class SpendWeightEvent extends InventoryEvent {
  final String materialId;
  final double spentDelta;
  const SpendWeightEvent(this.materialId, this.spentDelta);
}

class DeleteMaterialEvent extends InventoryEvent {
  final String materialId;
  const DeleteMaterialEvent(this.materialId);
}

@injectable
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final AppDatabase _db;
  final _uuid = const Uuid();

  InventoryBloc(this._db) : super(InventoryLoading()) {
    
    on<WatchInventory>((event, emit) async {
      await emit.forEach<List<Material>>(
        _db.watchActiveMaterials(),
        onData: (materialsList) => InventoryLoaded(materialsList),
      );
    });

    on<AddMaterialEvent>((event, emit) async {
      final materialId = _uuid.v4();
      final transactionId = _uuid.v4();

      // Записуємо чисті змінні у Drift
      final companion = MaterialsCompanion.insert(
        id: materialId,
        manufacturer: event.manufacturer,
        type: event.type,
        color: event.color,
        diameter: Value(event.diameter),
        imageUrl: Value(event.imageUrl.isEmpty ? null : event.imageUrl),
        initialWeight: event.weight,
      );

      await _db.insertMaterialWithLog(companion, transactionId);
    });

    on<SpendWeightEvent>((event, emit) async {
      final transactionId = _uuid.v4();
      await _db.updateMaterialWeight(event.materialId, event.spentDelta, transactionId);
    });

    on<DeleteMaterialEvent>((event, emit) async {
      await _db.softDeleteMaterial(event.materialId);
    });
  }
}