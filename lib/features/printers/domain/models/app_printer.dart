import 'package:equatable/equatable.dart';

/// Чистий стан слоту принтера (замість сирого динамічного JSON)
class PrinterSlot extends Equatable {
  final int index;
  final String? linkedMaterialId;

  const PrinterSlot({required this.index, this.linkedMaterialId});

  @override
  List<Object?> get props => [index, linkedMaterialId];
}

/// Чиста бізнес-модель 3D-принтера
class AppPrinter extends Equatable {
  final String id;
  final String name;
  final String ipAddress;
  final int port;
  final String manufacturer;
  final String model;
  final String? apiKey;
  final int slotsCount;
  final List<PrinterSlot> slots; // Типізована структура замість JSON рядка!
  final String? imageUrl;
  final int version;
  final DateTime timestamp;

  const AppPrinter({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.manufacturer,
    required this.model,
    this.apiKey,
    required this.slotsCount,
    required this.slots,
    this.imageUrl,
    required this.version,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id, name, ipAddress, port, manufacturer, model,
        apiKey, slotsCount, slots, imageUrl, version, timestamp
      ];
}