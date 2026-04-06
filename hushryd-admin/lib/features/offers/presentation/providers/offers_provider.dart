import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';

final offersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get(ApiEndpoints.offers);
  final data = response.data as Map<String, dynamic>;
  if (data['error'] == true) throw Exception(data['message']);
  final offers = data['data']?['offers'] as List<dynamic>? ?? [];
  return offers.map((o) => o as Map<String, dynamic>).toList();
});
