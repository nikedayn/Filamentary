import 'dart:async';
import 'package:flutter/material.dart';
import 'package:filamentary/core/di/injection.dart';
import 'package:filamentary/core/network/moonraker_client.dart';
import 'package:filamentary/core/database/database.dart' as db;

class PrinterStatusBadge extends StatefulWidget {
  final db.Printer printer;

  const PrinterStatusBadge({super.key, required this.printer});

  @override
  State<PrinterStatusBadge> createState() => _PrinterStatusBadgeState();
}

class _PrinterStatusBadgeState extends State<PrinterStatusBadge> {
  final _client = getIt<MoonrakerClient>();
  Timer? _timer;
  
  String _status = 'loading'; // loading, printing, standby, offline
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    // Опитуємо конкретний принтер кожні 4 секунди
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _fetchStatus());
  }

  Future<void> _fetchStatus() async {
    final telemetry = await _client.getPrinterStatus(
      widget.printer.ipAddress,
      widget.printer.port,
      widget.printer.apiKey,
    );

    if (mounted) {
      setState(() {
        if (!(telemetry['isOnline'] ?? false)) {
          _status = 'offline';
        } else {
          _status = telemetry['state'] ?? 'standby';
          _progress = telemetry['progress'] ?? 0.0;
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color badgeColor = Colors.grey;
    String statusText = 'ОПИТУВАННЯ';

    switch (_status) {
      case 'printing':
        badgeColor = Colors.green;
        statusText = 'ДРУК (${_progress.toStringAsFixed(0)}%)';
        break;
      case 'paused':
        badgeColor = Colors.amber;
        statusText = 'ПАУЗА';
        break;
      case 'standby':
        badgeColor = Colors.blueGrey;
        statusText = 'ГОТОВИЙ';
        break;
      case 'offline':
        badgeColor = Colors.redAccent;
        statusText = 'ОФЛАЙН';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150), // Напівпрозоре тло, щоб текст читався на фото
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}