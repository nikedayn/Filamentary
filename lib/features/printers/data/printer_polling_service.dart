import 'package:injectable/injectable.dart';
import 'package:filamentary/core/network/printer_client_interface.dart';
import 'package:filamentary/core/network/klipper_client.dart';
import 'package:filamentary/core/network/bambu_client.dart'; // 👈 ДОДАНО ІМПОРТ КЛІЄНТА
import 'package:filamentary/core/di/injection.dart'; 

@LazySingleton()
class PrinterPollingService {
  // Підтягуємо обидва клієнти через DI градиент
  KlipperClient get _klipperClient => getIt<KlipperClient>(instanceName: "KlipperClient");
  BambuClient get _bambuClient => getIt<BambuClient>(); // 👈 ДОДАНО ГЕТТЕР ДЛЯ BAMBU

  Future<PrinterTelemetry> fetchPrinterStatus({
    required String ipAddress,
    required int port,
    required String type,
    String? apiKey,
  }) async {
    if (ipAddress.isEmpty) return PrinterTelemetry.offline('Відсутня IP-адреса принтера.');

    final String lowerType = type.toLowerCase();

    // 🛠️ ФІКС ХАРДКОДУ: Тепер викликаємо живий MQTT клієнт замість мовчазного офлайну!
    if (lowerType.contains('bambu') || lowerType.contains('bambulab')) {
      return _bambuClient.getStatus(ipAddress, port, apiKey);
    }

    // Для Klipper Moonraker (Elegoo тощо)
    return _klipperClient.getStatus(ipAddress, port, apiKey);
  }
}