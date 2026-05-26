import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'printer_client_interface.dart';

@lazySingleton
class MoonrakerClient implements PrinterClient {
  // Кожен клієнт має власні залізобетонні таймаути для запобігання фризів UI
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
  ));

  @override
  Future<PrinterTelemetry> getStatus(String ip, int port, String? apiKey) async {
    final String url = 'http://$ip:$port/printer/objects/query';
    
    final Map<String, String> headers = {};
    if (apiKey != null && apiKey.isNotEmpty) {
      headers['X-Api-Key'] = apiKey;
    }

    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'gcode_move': '',
          'toolhead': '',
          'extruder': 'temperature,target',
          'heater_bed': 'temperature,target',
          'print_stats': 'filename,total_duration,print_duration,filament_used,state',
        },
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['result']['status'];
        final String rawState = data['print_stats']['state'] ?? 'standby';

        return PrinterTelemetry(
          isOnline: true,
          state: _parseState(rawState),
          filename: data['print_stats']['filename'] ?? '',
          extruderTemp: (data['extruder']['temperature'] as num?)?.toDouble() ?? 0.0,
          extruderTarget: (data['extruder']['target'] as num?)?.toDouble() ?? 0.0,
          bedTemp: (data['heater_bed']['temperature'] as num?)?.toDouble() ?? 0.0,
          bedTarget: (data['heater_bed']['target'] as num?)?.toDouble() ?? 0.0,
          progress: data['print_stats']['print_duration'] > 0 
              ? ((data['print_stats']['print_duration'] / data['print_stats']['total_duration']) * 100)
              : 0.0,
        );
      }
    } catch (e) {
      // Якщо принтер вимкнений з мережі — миттєво віддаємо offline-об'єкт
      return PrinterTelemetry.offline();
    }
    
    return PrinterTelemetry.offline();
  }

  PrinterState _parseState(String raw) {
    switch (raw.toLowerCase()) {
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