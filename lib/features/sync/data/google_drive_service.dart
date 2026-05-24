import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;
import 'package:filamentary/core/utils/app_logger.dart';
import 'package:filamentary/features/settings/data/google_auth_service.dart';

@LazySingleton()
class GoogleDriveService {
  final GoogleAuthService _authService;

  GoogleDriveService(this._authService);

  Future<Map<String, String>?> _getAuthHeaders() async {
    final account = _authService.currentUser;
    if (account == null) {
      AppLogger.w('Спроба доступу до Google Drive без авторизації!');
      return null;
    }
    
    // Беремо готові безпечні заголовки з нашої абстракції
    return await account.authHeaders;
  }

  Future<bool> uploadTransactionGroup(String fileName, List<Map<String, dynamic>> transactionsLog) async {
    try {
      final headers = await _getAuthHeaders();
      if (headers == null) return false;

      final metadata = {
        'name': fileName,
        'parents': ['appDataFolder'],
        'mimeType': 'application/json',
      };

      final content = jsonEncode(transactionsLog);
      
      final uri = Uri.parse('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..fields['metadata'] = jsonEncode(metadata)
        ..files.add(http.MultipartFile.fromString(
          'file',
          content,
        ));

      final response = await request.send();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('Файл логу $fileName успішно вивантажено на Google Drive.');
        return true;
      } else {
        AppLogger.e('Помилка завантаження на Drive. Код: ${response.statusCode}');
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.e('Критичний збій роботи з Google Drive API', e, stackTrace);
      return false;
    }
  }
}