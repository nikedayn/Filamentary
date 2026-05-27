import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart'; 

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', 
  preferRelativeImports: false, // 👈 ФІКС: Тепер генератор буде використовувати тільки package-імпорти!
  asExtension: true, 
)
// Викликаємо чисту автогенерацію, де вже прописані всі репозиторії та Блоки
void configureDependencies() => getIt.init();