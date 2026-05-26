import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:filamentary/features/printers/domain/models/app_printer.dart';

class ManualPrintDialog extends StatefulWidget {
  final AppPrinter printer;

  const ManualPrintDialog({super.key, required this.printer});

  @override
  State<ManualPrintDialog> createState() => _ManualPrintDialogState();
}

class _ManualPrintDialogState extends State<ManualPrintDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Контролери для текстових полів
  final _modelNameController = TextEditingController();
  final _hoursController = TextEditingController(text: '0');
  final _minutesController = TextEditingController(text: '0');

  String _status = 'Успішно';
  DateTime _selectedDateTime = DateTime.now(); // Єдине джерело правди для часу початку
  
  final Map<int, double> _slotWeights = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.printer.slots.length; i++) {
      if (widget.printer.slots[i].linkedMaterialId?.isNotEmpty == true) {
        _slotWeights[i] = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _modelNameController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  // Чистий метод-хелпер для вибору дати та часу
  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (pickedDate == null) return;

    if (!mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final assignedSlots = widget.printer.slots
        .asMap()
        .entries
        .where((e) => e.value.linkedMaterialId?.isNotEmpty == true)
        .toList();

    // Форматуємо дату для відображення користувачу
    final String formattedDateTime = DateFormat('dd.MM.yyyy HH:mm').format(_selectedDateTime);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.add_chart, color: Colors.blueGrey),
          SizedBox(width: 10),
          Text('Додати друк вручну', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Назва моделі
                TextFormField(
                  controller: _modelNameController,
                  decoration: const InputDecoration(
                    labelText: 'Назва деталі / G-code файлу',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.insert_drive_file_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Введіть назву' : null,
                ),
                const SizedBox(height: 16),

                // 2. Вибір дати та часу початку друку
                InkWell(
                  onTap: _pickDateTime,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Час початку друку',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDateTime,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Розділена тривалість (Години / Хвилини) та Статус
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _hoursController,
                        decoration: const InputDecoration(
                          labelText: 'Години',
                          border: OutlineInputBorder(),
                          suffixText: 'год',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return '0';
                          if (int.tryParse(v) == null) return 'Помилка';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _minutesController,
                        decoration: const InputDecoration(
                          labelText: 'Хвилини',
                          border: OutlineInputBorder(),
                          suffixText: 'хв',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return '0';
                          final val = int.tryParse(v);
                          if (val == null) return 'Помилка';
                          if (val < 0 || val > 59) return '0-59';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Статус',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Успішно', 'Скасовано', 'Збій'].map((s) {
                          return DropdownMenuItem(value: s, child: Text(s));
                        }).toList(),
                        onChanged: (val) => setState(() => _status = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Витрата пластику по слотах:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueGrey),
                ),
                const SizedBox(height: 10),

                if (assignedSlots.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'На принтері немає заправлених котушок.',
                      style: TextStyle(color: Colors.redAccent, fontStyle: FontStyle.italic),
                    ),
                  ),

                ...assignedSlots.map((entry) {
                  final idx = entry.key;
                  final slot = entry.value;
                  final String matId = slot.linkedMaterialId ?? '';
                  final String shortId = matId.length > 8 ? matId.substring(0, 8) : matId;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Слот #${idx + 1} (ID: $shortId...)',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              suffixText: 'г',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            initialValue: '0',
                            validator: (v) {
                              if (v == null || v.isEmpty) return '0';
                              if (double.tryParse(v) == null) return 'Помилка';
                              return null;
                            },
                            onSaved: (v) {
                              if (v != null) {
                                _slotWeights[idx] = double.tryParse(v) ?? 0.0;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Скасувати', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey.shade700,
            foregroundColor: Colors.white,
          ),
          onPressed: assignedSlots.isEmpty ? null : _submitData,
          child: const Text('Зафіксувати друк'),
        ),
      ],
    );
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final int hours = int.tryParse(_hoursController.text.trim()) ?? 0;
    final int minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
    
    // БІЗНЕС-КОНВЕРСІЯ: переводимо години і хвилини в секунди для збереження у базі
    final int durationSeconds = (hours * 3600) + (minutes * 60);

    if (durationSeconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Тривалість друку повинна бути більшою за 0!'), backgroundColor: Colors.orange),
      );
      return;
    }

    double totalSpentWeight = 0.0;
    List<Map<String, dynamic>> materialsLog = [];

    _slotWeights.forEach((slotIdx, weight) {
      if (weight > 0) {
        totalSpentWeight += weight;
        final materialId = widget.printer.slots[slotIdx].linkedMaterialId ?? '';
        materialsLog.add({
          'slotIndex': slotIdx + 1,
          'materialId': materialId,
          'spentWeight': weight,
        });
      }
    });

    if (totalSpentWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введіть вагу хоча б для одного слоту!'), backgroundColor: Colors.orange),
      );
      return;
    }

    // Повертаємо чистий Map з адаптованими даними
    Navigator.pop(context, {
      'id': const Uuid().v4(),
      'printerId': widget.printer.id,
      'modelName': _modelNameController.text.trim(),
      'status': _status,
      'spentWeight': totalSpentWeight,
      'usedMaterialsLogJson': jsonEncode(materialsLog),
      'startTime': _selectedDateTime, // Передаємо обрану користувачем дату назад у BLoC
      'duration': durationSeconds,
    });
  }
}