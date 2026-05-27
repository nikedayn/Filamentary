import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:filamentary/features/inventory/presentation/inventory_bloc.dart';

class AddMaterialSheet extends StatefulWidget {
  final InventoryBloc inventoryBloc;

  const AddMaterialSheet({super.key, required this.inventoryBloc});

  @override
  State<AddMaterialSheet> createState() => _AddMaterialSheetState();
}

class _AddMaterialSheetState extends State<AddMaterialSheet> {
  final _formKey = GlobalKey<FormState>();

  final _manufacturerController = TextEditingController();
  final _typeController = TextEditingController(text: 'PLA');
  final _colorController = TextEditingController();
  final _diameterController = TextEditingController(text: '1.75mm');
  final _weightController = TextEditingController(text: '1000');

  @override
  void dispose() {
    _manufacturerController.dispose();
    _colorController.dispose();
    _diameterController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 640;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: isDesktop ? 24 : 12,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Декоративний індикатор шторки (тільки для мобільного)
                if (!isDesktop) ...[
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      // ВИПРАВЛЕНО: Використовуємо .only(bottom: 16) замість .bottom(16)
                      margin: const EdgeInsets.only(bottom: 16), 
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Додати новий матеріал',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (isDesktop)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _manufacturerController,
                  decoration: const InputDecoration(
                    labelText: 'Виробник',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Введіть виробника' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _colorController,
                  decoration: const InputDecoration(
                    labelText: 'Колір (назва або HEX)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.color_lens_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Введіть колір' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _typeController.text,
                        decoration: const InputDecoration(labelText: 'Тип', border: OutlineInputBorder()),
                        items: ['PLA', 'PETG', 'TPU', 'ABS', 'ASA']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => _typeController.text = v!,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _diameterController.text,
                        decoration: const InputDecoration(labelText: 'Діаметр', border: OutlineInputBorder()),
                        items: ['1.75mm', '2.85mm']
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (v) => _diameterController.text = v!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  // Дозволяємо введення ком і крапок, але автоматично приводимо до спільного знаменника
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Початкова вага котушки (г)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.scale_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Введіть вагу';
                    // Перед перевіркою нормалізуємо рядок
                    final normalized = v.replaceAll(',', '.');
                    if (double.tryParse(normalized) == null) return 'Лише числа';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueGrey.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Заміна ком на крапки згідно з вимогами математичного ядра ТЗ
                      final cleanWeight = _weightController.text.replaceAll(',', '.');
                      
                      widget.inventoryBloc.add(
                        AddMaterialEvent(
                          manufacturer: _manufacturerController.text.trim(),
                          type: _typeController.text,
                          color: _colorController.text.trim(),
                          diameter: _diameterController.text,
                          initialWeight: double.parse(cleanWeight),
                          imageUrl: null,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  label: const Text('Зберегти на склад', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}