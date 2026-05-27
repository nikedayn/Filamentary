import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'printer_client_interface.dart';

@Named("KlipperClient")
@lazySingleton
class KlipperClient implements PrinterClient {
  // Використовуємо Dio з ТЗ з надійними таймаутами для запобігання фризів UI
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 1),
    receiveTimeout: const Duration(seconds: 1),
  ));

  @override
  Future<PrinterTelemetry> getStatus(String ip, int port, String? apiKey) async {
    final String url = 'http://$ip:$port/printer/objects/query';
    
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (apiKey != null && apiKey.isNotEmpty) {
      headers['X-Api-Key'] = apiKey;
    }

    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'extruder': 'temperature,target',
          'heater_bed': 'temperature,target',
          'print_stats': 'filename,total_duration,print_duration,state',
          'virtual_sdcard': 'progress', // Беремо прогрес напряму з Moonraker (він там від 0.0 до 1.0)
        },
        options: Options(headers: headers),
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode != 200 || response.data?['result']?['status'] == null) {
        return PrinterTelemetry.offline();
      }

      final status = response.data['result']['status'];
      
      // 1. Парсимо температури з безпечним приведенням типів (ТЗ)
      final double extruderTemp = (status['extruder']?['temperature'] as num?)?.toDouble() ?? 0.0;
      final double extruderTarget = (status['extruder']?['target'] as num?)?.toDouble() ?? 0.0;
      final double bedTemp = (status['heater_bed']?['temperature'] as num?)?.toDouble() ?? 0.0;
      final double bedTarget = (status['heater_bed']?['target'] as num?)?.toDouble() ?? 0.0;

      // 2. Парсимо стан друку
      final String rawState = status['print_stats']?['state'] ?? 'standby';
      final PrinterState appState = _parseState(rawState);

      // 3. БЕЗПЕЧНИЙ РОЗРАХУНОК ПРОГРЕСУ (Захист від ділення на нуль та Infinity)
      double progress = 0.0;
      
      // Спершу пробуємо отримати точний готовий прогрес від Moonraker virtual_sdcard
      if (status['virtual_sdcard']?['progress'] != null) {
        progress = (status['virtual_sdcard']['progress'] as num).toDouble();
      } else {
        // Резервний математичний прорахунок за часом з жорсткою валідацією знаменника
        final totalDuration = (status['print_stats']?['total_duration'] as num?)?.toDouble() ?? 0.0;
        final printDuration = (status['print_stats']?['print_duration'] as num?)?.toDouble() ?? 0.0;
        
        if (totalDuration > 0 && printDuration > 0) {
          progress = printDuration / totalDuration;
        }
      }

      // Захисний механізм: прогрес у системі Filamentary має бути строго в межах від 0.0 до 1.0,
      // жодних NaN або Infinity не пройде у UI шар!
      if (progress.isNaN || progress.isInfinite) {
        progress = 0.0;
      } else {
        progress = progress.clamp(0.0, 1.0);
      }

      final String filename = status['print_stats']?['filename'] ?? '';

      return PrinterTelemetry(
        isOnline: true,
        state: appState,
        filename: filename,
        extruderTemp: extruderTemp,
        extruderTarget: extruderTarget,
        bedTemp: bedTemp,
        bedTarget: bedTarget,
        progress: progress, // Прогрес тепер залізобетонно безпечний
      );

    } catch (_) {
      // Будь-який таймаут або обрив сокетів повертає чистий офлайн об'єкт без падіння потоку
      return PrinterTelemetry.offline();
    }
  }

  PrinterState _parseState(String raw) {
    switch (raw.toLowerCase().trim()) {
      case 'printing':
        return PrinterState.printing;
      case 'paused':
        return PrinterState.paused;
      case 'error':
        return PrinterState.error;
      case 'standby':
      case 'ready':
        return PrinterState.standby;
      default:
        return PrinterState.standby;
    }
  }
}