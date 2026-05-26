import 'package:flutter/material.dart';

class DeletePrintJobDialog extends StatefulWidget {
  final String modelName;
  const DeletePrintJobDialog({super.key, required this.modelName});

  @override
  State<DeletePrintJobDialog> createState() => _DeletePrintJobDialogState();
}

class _DeletePrintJobDialogState extends State<DeletePrintJobDialog> {
  bool _restoreWeight = true; // За замовчуванням чекбокс активний

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          SizedBox(width: 10),
          Text('Видалення запису', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ви впевнені, що хочете видалити запис друку "${widget.modelName}" з історії?'),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Повернути списану вагу пластику на котушки', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            subtitle: const Text('Вага використаного матеріалу знову з\'явиться в інвентарі як залишок', style: TextStyle(fontSize: 12)),
            value: _restoreWeight,
            activeColor: Colors.blueGrey.shade700,
            contentPadding: EdgeInsets.zero,
            // ЗАЛІЗОБЕТОННИЙ ФІКС ТУТ: правильний параметр та enum
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) => setState(() => _restoreWeight = val ?? true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Скасувати', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(context, _restoreWeight),
          child: const Text('Видалити'),
        ),
      ],
    );
  }
}