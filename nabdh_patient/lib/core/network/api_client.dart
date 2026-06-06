import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Notifies GoRouter to re-evaluate the redirect when auth state changes.
class AuthNotifier extends ChangeNotifier {
  static final AuthNotifier instance = AuthNotifier._();
  AuthNotifier._();
  void notify() => notifyListeners();
}

class ApiClient {
  static Dio? _instance;
  static const _storage = FlutterSecureStorage();

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: AppConstants.tokenKey);
          // Navigate to login - handled by GoRouter redirect
        }
        handler.next(error);
      },
    ));

    return dio;
  }

  static Future<void> setToken(String token) async {
    try {
      await _storage.write(key: AppConstants.tokenKey, value: token);
    } catch (_) {
      await _storage.deleteAll();
      await _storage.write(key: AppConstants.tokenKey, value: token);
    }
  }

  static Future<void> clearToken() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
    AuthNotifier.instance.notify();
  }

  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: AppConstants.tokenKey);
    } catch (_) {
      // Decryption error (e.g. app reinstalled with different key) — wipe and treat as logged out
      try { await _storage.deleteAll(); } catch (_) {}
      return null;
    }
  }
}
