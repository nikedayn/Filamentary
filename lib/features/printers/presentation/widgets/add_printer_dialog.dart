import 'package:flutter/material.dart';
import '../printers_bloc.dart';
import 'printer_presets.dart';

class AddPrinterDialog extends StatefulWidget {
  final PrintersBloc printersBloc;
  const AddPrinterDialog({super.key, required this.printersBloc});

  @override
  State<AddPrinterDialog> createState() => _AddPrinterDialogState();
}

class _AddPrinterDialogState extends State<AddPrinterDialog> {
  final _formKey = GlobalKey<FormState>();
  
  String _name = '';
  String _ipAddress = '';
  
  String _selectedBrand = 'Elegoo';
  String _customBrand = '';
  
  String _selectedModel = 'Neptune 4';
  String _customModel = '';
  
  int _slotsCount = 1;
  int _port = 80;
  String? _apiKey;
  String? _manualImageUrl; 

  bool _isAdvancedMode = false;

  List<String> _getModelsForBrand(String brand) {
    if (brand == 'Інший') return ['Інша модель'];
    final presets = PrinterPresets.brandsData[brand] ?? [];
    return presets.map((e) => e.modelName).toList()..add('Інша model');
  }

  PrinterModelPreset? _getCurrentPreset() {
    if (_selectedBrand == 'Інший' || _selectedModel == 'Інша модель') return null;
    final presets = PrinterPresets.brandsData[_selectedBrand] ?? [];
    return presets.firstWhere((e) => e.modelName == _selectedModel, orElse: () => const PrinterModelPreset(modelName: '', defaultSlots: 1, imageUrl: ''));
  }

  @override
  Widget build(BuildContext context) {
    final List<String> availableBrands = [...PrinterPresets.brandsData.keys, 'Інший'];
    final List<String> availableModels = _getModelsForBrand(_selectedBrand);
    final currentPreset = _getCurrentPreset();

    if (currentPreset != null) {
      _slotsCount = currentPreset.defaultSlots;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Додати новий 3D Принтер', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 450,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Назва принтера (напр. Ворон)', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Введіть назву' : null,
                  onSaved: (v) => _name = v!.trim(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'IP-Адреса (напр. 192.168.1.50)', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Введіть IP-адресу' : null,
                  onSaved: (v) => _ipAddress = v!.trim(),
                ),
                const SizedBox(height: 12),
                
                // Вибір Виробника
                DropdownButtonFormField<String>(
                  initialValue: _selectedBrand, // ФІКС: Замінено застарілий initialValue на value
                  decoration: const InputDecoration(labelText: 'Виробник', border: OutlineInputBorder()),
                  items: availableBrands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedBrand = v!;
                      _selectedModel = _getModelsForBrand(_selectedBrand).first;
                    });
                  },
                ),
                if (_selectedBrand == 'Інший') ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Введіть назву виробника', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Введіть бренд' : null,
                    onSaved: (v) => _customBrand = v!.trim(),
                  ),
                ],
                const SizedBox(height: 12),

                // Вибір Моделі
                DropdownButtonFormField<String>(
                  initialValue: _selectedModel, // ФІКС: Замінено застарілий initialValue на value
                  decoration: const InputDecoration(labelText: 'Модель принтера', border: OutlineInputBorder()),
                  items: availableModels.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedModel = v!;
                    });
                  },
                ),
                if (_selectedModel == 'Інша модель') ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Введіть назву моделі', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Введіть модель' : null,
                    onSaved: (v) => _customModel = v!.trim(),
                  ),
                ],

                if (_selectedBrand == 'Інший' || _selectedModel == 'Інша модель') ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Посилання на photo принтера (URL)', border: OutlineInputBorder()),
                    onSaved: (v) => _manualImageUrl = v?.trim().isEmpty == true ? null : v?.trim(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: '1',
                    decoration: const InputDecoration(labelText: 'Кількість слотів під котушки', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || int.tryParse(v) == null || int.parse(v) < 1) return 'Мінімум 1 слот';
                      return null;
                    },
                    onSaved: (v) => _slotsCount = int.parse(v!),
                  ),
                ],
                const SizedBox(height: 8),

                CheckboxListTile(
                  title: const Text('Розширені налаштування (Порт / API)', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  value: _isAdvancedMode,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => _isAdvancedMode = v!),
                ),
                if (_isAdvancedMode) ...[
                  TextFormField(
                    initialValue: '80',
                    decoration: const InputDecoration(labelText: 'Кастомний Порт', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onSaved: (v) => _port = int.tryParse(v ?? '80') ?? 80,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'API Ключ Moonraker (опціонально)', border: OutlineInputBorder()),
                    onSaved: (v) => _apiKey = v?.trim().isEmpty == true ? null : v?.trim(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Скасувати')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade700),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              final finalBrand = _selectedBrand == 'Інший' ? _customBrand : _selectedBrand;
              final finalModel = _selectedModel == 'Інша модель' ? _customModel : _selectedModel;
              final finalImageUrl = currentPreset != null ? currentPreset.imageUrl : _manualImageUrl;

              // ЗАЛІЗОБЕТОННИЙ ВИКЛИК: Блок тепер без помилок приймає imageUrl
              widget.printersBloc.add(AddPrinterEvent(
                name: _name,
                ipAddress: _ipAddress,
                manufacturer: finalBrand,
                model: finalModel,
                port: _port,
                apiKey: _apiKey,
                slotsCount: _slotsCount,
                imageUrl: finalImageUrl, 
              ));

              Navigator.pop(context);
            }
          },
          child: const Text('Зберегти принтер', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}