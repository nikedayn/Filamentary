import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'printer_client_interface.dart';

@Named("KlipperClient")
@lazySingleton
class KlipperClient implements PrinterClient {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 2),
    receiveTimeout: const Duration(seconds: 2),
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
          'virtual_sdcard': 'progress',
        },
        options: Options(headers: headers),
      );

      if (response.statusCode != 200 || response.data?['result']?['status'] == null) {
        return PrinterTelemetry.offline('Moonraker повернув некоректний статус сервера: ${response.statusCode}');
      }

      final status = response.data['result']['status'];
      
      final double extruderTemp = (status['extruder']?['temperature'] as num?)?.toDouble() ?? 0.0;
      final double extruderTarget = (status['extruder']?['target'] as num?)?.toDouble() ?? 0.0;
      final double bedTemp = (status['heater_bed']?['temperature'] as num?)?.toDouble() ?? 0.0;
      final double bedTarget = (status['heater_bed']?['target'] as num?)?.toDouble() ?? 0.0;

      final String rawState = status['print_stats']?['state'] ?? 'standby';
      final PrinterState appState = _parseState(rawState);

      double progress = 0.0;
      if (status['virtual_sdcard']?['progress'] != null) {
        progress = (status['virtual_sdcard']['progress'] as num).toDouble();
      } else {
        final totalDuration = (status['print_stats']?['total_duration'] as num?)?.toDouble() ?? 0.0;
        final printDuration = (status['print_stats']?['print_duration'] as num?)?.toDouble() ?? 0.0;
        
        if (totalDuration > 0 && printDuration > 0) {
          progress = printDuration / totalDuration;
        }
      }

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
        progress: progress,
        errorMessage: '', // З'єднання успішне, помилок немає
      );

    } on DioException catch (e) {
      // Розумне розпізнавання помилок виключно для Klipper екосистеми
      String msg = 'Помилка мережі Klipper: ';
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        msg += 'Таймаут з\'єднання! Перевірте, чи увімкнено принтер.';
      } else if (e.error is SocketException) {
        msg += 'Пристрій недоступний. Перевірте IP $ip та порт $port.';
      } else {
        msg += e.message ?? 'Невідомий збій Dio сокета.';
      }
      return PrinterTelemetry.offline(msg);
    } catch (e) {
      return PrinterTelemetry.offline('Системна помилка підключення: $e');
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