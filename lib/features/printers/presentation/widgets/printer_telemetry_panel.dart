import 'package:flutter/material.dart';
import 'package:filamentary/features/printers/domain/models/app_printer.dart';
import 'package:filamentary/core/network/printer_client_interface.dart';
import 'telemetry_info_block.dart';
import 'printer_slot_card.dart';

class PrinterTelemetryPanel extends StatelessWidget {
  final AppPrinter printer;
  final PrinterTelemetry telemetry;

  const PrinterTelemetryPanel({
    super.key,
    required this.printer,
    required this.telemetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок та назва принтера
          Text(
            printer.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            printer.model,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),

          // 1. БЛОК ТЕЛЕМЕТРІЇ (Винесено в окремий віджет)
          TelemetryInfoBlock(telemetry: telemetry),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // 2. КЕРУВАННЯ СЛОТАМИ КОТУШОК
          const Text(
            'Слоти котушок',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Динамічний список слотів (Використовує виділений PrinterSlotCard)
          Expanded(
            child: ListView.builder(
              itemCount: printer.slotsCount,
              itemBuilder: (context, index) {
                return PrinterSlotCard(
                  printer: printer,
                  slotIndex: index,
                );
              },
            ),
          ),

          const SizedBox(height: 8),
          // Мережевий підвал
          Center(
            child: Text(
              'Мережа: ${printer.ipAddress}:${printer.port}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}