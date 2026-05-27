import 'package:flutter/material.dart';
import 'package:filamentary/core/network/printer_client_interface.dart';

class TelemetryInfoBlock extends StatelessWidget {
  final PrinterTelemetry telemetry;

  const TelemetryInfoBlock({super.key, required this.telemetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTelemetryRow(
          icon: Icons.thermostat_outlined,
          label: 'Екструдер:',
          value: '${telemetry.extruderTemp.toStringAsFixed(1).replaceAll('.', ',')} / ${telemetry.extruderTarget.toStringAsFixed(0)} °C',
        ),
        const SizedBox(height: 12),
        _buildTelemetryRow(
          icon: Icons.layers_outlined,
          label: 'Стіл:',
          value: '${telemetry.bedTemp.toStringAsFixed(1)} / ${telemetry.bedTarget.toStringAsFixed(0)} °C',
        ),
        const SizedBox(height: 12),
        _buildTelemetryRow(
          icon: Icons.speed_outlined,
          label: 'Прогрес:',
          value: '${(telemetry.progress * 100).toStringAsFixed(0)}%',
        ),
        if (telemetry.filename.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildTelemetryRow(
            icon: Icons.insert_drive_file_outlined,
            label: 'Файл:',
            value: telemetry.filename,
          ),
        ],
      ],
    );
  }

  Widget _buildTelemetryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey.shade600, size: 22),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
      ],
    );
  }
}