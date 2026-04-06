import 'package:dart_frog/dart_frog.dart';
import 'package:hushryd_backend/models/user.dart';
import 'package:hushryd_backend/models/ride.dart';
import 'package:hushryd_backend/models/booking.dart';
import 'package:hushryd_backend/models/admin.dart';
import 'package:hushryd_backend/middleware/auth.dart';
import 'package:hushryd_backend/utils/response.dart';

Future<Response> onRequest(RequestContext context) async {
  final payload = extractTokenPayload(context);
  if (payload == null) return ApiResponse.unauthorized('No token');
  if (!hasRole(payload, ['superadmin', 'admin'])) return ApiResponse.forbidden('Access denied');

  try {
    final results = await Future.wait([
      User.getStats(), Ride.getStats(), Booking.getStats(), Admin.getStats(),
    ]);
    return ApiResponse.success('Dashboard stats retrieved', data: {
      'stats': {
        'users': results[0], 'rides': results[1],
        'bookings': results[2], 'admins': results[3],
        'overview': {
          'totalUsers': results[0]['totalUsers'],
          'totalRides': results[1]['totalRides'],
          'totalBookings': results[2]['totalBookings'],
          'totalRevenue': results[2]['totalRevenue'],
          'activeUsers': results[0]['activeUsers'],
          'completedRides': results[1]['completedRides'],
          'pendingBookings': results[2]['pendingBookings'],
        },
      },
    });
  } catch (e) {
    return ApiResponse.error('Internal server error');
  }
}
