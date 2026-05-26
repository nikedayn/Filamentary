import 'package:filamentary/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:filamentary/features/inventory/domain/models/filament_material.dart'; // Чиста бізнес-модель даних
import 'package:filamentary/main.dart'; // Глобальний ключ rootScaffoldMessengerKey
import '../inventory_bloc.dart';
import 'package:filamentary/core/services/label_print_service.dart';

class GroupDetailsDialog extends StatelessWidget {
  final List<FilamentMaterial> items; 
  final Function(String id, double value) onSpendWeight;
  final Function(String id) onDeleteMaterial;
  final InventoryBloc bloc;

  const GroupDetailsDialog({
    super.key,
    required this.items,
    required this.onSpendWeight,
    required this.onDeleteMaterial,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    final firstItem = items.first;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Expanded(
            child: Text(
              '${firstItem.manufacturer} ${firstItem.type} | ${firstItem.color}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 26),
            tooltip: 'Поповнити запас (додати котушку)',
            onPressed: () {
              Navigator.pop(context); 
              _showAddUnitDialog(context, firstItem, bloc); 
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 500, 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            // ЗАЛІЗОБЕТОННИЙ ФІКС: Повернули ConstrainedBox на місце
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, idx) {
                  final material = items[idx];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text('Котушка №${idx + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Залишок: ${material.currentWeight.toStringAsFixed(1)} г / ${material.initialWeight.toStringAsFixed(0)} г'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                            tooltip: 'Списати вагу',
                            onPressed: () {
                              Navigator.pop(context); 
                              _showSpendWeightDialog(context, material, bloc);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.print, color: Colors.indigo),
                            tooltip: 'Надрукувати етикетку',
                            onPressed: () {
                              getIt<LabelPrintService>().printSpoolLabel(
                                material.id,
                                material.manufacturer,
                                material.type,
                                material.color,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            tooltip: 'Видалити котушку',
                            onPressed: () {
                              onDeleteMaterial(material.id);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUnitDialog(BuildContext context, FilamentMaterial patternMaterial, InventoryBloc bloc) {
    final TextEditingController weightController = TextEditingController(text: '1000');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Поповнення матеріалу'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Додати нову котушку в групу:\n${patternMaterial.manufacturer} ${patternMaterial.type}'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: weightController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Початкова вага котушки (г)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Введіть значення';
                    if (!RegExp(r'^[0-9]*\.?[0-9]+$').hasMatch(v)) return 'Лише числа через крапку';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Скасувати')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final double initialWeightValue = double.parse(weightController.text);
                  
                  bloc.add(AddMaterialEvent(
                    manufacturer: patternMaterial.manufacturer,
                    type: patternMaterial.type,
                    color: patternMaterial.color,
                    diameter: patternMaterial.diameter,
                    imageUrl: patternMaterial.imageUrl,
                    initialWeight: initialWeightValue,
                  ));

                  Navigator.pop(ctx);
                  
                  rootScaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(content: Text('Нову котушку на $initialWeightValue г успішно додано')),
                  );
                }
              },
              child: const Text('Додати', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSpendWeightDialog(BuildContext context, FilamentMaterial material, InventoryBloc bloc) {
    final TextEditingController weightController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Списання матеріалу'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Введіть точну вагу списання в грамах:'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: weightController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Вага списання (г)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Введіть значення';
                    if (!RegExp(r'^[0-9]*\.?[0-9]+$').hasMatch(v)) return 'Лише числа через крапку';
                    final double val = double.parse(v);
                    if (val > material.currentWeight) return 'Не можна списати більше, ніж є';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Скасувати')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final double spendValue = double.parse(weightController.text);
                  onSpendWeight(material.id, spendValue);
                  Navigator.pop(ctx);
                  
                  rootScaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(content: Text('Успішно списано $spendValue г матеріалу')),
                  );
                }
              },
              child: const Text('Списати', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}