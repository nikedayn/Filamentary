import 'package:equatable/equatable.dart';

/// Абсолютно чиста бізнес-модель матеріалу, яка не залежить від ORM
class FilamentMaterial extends Equatable {
  final String id;
  final String manufacturer;
  final String type;
  final String color;
  final String diameter;
  final String? imageUrl;
  final double initialWeight;
  final double usedWeight;
  final int version;
  final DateTime timestamp;

  const FilamentMaterial({
    required this.id,
    required this.manufacturer,
    required this.type,
    required this.color,
    required this.diameter,
    this.imageUrl,
    required this.initialWeight,
    required this.usedWeight,
    required this.version,
    required this.timestamp,
  });

  /// Обчислювальна властивість: скільки пластику залишилося в грамах
  double get currentWeight => initialWeight - usedWeight;

  @override
  List<Object?> get props => [
        id, manufacturer, type, color, diameter, 
        imageUrl, initialWeight, usedWeight, version, timestamp
      ];
}