import 'package:flutter/material.dart';
import 'package:filamentary/core/database/database.dart' as db;
import 'package:filamentary/core/di/injection.dart';

class MaterialSelectDialog extends StatelessWidget {
  // НОВЕ: Опціональний вхідний список для синхронізації нумерації між екранами
  final List<db.Material>? customMaterials;

  const MaterialSelectDialog({
    super.key,
    this.customMaterials,
  });

  @override
  Widget build(BuildContext context) {
    final database = getIt<db.AppDatabase>();

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.inventory_2_outlined, color: Colors.blueGrey),
          SizedBox(width: 10),
          Text('Вибір котушки для заправки'),
        ],
      ),
      content: SizedBox(
        width: 450,
        height: 500,
        // ФІКС: Якщо дані прокинуті ззовні — будуємо список миттєво, інакше — читаємо реактивний стрім
        child: customMaterials != null
            ? _buildMaterialsList(context, customMaterials!)
            : StreamBuilder<List<db.Material>>(
                stream: database.watchActiveMaterials(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildMaterialsList(context, snapshot.data ?? []);
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ''), 
          child: const Text('Розвантажити слот', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Скасувати'),
        ),
      ],
    );
  }

  // ЧИСТИЙ МЕТОД: Будує відфільтровану та згруповану розмітку списку котушок
  Widget _buildMaterialsList(BuildContext context, List<db.Material> materials) {
    if (materials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.layers_clear_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'У вашому інвентарі немає\nактивних котушок пластику.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // АЛГОРИТМ ГРУПУВАННЯ ТА НУМЕРАЦІЇ (Єдиний для всього додатка)
    final Map<String, List<db.Material>> groupedMaterials = {};
    
    for (final m in materials) {
      final key = '${m.manufacturer}_${m.type}_${m.color}';
      groupedMaterials.putIfAbsent(key, () => []).add(m);
    }

    final groupKeys = groupedMaterials.keys.toList();

    return ListView.builder(
      itemCount: groupKeys.length,
      itemBuilder: (context, groupIdx) {
        final key = groupKeys[groupIdx];
        final groupItems = groupedMaterials[key]!;
        final sample = groupItems.first; 

        return ExpansionTile(
          initiallyExpanded: true, 
          leading: Icon(
            Icons.layers_outlined,
            color: _getMaterialColor(sample.color),
            size: 28,
          ),
          title: Text(
            '${sample.manufacturer} ${sample.type}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text('Колір: ${sample.color} • ${sample.diameter} (${groupItems.length} шт.)'),
          children: groupItems.asMap().entries.map((entry) {
            final int indexInsideGroup = entry.key;
            final db.Material item = entry.value;
            final double currentWeight = item.initialWeight - item.usedWeight;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListTile(
                dense: true,
                iconColor: Colors.blueGrey,
                leading: const Icon(Icons.blur_circular_outlined, size: 20),
                title: Text(
                  'Котушка №${indexInsideGroup + 1}', // Гарантована послідовна нумерація
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text('ID: ${item.id.substring(0, 8)}...'),
                trailing: Text(
                  '${currentWeight.toStringAsFixed(0)}г',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: currentWeight < 150 ? Colors.red.shade700 : Colors.indigo,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context, item.id);
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Color _getMaterialColor(String colorName) {
    final lower = colorName.toLowerCase();
    if (lower.contains('red') || lower.contains('червон')) return Colors.red;
    if (lower.contains('blue') || lower.contains('син')) return Colors.blue;
    if (lower.contains('green') || lower.contains('зелен')) return Colors.green;
    if (lower.contains('black') || lower.contains('чорн')) return Colors.black;
    if (lower.contains('white') || lower.contains('біл')) return Colors.grey.shade400;
    if (lower.contains('orange') || lower.contains('помаранч')) return Colors.orange;
    if (lower.contains('yellow') || lower.contains('жовт')) return Colors.yellow.shade700;
    return Colors.blueGrey;
  }
}