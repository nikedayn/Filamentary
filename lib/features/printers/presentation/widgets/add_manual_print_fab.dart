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
        // КРИТИЧНИЙ ФІКС: Заздалегідь зберігаємо посилання на Блок у потоку контексту.
        // Це гарантує, що подія не загубиться при переході між контекстами шторки/діалогу!
        final detailBloc = context.read<PrinterDetailBloc>();
        final double screenWidth = MediaQuery.of(context).size.width;
        
        Map<String, dynamic>? printData;

        if (screenWidth < 600) {
          // НА ТЕЛЕФОНІ: Відкриваємо як ергономічну нижню шторку (BottomSheet)
          printData = await showModalBottomSheet<Map<String, dynamic>?>(
            context: context,
            isScrollControlled: true, // Дозволяє формі адаптуватися під клавіатуру
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => ManualPrintDialog(printer: printer),
          );
        } else {
          // НА ДЕСКТОПІ/ПК: Залишаємо класичний акуратний діалог
          printData = await showDialog<Map<String, dynamic>?>(
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.antiAlias,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ManualPrintDialog(printer: printer),
              ),
            ),
          );
        }

        if (printData == null) return;

        // Використовуємо збережене посилання на Блок
        detailBloc.add(
          AddManualPrintJobEvent(printData: printData),
        );
        
        if (context.mounted) {
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