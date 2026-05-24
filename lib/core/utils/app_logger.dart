import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,       // Скільки ліній виклику функцій показувати
      errorMethodCount: 8,  // Скільки ліній показувати, якщо це помилка
      lineLength: 120,      // Ширина лінії в консолі
      colors: true,         // Кольорове підсвічування логів
      printEmojis: true,    // Додавати емодзі (⚠️, ❌, ℹ️)
    ),
  );

  // Для звичайної інформації (наприклад: "Синхронізація успішна")
  static void i(String message) => _logger.i(message);

  // Для попереджень (наприклад: "Низький рівень пластику на котушці")
  static void w(String message) => _logger.w(message);

  // Для критичних помилок (наприклад: "Не вдалося записати транзакцію в БД")
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}