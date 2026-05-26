import 'dart:convert';
import 'database.dart' as db;
import 'package:filamentary/features/inventory/domain/models/filament_material.dart';
import 'package:filamentary/features/printers/domain/models/app_printer.dart';

extension MaterialMapper on db.Material {
  /// Конвертація автогенерованої моделі Drift у чисту бізнес-модель
  FilamentMaterial toDomain() {
    return FilamentMaterial(
      id: id,
      manufacturer: manufacturer,
      type: type,
      color: color,
      diameter: diameter,
      imageUrl: imageUrl,
      initialWeight: initialWeight,
      usedWeight: usedWeight,
      version: version,
      timestamp: timestamp,
    );
  }
}

extension PrinterMapper on db.Printer {
  /// Конвертація автогенерованої моделі Дріфт + парсинг внутрішнього JSON слотів
  AppPrinter toDomain() {
    final List<PrinterSlot> parsedSlots = [];
    
    try {
      final Map<String, dynamic> slotsMap = jsonDecode(activeSlotsJson);
      for (int i = 1; i <= slotsCount; i++) {
        parsedSlots.add(PrinterSlot(
          index: i,
          linkedMaterialId: slotsMap['slot_$i'],
        ));
      }
    } catch (_) {
      // Захисний механізм на випадок битого JSON
      for (int i = 1; i <= slotsCount; i++) {
        parsedSlots.add(PrinterSlot(index: i, linkedMaterialId: null));
      }
    }

    return AppPrinter(
      id: id,
      name: name,
      ipAddress: ipAddress,
      port: port,
      manufacturer: manufacturer,
      model: model,
      apiKey: apiKey,
      slotsCount: slotsCount,
      slots: parsedSlots,
      imageUrl: imageUrl,
      version: version,
      timestamp: timestamp,
    );
  }
}