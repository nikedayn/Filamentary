import 'package:injectable/injectable.dart';

@lazySingleton
class DeepLinkHandler {
  // Метод, який приймає сирий рядок з QR-коду або системи
  void handleUri(String rawUri) {
    try {
      final uri = Uri.parse(rawUri);
      
      // Перевіряємо, чи це наша схема
      if (uri.scheme == 'filamentary') {
        _routeDeepLink(uri);
      }
    } catch (e) {
      // Тут можна задіяти твій AppLogger, якщо буде потреба
    }
  }

  void _routeDeepLink(Uri uri) {
    // uri.pathSegments для 'filamentary://spool/123-456' поверне ['spool', '123-456']
    if (uri.pathSegments.length >= 2) {
      final target = uri.pathSegments[0]; // 'spool'
      final id = uri.pathSegments[1];     // UUID котушки

      if (target == 'spool') {
        _navigateToSpoolDetails(id);
      }
    }
  }

  void _navigateToSpoolDetails(String spoolId) {
    // TODO: Тут ми підключимо твій Navigator або BLoC, 
    // щоб відкрити екран деталей котушки із завантаженням її стану з Drift.
    print('Переходимо на екран котушки з ID: $spoolId');
  }
}