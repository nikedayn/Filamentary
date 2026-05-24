import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class ApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      // Якщо принтер не відповідає протягом 3 секунд — вважаємо його офлайн
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Dio get dio => _dio;
}