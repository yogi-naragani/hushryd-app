import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/user.dart';
import '../models/ride.dart';
import '../models/booking.dart';
import '../models/admin.dart';
import '../middleware/auth_middleware.dart';
import '../utils/response.dart';

class DashboardRoutes {
  Router get router {
    final router = Router();

    router.get('/stats', Pipeline()
        .addMiddleware(authenticateAdmin())
        .addMiddleware(requireRole(['superadmin', 'admin']))
        .addHandler(_getStats));

    router.get('/analytics', Pipeline()
        .addMiddleware(authenticateAdmin())
        .addMiddleware(requireRole(['superadmin', 'admin']))
        .addHandler(_getAnalytics));

    router.get('/recent-activity', Pipeline()
        .addMiddleware(authenticateAdmin())
        .addMiddleware(requireRole(['superadmin', 'admin']))
        .addHandler(_getRecentActivity));

    return router;
  }

  Future<Response> _getStats(Request request) async {
    try {
      final results = await Future.wait([
        User.getStats(),
        Ride.getStats(),
        Booking.getStats(),
        Admin.getStats(),
      ]);

      final userStats = results[0];
      final rideStats = results[1];
      final bookingStats = results[2];
      final adminStats = results[3];

      return ApiResponse.success('Dashboard statistics retrieved successfully',
          data: {
        'stats': {
          'users': userStats,
          'rides': rideStats,
          'bookings': bookingStats,
          'admins': adminStats,
          'overview': {
            'totalUsers': userStats['totalUsers'],
            'totalRides': rideStats['totalRides'],
            'totalBookings': bookingStats['totalBookings'],
            'totalRevenue': bookingStats['totalRevenue'],
            'activeUsers': userStats['activeUsers'],
            'completedRides': rideStats['completedRides'],
            'pendingBookings': bookingStats['pendingBookings'],
          },
        },
      });
    } catch (e) {
      print('Get dashboard stats error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getAnalytics(Request request) async {
    try {
      final period =
          request.requestedUri.queryParameters['period'] ?? '7d';

      final analytics = {
        'period': period,
        'revenue': {
          'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          'data': [1200, 1900, 3000, 5000, 2000, 3000, 4500],
        },
        'bookings': {
          'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          'data': [12, 19, 30, 50, 20, 30, 45],
        },
        'users': {
          'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          'data': [5, 8, 12, 18, 10, 15, 22],
        },
        'rides': {
          'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          'data': [8, 15, 25, 35, 18, 28, 40],
        },
      };

      return ApiResponse.success(
          'Dashboard analytics retrieved successfully',
          data: {'analytics': analytics});
    } catch (e) {
      print('Get dashboard analytics error: $e');
      return ApiResponse.error('Internal server error');
    }
  }

  Future<Response> _getRecentActivity(Request request) async {
    try {
      final activities = [
        {
          'id': '1',
          'type': 'booking',
          'description': 'New booking created by John Doe',
          'timestamp': DateTime.now()
              .subtract(Duration(minutes: 5))
              .toIso8601String(),
          'user': 'John Doe',
        },
        {
          'id': '2',
          'type': 'ride',
          'description': 'Ride completed from Mumbai to Pune',
          'timestamp': DateTime.now()
              .subtract(Duration(minutes: 15))
              .toIso8601String(),
          'user': 'Jane Smith',
        },
        {
          'id': '3',
          'type': 'user',
          'description': 'New user registered',
          'timestamp': DateTime.now()
              .subtract(Duration(minutes: 30))
              .toIso8601String(),
          'user': 'Mike Johnson',
        },
        {
          'id': '4',
          'type': 'payment',
          'description': 'Payment received for booking #12345',
          'timestamp': DateTime.now()
              .subtract(Duration(minutes: 45))
              .toIso8601String(),
          'user': 'Sarah Wilson',
        },
        {
          'id': '5',
          'type': 'ride',
          'description': 'Ride cancelled by driver',
          'timestamp': DateTime.now()
              .subtract(Duration(minutes: 60))
              .toIso8601String(),
          'user': 'Tom Brown',
        },
      ];

      return ApiResponse.success('Recent activity retrieved successfully',
          data: {'activities': activities});
    } catch (e) {
      print('Get recent activity error: $e');
      return ApiResponse.error('Internal server error');
    }
  }
}
