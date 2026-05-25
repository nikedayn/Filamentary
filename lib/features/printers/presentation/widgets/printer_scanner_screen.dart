import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';

class PrinterScannerScreen extends StatefulWidget {
  const PrinterScannerScreen({super.key});

  @override
  State<PrinterScannerScreen> createState() => _PrinterScannerScreenState();
}

class _PrinterScannerScreenState extends State<PrinterScannerScreen> {
  final TextEditingController _desktopInputController = TextEditingController();
  MobileScannerController? _cameraController;
  bool _isProcessed = false;

  @override
  void initState() {
    super.initState();
    // Ініціалізуємо камеру тільки для мобільних, щоб Windows не висзав
    if (!Platform.isWindows) {
      _cameraController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _desktopInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ІНТЕРФЕЙС ДЛЯ WINDOWS (Емуляція)
    if (Platform.isWindows) {
      return Scaffold(
        backgroundColor: Colors.blueGrey.shade900,
        appBar: AppBar(
          title: const Text('Емуляція сканування (Windows)'),
          backgroundColor: Colors.blueGrey.shade700,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Container(
            // ТУТ ВИПРАВЛЕНО: Правильне задання обмежень ширини для Container
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40), 
                  blurRadius: 10, 
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monitor, size: 48, color: Colors.blueGrey.shade700),
                const SizedBox(height: 16),
                const Text(
                  'Режим розробки Windows',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Камера доступна лише на мобільних пристроях. Введіть або вставте UUID котушки для імітації зчитування:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _desktopInputController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'UUID котушки (Spool ID)',
                    hintText: 'наприклад: 123e4567-e89b-12d3-a456-426614174000',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Скасувати'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade700,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final input = _desktopInputController.text.trim();
                        if (input.isNotEmpty) {
                          Navigator.pop(context, input);
                        }
                      },
                      child: const Text('Прив\'язати'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ІНТЕРФЕЙС ДЛЯ ANDROID (Реальна камера)
    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(
        title: const Text('Прив\'язка котушки до слота'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController!,
            onDetect: (capture) {
              if (_isProcessed) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final rawValue = barcode.rawValue;
                
                if (rawValue != null && rawValue.startsWith('filamentary://spool/')) {
                  setState(() {
                    _isProcessed = true;
                  });

                  final uuid = rawValue.replaceFirst('filamentary://spool/', '');
                  Navigator.pop(context, uuid);
                  break;
                }
              }
            },
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.teal.shade400, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}