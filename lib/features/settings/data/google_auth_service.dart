import 'package:injectable/injectable.dart';
import 'package:filamentary/core/utils/app_logger.dart';

// Створюємо безпечний Mock-аккаунт для сумісності з іншими сервісами
class FakeGoogleAccount {
  final String email = "test.user@gmail.com";
  final String displayName = "3D Printer Operator";
  
  // Імітуємо повернення чистих тестових заголовків
  Future<Map<String, String>> get authHeaders async => {
        'Authorization': 'Bearer fake_mock_token_12345',
        'Accept': 'application/json',
      };
}

@LazySingleton()
class GoogleAuthService {
  FakeGoogleAccount? _currentUser;

  FakeGoogleAccount? get currentUser => _currentUser;

  Future<bool> isSignedIn() async {
    // Імітуємо, що користувач завжди авторизований локально для тестів
    _currentUser = FakeGoogleAccount();
    return true;
  }

  Future<FakeGoogleAccount?> signIn() async {
    try {
      _currentUser = FakeGoogleAccount();
      AppLogger.i('Тестовий режим: Успішний вхід під аккаунтом: ${_currentUser!.email}');
      return _currentUser;
    } catch (e, stackTrace) {
      AppLogger.e('Помилка авторизації', e, stackTrace);
      return null;
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    AppLogger.i('Тестовий режим: Користувач вийшов з аккаунту');
  }
}