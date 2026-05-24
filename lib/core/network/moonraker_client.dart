import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class MoonrakerClient {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 3), // Якщо принтер вимкнено, ми дізнаємося про це за 3 сек
    receiveTimeout: const Duration(seconds: 3),
  ));

  /// Отримання статусів та температур хотенду і столу з Klipper
  Future<Map<String, dynamic>> getPrinterStatus(String ip, int port, String? apiKey) async {
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
        return {
          'isOnline': true,
          'state': data['print_stats']['state'] ?? 'standby', // printing, paused, standby, error
          'filename': data['print_stats']['filename'] ?? '',
          'extruderTemp': data['extruder']['temperature'] ?? 0.0,
          'extruderTarget': data['extruder']['target'] ?? 0.0,
          'bedTemp': data['heater_bed']['temperature'] ?? 0.0,
          'bedTarget': data['heater_bed']['target'] ?? 0.0,
          'progress': data['print_stats']['print_duration'] > 0 
              ? (data['print_stats']['print_duration'] / data['print_stats']['total_duration']) * 100 
              : 0.0,
        };
      }
    } catch (e) {
      // Якщо принтер вимкнений з розетки або немає мережі
      return {
        'isOnline': false,
        'state': 'offline',
        'filename': '',
        'extruderTemp': 0.0,
        'extruderTarget': 0.0,
        'bedTemp': 0.0,
        'bedTarget': 0.0,
        'progress': 0.0,
      };
    }
    
    return {'isOnline': false, 'state': 'offline'};
  }
}