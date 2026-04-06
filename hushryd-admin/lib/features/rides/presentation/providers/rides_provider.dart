import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';

final ridesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get(ApiEndpoints.rides);
  final data = response.data as Map<String, dynamic>;
  if (data['error'] == true) throw Exception(data['message']);
  final rides = data['data']?['rides'] as List<dynamic>? ?? [];
  return rides.map((r) => r as Map<String, dynamic>).toList();
});
