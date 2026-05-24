import 'package:equatable/equatable.dart';

// Клас, який описує конфлікт у зрозумілому для UI вигляді
class SyncConflict extends Equatable {
  final String entityId;
  final String entityType; // Наприклад: 'Printer' або 'Material'
  final Map<String, dynamic> localData;
  final Map<String, dynamic> cloudData;

  const SyncConflict({
    required this.entityId,
    required this.entityType,
    required this.localData,
    required this.cloudData,
  });

  @override
  List<Object?> get props => [entityId, entityType, localData, cloudData];
}