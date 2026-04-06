import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';

final adminsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get(ApiEndpoints.admins);
  final data = response.data as Map<String, dynamic>;
  if (data['error'] == true) throw Exception(data['message']);
  final admins = data['data']?['admins'] as List<dynamic>? ?? [];
  return admins.map((a) => a as Map<String, dynamic>).toList();
});
