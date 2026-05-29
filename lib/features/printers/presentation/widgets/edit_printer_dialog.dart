import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:filamentary/features/printers/domain/models/app_printer.dart';
import 'printer_presets.dart';

class EditPrinterDialog extends StatefulWidget {
  final AppPrinter printer; 
  final Function(AppPrinter updatedPrinter) onSave;

  const EditPrinterDialog({
    super.key,
    required this.printer,
    required this.onSave,
  });

  @override
  State<EditPrinterDialog> createState() => _EditPrinterDialogState();
}

class _EditPrinterDialogState extends State<EditPrinterDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _ipController;
  late TextEditingController _portController;
  late TextEditingController _customBrandController;
  late TextEditingController _customModelController;
  late TextEditingController _apiKeyController;
  late TextEditingController _imageUrlController; 

  String _selectedBrand = 'Elegoo';
  String _selectedModel = 'Neptune 4';
  int _slotsCount = 1;
  bool _isAdvancedMode = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.printer.name);
    _ipController = TextEditingController(text: widget.printer.ipAddress);
    _portController = TextEditingController(text: widget.printer.port.toString());
    _apiKeyController = TextEditingController(text: widget.printer.apiKey ?? '');
    _imageUrlController = TextEditingController(text: widget.printer.imageUrl ?? '');
    
    _customBrandController = TextEditingController();
    _customModelController = TextEditingController();

    _slotsCount = widget.printer.slotsCount;
    if (widget.printer.apiKey != null && widget.printer.apiKey!.isNotEmpty) {
      _isAdvancedMode = true;
    }

    final String currentBrand = widget.printer.manufacturer;
    final String currentModel = widget.printer.model;

    if (PrinterPresets.brandsData.containsKey(currentBrand)) {
      _selectedBrand = currentBrand;
      final availableModels = _getModelsForBrand(_selectedBrand);
      if (availableModels.contains(currentModel)) {
        _selectedModel = currentModel;
      } else {
        _selectedModel = 'Інша модель';
        _customModelController.text = currentModel;
      }
    } else {
      _selectedBrand = 'Інший';
      _customBrandController.text = currentBrand;
      _selectedModel = 'Інша модель';
      _customModelController.text = currentModel;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _portController.dispose();
    _customBrandController.dispose();
    _customModelController.dispose();
    _apiKeyController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  List<String> _getModelsForBrand(String brand) {
    if (brand == 'Інший') return ['Інша модель'];
    final presets = PrinterPresets.brandsData[brand] ?? [];
    return presets.map((e) => e.modelName).toList()..add('Інша модель');
  }

  void _onBrandChanged(String? brand) {
    if (brand == null) return;
    setState(() {
      _selectedBrand = brand;
      final models = _getModelsForBrand(_selectedBrand);
      _selectedModel = models.first;
      
      // Якщо перемкнулися на пресет — підставляємо його дефолтну кількість слотів
      if (_selectedBrand != 'Інший' && _selectedModel != 'Інша модель') {
        final presets = PrinterPresets.brandsData[_selectedBrand] ?? [];
        if (presets.isNotEmpty) {
          _slotsCount = presets.first.defaultSlots;
        }
      }
    });
  }

  void _onModelChanged(String? model) {
    if (model == null) return;
    setState(() {
      _selectedModel = model;
      if (_selectedBrand != 'Інший' && _selectedModel != 'Інша модель') {
        final presets = PrinterPresets.brandsData[_selectedBrand] ?? [];
        final matched = presets.firstWhere((e) => e.modelName == _selectedModel);
        _slotsCount = matched.defaultSlots;
        _imageUrlController.text = matched.imageUrl;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> availableBrands = [...PrinterPresets.brandsData.keys, 'Інший'];
    final List<String> availableModels = _getModelsForBrand(_selectedBrand);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        // Оптимальні відступи під мобільні екрани та системну клавіатуру
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.edit_note, color: Colors.blueGrey.shade700, size: 24),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Редагувати налаштування', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Назва принтера в додатку', isDense: true, border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Введіть назву' : null,
            ),
            const SizedBox(height: 10),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _ipController,
                    decoration: const InputDecoration(
                      labelText: 'IP-Адреса', 
                      prefixIcon: Icon(Icons.dns_outlined, size: 18),
                      isDense: true,
                      border: OutlineInputBorder()
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Введіть IP' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _portController,
                    decoration: const InputDecoration(labelText: 'Порт', isDense: true, border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => v == null || v.isEmpty ? 'Порт' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            DropdownButtonFormField<String>(
              initialValue: _selectedBrand, 
              decoration: const InputDecoration(labelText: 'Виробник', isDense: true, border: OutlineInputBorder()),
              items: availableBrands.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: _onBrandChanged,
            ),
            if (_selectedBrand == 'Інший') ...[
              const SizedBox(height: 10),
              TextFormField(
                controller: _customBrandController,
                decoration: const InputDecoration(labelText: 'Введіть назву виробника', isDense: true, border: OutlineInputBorder()),
                validator: (v) => _selectedBrand == 'Інший' && (v == null || v.trim().isEmpty) ? 'Введіть бренд' : null,
              ),
            ],
            const SizedBox(height: 10),
            
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedBrand),
              initialValue: _selectedModel, 
              decoration: const InputDecoration(labelText: 'Модель принтера', isDense: true, border: OutlineInputBorder()),
              items: availableModels.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: _onModelChanged,
            ),
            if (_selectedModel == 'Інша модель') ...[
              const SizedBox(height: 10),
              TextFormField(
                controller: _customModelController,
                decoration: const InputDecoration(labelText: 'Введіть назву моделі', isDense: true, border: OutlineInputBorder()),
                validator: (v) => _selectedModel == 'Інша модель' && (v == null || v.trim().isEmpty) ? 'Введіть модель' : null,
              ),
            ],
            if (_selectedBrand == 'Інший' || _selectedModel == 'Інша модель') ...[
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Посилання на фото (URL)', isDense: true, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _slotsCount.toString(),
                decoration: const InputDecoration(labelText: 'Кількість слотів під котушки', isDense: true, border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || int.tryParse(v) == null || int.parse(v) < 1) return 'Мінімум 1';
                  return null;
                },
                onChanged: (v) {
                  final parsed = int.tryParse(v);
                  if (parsed != null && parsed >= 1) _slotsCount = parsed;
                },
              ),
            ],
            
            CheckboxListTile(
              title: const Text('Потрібен API Ключ безпеки', style: TextStyle(fontSize: 13, color: Colors.grey)),
              value: _isAdvancedMode,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _isAdvancedMode = v!),
            ),
            if (_isAdvancedMode) ...[
              TextFormField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Ключ Moonraker / Токен', 
                  prefixIcon: Icon(Icons.vpn_key_outlined, size: 18),
                  isDense: true,
                  border: OutlineInputBorder()
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: Text('Скасувати', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade700,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                  ),
                  onPressed: _submitData,
                  child: const Text('Зберегти', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      // 1. ПРАВИЛЬНЕ ЗЧИТУВАННЯ ТИПУ ПРИНТЕРА (Виробник + Модель)
      final finalBrand = _selectedBrand == 'Інший' 
          ? _customBrandController.text.trim() 
          : _selectedBrand;
          
      final finalModel = _selectedModel == 'Інша модель' 
          ? _customModelController.text.trim() 
          : _selectedModel;
      
      // 2. ЗЧИТУВАННЯ ПОРТУ ТА КАРТИНКИ
      final int finalPort = int.tryParse(_portController.text.trim()) ?? 80;
      
      String? finalImageUrl = _imageUrlController.text.trim();
      if (_selectedBrand != 'Інший' && _selectedModel != 'Інша модель') {
        final presets = PrinterPresets.brandsData[_selectedBrand] ?? [];
        final matched = presets.firstWhere((e) => e.modelName == _selectedModel);
        finalImageUrl = matched.imageUrl;
      }

      // 3. ПЕРЕДАЧА ОНОВЛЕНОГО ОБ'ЄКТА ЗБЕРЕЖЕННЯ
      widget.onSave(
        AppPrinter(
          id: widget.printer.id,
          name: _nameController.text.trim(), // Назва зчитується прямо з текстового поля
          ipAddress: _ipController.text.trim(),
          port: finalPort, // Порт тепер точно оновлюється
          manufacturer: finalBrand, // Новий тип виробника
          model: finalModel, // Нова модель
          apiKey: _isAdvancedMode && _apiKeyController.text.trim().isNotEmpty 
              ? _apiKeyController.text.trim() 
              : null,
          slotsCount: _slotsCount,
          slots: widget.printer.slots,
          imageUrl: finalImageUrl.isEmpty ? null : finalImageUrl, 
          version: widget.printer.version, // Блок сам підніме версію для Drift
          timestamp: DateTime.now(), // Оновлюємо час редагування
        ),
      );
      Navigator.pop(context);
    }
  }
}