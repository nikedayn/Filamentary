import 'dart:convert';
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
      width: 360,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. ДІАГНОСТИКА ПОМИЛКИ: Чистий динамічний заголовок замість хардкоду
          if (!telemetry.isOnline && telemetry.errorMessage.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // АРХІТЕКТУРНИЙ ФІКС: Текст підлаштовується під виробника принтера автоматично
                          'Помилка підключення до ${printer.manufacturer}',
                          style: TextStyle(
                            fontSize: 13, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.red.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          telemetry.errorMessage,
                          style: TextStyle(
                            fontSize: 12, 
                            color: Colors.red.shade700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 2. БЛОК ТЕЛЕМЕТРІЇ (Показники датчиків/температур)
          TelemetryInfoBlock(telemetry: telemetry),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // 3. КЕРУВАННЯ СЛОТАМИ КОТУШОК
          const Text(
            'Слоти котушок',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Генерація слотів філаменту
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              printer.slotsCount,
              (index) => PrinterSlotCard(
                printer: printer,
                slotIndex: index,
              ),
            ),
          ),

          const SizedBox(height: 12),
          Center(
            child: Text(
              'Мережа: ${printer.ipAddress}:${printer.port}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}