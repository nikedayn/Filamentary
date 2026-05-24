import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:filamentary/core/di/injection.dart';
import 'package:filamentary/core/database/database.dart' as db;
import 'printer_detail_bloc.dart';
import 'widgets/printer_telemetry_panel.dart';
import 'widgets/printer_history_panel.dart';

class PrinterDetailScreen extends StatelessWidget {
  final db.Printer printer;

  const PrinterDetailScreen({super.key, required this.printer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PrinterDetailBloc>()..add(StartMonitoring(printer)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Центр керування: ${printer.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blueGrey.shade100,
          elevation: 1,
        ),
        body: BlocBuilder<PrinterDetailBloc, PrinterDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Автономний віджет лівої панелі телеметрії
                PrinterTelemetryPanel(printer: printer, telemetry: state.telemetry),
                
                const VerticalDivider(width: 1),

                // 2. Автономний віджет центральної панелі логів
                Expanded(
                  child: PrinterHistoryPanel(history: state.history),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}