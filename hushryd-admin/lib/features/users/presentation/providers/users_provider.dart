import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';

final usersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get(ApiEndpoints.users);
  final data = response.data as Map<String, dynamic>;
  if (data['error'] == true) throw Exception(data['message']);
  final users = data['data']?['users'] as List<dynamic>? ?? [];
  return users.map((u) => u as Map<String, dynamic>).toList();
});
