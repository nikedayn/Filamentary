import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerSheet extends StatefulWidget {
  const QrScannerSheet({super.key});

  @override
  State<QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<QrScannerSheet> {
  // КАНOНІЧНИЙ ФІКС: Конфігуруємо сканер суворо на QR-коди, розвантажуючи графічний процесор Mali смартфона Samsung
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal, 
    facing: CameraFacing.back,
    torchEnabled: false,
    formats: [BarcodeFormat.qrCode], // ШУКАЄМО ТІЛЬКИ QR КОДИ (Прибирає Buffer abandonment баг)
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Інтелектуальний очищувач заводських та внутрішньосистемних рядків QR (п. 2.1 ТЗ)
  String _parseScannedValue(String rawValue) {
    final trimmed = rawValue.trim();
    
    // Сценарій 1: РІДНИЙ ФІКС ДЛЯ FILAMENTARY. Якщо QR-код містить унікальний протокол додатку
    if (trimmed.startsWith('filamentary://spool/')) {
      // Відсікаємо префікс 'filamentary://spool/' і повертаємо чистий 36-значний UUID для бази
      return trimmed.replaceFirst('filamentary://spool/', '');
    }
    
    // Сценарій 2: Якщо QR-код містить стандартне веб-посилання (наприклад, згенероване стороннім сайтом)
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      try {
        final uri = Uri.parse(trimmed);
        if (uri.queryParameters.containsKey('id')) {
          return uri.queryParameters['id']!;
        }
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : trimmed;
      } catch (_) {
        return trimmed;
      }
    }

    // Сценарій 3: Якщо заводський QR-код є JSON-структурою (Bambu Lab AMS / Serial)
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final Map<String, dynamic> json = jsonDecode(trimmed);
        if (json.containsKey('id')) return json['id'].toString();
        if (json.containsKey('uuid')) return json['uuid'].toString();
        if (json.containsKey('serial')) return json['serial'].toString();
      } catch (_) {
        return trimmed;
      }
    }

    // Сценарій 4: Стандартний чистий UUID котушки, заведений вручну
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Наведіть камеру на QR-код котушки',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: MobileScanner(
                      controller: _controller,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final String? qrCodeValue = barcodes.first.rawValue;
                          if (qrCodeValue != null && qrCodeValue.isNotEmpty) {
                            // Пропускаємо строку через наш інтелектуальний парсер
                            final String processedId = _parseScannedValue(qrCodeValue);
                            Navigator.pop(context, processedId);
                          }
                        }
                      },
                    ),
                  ),
                ),
                
                Container(
                  width: 284,
                  height: 284,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.shade400, width: 3),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ValueListenableBuilder<MobileScannerState>(
                  valueListenable: _controller,
                  builder: (context, state, child) {
                    Widget icon;
                    switch (state.torchState) {
                      case TorchState.on:
                        icon = const Icon(Icons.flash_on, color: Colors.amber);
                        break;
                      case TorchState.off:
                      default:
                        icon = const Icon(Icons.flash_off, color: Colors.white);
                        break;
                    }
                    return IconButton(
                      icon: icon,
                      iconSize: 28,
                      onPressed: () => _controller.toggleTorch(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}