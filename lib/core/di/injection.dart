import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart'; // Цей файл згенерується автоматично!

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', 
  preferRelativeImports: true, 
  asExtension: true, 
)
// ФІКС: Прибираємо await перед getIt, бо сам метод ініціалізації синхронний
void configureDependencies() => getIt.init();