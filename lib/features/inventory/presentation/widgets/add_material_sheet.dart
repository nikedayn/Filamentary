import 'package:flutter/material.dart';
import 'package:filamentary/features/inventory/presentation/inventory_bloc.dart';

class AddMaterialSheet extends StatefulWidget {
  final InventoryBloc inventoryBloc;

  const AddMaterialSheet({super.key, required this.inventoryBloc});

  @override
  State<AddMaterialSheet> createState() => _AddMaterialSheetState();
}

// ФІКС НАЗВИ КЛАСУ СТАНУ (мав друкарську помилку _EditMaterialSheetState)
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
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Додати новий матеріал', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _manufacturerController,
                decoration: const InputDecoration(labelText: 'Виробник', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Введіть виробника' : null,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Колір (назва або HEX)', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Введіть колір' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _typeController.text,
                      decoration: const InputDecoration(labelText: 'Тип', border: OutlineInputBorder()),
                      items: ['PLA', 'PETG', 'TPU', 'ABS']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => _typeController.text = v!,
                    ),
                  ),
                  const SizedBox(width: 12),
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
              const SizedBox(height: 12),

              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Початкова вага котушки (г)', border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Введіть вагу';
                  if (double.tryParse(v) == null) return 'Лише числа';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // ЗАЛІЗОБЕТОННИЙ ФІКС: Використовуємо правильний параметр initialWeight замість застарілого weight
                    widget.inventoryBloc.add(
                      AddMaterialEvent(
                        manufacturer: _manufacturerController.text.trim(),
                        type: _typeController.text,
                        color: _colorController.text.trim(),
                        diameter: _diameterController.text,
                        initialWeight: double.parse(_weightController.text), // Тут була помилка!
                        imageUrl: null,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Зберегти на склад', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}