import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import 'dart:io';

/// Tracks auth state synchronously so GoRouter redirect never needs async getToken().
class AuthNotifier extends ChangeNotifier {
  static final AuthNotifier instance = AuthNotifier._();
  AuthNotifier._();

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  /// Call once at startup with the persisted token state.
  void initialize(bool loggedIn) => _isAuthenticated = loggedIn;

  /// Sets state AND notifies GoRouter (use for 401 interceptor / background logout).
  void setAuthenticated(bool value) {
    if (_isAuthenticated == value) return;
    _isAuthenticated = value;
    notifyListeners();
  }

  /// Sets state WITHOUT notifying — caller must navigate explicitly with context.go().
  void setAuthenticatedSilent(bool value) {
    _isAuthenticated = value;
  }
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
          await clearToken(); // clears storage + notifies GoRouter → redirect to /auth
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
    AuthNotifier.instance.setAuthenticated(true);
  }

  /// Clears token and notifies GoRouter (for 401 / background cases without context).
  static Future<void> clearToken() async {
    try { await _storage.deleteAll(); } catch (_) {}
    AuthNotifier.instance.setAuthenticated(false);
  }

  /// Clears token silently — caller MUST call context.go('/auth') afterwards.
  static Future<void> clearTokenSilent() async {
    try { await _storage.deleteAll(); } catch (_) {}
    AuthNotifier.instance.setAuthenticatedSilent(false);
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

  static Future<Response> multipartPost(String path, String filePath, String fieldName) async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(File(filePath).path, filename: filePath.split('/').last),
    });
    return instance.post(
      path,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}
