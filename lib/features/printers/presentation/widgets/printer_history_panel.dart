import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // КРИТИЧНО: додає метод .read() для BuildContext
import 'package:filamentary/core/database/database.dart' as db;
import '../printer_detail_bloc.dart'; // КРИТИЧНО: додає PrinterDetailBloc, EditPrintJobEvent та DeletePrintJobEvent
import 'edit_print_job_dialog.dart';
import 'delete_print_job_dialog.dart';
import 'package:filamentary/features/printers/domain/models/app_printer.dart'; // Додали модель принтера для передачі в діалоги

class PrinterHistoryPanel extends StatelessWidget {
  final List<db.PrintJob> history;
  final List<db.Material> allMaterials; // Змінено тут!

  const PrinterHistoryPanel({
    super.key, 
    required this.history, 
    required this.allMaterials, // І тут
  });

  // Перенесли функцію всередину як приватний метод хелпер класу для чистоти
  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '0 хв';

    final int totalMinutes = totalSeconds ~/ 60;
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;

    if (hours > 0) {
      return '$hours год${minutes > 0 ? ' $minutes хв' : ''}';
    } else {
      return '$minutes хв';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Історія операцій принтера (Лог друку)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text('Жодної операції ще не зафіксовано', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final job = history[index];
                      
                      // Викликаємо наш форматер замість сирих хвилин
                      final durationText = _formatDuration(job.duration);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: Icon(
                            job.status == 'Успішно' ? Icons.check_circle_outline : (job.status == 'Скасовано' ? Icons.cancel_outlined : Icons.error_outline),
                            color: job.status == 'Успішно' ? Colors.green : (job.status == 'Скасовано' ? Colors.orange : Colors.red),
                            size: 32,
                          ),
                          title: Text(job.modelName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Дата: ${job.startTime.day}.${job.startTime.month}.${job.startTime.year}  |  Тривалість: $durationText\nВитрата матеріалу: ${job.spentWeight.toStringAsFixed(1)} г',
                              style: const TextStyle(fontSize: 13, height: 1.4),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Наш статус-бейдж
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  job.status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 12, 
                                    color: job.status == 'Успішно' ? Colors.green.shade800 : Colors.red.shade800
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Контекстне меню дій
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    final updatedData = await showDialog<Map<String, dynamic>?>(
                                      context: context,
                                      builder: (context) => EditPrintJobDialog(
                                        job: job, 
                                        allMaterials: allMaterials, // Передаємо список матеріалів
                                      ),
                                    );
                                    if (updatedData != null && context.mounted) {
                                      context.read<PrinterDetailBloc>().add(EditPrintJobEvent(oldJob: job, updatedData: updatedData));
                                    }
                                  } else if (value == 'delete') {
                                    final bool? restore = await showDialog<bool?>(
                                      context: context,
                                      builder: (context) => DeletePrintJobDialog(modelName: job.modelName),
                                    );
                                    if (restore != null && context.mounted) {
                                      context.read<PrinterDetailBloc>().add(DeletePrintJobEvent(job: job, restoreWeight: restore));
                                    }
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Редагувати')]),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 18), SizedBox(width: 8), Text('Видалити', style: TextStyle(color: Colors.red))]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}