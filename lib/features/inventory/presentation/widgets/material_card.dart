import 'package:flutter/material.dart';
import 'package:filamentary/features/inventory/domain/models/filament_material.dart';

class MaterialGridCard extends StatelessWidget {
  final List<FilamentMaterial> items;
  final VoidCallback onTap;

  const MaterialGridCard({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double totalInitial = 0;
    double totalRemaining = 0;

    for (var item in items) {
      totalInitial += item.initialWeight;
      totalRemaining += item.currentWeight;
    }

    final double progress = totalInitial > 0 ? (totalRemaining / totalInitial).clamp(0.0, 1.0) : 0.0;
    final firstItem = items.first;
    final String? imageUrl = firstItem.imageUrl;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.blueGrey.withAlpha(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0), // Оптимізовані відступи
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. БЛОК ЗОБРАЖЕННЯ (Тепер повністю адаптивний)
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withAlpha(10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.broken_image,
                                  size: 28,
                                  color: Colors.grey,
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.layers,
                                  size: 36,
                                  color: Colors.blueGrey,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // 2. ІНФОРМАЦІЙНИЙ БЛОК із захистом від Overflow
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '${firstItem.manufacturer} ${firstItem.type}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                '${firstItem.color} (${firstItem.diameter})',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Рядок К-сті та Ваги
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'К-сть: ${items.length} шт',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${totalRemaining.toStringAsFixed(0)}г зал.',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: progress < 0.2 ? Colors.red : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Лінійка прогресу
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3.5,
                  backgroundColor: Colors.grey.shade200,
                  color: progress < 0.2 ? Colors.red : Colors.blueGrey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}