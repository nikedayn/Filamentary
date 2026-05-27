import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:filamentary/core/di/injection.dart';
import 'package:filamentary/features/inventory/domain/models/filament_material.dart';
import 'package:filamentary/core/navigation/adaptive_scaffold.dart'; // Інтеграція адаптивного кросплатформеного шаблону
import 'inventory_bloc.dart';
import 'widgets/material_card.dart';
import 'widgets/add_material_sheet.dart';
import 'widgets/group_details_dialog.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InventoryBloc>()..add(WatchInventory()),
      child: Builder(
        builder: (innerContext) {
          return AdaptiveScaffold(
            currentRoute: 'inventory',
            title: 'Інвентар матеріалів',
            body: Scaffold(
              // Внутрішній Scaffold залишається без власного AppBar та Drawer,
              // оскільки верхню панель та бічне меню тепер контролює AdaptiveScaffold
              body: BlocBuilder<InventoryBloc, InventoryState>(
                builder: (context, state) {
                  if (state is InventoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is InventoryFailure) {
                    return Center(child: Text('Помилка: ${state.error}'));
                  }

                  if (state is InventoryLoaded) {
                    final materials = state.materials;

                    if (materials.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.layers_clear_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Матеріалів не знайдено',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Групування котушок за характеристиками для Clean Architecture
                    final Map<String, List<FilamentMaterial>> groupedMaterials = {};
                    for (var mat in materials) {
                      final String groupKey =
                          '${mat.manufacturer}_${mat.type}_${mat.color}_${mat.diameter}';
                      if (!groupedMaterials.containsKey(groupKey)) {
                        groupedMaterials[groupKey] = [];
                      }
                      groupedMaterials[groupKey]!.add(mat);
                    }

                    final groupKeys = groupedMaterials.keys.toList();

                    // Використовуємо LayoutBuilder для гнучкого керування сіткою
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          // АДАПТИВНИЙ ФІКС: Замість захардкоджених 5 колонок використовуємо MaxCrossAxisExtent.
                          // Це дозволяє карткам автоматично перегруповуватися (наприклад, 2-3 колонки на смартфоні,
                          // та 5-8 колонок на великому моніторі Windows) без переповнення та порожніх зон.
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220, // Оптимальна ширина картки матеріалу
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.76, // Пропорція картки згідно з ТЗ
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
                                    bloc: innerContext.read<InventoryBloc>(),
                                    onSpendWeight: (id, value) {
                                      innerContext.read<InventoryBloc>().add(
                                            DeleteMaterialEvent(id),
                                          );
                                    },
                                    onDeleteMaterial: (id) {
                                      innerContext.read<InventoryBloc>().add(
                                            DeleteMaterialEvent(id),
                                          );
                                    },
                                  ),
                                );
                              },
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
                backgroundColor: Colors.blueGrey.shade700,
                foregroundColor: Colors.white,
                onPressed: () => _showAddMaterialForm(innerContext),
              ),
            ),
          );
        },
      ),
    );
  }

  // КРОСПЛАТФОРМЕНИЙ UX: Адаптивне відображення форми додавання
  void _showAddMaterialForm(BuildContext blocContext) {
    final double screenWidth = MediaQuery.of(blocContext).size.width;

    if (screenWidth >= 640) {
      // DESKTOP UX (Windows): Відображаємо як компактне діалогове вікно по центру,
      // щоб інтерфейс введення тексту не розтягувався потворніть на весь широкий монітор
      showDialog(
        context: blocContext,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
            child: AddMaterialSheet(inventoryBloc: blocContext.read<InventoryBloc>()),
          ),
        ),
      );
    } else {
      // MOBILE UX (Android): Залишаємо нативну та зручну для пальця нижню шторку (Bottom Sheet)
      showModalBottomSheet(
        context: blocContext,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) =>
            AddMaterialSheet(inventoryBloc: blocContext.read<InventoryBloc>()),
      );
    }
  }
}