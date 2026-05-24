class PrinterModelPreset {
  final String modelName;
  final int defaultSlots;
  final String imageUrl; // Нове поле: пряме посилання на фото моделі

  const PrinterModelPreset({
    required this.modelName, 
    required this.defaultSlots,
    required this.imageUrl,
  });
}

class PrinterPresets {
  static const Map<String, List<PrinterModelPreset>> brandsData = {
    'Elegoo': [
      PrinterModelPreset(
        modelName: 'Neptune 4', 
        defaultSlots: 1,
        imageUrl: 'https://images.officialthreed.com/products/elegoo/neptune-4/neptune-4-1.jpg',
      ),
      PrinterModelPreset(
        modelName: 'Neptune 4 Pro', 
        defaultSlots: 1,
        imageUrl: 'https://images.officialthreed.com/products/elegoo/neptune-4-pro/neptune-4-pro-1.jpg',
      ),
      PrinterModelPreset(
        modelName: 'Neptune 4 Max', 
        defaultSlots: 1,
        imageUrl: 'https://images.officialthreed.com/products/elegoo/neptune-4-max/neptune-4-max-1.jpg',
      ),
    ],
    'Bambu Lab': [
      PrinterModelPreset(
        modelName: 'X1-Carbon', 
        defaultSlots: 4,
        imageUrl: 'https://images.officialthreed.com/products/bambulab/x1-carbon/bambulab-x1-carbon-1.jpg',
      ),
      PrinterModelPreset(
        modelName: 'P1S', 
        defaultSlots: 4,
        imageUrl: 'https://images.officialthreed.com/products/bambulab/p1s/bambulab-p1s-1.jpg',
      ),
      PrinterModelPreset(
        modelName: 'A1', 
        defaultSlots: 4,
        imageUrl: 'https://images.officialthreed.com/products/bambulab/a1/bambulab-a1-1.jpg',
      ),
    ],
    'Creality': [
      PrinterModelPreset(
        modelName: 'Ender 3', 
        defaultSlots: 1,
        imageUrl: 'https://images.officialthreed.com/products/creality/ender-3/creality-ender-3-1.jpg',
      ),
      PrinterModelPreset(
        modelName: 'K1', 
        defaultSlots: 1,
        imageUrl: 'https://images.officialthreed.com/products/creality/k1/creality-k1-1.jpg',
      ),
      PrinterModelPreset(
        modelName: 'K1 Max', 
        defaultSlots: 1,
        imageUrl: 'https://images.officialthreed.com/products/creality/k1-max/creality-k1-max-1.jpg',
      ),
    ],
  };
}