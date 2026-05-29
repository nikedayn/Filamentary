import 'package:flutter/material.dart';
import 'package:filamentary/core/network/printer_client_interface.dart';

class PrinterStatusBadge extends StatelessWidget {
  final PrinterState state; 
  final String? errorMessage; // 👈 Обов'язкове поле для відображення детального тексту помилки

  const PrinterStatusBadge({
    super.key, 
    required this.state,
    this.errorMessage, // 👈 Іменований параметр чітко задекларовано в конструкторі
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (state) {
      case PrinterState.printing:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        text = 'Друк...';
        break;
      case PrinterState.paused:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        text = 'Пауза';
        break;
      case PrinterState.standby:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        text = 'Готовий';
        break;
      case PrinterState.error:
        backgroundColor = Colors.red.shade900;
        textColor = Colors.white;
        text = 'Критичний збій';
        break;
      case PrinterState.offline:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        text = 'Офлайн';
        break;
    }

    final bool hasTooltip = errorMessage != null && errorMessage!.isNotEmpty;

    return Tooltip(
      message: hasTooltip ? errorMessage! : 'Статус: $text',
      preferBelow: true,
      triggerMode: TooltipTriggerMode.tap, 
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: textColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor, 
            fontWeight: FontWeight.bold, 
            fontSize: 12, 
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}