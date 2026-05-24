import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../inventory_bloc.dart';

class AddMaterialSheet extends StatefulWidget {
  final BuildContext blocContext;
  const AddMaterialSheet({super.key, required this.blocContext});

  @override
  State<AddMaterialSheet> createState() => _AddMaterialSheetState();
}

class _AddMaterialSheetState extends State<AddMaterialSheet> {
  final _formKey = GlobalKey<FormState>();
  String _manufacturer = '';
  String _selectedType = 'PLA';
  String _color = '';
  String _diameter = '1.75mm';
  double _weight = 1000.0;
  String _imageUrl = '';

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
              const Text('Картка нового матеріалу', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Виробник', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Введіть виробника' : null,
                onSaved: (v) => _manufacturer = v!.trim(),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Тип матеріалу', border: OutlineInputBorder()),
                items: ['PLA', 'PETG', 'TPU'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (v) => _selectedType = v!,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Колір', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Введіть колір' : null,
                      onSaved: (v) => _color = v!.trim(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: _diameter,
                      decoration: const InputDecoration(labelText: 'Діаметр', border: OutlineInputBorder()),
                      items: ['1.75mm', '2.85mm'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) => _diameter = v!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Посилання на зображення (URL)', border: OutlineInputBorder()),
                keyboardType: TextInputType.url,
                onSaved: (v) => _imageUrl = v?.trim() ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Початкова вага матеріалу (г)', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                initialValue: '1000',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Введіть вагу';
                  if (!RegExp(r'^[0-9]*\.?[0-9]+$').hasMatch(v)) return 'Лише числа через крапку';
                  return null;
                },
                onSaved: (v) => _weight = double.parse(v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blueGrey.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    
                    widget.blocContext.read<InventoryBloc>().add(AddMaterialEvent(
                      manufacturer: _manufacturer,
                      type: _selectedType,
                      color: _color,
                      diameter: _diameter,
                      imageUrl: _imageUrl,
                      weight: _weight,
                    ));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Зберегти в інвентар', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}