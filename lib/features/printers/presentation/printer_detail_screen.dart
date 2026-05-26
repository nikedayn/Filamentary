import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:filamentary/core/di/injection.dart';
import 'package:filamentary/features/printers/domain/models/app_printer.dart'; 
import 'printer_detail_bloc.dart';
import 'widgets/printer_telemetry_panel.dart';
import 'widgets/printer_history_panel.dart';
import 'widgets/printer_status_badge.dart';
import 'widgets/add_manual_print_fab.dart'; // Імпортуємо нашу нову кнопку

class PrinterDetailScreen extends StatelessWidget {
  final AppPrinter printer; 

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
          actions: [
            BlocBuilder<PrinterDetailBloc, PrinterDetailState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: PrinterStatusBadge(state: state.telemetry.state),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<PrinterDetailBloc, PrinterDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrinterTelemetryPanel(
                  printer: state.printer ?? printer, 
                  telemetry: state.telemetry,
                ),
                
                const VerticalDivider(width: 1),

                Expanded(
                  child: PrinterHistoryPanel(
                    history: state.history,
                    allMaterials: state.materials, // Прокидаємо завантажений список котушок BLoC стану
                  ),
                ),
              ],
            );
          },
        ),
        // ФІКС ТУТ: Додаємо виділений віджет кнопки у нижній правий кут екрана
        floatingActionButton: BlocBuilder<PrinterDetailBloc, PrinterDetailState>(
          builder: (context, state) {
            if (state.isLoading) return const SizedBox.shrink();
            // Передаємо актуальний стан принтера з Блоку (або початковий)
            return AddManualPrintFab(printer: state.printer ?? printer);
          },
        ),
      ),
    );
  }
}