import 'package:flutter/material.dart';
import 'package:filamentary/core/di/injection.dart';
import 'package:filamentary/core/utils/app_logger.dart';
import 'package:filamentary/features/inventory/presentation/inventory_screen.dart';

// Глобальний ключ для безпечного виклику SnackBar без BuildContext
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  // 1. Спочатку ініціалізуємо зв'язку з нативною платформою (критично для Android!)
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 2. Ініціалізуємо залежності синхронно
    configureDependencies(); 
    AppLogger.i('💡 💡 Фундамент додатку Filamentary успішно запущено!');
  } catch (e) {
    AppLogger.i('💥 Помилка ініціалізації: $e');
  }
  
  // 3. Стартуємо інтерфейс
  runApp(const FilamentaryApp());
}

class FilamentaryApp extends StatelessWidget {
  const FilamentaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filamentary',
      scaffoldMessengerKey: rootScaffoldMessengerKey, 
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
        // На Android краще явно задати комфортну щільність елементів
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const InventoryScreen(),
    );
  }
}