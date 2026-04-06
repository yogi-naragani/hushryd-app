import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';

final dashboardStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get(ApiEndpoints.dashboardStats);
    final data = response.data as Map<String, dynamic>;
    if (data['error'] == true) return {};
    return (data['data']?['stats'] as Map<String, dynamic>?) ?? {};
  } catch (_) {
    return {};
  }
});
