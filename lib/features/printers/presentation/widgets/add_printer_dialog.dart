import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return presets.map((e) => e.modelName).toList()..add('Інша модель');
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

    // Головний контент нашої форми
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        // Додаємо автоматичний відступ під системну клавіатуру, щоб вона не перекривала кнопку «Зберегти»
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Декоративний індикатор шторки для мобільного вигляду
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
            
            // 1. ЗАГОЛОВОК ВІКНА
            Row(
              children: [
                Icon(Icons.add_box_outlined, color: Colors.blueGrey.shade700, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Додати новий 3D Принтер', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. ПОЛЯ ВВОДУ (Зменшено проміжні відступи з 12 до 10 для компактності)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Назва принтера (напр. Ворон)', 
                prefixIcon: Icon(Icons.label_outline, size: 18),
                isDense: true, // Робіть поля компактнішими за висотою
                border: OutlineInputBorder()
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Введіть назву' : null,
              onSaved: (v) => _name = v!.trim(),
            ),
            const SizedBox(height: 10),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'IP-Адреса', 
                      prefixIcon: Icon(Icons.dns_outlined, size: 18),
                      hintText: '192.168.1.50',
                      isDense: true,
                      border: OutlineInputBorder()
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Введіть IP' : null,
                    onSaved: (v) => _ipAddress = v!.trim(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: '80',
                    decoration: const InputDecoration(labelText: 'Порт', isDense: true, border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSaved: (v) => _port = int.tryParse(v ?? '80') ?? 80,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            DropdownButtonFormField<String>(
              initialValue: _selectedBrand, 
              decoration: const InputDecoration(labelText: 'Виробник', isDense: true, border: OutlineInputBorder()),
              items: availableBrands.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: (v) {
                setState(() {
                  _selectedBrand = v!;
                  _selectedModel = _getModelsForBrand(_selectedBrand).first;
                });
              },
            ),
            if (_selectedBrand == 'Інший') ...[
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Введіть назву виробника', isDense: true, border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Введіть бренд' : null,
                onSaved: (v) => _customBrand = v!.trim(),
              ),
            ],
            const SizedBox(height: 10),
            
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedBrand), // Оновлює стан при зміні бренду
              initialValue: _selectedModel, 
              decoration: const InputDecoration(labelText: 'Модель принтера', isDense: true, border: OutlineInputBorder()),
              items: availableModels.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: (v) {
                setState(() {
                  _selectedModel = v!;
                });
              },
            ),
            if (_selectedModel == 'Інша модель') ...[
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Введіть назву моделі', isDense: true, border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Введіть модель' : null,
                onSaved: (v) => _customModel = v!.trim(),
              ),
            ],
            if (_selectedBrand == 'Інший' || _selectedModel == 'Інsha модель' || _selectedModel == 'Інша модель') ...[
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Посилання на фото (URL)', isDense: true, border: OutlineInputBorder()),
                onSaved: (v) => _manualImageUrl = v?.trim().isEmpty == true ? null : v?.trim(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _slotsCount.toString(),
                decoration: const InputDecoration(labelText: 'Кількість слотів', isDense: true, border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || int.tryParse(v) == null || int.parse(v) < 1) return 'Мінімум 1';
                  return null;
                },
                onSaved: (v) => _slotsCount = int.parse(v!),
              ),
            ],
            
            CheckboxListTile(
              title: const Text('Потрібен API Ключ', style: TextStyle(fontSize: 13, color: Colors.grey)),
              value: _isAdvancedMode,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _isAdvancedMode = v!),
            ),
            if (_isAdvancedMode) ...[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'API Ключ / Токен', 
                  prefixIcon: Icon(Icons.vpn_key_outlined, size: 18),
                  isDense: true,
                  border: OutlineInputBorder()
                ),
                obscureText: true,
                onSaved: (v) => _apiKey = v?.trim().isEmpty == true ? null : v?.trim(),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 12),

            // 3. КНОПКИ ДІЇ (Оновлено стилістику та вирівнювання)
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
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                  ),
                  onPressed: _submitForm,
                  child: const Text('Зберегти', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final currentPreset = _getCurrentPreset();
      final finalBrand = _selectedBrand == 'Інший' ? _customBrand : _selectedBrand;
      final finalModel = _selectedModel == 'Інша модель' ? _customModel : _selectedModel;
      final finalImageUrl = currentPreset != null ? currentPreset.imageUrl : _manualImageUrl;

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
  }
}