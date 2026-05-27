import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 👈 Обов'язково додаємо для context.watch та context.read
import 'package:filamentary/features/printers/domain/models/app_printer.dart';
import 'package:filamentary/core/network/printer_client_interface.dart';
import 'package:filamentary/features/printers/presentation/printers_bloc.dart'; // 👈 Імпортуємо твій Блок

// Припускаємо, що ці віджети та екрани лежать у твоїх імпортах:
import 'printer_status_badge.dart';
import 'edit_printer_dialog.dart';
import '../printer_detail_screen.dart'; 

class PrinterCard extends StatelessWidget {
  final AppPrinter printer; 

  const PrinterCard({super.key, required this.printer});

  @override
  Widget build(BuildContext context) {
    // ФІКС 1 & 3: Слухаємо стан Блоку через context.watch. 
    // Тепер картка буде перерисовуватися автоматично кожні 2 секунди за константою!
    final blocState = context.watch<PrintersBloc>().state;

    PrinterState currentStatus = PrinterState.offline; // дефолт, якщо не достукалися

    if (blocState is PrintersLoaded) {
      // ФІКС 2: Витягуємо живий статус конкретно цього принтера, читаючи стан об'єкта телеметрії
      final PrinterTelemetry? telemetry = blocState.telemetryMap[printer.id];
      if (telemetry != null) {
        currentStatus = telemetry.state;
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => PrinterDetailScreen(printer: printer)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              // 1. НАЗВА ТА КНОПКИ КЕРУВАННЯ
              Row(
                children: [
                  Expanded(
                    child: Text(
                      printer.name, 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_note, size: 22, color: Colors.blueGrey), 
                    constraints: const BoxConstraints(), 
                    padding: EdgeInsets.zero, 
                    onPressed: () {
                      final printersBloc = context.read<PrintersBloc>();
                      final double screenWidth = MediaQuery.of(context).size.width;

                      if (screenWidth < 600) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => EditPrinterDialog(
                            printer: printer,
                            onSave: (updated) => printersBloc.add(UpdatePrinterEvent(updated)),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context, 
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            clipBehavior: Clip.antiAlias,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 460),
                              child: EditPrinterDialog(
                                printer: printer, 
                                onSave: (updated) => printersBloc.add(UpdatePrinterEvent(updated)),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), 
                    constraints: const BoxConstraints(), 
                    padding: EdgeInsets.zero, 
                    onPressed: () => _showDeleteConfirmation(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 2. ПРЕВ'Ю ПРИНТЕРА
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 1.0, 
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ColoredBox(color: Colors.blueGrey.shade50),
                        ),
                        Positioned.fill(
                          child: printer.imageUrl != null && printer.imageUrl!.isNotEmpty
                              ? Image.network(
                                  printer.imageUrl!, 
                                  fit: BoxFit.contain, 
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.print_outlined, 
                                    color: Colors.blueGrey, 
                                    size: 40,
                                  ),
                                )
                              : const Icon(
                                  Icons.print_outlined, 
                                  color: Colors.blueGrey, 
                                  size: 40,
                                ),
                        ),
                        Positioned(
                          top: 8, 
                          left: 8, 
                          child: PrinterStatusBadge(state: currentStatus), 
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 3. ТЕКСТОВИЙ БЛОК ХАРАКТЕРИСТИК
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${printer.manufacturer} ${printer.model}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${printer.ipAddress}:${printer.port}',
                          style: const TextStyle(color: Colors.blueGrey, fontSize: 11, fontFamily: 'monospace'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withAlpha(20), 
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Слотів: ${printer.slotsCount}', 
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final printersBloc = context.read<PrintersBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Видалення принтера', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text('Ви впевнені, що хочете видалити принтер "${printer.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text('Скасувати', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () {
              printersBloc.add(DeletePrinterEvent(printer.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
  }
}