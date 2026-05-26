import 'package:injectable/injectable.dart';
import 'package:filamentary/core/network/printer_client_interface.dart';
import 'package:filamentary/core/network/klipper_client.dart';

@LazySingleton()
class PrinterPollingService {
  // Ми ініціалізуємо клієнт Klipper. За потреби сюди можна додати BambuClient тощо.
  final KlipperClient _klipperClient = KlipperClient();

  /// Автоматично підбирає потрібний клієнт на основі виробника (Klipper, Elegoo, Voron...)
  Future<PrinterTelemetry> fetchPrinterStatus({
    required String ipAddress,
    required int port,
    required String type,
    String? apiKey,
  }) async {
    // Чиста логіка вибору: якщо це не специфічний закритий екосистемний принтер,
    // за замовчуванням опитуємо його як Klipper (через Moonraker API)
    if (type.toLowerCase() == 'bambu' || type.toLowerCase() == 'bambulab') {
      // Тут у майбутньому буде: return _bambuClient.getStatus(...);
      return PrinterTelemetry.offline(); 
    }

    // Для всіх Klipper-сумісних пристроїв (Elegoo Neptune 4, Creality K1, Voron)
    return _klipperClient.getStatus(ipAddress, port, apiKey);
  }
}