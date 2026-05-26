import 'dart:convert';
import 'package:http/http.dart' as http;
import 'printer_client_interface.dart';

class KlipperClient implements PrinterClient {
  final http.Client _httpClient;

  KlipperClient({http.Client? client}) : _httpClient = client ?? http.Client();

  @override
  Future<PrinterTelemetry> getStatus(String ip, int port, String? apiKey) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (apiKey != null && apiKey.isNotEmpty) {
      headers['X-Api-Key'] = apiKey;
    }

    // Формуємо URL до ендпоінту Moonraker для отримання об'єктів принтера
    // Нам потрібні: температура екструдера, столу, стан друку та файл
    final url = Uri.parse(
      'http://$ip:$port/printer/objects/query?'
      'heater_bed&extruder&print_stats&virtual_sdcard'
    );

    try {
      final response = await _httpClient.get(url, headers: headers).timeout(
        const Duration(seconds: 2),
      );

      if (response.statusCode != 200) {
        return PrinterTelemetry.offline();
      }

      final data = jsonDecode(response.body);
      final status = data['result']?['status'];

      if (status == null) return PrinterTelemetry.offline();

      // 1. Парсимо температури
      final double extruderTemp = (status['extruder']?['temperature'] as num?)?.toDouble() ?? 0.0;
      final double extruderTarget = (status['extruder']?['target'] as num?)?.toDouble() ?? 0.0;
      final double bedTemp = (status['heater_bed']?['temperature'] as num?)?.toDouble() ?? 0.0;
      final double bedTarget = (status['heater_bed']?['target'] as num?)?.toDouble() ?? 0.0;

      // 2. Парсимо стан друку
      final String klipperState = status['print_stats']?['state'] ?? 'standby';
      PrinterState appState;
      switch (klipperState) {
        case 'printing':
          appState = PrinterState.printing;
          break;
        case 'paused':
          appState = PrinterState.paused;
          break;
        case 'error':
          appState = PrinterState.error;
          break;
        default:
          appState = PrinterState.standby;
      }

      // 3. Парсимо прогрес та назву файлу
      final double progress = (status['virtual_sdcard']?['progress'] as num?)?.toDouble() ?? 0.0;
      final String filename = status['print_stats']?['filename'] ?? '';

      return PrinterTelemetry(
        isOnline: true,
        state: appState,
        filename: filename,
        extruderTemp: extruderTemp,
        extruderTarget: extruderTarget,
        bedTemp: bedTemp,
        bedTarget: bedTarget,
        progress: progress,
      );
    } catch (_) {
      // Будь-який таймаут або помилка мережі повертає чистий оффлайн-стан
      return PrinterTelemetry.offline();
    }
  }
}