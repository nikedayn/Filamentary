import 'package:flutter/material.dart';
import 'package:filamentary/core/database/database.dart' as db;
import 'package:filamentary/core/di/injection.dart';

class MaterialSelectDialog extends StatelessWidget {
  final List<db.Material>? customMaterials;

  const MaterialSelectDialog({
    super.key,
    this.customMaterials,
  });

  @override
  Widget build(BuildContext context) {
    final database = getIt<db.AppDatabase>();
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    // Головний вміст форми (заголовок + список + кнопки)
    Widget buildBody(BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isMobile)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            
            // 1. ЗАГОЛОВОК З ЗАХИСТОМ ВІД OVERFLOW
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, color: Colors.blueGrey, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Вибір котушки для заправки',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. ДИНАМІЧНИЙ СПИСОК КОТУШОК
            Flexible(
              child: SizedBox(
                height: isMobile ? 400 : 500, // Гнучка висота під тип пристрою
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
            ),
            const SizedBox(height: 16),

            // 3. КНОПКИ ДІЇ У НИЖНІЙ ЧАСТИНІ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context, ''), 
                  icon: const Icon(Icons.layers_clear_outlined, size: 16),
                  label: const Text('Розвантажити'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: Text('Скасувати', style: TextStyle(color: Colors.grey.shade700)),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // РЕНДЕР ЗАЛЕЖНО ВІД ЕКРАНА СМАРТФОНА/ПК
    if (isMobile) {
      return buildBody(context);
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: buildBody(context),
      ),
    );
  }

  // МЕТОД ПУЛУ КОТУШОК (Логіку збережено повністю, оптимізовано відступи)
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

    final Map<String, List<db.Material>> groupedMaterials = {};
    for (final m in materials) {
      final key = '${m.manufacturer}_${m.type}_${m.color}';
      groupedMaterials.putIfAbsent(key, () => []).add(m);
    }

    final groupKeys = groupedMaterials.keys.toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: groupKeys.length,
      itemBuilder: (context, groupIdx) {
        final key = groupKeys[groupIdx];
        final groupItems = groupedMaterials[key]!;
        final sample = groupItems.first; 

        return ExpansionTile(
          initiallyExpanded: true, 
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.layers_outlined,
            color: _getMaterialColor(sample.color),
            size: 26,
          ),
          title: Text(
            '${sample.manufacturer} ${sample.type}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            'Колір: ${sample.color} • ${sample.diameter} (${groupItems.length} шт.)',
            style: const TextStyle(fontSize: 12),
          ),
          children: groupItems.asMap().entries.map((entry) {
            final int indexInsideGroup = entry.key;
            final db.Material item = entry.value;
            final double currentWeight = item.initialWeight - item.usedWeight;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withAlpha(8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                iconColor: Colors.blueGrey,
                leading: const Icon(Icons.blur_circular_outlined, size: 18),
                title: Text(
                  'Котушка №${indexInsideGroup + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                subtitle: Text('ID: ${item.id.substring(0, 8)}...', style: const TextStyle(fontSize: 11)),
                trailing: Text(
                  '${currentWeight.toStringAsFixed(0)}г',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: currentWeight < 150 ? Colors.red.shade700 : Colors.indigo,
                  ),
                ),
                onTap: () => Navigator.pop(context, item.id),
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