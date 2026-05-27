import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
// ФІКС: Імпортуємо сучасний mobile_scanner замість померлого qr_code_tools
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:filamentary/features/printers/domain/models/app_printer.dart';
import '../printer_detail_bloc.dart';
import 'material_select_dialog.dart';
import 'qr_scanner_sheet.dart';

class PrinterSlotCard extends StatelessWidget {
  final AppPrinter printer;
  final int slotIndex;

  const PrinterSlotCard({
    super.key,
    required this.printer,
    required this.slotIndex,
  });

  @override
  Widget build(BuildContext context) {
    PrinterSlot? activeSlot;
    if (slotIndex < printer.slots.length) {
      activeSlot = printer.slots[slotIndex];
    }

    final String? assignedMaterialId = activeSlot?.linkedMaterialId;
    final bool isAssigned = assignedMaterialId != null && assignedMaterialId.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50.withAlpha(125),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.circle, 
                color: isAssigned ? Colors.green.shade600 : Colors.grey.shade400, 
                size: 10
              ),
              const SizedBox(width: 8),
              Text(
                'Слот #${slotIndex + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),

          if (isAssigned) ...[
            Text(
              'Заправлено (ID: ${assignedMaterialId.length > 8 ? assignedMaterialId.substring(0, 8) : assignedMaterialId}...)',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            Text(
              'Не заправлено',
              style: TextStyle(
                fontSize: 12, 
                fontStyle: FontStyle.italic, 
                color: Colors.grey.shade600,
              ),
            ),
          ],
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleQRScan(context),
                  icon: const Icon(Icons.qr_code_scanner, size: 14),
                  label: const Text('QR-код', style: TextStyle(fontSize: 10)),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.blueGrey.shade100,
                    foregroundColor: Colors.blueGrey.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleManualSelect(context),
                  icon: const Icon(Icons.list, size: 14),
                  label: const Text('Вибрати', style: TextStyle(fontSize: 10)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue.shade800,
                    side: BorderSide(color: Colors.blue.shade200),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleQRScan(BuildContext context) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      _showDesktopCodeInputDialog(context);
      return;
    }

    final String? scannedMaterialId = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QrScannerSheet(),
    );

    if (scannedMaterialId == null || scannedMaterialId.isEmpty) return;

    if (context.mounted) {
      context.read<PrinterDetailBloc>().add(
        ChangeSlotMaterialEvent(
          printerId: printer.id,
          slotIndex: slotIndex + 1,
          materialId: scannedMaterialId,
        ),
      );
    }
  }

  void _showDesktopCodeInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.qr_code_2, color: Colors.blueGrey.shade700),
            const SizedBox(width: 10),
            const Text('Сканування QR-коду'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Пряме сканування через камеру доступне лише на мобільних пристроях (Android / iOS).',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            Text(
              'На комп\'ютері ви можете вибрати фотографію або скріншот QR-коду котушки через провідник, і додаток розпізнає його автоматично.',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Скасувати'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.folder_open),
            label: const Text('Обрати фото з QR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              try {
                // 1. Обираємо файл через FilePicker
                final FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: false,
                );

                if (result == null || result.files.single.path == null) return;
                final String filePath = result.files.single.path!;

                // 2. ФІКС UI/БІЛДУ: Використовуємо нативний аналізатор mobile_scanner для картинок
                final MobileScannerController scannerController = MobileScannerController();
                final BarcodeCapture? capture = await scannerController.analyzeImage(filePath);
                
                // Звільняємо ресурси контролера сканера
                scannerController.dispose();

                if (capture != null && capture.barcodes.isNotEmpty) {
                  final String? decodedId = capture.barcodes.first.rawValue;

                  if (decodedId != null && decodedId.isNotEmpty) {
                    if (context.mounted) {
                      context.read<PrinterDetailBloc>().add(
                        ChangeSlotMaterialEvent(
                          printerId: printer.id,
                          slotIndex: slotIndex + 1,
                          materialId: decodedId,
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('QR-код успішно розпізнано! Слот #${slotIndex + 1} заправлено.'),
                          backgroundColor: Colors.green.shade700,
                        ),
                      );
                    }
                    return;
                  }
                }
                
                // Якщо capture порожній або коду немає — кидаємо виняток для блоку catch
                throw Exception('QR code not found on image');

              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Не вдалося знайти або розпізнати QR-код на цьому зображенні.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _handleManualSelect(BuildContext context) async {
    final printersBloc = context.read<PrinterDetailBloc>();
    final double screenWidth = MediaQuery.of(context).size.width;
    String? selectedMaterialId;

    if (screenWidth < 600) {
      // НА ТЕЛЕФОНІ: Зручна нижня шторка без будь-яких оверфлоу
      selectedMaterialId = await showModalBottomSheet<String?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => const MaterialSelectDialog(),
      );
    } else {
      // НА ДЕСКТОПІ/ПК: Акуратне діалогове вікно
      selectedMaterialId = await showDialog<String?>(
        context: context,
        builder: (context) => const MaterialSelectDialog(),
      );
    }

    if (selectedMaterialId == null) return;
    final String? targetId = selectedMaterialId.isEmpty ? null : selectedMaterialId;

    if (context.mounted) {
      context.read<PrinterDetailBloc>().add(
        ChangeSlotMaterialEvent(
          printerId: printer.id,
          slotIndex: slotIndex + 1,
          materialId: targetId,
        ),
      );
    }
  }
}