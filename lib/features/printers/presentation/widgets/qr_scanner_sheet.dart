import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerSheet extends StatefulWidget {
  const QrScannerSheet({super.key});

  @override
  State<QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<QrScannerSheet> {
  // Ініціалізуємо контролер згідно з актуальною документацією v5/v6
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          // Індикатор шторки
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
          
          // Область камери з прицілом
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
                            Navigator.pop(context, qrCodeValue);
                          }
                        }
                      },
                    ),
                  ),
                ),
                
                // Візуальна рамка-приціл
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
          
          // Кнопка керування спалахом (Фікс під актуальне API mobile_scanner)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Оскільки контролер є ValueNotifier<MobileScannerState>, 
                // ми підписуємося на сам контролер (_controller)
                ValueListenableBuilder<MobileScannerState>(
                  valueListenable: _controller,
                  builder: (context, state, child) {
                    Widget icon;
                    // Читаємо актуальний стан спалаху з поля state.torchState
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