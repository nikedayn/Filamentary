import 'package:filamentary/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:filamentary/features/inventory/domain/models/filament_material.dart'; 
import 'package:filamentary/main.dart'; 
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
    
    double totalInitial = 0;
    double totalRemaining = 0;
    for (var item in items) {
      totalInitial += item.initialWeight;
      totalRemaining += item.currentWeight;
    }
    final double groupProgress = totalInitial > 0 ? totalRemaining / totalInitial : 0.0;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.only(top: 16, left: 20, right: 16, bottom: 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      actionsPadding: const EdgeInsets.only(bottom: 12, right: 16, top: 8),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${firstItem.manufacturer} ${firstItem.type}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  'Колір: ${firstItem.color} (${firstItem.diameter})',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 24),
            tooltip: 'Додати котушку в групу',
            onPressed: () => _showAddUnitDialog(context, firstItem, bloc), 
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 440, // Трохи зменшили ширину вікна, оскільки іконки тепер сховані
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: groupProgress,
              backgroundColor: Colors.grey.shade100,
              color: groupProgress < 0.2 ? Colors.red : Colors.blueGrey.shade600,
              minHeight: 4,
            ),
            const SizedBox(height: 12),
            
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, idx) {
                  final material = items[idx];

                  // Академічне форматування чисел з ТЗ (крапки замінено на коми)
                  final String currentWeight = material.currentWeight.toStringAsFixed(1).replaceAll('.', ',');
                  final String initialWeight = material.initialWeight.toStringAsFixed(0).replaceAll('.', ',');

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50.withAlpha(120),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blueGrey.shade100.withAlpha(150)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.blueGrey.shade700,
                          child: Text(
                            '${idx + 1}', 
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$currentWeight г залишок',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                              Text(
                                'Нова: $initialWeight г',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),

                        // ЗАЛІЗОБЕТОННИЙ UI/UX ФІКС: Усі кнопки сховані під три крапки
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.blueGrey, size: 20),
                          borderRadius: BorderRadius.circular(8),
                          elevation: 3,
                          tooltip: 'Операції з котушкою',
                          onSelected: (value) {
                            if (value == 'spend') {
                              _showSpendWeightDialog(context, material, bloc);
                            } else if (value == 'print') {
                              getIt<LabelPrintService>().printSpoolLabel(
                                material.id,
                                material.manufacturer,
                                material.type,
                                material.color,
                              );
                            } else if (value == 'delete') {
                              onDeleteMaterial(material.id);
                              Navigator.pop(context);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'spend',
                              child: Row(
                                children: [
                                  Icon(Icons.scale_outlined, color: Colors.orange, size: 18),
                                  SizedBox(width: 10),
                                  Text('Списати вагу', style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'print',
                              child: Row(
                                children: [
                                  Icon(Icons.print_outlined, color: Colors.indigo, size: 18),
                                  SizedBox(width: 10),
                                  Text('Надрукувати етикетку', style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(height: 1),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.red.shade400, size: 18),
                                  SizedBox(width: 10),
                                  Text(
                                    'Видалити котушку', 
                                    style: TextStyle(fontSize: 13, color: Colors.red.shade600)
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Поповнення матеріалу', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Додати нову котушку в групу:\n${patternMaterial.manufacturer} ${patternMaterial.type}', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 14),
                TextFormField(
                  controller: weightController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  decoration: const InputDecoration(
                    labelText: 'Початкова вага (г)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Введіть значення';
                    if (!RegExp(r'^[0-9]*[.,]?[0-9]+$').hasMatch(v)) return 'Лише числа';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Скасувати', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final cleanInput = weightController.text.replaceAll(',', '.');
                  final double initialWeightValue = double.parse(cleanInput);
                  
                  bloc.add(AddMaterialEvent(
                    manufacturer: patternMaterial.manufacturer,
                    type: patternMaterial.type,
                    color: patternMaterial.color,
                    diameter: patternMaterial.diameter,
                    imageUrl: patternMaterial.imageUrl,
                    initialWeight: initialWeightValue,
                  ));

                  Navigator.pop(ctx);
                  
                  final snackBarWeight = initialWeightValue.toStringAsFixed(0).replaceAll('.', ',');
                  rootScaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(
                      content: Text('Нову котушку на $snackBarWeight г успішно додано'),
                      backgroundColor: Colors.green.shade700,
                    ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Списання матеріалу', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Введіть вагу чистого списання пластику (г):', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: weightController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  decoration: const InputDecoration(
                    labelText: 'Вага списання (г)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Введіть значення';
                    if (!RegExp(r'^[0-9]*[.,]?[0-9]+$').hasMatch(v)) return 'Лише числа';
                    
                    final cleanInput = v.replaceAll(',', '.');
                    final double val = double.parse(cleanInput);
                    if (val > material.currentWeight) return 'Не можна списати більше, ніж є';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Скасувати', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final cleanInput = weightController.text.replaceAll(',', '.');
                  final double spendValue = double.parse(cleanInput);
                  
                  onSpendWeight(material.id, spendValue);
                  Navigator.pop(ctx);
                  
                  final snackBarSpend = spendValue.toStringAsFixed(1).replaceAll('.', ',');
                  rootScaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(
                      content: Text('Успішно списано $snackBarSpend г матеріалу'),
                      backgroundColor: Colors.blueGrey.shade600,
                    ),
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