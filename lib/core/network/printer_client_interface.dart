/// Уніфіковані стани принтера відповідно до ТЗ
enum PrinterState { printing, paused, standby, error, offline }

/// Чиста бізнес-модель телеметрії, яка замінює хаотичні Map<String, dynamic>
class PrinterTelemetry {
  final bool isOnline;
  final PrinterState state;
  final String filename;
  final double extruderTemp;
  final double extruderTarget;
  final double bedTemp;
  final double bedTarget;
  final double progress;

  const PrinterTelemetry({
    required this.isOnline,
    required this.state,
    required this.filename,
    required this.extruderTemp,
    required this.extruderTarget,
    required this.bedTemp,
    required this.bedTarget,
    required this.progress,
  });

  /// Стан за замовчуванням, якщо принтер вимкнений або недоступний
  factory PrinterTelemetry.offline() {
    return const PrinterTelemetry(
      isOnline: false,
      state: PrinterState.offline,
      filename: '',
      extruderTemp: 0.0,
      extruderTarget: 0.0,
      bedTemp: 0.0,
      bedTarget: 0.0,
      progress: 0.0,
    );
  }
}

/// Спільний архітектурний контракт для всіх майбутніх інтеграцій принтерів
abstract class PrinterClient {
  Future<PrinterTelemetry> getStatus(String ip, int port, String? apiKey);
}