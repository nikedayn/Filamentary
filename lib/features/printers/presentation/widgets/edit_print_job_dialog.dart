import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:filamentary/core/database/database.dart' as db;
import 'material_select_dialog.dart'; // ПЕРЕВИКОРИСТОВУЄМО: твій готовий діалог

class EditPrintJobDialog extends StatefulWidget {
  final db.PrintJob job;
  final List<db.Material> allMaterials; // Використовуємо локальний кеш для миттєвого пошуку назв обраних котушок

  const EditPrintJobDialog({
    super.key, 
    required this.job, 
    required this.allMaterials,
  });

  @override
  State<EditPrintJobDialog> createState() => _EditPrintJobDialogState();
}

class _EditPrintJobDialogState extends State<EditPrintJobDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _modelNameController;
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late String _status;
  late DateTime _selectedDateTime;
  
  // Робочий динамічний лог матеріалів для редагування
  List<Map<String, dynamic>> _editableMaterialsLog = [];

  @override
  void initState() {
    super.initState();
    _modelNameController = TextEditingController(text: widget.job.modelName);
    
    final int totalMinutes = widget.job.duration ~/ 60;
    _hoursController = TextEditingController(text: (totalMinutes ~/ 60).toString());
    _minutesController = TextEditingController(text: (totalMinutes % 60).toString());
    
    _status = widget.job.status;
    _selectedDateTime = widget.job.startTime;

    try {
      final List<dynamic> decoded = jsonDecode(widget.job.usedMaterialsLogJson);
      _editableMaterialsLog = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (_) {
      _editableMaterialsLog = [];
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

  // МЕТОД: Викликає ТВОЙ MaterialSelectDialog та оновлює лог
  Future<void> _selectMaterialForSlot(int logIndex) async {
    final selectedMaterialId = await showDialog<String?>(
      context: context,
      // ФІКС: передаємо в твій діалог той самий список котушок з стану екрана
      builder: (context) => MaterialSelectDialog(customMaterials: widget.allMaterials), 
    );

    if (selectedMaterialId != null && selectedMaterialId.isNotEmpty && mounted) {
      setState(() {
        _editableMaterialsLog[logIndex]['materialId'] = selectedMaterialId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDateTime = DateFormat('dd.MM.yyyy HH:mm').format(_selectedDateTime);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.edit_note, color: Colors.blueGrey),
          SizedBox(width: 10),
          Text('Редагування запису', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 500,
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
                    labelText: 'Назва деталі / G-code файл',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Введіть назву' : null,
                ),
                const SizedBox(height: 16),

                // 2. Дата та Час
                InkWell(
                  onTap: _pickDateTime,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Дата та час початку друку',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today, size: 18),
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

                // 3. Тривалість та Статус
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _hoursController,
                        decoration: const InputDecoration(labelText: 'Год', border: OutlineInputBorder(), suffixText: 'год'),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || int.tryParse(v) == null) ? '0' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _minutesController,
                        decoration: const InputDecoration(labelText: 'Хв', border: OutlineInputBorder(), suffixText: 'хв'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null) return '0';
                          final m = int.tryParse(v);
                          if (m == null || m < 0 || m > 59) return '0-59';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(labelText: 'Статус', border: OutlineInputBorder()),
                        items: ['Успішно', 'Скасовано', 'Збій'].map((s) {
                          return DropdownMenuItem(value: s, child: Text(s));
                        }).toList(),
                        onChanged: (val) => setState(() => _status = val!),
                      ),
                    ),
                  ],
                ),
                
                // 4. Поля списання пластику
                if (_editableMaterialsLog.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.layers_outlined, size: 18, color: Colors.blueGrey),
                      SizedBox(width: 6),
                      Text(
                        'Редагування витрати пластику:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  ..._editableMaterialsLog.asMap().entries.map((entry) {
                    final int logIndex = entry.key;
                    final Map<String, dynamic> logItem = entry.value;
                    
                    final int slotIdx = logItem['slotIndex'] ?? 1;
                    final String currentMatId = logItem['materialId'] ?? '';
                    final double currentWeight = (logItem['spentWeight'] as num?)?.toDouble() ?? 0.0;

                    String spoolDisplayName = 'Котушка не обрана';
                    
                    if (currentMatId.isNotEmpty) {
                      final matchedMaterial = widget.allMaterials.any((m) => m.id == currentMatId)
                          ? widget.allMaterials.firstWhere((m) => m.id == currentMatId)
                          : null;

                      if (matchedMaterial != null) {
                        // ЗАЛІЗОБЕТОННИЙ ФІКС НУМЕРАЦІЇ:
                        // Знаходимо всі котушки ТАКУ Ж ГРУПИ у вихідному масиві allMaterials
                        final sameGroupMaterials = widget.allMaterials.where((m) =>
                          m.manufacturer == matchedMaterial.manufacturer &&
                          m.type == matchedMaterial.type &&
                          m.color == matchedMaterial.color
                        ).toList();
                        
                        // Порядковий індекс шукаємо строго всередині цієї ж відфільтрованої групи
                        final groupIndex = sameGroupMaterials.indexWhere((m) => m.id == currentMatId);
                        final displayNum = groupIndex != -1 ? groupIndex + 1 : 1;

                        spoolDisplayName = '${matchedMaterial.manufacturer} ${matchedMaterial.type} — Котушка №$displayNum';
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Слот #$slotIdx',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // Кнопка-плашка виклику твоєї сторінки заправки котушок
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () => _selectMaterialForSlot(logIndex),
                                    borderRadius: BorderRadius.circular(8),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Використана котушка',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              spoolDisplayName,
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Вага
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    initialValue: currentWeight.toStringAsFixed(1),
                                    decoration: const InputDecoration(
                                      labelText: 'Вага',
                                      suffixText: 'г',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: (v) => (v == null || double.tryParse(v) == null) ? 'Помилка' : null,
                                    onChanged: (v) {
                                      final parsedW = double.tryParse(v) ?? 0.0;
                                      _editableMaterialsLog[logIndex]['spentWeight'] = parsedW;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
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
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            
            final int h = int.tryParse(_hoursController.text.trim()) ?? 0;
            final int m = int.tryParse(_minutesController.text.trim()) ?? 0;
            
            double totalNewWeight = 0.0;
            for (var log in _editableMaterialsLog) {
              totalNewWeight += log['spentWeight'] ?? 0.0;
            }

            Navigator.pop(context, {
              'modelName': _modelNameController.text.trim(),
              'status': _status,
              'startTime': _selectedDateTime,
              'duration': (h * 3600) + (m * 60),
              'spentWeight': totalNewWeight, 
              'usedMaterialsLogJson': jsonEncode(_editableMaterialsLog), 
            });
          },
          child: const Text('Зберегти зміни'),
        )
      ],
    );
  }
}