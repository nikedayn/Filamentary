import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:filamentary/core/database/database.dart' as db;
import 'package:filamentary/features/printers/presentation/widgets/printer_scanner_screen.dart'; // КРИТИЧНИЙ ІМПОРТ ФІКСУ
import '../printer_detail_bloc.dart';

class PrinterTelemetryPanel extends StatelessWidget {
  final db.Printer printer;
  final Map<String, dynamic> telemetry;

  const PrinterTelemetryPanel({
    super.key, 
    required this.printer, 
    required this.telemetry,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = telemetry['isOnline'] ?? false;
    final String printerState = telemetry['state'] ?? 'offline';
    final double extruderTemp = telemetry['extruderTemp'] ?? 0.0;
    final double extruderTarget = telemetry['extruderTarget'] ?? 0.0;
    final double bedTemp = telemetry['bedTemp'] ?? 0.0;
    final double bedTarget = telemetry['bedTarget'] ?? 0.0;
    final double progress = telemetry['progress'] ?? 0.0;
    final String currentFile = telemetry['filename'] ?? '';

    // Розкодовуємо активні слоти з нашої бази даних
    final Map<String, dynamic> slotsMap = jsonDecode(printer.activeSlotsJson);

    return Container(
      width: 320,
      color: Colors.blueGrey.shade50.withAlpha(120),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(printer.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text('${printer.manufacturer} ${printer.model}', style: const TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('Мережа: ${printer.ipAddress}:${printer.port}', style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontFamily: 'monospace')),
          const Divider(height: 24),
          
          Row(
            children: [
              Icon(Icons.circle, size: 12, color: !isOnline ? Colors.red : (printerState == 'printing' ? Colors.green : Colors.orange)),
              const SizedBox(width: 8),
              Text(printerState.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildTempRow(Icons.local_fire_department_outlined, 'Сопло', extruderTemp, extruderTarget, Colors.orange.shade700),
          const SizedBox(height: 12),
          _buildTempRow(Icons.calendar_view_day, 'Стіл', bedTemp, bedTarget, Colors.blue.shade700),
          
          if (printerState == 'printing') ...[
            const Divider(height: 24),
            const Text('Поточний Друк:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              currentFile, 
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress / 100, minHeight: 6, backgroundColor: Colors.grey.shade200, color: Colors.green),
            ),
          ],

          const Divider(height: 28),
          const Text(
            'АКТИВНІ КОТУШКИ (СЛОТИ):', 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 0.5)
          ),
          const SizedBox(height: 10),

          // ДИНАМІЧНИЙ СПИСОК СЛОТІВ ПРИНТЕРА
          Expanded(
            child: ListView.builder(
              itemCount: printer.slotsCount,
              itemBuilder: (context, index) {
                final slotIndex = index + 1;
                final String? attachedMaterialId = slotsMap['slot_$slotIndex'];

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueGrey.shade100),
                  ),
                  child: Row(
                    children: [
                      // Номер слоту
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.blueGrey.shade700,
                        child: Text('$slotIndex', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),

                      // Назва матеріалу
                      Expanded(
                        child: attachedMaterialId == null
                            ? Text('Порожній слот', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontStyle: FontStyle.italic))
                            : Text(
                                'Котушка заправлена', 
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),

                      // Дія: або заправити через камеру, або витягнути
                      if (attachedMaterialId == null)
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner, color: Colors.blueGrey, size: 20),
                          tooltip: 'Заправити котушку через камеру',
                          onPressed: () async {
                            // КРОК 1. Викликаємо наш відремонтований сканер
                            final String? scannedSpoolId = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(builder: (context) => const PrinterScannerScreen()),
                            );

                            // КРОК 2. Приймаємо UUID і відправляємо івент у BLoC
                            if (scannedSpoolId != null && context.mounted) {
                              context.read<PrinterDetailBloc>().add(ChangeSlotMaterialEvent(
                                printerId: printer.id,
                                slotIndex: slotIndex,
                                materialId: scannedSpoolId, // Заправляємо зчитаний UUID
                              ));
                            }
                          },
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.logout_outlined, color: Colors.redAccent, size: 18),
                          tooltip: 'Витягнути котушку',
                          onPressed: () {
                            context.read<PrinterDetailBloc>().add(ChangeSlotMaterialEvent(
                                  printerId: printer.id,
                                  slotIndex: slotIndex,
                                  materialId: null, // Скидаємо в null
                                ));
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempRow(IconData icon, String title, double current, double target, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          ],
        ),
        Text('${current.toStringAsFixed(0)}°C / ${target.toStringAsFixed(0)}°C', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}