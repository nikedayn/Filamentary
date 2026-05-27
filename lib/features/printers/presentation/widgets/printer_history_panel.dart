import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:filamentary/core/database/database.dart' as db;
import '../printer_detail_bloc.dart';
import 'edit_print_job_dialog.dart';
import 'delete_print_job_dialog.dart';

class PrinterHistoryPanel extends StatelessWidget {
  final List<db.PrintJob> history;
  final List<db.Material> allMaterials;
  final ScrollController? scrollController;

  const PrinterHistoryPanel({
    super.key, 
    required this.history, 
    required this.allMaterials,
    this.scrollController,
  });

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '0 хв';
    final int totalMinutes = totalSeconds ~/ 60;
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    return hours > 0 ? '$hours год${minutes > 0 ? ' $minutes хв' : ''}' : '$minutes khv';
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileSheet = scrollController != null;

    // Якщо лог порожній
    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_toggle_off, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text('Жодної операції ще не зафіксовано', style: TextStyle(color: Colors.grey.shade500)),
            ],
          ),
        ),
      );
    }

    // ЗАЛІЗОБЕТОННИЙ ФІКС: Якщо віджет викликано всередині мобільної шторки (isMobileSheet),
    // ми повертаємо безпосередньо ListView.builder як корінь, підключивши до нього заголовок через спільний індекс 0.
    // Це повністю прибирає вкладені Column/Expanded блоки і анігілює зависання!
    return ListView.builder(
      controller: scrollController,
      // На мобільці шторка сама контролює фізику, на десктопі — стандартний скрол
      physics: isMobileSheet ? const BouncingScrollPhysics() : const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 8),
      itemCount: history.length + 1, // +1 для заголовка екрана
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16, top: 4),
            child: Text(
              'Історія операцій (Лог друку)', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
          );
        }

        // Зміщуємо індекс на -1 через заголовок
        final job = history[index - 1];
        final durationText = _formatDuration(job.duration);
        
        // Академічна вимога ТЗ: заміна крапок на коми у виведенні чисел
        final String weightFormatted = job.spentWeight.toStringAsFixed(1).replaceAll('.', ',');

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Icon(
              job.status == 'Успішно' ? Icons.check_circle_outline : (job.status == 'Скасовано' ? Icons.cancel_outlined : Icons.error_outline),
              color: job.status == 'Успішно' ? Colors.green : (job.status == 'Скасовано' ? Colors.orange : Colors.red),
              size: 26,
            ),
            title: Text(job.modelName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Дата: ${job.startTime.day}.${job.startTime.month}.${job.startTime.year}  |  Тривалість: $durationText\nВитрата матеріалу: $weightFormatted г',
                style: const TextStyle(fontSize: 11, height: 1.3),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    job.status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 10, 
                      color: job.status == 'Успішно' ? Colors.green.shade800 : Colors.red.shade800
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey, size: 18),
                  borderRadius: BorderRadius.circular(8),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final updatedData = await showDialog<Map<String, dynamic>?>(
                        context: context,
                        builder: (context) => EditPrintJobDialog(job: job, allMaterials: allMaterials),
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
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Редагувати')])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 16), SizedBox(width: 8), Text('Видалити', style: TextStyle(color: Colors.red))])),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}