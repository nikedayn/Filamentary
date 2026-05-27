import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'printer_client_interface.dart';

@lazySingleton
class BambuClient implements PrinterClient {
  
  @override
  Future<PrinterTelemetry> getStatus(String ip, int port, String? apiKey) async {
    if (apiKey == null || apiKey.isEmpty) {
      return PrinterTelemetry.offline('Відсутній Access Code у налаштуваннях.');
    }

    // Дефолтний MQTT TLS порт для Bambu Lab — 8883
    final int mqttPort = port == 80 ? 8883 : port; 
    
    // ФІКС 1: Генеруємо унікальний Client ID для кожного запиту, щоб уникнути конфліктів сокетів
    final String clientId = 'filamentary_${DateTime.now().millisecondsSinceEpoch}';
    final MqttServerClient client = MqttServerClient.withPort(ip, clientId, mqttPort);
    
    // Налаштування безпеки та логування
    client.secure = true;
    client.keepAlivePeriod = 10;
    client.setProtocolV311();
    
    // КРИТИЧНИЙ ФІКС: Очікується тип Object відповідно до тексту помилки
    // 'type (X509Certificate) => bool' is not a subtype of type '((Object) => bool)?'
    client.onBadCertificate = (Object cert) => true; 

    // Формуємо Connection Message. Логін у Bambu ЗАВЖДИ 'bblp', пароль — Access Code (apiKey)
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs('bblp', apiKey)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;

    try {
      // 1. Намагаємося підключитися (таймаут 2 секунди)
      await client.connect().timeout(const Duration(seconds: 2));
      
      if (client.connectionStatus!.state != MqttConnectionState.connected) {
        final String returnCode = client.connectionStatus!.returnCode.toString();
        client.disconnect();
        
        // Розпізнаємо причину відхилення брокером принтера
        if (returnCode.contains('badUsernameOrPassword')) {
          return PrinterTelemetry.offline('Неправильний Access Code! Перевір код з екрана принтера.');
        } else if (returnCode.contains('notAuthorized')) {
          return PrinterTelemetry.offline('Принтер відхилив авторизацію. Увімкни LAN Mode.');
        }
        return PrinterTelemetry.offline('Помилка брокера MQTT: $returnCode');
      }

      // 2. Підписуємося на універсальний топік звітів
      const String topic = 'device/+/report';
      client.subscribe(topic, MqttQos.atMostOnce);

      final Completer<PrinterTelemetry> completer = Completer<PrinterTelemetry>();

      // 3. Слухаємо потік повідомлень від принтера
      final subscription = client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        try {
          final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
          final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          
          final Map<String, dynamic> json = jsonDecode(payload);
          
          // Пом'якшуємо перевірку: зчитуємо дані, навіть якщо Bambu надіслав їх без обгортки 'print'
          final printData = json['print'] ?? json;
          
          if (printData['gcode_state'] != null || printData['nozzle_temper'] != null) {
            final String gcodeState = printData['gcode_state'] ?? 'idle';
            final double mcPercent = (printData['mc_percent'] as num?)?.toDouble() ?? 0.0;
            
            final double nozzleTemp = (printData['nozzle_temper'] as num?)?.toDouble() ?? 0.0;
            final double nozzleTarget = (printData['nozzle_target_temper'] as num?)?.toDouble() ?? 0.0;
            final double bedTemp = (printData['bed_temper'] as num?)?.toDouble() ?? 0.0;
            final double bedTarget = (printData['bed_target_temper'] as num?)?.toDouble() ?? 0.0;
            final String subTaskName = printData['subtask_name'] ?? '';

            final telemetry = PrinterTelemetry(
              isOnline: true,
              state: _parseState(gcodeState),
              filename: subTaskName,
              extruderTemp: nozzleTemp,
              extruderTarget: nozzleTarget,
              bedTemp: bedTemp,
              bedTarget: bedTarget,
              progress: (mcPercent / 100.0).clamp(0.0, 1.0),
            );

            if (!completer.isCompleted) completer.complete(telemetry);
          }
        } catch (e) {
          if (!completer.isCompleted) completer.complete(PrinterTelemetry.offline('Помилка десеріалізації: $e'));
        }
      });

      // ФІКС 2: ПРИМУСОВИЙ ШТОВХАНЕЦЬ. Відправляємо команду "дай статус", щоб принтер віддав інфо негайно
      final builder = MqttClientPayloadBuilder();
      builder.addString(jsonEncode({
        "pushing": {"sequence_id": "1", "command": "push_status"}
      }));
      client.publishMessage('device/+/request', MqttQos.atMostOnce, builder.payload!);

      // Очікуємо відповідь від принтера протягом 1.5 секунди
      final result = await completer.future.timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () => PrinterTelemetry.offline('Принтер підключився, але не надіслав пакет телеметрії.'),
      );

      subscription?.cancel();
      client.disconnect();
      return result;

    } on TimeoutException {
      client.disconnect();
      return PrinterTelemetry.offline('Таймаут з\'єднання! Телефон не бачить IP $ip. Перевір Wi-Fi мережу.');
    } on SocketException catch (e) {
      client.disconnect();
      return PrinterTelemetry.offline('Помилка сокета Android: ${e.message}. Перевір CleartextTraffic.');
    } catch (e) {
      client.disconnect();
      return PrinterTelemetry.offline('Невідома помилка мережі: $e');
    }
  }

  PrinterState _parseState(String raw) {
    switch (raw.toLowerCase().trim()) {
      case 'prepare':
      case 'running':
        return PrinterState.printing;
      case 'pause':
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