import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:filamentary/features/printers/domain/models/app_printer.dart'; // чиста модель
import 'package:filamentary/core/network/printer_client_interface.dart'; 
import '../printers_bloc.dart';
import '../printer_detail_screen.dart';
import 'printer_status_badge.dart';
import 'edit_printer_dialog.dart';

class PrinterCard extends StatelessWidget {
  final AppPrinter printer; 

  const PrinterCard({super.key, required this.printer});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrinterDetailScreen(printer: printer),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. НАЗВА ТА УПРАВЛІННЯ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      printer.name, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_note, size: 22, color: Colors.blueGrey),
                    constraints: const BoxConstraints(), // Зменшуємо дефолтні падінги кнопки
                    padding: EdgeInsets.zero,
                    tooltip: 'Редагувати принтер',
                    onPressed: () {
                      final printersBloc = context.read<PrintersBloc>();
                      showDialog(
                        context: context,
                        builder: (context) => EditPrinterDialog(
                          printer: printer,
                          printersBloc: printersBloc,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    tooltip: 'Видалити принтер',
                    onPressed: () {
                      final printersBloc = context.read<PrintersBloc>();

                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                              SizedBox(width: 10),
                              Text('Видалення принтера', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 2. ПРЕВ'Ю ЗОБРАЖЕННЯ (ФІКС: Використовуємо Expanded, щоб макет контролював висоту)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.0, // Ідеальний квадрат
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: printer.imageUrl != null && printer.imageUrl!.isNotEmpty
                                  ? Image.network(
                                      printer.imageUrl!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.print_outlined, 
                                        color: Colors.blueGrey, 
                                        size: 36,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.print_outlined, 
                                      color: Colors.blueGrey, 
                                      size: 36,
                                    ),
                            ),
                          ),
                        ),
                        const Positioned(
                          top: 8,
                          left: 8,
                          child: PrinterStatusBadge(state: PrinterState.offline),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 3. СПЕЦИФІКАЦІЇ ПРИСТРОЮ (Більше нікуди не зсуваються і не затискаються)
              Text(
                '${printer.manufacturer} ${printer.model}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
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
                      style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontFamily: 'monospace'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Слотів: ${printer.slotsCount}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}