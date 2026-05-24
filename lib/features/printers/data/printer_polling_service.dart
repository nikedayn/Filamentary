import 'package:injectable/injectable.dart';
import 'package:filamentary/core/network/api_client.dart';
import 'package:filamentary/core/utils/app_logger.dart';

@LazySingleton()
class PrinterPollingService {
  final ApiClient _apiClient;

  PrinterPollingService(this._apiClient);

  // Опитування стану принтера залежно від його типу
  Future<Map<String, dynamic>> fetchPrinterStatus(String ipAddress, String type) async {
    try {
      if (type.toLowerCase() == 'klipper') {
        // Запит до Moonraker API для Klipper
        final response = await _apiClient.dio.get('http://$ipAddress/printer/objects/query?print_stats');
        if (response.statusCode == 200) {
          final status = response.data['result']['status']['print_stats']['state']; // e.g. "printing", "complete"
          return {'status': status, 'success': true};
        }
      } else if (type.toLowerCase() == 'bambu') {
        // Базовий REST-запит для Bambu API
        final response = await _apiClient.dio.get('http://$ipAddress/api/v1/status');
        if (response.statusCode == 200) {
          return {'status': response.data['print_status'], 'success': true};
        }
      }
      return {'status': 'offline', 'success': false};
    } catch (e) {
      // Якщо принтер вимкнений, Dio викине помилку таймауту. Логуємо її м'яко без падіння додатку
      AppLogger.w('Принтер $ipAddress недоступний (Offline)');
      return {'status': 'offline', 'success': false};
    }
  }
}