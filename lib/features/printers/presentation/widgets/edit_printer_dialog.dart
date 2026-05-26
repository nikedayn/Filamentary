import 'package:flutter/material.dart';
import 'package:filamentary/features/printers/domain/models/app_printer.dart'; // КРИТИЧНИЙ ІМПОРТ
import '../printers_bloc.dart';

class EditPrinterDialog extends StatefulWidget {
  final AppPrinter printer; // ФІКС: Приймаємо AppPrinter замість db.Printer
  final PrintersBloc printersBloc;

  const EditPrinterDialog({
    super.key,
    required this.printer,
    required this.printersBloc,
  });

  @override
  State<EditPrinterDialog> createState() => _EditPrinterDialogState();
}

class _EditPrinterDialogState extends State<EditPrinterDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _ipController;
  late final TextEditingController _portController;
  late final TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.printer.name);
    _ipController = TextEditingController(text: widget.printer.ipAddress);
    _portController = TextEditingController(text: widget.printer.port.toString());
    _apiKeyController = TextEditingController(text: widget.printer.apiKey ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _portController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редагувати принтер'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Назва')),
            TextFormField(controller: _ipController, decoration: const InputDecoration(labelText: 'IP')),
            TextFormField(controller: _portController, decoration: const InputDecoration(labelText: 'Порт'), keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Скасувати')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(context);
            }
          },
          child: const Text('Зберегти'),
        ),
      ],
    );
  }
}