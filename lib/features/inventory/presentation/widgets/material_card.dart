import 'package:flutter/material.dart';
import 'package:filamentary/features/inventory/domain/models/filament_material.dart'; // КРИТИЧНИЙ ІМПОРТ: чиста бізнес-модель

class MaterialGridCard extends StatelessWidget {
  final List<FilamentMaterial> items; // ФІКС: Працюємо виключно з FilamentMaterial
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
      elevation: 2, // Трохи зменшили тінь для компактного вигляду
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Зменшили радіус з 16 до 12
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.blueGrey.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // ЗМЕНШЕНО: Падінг з 16 до 12 робить картку значно компактнішою
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. БЛОК ЗОБРАЖЕННЯ
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.0, 
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8), // Зменшено з 12 до 8
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high, 
                              errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 36, color: Colors.grey),
                            )
                          : const Center(
                              child: Icon(Icons.layers, size: 48, color: Colors.blueGrey), // Зменшено розмір іконки плейсхолдера
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8), // Зменшено відступ з 12 до 8
              
              // 2. ІНФОРМАЦІЙНИЙ БЛОК (Пропорційно зменшені шрифти)
              Text(
                '${firstItem.manufacturer} ${firstItem.type}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), // Зменшено з 16 до 14
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${firstItem.color} (${firstItem.diameter})',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12), // Зменшено з 14 до 12
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6), // Зменшено з 8 до 6
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'К-сть: ${items.length} шт',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey), // Зменшено з 12 до 11
                  ),
                  Text(
                    '${totalRemaining.toStringAsFixed(0)}г залишок',
                    style: TextStyle(
                      fontSize: 11, // Зменшено з 12 до 11
                      fontWeight: FontWeight.w600,
                      color: progress < 0.2 ? Colors.red : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4), // Зменшено з 6 до 4
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4, // ЗМЕНШЕНО: Товщина лінії прогресу з 6 до 4 для витонченості
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