import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:filamentary/features/inventory/domain/models/filament_material.dart'; // Чиста модель
import 'package:filamentary/features/inventory/presentation/inventory_bloc.dart';

class EditGroupSheet extends StatefulWidget {
  final List<FilamentMaterial> groupMaterials;

  const EditGroupSheet({
    super.key,
    required this.groupMaterials,
  });

  @override
  State<EditGroupSheet> createState() => _EditGroupSheetState();
}

class _EditGroupSheetState extends State<EditGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _manufacturerController;
  late final TextEditingController _colorController;
  
  String _selectedType = 'PLA';
  String _diameter = '1.75mm';

  @override
  void initState() {
    super.initState();
    final baseMaterial = widget.groupMaterials.first;
    
    _manufacturerController = TextEditingController(text: baseMaterial.manufacturer);
    _colorController = TextEditingController(text: baseMaterial.color);
    _selectedType = baseMaterial.type;
    _diameter = baseMaterial.diameter;
  }

  @override
  void dispose() {
    _manufacturerController.dispose();
    _colorController.dispose();
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
                'Редагування групи матеріалів', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _manufacturerController,
                decoration: const InputDecoration(labelText: 'Виробник', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Введіть виробника' : null,
              ),
              const SizedBox(height: 12),
              
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Тип матеріалу', border: OutlineInputBorder()),
                items: ['PLA', 'PETG', 'TPU', 'ABS']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(labelText: 'Колір', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Введіть колір' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: _diameter,
                      decoration: const InputDecoration(labelText: 'Діаметр', border: OutlineInputBorder()),
                      items: ['1.75mm', '2.85mm']
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (v) => setState(() => _diameter = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blueGrey.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // ЗАЛІЗОБЕТОННИЙ ФІКС: додаємо об'єкт події через метод .add(...)
                    context.read<InventoryBloc>().add(
                      UpdateGroupMaterialsEvent(
                        materialIds: widget.groupMaterials.map((e) => e.id).toList(),
                        manufacturer: _manufacturerController.text.trim(),
                        type: _selectedType,
                        color: _colorController.text.trim(),
                        diameter: _diameter,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Застосувати до групи', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}