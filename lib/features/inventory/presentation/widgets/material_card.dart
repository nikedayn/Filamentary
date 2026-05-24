import 'package:flutter/material.dart';
import 'package:filamentary/core/database/database.dart' as db;

class MaterialGridCard extends StatelessWidget {
  final List<db.Material> items;
  final VoidCallback onTap; // Викликається при кліку на картку для відкриття деталей

  const MaterialGridCard({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double totalInitial = 0;
    double totalUsed = 0;
    for (var item in items) {
      totalInitial += item.initialWeight;
      totalUsed += item.usedWeight;
    }
    final double totalRemaining = totalInitial - totalUsed;
    final double progress = (totalRemaining / totalInitial).clamp(0.0, 1.0);

    final firstItem = items.first;
    final String? imageUrl = firstItem.imageUrl;

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        // Робимо колір сплеску при наведенні м'яким, без грубих білих підкладок
        hoverColor: Colors.blueGrey.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Блок зображення з чистою прозорістю (Рішення проблеми №3)
              Expanded(
                child: Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent, // Жорстко прибираємо білі фони
                    ),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.contain, // Щоб котушка зберігала пропорції
                            // Усуваємо артефакти рендерингу прозорості у Flutter
                            filterQuality: FilterQuality.high, 
                            errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                          )
                        : const Icon(Icons.layers, size: 64, color: Colors.blueGrey),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Головний рядок: Назва Тип | Колір
              Text(
                '${firstItem.manufacturer} ${firstItem.type}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${firstItem.color} (${firstItem.diameter})',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'К-сть: ${items.length} шт',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  Text(
                    '${totalRemaining.toStringAsFixed(0)}г залишок',
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.w600,
                      color: progress < 0.2 ? Colors.red : Colors.black87
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
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