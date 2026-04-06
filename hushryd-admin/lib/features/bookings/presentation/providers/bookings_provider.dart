import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';

final bookingsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get(ApiEndpoints.bookings);
  final data = response.data as Map<String, dynamic>;
  if (data['error'] == true) throw Exception(data['message']);
  final bookings = data['data']?['bookings'] as List<dynamic>? ?? [];
  return bookings.map((b) => b as Map<String, dynamic>).toList();
});
