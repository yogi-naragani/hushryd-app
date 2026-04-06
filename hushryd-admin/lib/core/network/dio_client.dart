import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_endpoints.dart';
import '../security/secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  // Auth interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await SecureStorage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        await SecureStorage.clearAll();
      }
      handler.next(error);
    },
  ));

  // Logging interceptor (debug only)
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (msg) => print('[DIO] $msg'),
  ));

  return dio;
});

/// Generic API response matching backend format.
class ApiResponse<T> {
  final bool error;
  final String message;
  final T? data;

  ApiResponse({required this.error, required this.message, this.data});

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic)? fromData) {
    return ApiResponse(
      error: json['error'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : json['data'] as T?,
    );
  }
}
