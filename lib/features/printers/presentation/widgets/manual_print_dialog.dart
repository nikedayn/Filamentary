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
  
  final _modelNameController = TextEditingController();
  final _hoursController = TextEditingController(text: '0');
  final _minutesController = TextEditingController(text: '0');

  String _status = 'Успішно';
  DateTime _selectedDateTime = DateTime.now(); 
  
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

    final String formattedDateTime = DateFormat('dd.MM.yyyy HH:mm').format(_selectedDateTime);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        // ВНУТРІШНЯ РОЗМІТКА ФОРМИ (Спільна для Desktop та Mobile)
        Widget buildFormContent() {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMobile)
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                  // 1. ЗАГОЛОВОК З ЗАХИСТОМ Expanded
                  Row(
                    children: [
                      const Icon(Icons.add_chart, color: Colors.blueGrey, size: 22),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Додати друк вручну', 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. НАЗВА МОДЕЛІ
                  TextFormField(
                    controller: _modelNameController,
                    decoration: const InputDecoration(
                      labelText: 'Назва деталі / G-code файлу',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.insert_drive_file_outlined, size: 18),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Введіть назву' : null,
                  ),
                  const SizedBox(height: 12),

                  // 3. ВИБІР ЧАСУ ПОЧАТКУ
                  InkWell(
                    onTap: _pickDateTime,
                    borderRadius: BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Час початку друку',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.calendar_month_outlined, size: 18),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedDateTime,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4. АДАПТИВНИЙ РЯДОК ТРИВАЛОСТІ ТА СТАТУСУ
                  if (isMobile) ...[
                    // На телефонах розбиваємо на два рядки, щоб не було Overflow
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _hoursController,
                            decoration: const InputDecoration(labelText: 'Години', isDense: true, border: OutlineInputBorder(), suffixText: 'год'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _minutesController,
                            decoration: const InputDecoration(labelText: 'Хвилини', isDense: true, border: OutlineInputBorder(), suffixText: 'хв'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Статус', isDense: true, border: OutlineInputBorder()),
                      items: ['Успішно', 'Скасовано', 'Збій'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _status = val!),
                    ),
                  ] else ...[
                    // На десктопі залишаємо все в один компактний рядок
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _hoursController,
                            decoration: const InputDecoration(labelText: 'Години', isDense: true, border: OutlineInputBorder(), suffixText: 'год'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _minutesController,
                            decoration: const InputDecoration(labelText: 'Хвилини', isDense: true, border: OutlineInputBorder(), suffixText: 'хв'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _status,
                            decoration: const InputDecoration(labelText: 'Статус', isDense: true, border: OutlineInputBorder()),
                            items: ['Успішно', 'Скасовано', 'Збій'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (val) => setState(() => _status = val!),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Витрата пластику по слотах:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 10),

                  if (assignedSlots.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'На принтері немає заправлених котушок.',
                        style: TextStyle(color: Colors.redAccent, fontStyle: FontStyle.italic, fontSize: 13),
                      ),
                    ),

                  ...assignedSlots.map((entry) {
                    final idx = entry.key;
                    final slot = entry.value;
                    final String matId = slot.linkedMaterialId ?? '';
                    final String shortId = matId.length > 8 ? matId.substring(0, 8) : matId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Слот #${idx + 1} (ID: $shortId...)',
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                suffixText: 'г',
                                isDense: true,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              initialValue: '0',
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
                  const SizedBox(height: 16),

                  // КНОПКИ УПРАВЛІННЯ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Скасувати', style: TextStyle(color: Colors.grey.shade700)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey.shade700,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: assignedSlots.isEmpty ? null : _submitData,
                        child: const Text('Зафіксувати друк', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        // ПОВНА АДАПТИВНІСТЬ: Шторка для телефону, Діалог для десктопу
        if (isMobile) {
          return buildFormContent();
        }

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: buildFormContent(),
          ),
        );
      },
    );
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final int hours = int.tryParse(_hoursController.text.trim()) ?? 0;
    final int minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
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

    Navigator.pop(context, {
      'id': const Uuid().v4(),
      'printerId': widget.printer.id,
      'modelName': _modelNameController.text.trim(),
      'status': _status,
      'spentWeight': totalSpentWeight,
      'usedMaterialsLogJson': jsonEncode(materialsLog),
      'startTime': _selectedDateTime, 
      'duration': durationSeconds,
    });
  }
}