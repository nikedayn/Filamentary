import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:filamentary/core/database/database.dart' as db;
import '../printers_bloc.dart';
import '../printer_detail_screen.dart';
import 'printer_status_badge.dart';
import 'edit_printer_dialog.dart';

class PrinterCard extends StatelessWidget {
  final db.Printer printer;

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
              // 1. НАЗВА ТА ВИДАЛЕННЯ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Назва принтера
                  Expanded(
                    child: Text(
                      printer.name, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // КНОПКА РЕДАГУВАННЯ (Олівець)
                  IconButton(
                    icon: const Icon(Icons.edit_note, size: 22, color: Colors.blueGrey),
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

                  // КНОПКА ВИДАЛЕННЯ (Червоний смітник) з підтвердженням
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                    tooltip: 'Видалити принтер',
                    onPressed: () {
                      // Фіксуємо Блок перед відкриттям діалогу, щоб не втратити контекст
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
                          content: Text('Ви впевнені, що хочете видалити принтер "${printer.name}"? Цю дію не можна буде скасувати.'),
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
                                // Викликаємо видалення через зафіксований Блок
                                printersBloc.add(DeletePrinterEvent(printer.id));
                                Navigator.pop(dialogContext); // Закриваємо діалог
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

              // 2. ЗОБРАЖЕННЯ З БЕЙДЖЕМ
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: printer.imageUrl != null && printer.imageUrl!.isNotEmpty
                              ? Image.network(
                                  printer.imageUrl!,
                                  fit: BoxFit.cover,
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
                    Positioned(
                      top: 8,
                      left: 8,
                      child: PrinterStatusBadge(printer: printer),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 3. ІНФОРМАЦІЙНИ / СЛОТИ
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