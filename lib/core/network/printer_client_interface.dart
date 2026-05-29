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
  
  // Додаткові службові поля для автоматичного списання інвентаря (п. 3.1 ТЗ)
  final double filamentWeightTotal; // Вага пластику, що потрібна на модель
  final int totalPrintTime;         // Поточна тривалість друку в секундах
  final String errorMessage;        // Відображення текстового опису помилок сокетів/таймаутів

  const PrinterTelemetry({
    required this.isOnline,
    required this.state,
    required this.filename,
    required this.extruderTemp,
    required this.extruderTarget,
    required this.bedTemp,
    required this.bedTarget,
    required this.progress,
    this.filamentWeightTotal = 0.0,
    this.totalPrintTime = 0,
    this.errorMessage = '',
  });

  /// Стан за замовчуванням, якщо принтер вимкнений або недоступний
  factory PrinterTelemetry.offline([String message = '']) {
    return PrinterTelemetry(
      isOnline: false,
      state: PrinterState.offline,
      filename: '',
      extruderTemp: 0.0,
      extruderTarget: 0.0,
      bedTemp: 0.0,
      bedTarget: 0.0,
      progress: 0.0,
      errorMessage: message,
    );
  }
}

/// Спільний архітектурний контракт для всіх майбутніх інтеграцій принтерів
abstract class PrinterClient {
  Future<PrinterTelemetry> getStatus(String ip, int port, String? apiKey);
}