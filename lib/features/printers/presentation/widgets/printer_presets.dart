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
        imageUrl: 'https://cdn03.plentymarkets.com/ioseuwg7moqp/item/images/32285/full/Elegoo-Neptune-4-3D-Printer-32285.png',
      ),
      PrinterModelPreset(
        modelName: 'Neptune 4 Pro', 
        defaultSlots: 1,
        imageUrl: 'https://images.tcdn.com.br/img/img_prod/1374743/impressora_3d_filamento_elegoo_neptune_4_pro_117_1_1f427c7e6105d9a33aec990972b18b53.png',
      ),
      PrinterModelPreset(
        modelName: 'Neptune 4 Max', 
        defaultSlots: 1,
        imageUrl: 'https://cdn.awsli.com.br/400x400/1923/1923652/produto/336648704/neptune-4-pro--6--68lr64s6rw.png',
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