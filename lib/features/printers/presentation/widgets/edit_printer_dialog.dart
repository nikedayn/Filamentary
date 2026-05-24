import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:filamentary/core/database/database.dart' as db;
import '../printers_bloc.dart'; // Імпортуй Блок, якщо потрібно

class EditPrinterDialog extends StatefulWidget {
  final db.Printer printer;
  final PrintersBloc printersBloc; // <--- ДОДАЄМО ЦЕ ПОЛЕ

  const EditPrinterDialog({
    super.key, 
    required this.printer, 
    required this.printersBloc, // <--- І СЮДИ
  });

  @override
  State<EditPrinterDialog> createState() => _EditPrinterDialogState();
}

class _EditPrinterDialogState extends State<EditPrinterDialog> {
  late TextEditingController _nameController;
  late TextEditingController _ipController;
  late int _selectedSlots;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.printer.name);
    _ipController = TextEditingController(text: widget.printer.ipAddress);
    _selectedSlots = widget.printer.slotsCount;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редагування принтера', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Назва принтера', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(labelText: 'IP Адреса', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            const Text('Кількість слотів (AMS/Котушки):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 8),
            
            // СЕГМЕНТОВАНИЙ ВИБІР СЛОТІВ
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1')),
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 4, label: Text('4')),
              ],
              selected: {_selectedSlots},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() => _selectedSlots = newSelection.first);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Скасувати')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade700, foregroundColor: Colors.white),
          onPressed: () {
            // Формуємо нову структуру JSON, якщо кількість слотів змінилася
            Map<String, dynamic> currentSlots = jsonDecode(widget.printer.activeSlotsJson);
            Map<String, dynamic> newSlots = {};
            for (int i = 1; i <= _selectedSlots; i++) {
              newSlots['slot_$i'] = currentSlots['slot_$i']; // Зберігаємо старі прив'язки, якщо вони були
            }

            final updatedPrinter = widget.printer.copyWith(
              name: _nameController.text,
              ipAddress: _ipController.text,
              slotsCount: _selectedSlots,
              activeSlotsJson: jsonEncode(newSlots),
            );
            
            widget.printersBloc.add(UpdatePrinter(updatedPrinter));
            Navigator.pop(context);
          },
          child: const Text('Зберегти'),
        ),
      ],
    );
  }
}