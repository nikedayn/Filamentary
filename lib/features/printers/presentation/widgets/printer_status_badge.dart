import 'package:flutter/material.dart';
import 'package:filamentary/core/network/printer_client_interface.dart';

class PrinterStatusBadge extends StatelessWidget {
  final PrinterState state; 

  const PrinterStatusBadge({super.key, required this.state});

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

    return Container(
      // Збільшуємо горизонтальний падінг для правильної форми капсули
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        // ЧІТКИЙ UI ФІКС: Повне закруглення з усіх боків (форма стадіону)
        borderRadius: BorderRadius.circular(10),
        // Легкий нативний бордер для виразності на фоні світлого AppBar
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
          fontSize: 12, // Трохи збільшили для десктопного монітора
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}