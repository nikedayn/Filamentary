import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:filamentary/features/printers/domain/models/app_printer.dart';
import '../printer_detail_bloc.dart';
import 'manual_print_dialog.dart';

class AddManualPrintFab extends StatelessWidget {
  final AppPrinter printer;

  const AddManualPrintFab({super.key, required this.printer});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'add_manual_print_fab_tag',
      backgroundColor: Colors.blueGrey.shade700,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_chart_outlined),
      label: const Text('Додати друк вручну'),
      onPressed: () async {
        final Map<String, dynamic>? printData = await showDialog<Map<String, dynamic>?>(
          context: context,
          builder: (context) => ManualPrintDialog(printer: printer),
        );

        if (printData == null) return;

        if (context.mounted) {
          // СИНТАКСИЧНИЙ ФІКС: Подія AddManualPrintJobEvent тепер правильно 
          // передається всередину методу .add() твого Блоку!
          context.read<PrinterDetailBloc>().add(
            AddManualPrintJobEvent(printData: printData),
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Операцію друку успішно додано до історії!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }
}