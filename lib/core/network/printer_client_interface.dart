import 'package:equatable/equatable.dart';

/// Уніфіковані стани принтера відповідно до ТЗ
enum PrinterState { printing, paused, standby, error, offline }

/// Чиста бізнес-модель телеметрії, яка замінює хаотичні Map<String, dynamic>
class PrinterTelemetry extends Equatable {
  final bool isOnline;
  final PrinterState state;
  final String filename;
  final double extruderTemp;
  final double extruderTarget;
  final double bedTemp;
  final double bedTarget;
  final double progress;
  final String? errorMessage; // 👈 ДОДАНО: Поле для діагностики помилок мережі

  const PrinterTelemetry({
    required this.isOnline,
    required this.state,
    this.filename = '',         // 👈 РОБИМО ОПЦІОНАЛЬНИМ З ДЕФОЛТОМ
    this.extruderTemp = 0.0,    // 👈 РОБИМО ОПЦІОНАЛЬНИМ З ДЕФОЛТОМ
    this.extruderTarget = 0.0,  // 👈 РОБИМО ОПЦІОНАЛЬНИМ З ДЕФОЛТОМ
    this.bedTemp = 0.0,         // 👈 РОБИМО ОПЦІОНАЛЬНИМ З ДЕФОЛТОМ
    this.bedTarget = 0.0,       // 👈 РОБИМО ОПЦІОНАЛЬНИМ З ДЕФОЛТОМ
    this.progress = 0.0,        // 👈 РОБИМО ОПЦІОНАЛЬНИМ З ДЕФОЛТОМ
    this.errorMessage,          // 👈 ОПЦІОНАЛЬНЕ ПОЛЕ ПOМИЛКИ
  });

  /// Стан за замовчуванням, якщо принтер вимкнений або недоступний
  factory PrinterTelemetry.offline([String? message]) {
    return PrinterTelemetry(
      isOnline: false,
      state: PrinterState.offline,
      filename: '',
      extruderTemp: 0,
      extruderTarget: 0,
      bedTemp: 0,
      bedTarget: 0,
      progress: 0,
      errorMessage: message, // 👈 ПЕРЕДАЄМО ПОВІДОМЛЕННЯ В КАРТКУ ПОМИЛКИ
    );
  }

  @override
  List<Object?> get props => [
        isOnline,
        state,
        filename,
        extruderTemp,
        extruderTarget,
        bedTemp,
        bedTarget,
        progress,
        errorMessage, // 👈 ДОДАНО ДЛЯ ПРАВИЛЬНОГО ПОРІВНЯННЯ СТАНІВ В BLOC
      ];
}

/// Спільний архітектурний контракт для всіх майбутніх інтеграцій принтерів
abstract class PrinterClient {
  Future<PrinterTelemetry> getStatus(String ip, int port, String? apiKey);
}