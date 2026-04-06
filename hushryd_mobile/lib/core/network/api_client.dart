import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api.dart';
import '../security/secure_storage.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          SecureStorage.clearAll();
        }
        handler.next(error);
      },
    ));
  }

  Future<ApiResponse> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(path, queryParameters: params);
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromError(e);
    }
  }

  Future<ApiResponse> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromError(e);
    }
  }

  Future<ApiResponse> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromError(e);
    }
  }

  Future<ApiResponse> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return ApiResponse.fromResponse(response);
    } on DioException catch (e) {
      return ApiResponse.fromError(e);
    }
  }
}

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int? statusCode;

  ApiResponse({required this.success, required this.message, this.data, this.statusCode});

  factory ApiResponse.fromResponse(Response response) {
    final body = response.data as Map<String, dynamic>? ?? {};
    return ApiResponse(
      success: body['error'] != true && (response.statusCode ?? 500) < 400,
      message: body['message']?.toString() ?? 'Success',
      data: body['data'],
      statusCode: response.statusCode,
    );
  }

  factory ApiResponse.fromError(DioException e) {
    final body = e.response?.data;
    String message = 'Network error';
    if (body is Map<String, dynamic>) {
      message = body['message']?.toString() ?? 'Request failed';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout';
    }
    return ApiResponse(success: false, message: message, statusCode: e.response?.statusCode);
  }
}
