import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:filamentary/core/di/injection.dart';
import 'package:filamentary/core/database/database.dart' as db;
import 'inventory_bloc.dart';
import 'widgets/material_card.dart';
import 'widgets/add_material_sheet.dart';
import 'widgets/group_details_dialog.dart';
import 'package:filamentary/core/navigation/main_navigation_drawer.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InventoryBloc>()..add(WatchInventory()),
      child: Builder(
        builder: (innerContext) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Інвентар матеріалів', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.blueGrey.shade100,
              elevation: 2,
            ),
            drawer: const MainNavigationDrawer(currentRoute: 'inventory'), // <--- ДОДАЙТЕ ЦЕЙ РЯДОК
            body: BlocBuilder<InventoryBloc, InventoryState>(
              builder: (context, state) {
                if (state is InventoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is InventoryLoaded) {
                  final materials = state.materials;

                  if (materials.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.layers_clear_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('Матеріалів не знайдено', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                        ],
                      ),
                    );
                  }

                  // Групування за нативними параметрами
                  final Map<String, List<db.Material>> groupedMaterials = {};
                  for (var mat in materials) {
                    final String groupKey = '${mat.manufacturer}_${mat.type}_${mat.color}_${mat.diameter}';
                    if (!groupedMaterials.containsKey(groupKey)) {
                      groupedMaterials[groupKey] = [];
                    }
                    groupedMaterials[groupKey]!.add(mat);
                  }

                  final groupKeys = groupedMaterials.keys.toList();

                  // ПУНКТ №2: Перехід на професійну адаптивну сітку GridView
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 280, // Максимальна ширина однієї картки матеріалу
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.82, // Співвідношення сторін картки (висота трохи більша за ширину)
                    ),
                    itemCount: groupKeys.length,
                    itemBuilder: (context, index) {
                      final key = groupKeys[index];
                      final itemsInGroup = groupedMaterials[key]!;

                      return MaterialGridCard(
                        items: itemsInGroup,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => GroupDetailsDialog(
                              items: itemsInGroup,
                              bloc: innerContext.read<InventoryBloc>(), // <--- ПЕРЕДАЄМО ЖИВИЙ БЛОК З ЕКРАНУ СЮДИ
                              onSpendWeight: (id, value) {
                                innerContext.read<InventoryBloc>().add(SpendWeightEvent(id, value));
                              },
                              onDeleteMaterial: (id) {
                                innerContext.read<InventoryBloc>().add(DeleteMaterialEvent(id));
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                return const Center(child: Text('Щось пішло не так.'));
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Додати матеріал'),
              onPressed: () => _showAddBottomSheet(innerContext),
            ),
          );
        }
      ),
    );
  }

  void _showAddBottomSheet(BuildContext blocContext) {
    showModalBottomSheet(
      context: blocContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => AddMaterialSheet(blocContext: blocContext),
    );
  }
}