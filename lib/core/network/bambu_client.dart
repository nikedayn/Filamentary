import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'printer_client_interface.dart';

@lazySingleton
class BambuClient implements PrinterClient {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
  ));

  @override
  Future<PrinterTelemetry> getStatus(String ip, int port, String? apiKey) async {
    // Базовий REST-запит до локального API або MQTT-проксі Bambu
    final String url = 'http://$ip:$port/api/v1/status'; 
    
    final Map<String, String> headers = {};
    if (apiKey != null && apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }

    try {
      final response = await _dio.get(url, options: Options(headers: headers));
      if (response.statusCode == 200) {
        final data = response.data;
        final String rawState = data['print_status'] ?? 'idle';

        return PrinterTelemetry(
          isOnline: true,
          state: _parseState(rawState),
          filename: data['gcode_file'] ?? '',
          extruderTemp: (data['nozzle_temper'] as num?)?.toDouble() ?? 0.0,
          extruderTarget: (data['nozzle_target_temper'] as num?)?.toDouble() ?? 0.0,
          bedTemp: (data['bed_temper'] as num?)?.toDouble() ?? 0.0,
          bedTarget: (data['bed_target_temper'] as num?)?.toDouble() ?? 0.0,
          progress: (data['percent'] as num?)?.toDouble() ?? 0.0,
        );
      }
    } catch (e) {
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
      case 'failed':
        return PrinterState.error;
      case 'idle':
      case 'finish':
        return PrinterState.standby;
      default:
        return PrinterState.standby;
    }
  }
}