import 'package:flutter/material.dart';
import 'package:filamentary/core/database/database.dart' as db;

class PrinterHistoryPanel extends StatelessWidget {
  final List<db.PrintJob> history;

  const PrinterHistoryPanel({super.key, required this.history});

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
                    )
                  )
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final job = history[index];
                      final minutes = (job.duration / 60).toStringAsFixed(0);

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
                              'Дата: ${job.startTime.day}.${job.startTime.month}.${job.startTime.year}  |  Тривалість: $minutes хв\nВитрата матеріалу: ${job.spentWeight.toStringAsFixed(1)} г',
                              style: const TextStyle(fontSize: 13, height: 1.4),
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              job.status,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: job.status == 'Успішно' ? Colors.green.shade800 : Colors.red.shade800),
                            ),
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