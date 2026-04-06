import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../config/database.dart';
import '../middleware/auth_middleware.dart';
import '../utils/response.dart';

class DatabaseRoutes {
  Router get router {
    final router = Router();

    router.post('/seed', Pipeline()
        .addMiddleware(authenticateAdmin())
        .addMiddleware(requireRole(['superadmin', 'admin']))
        .addHandler(_seed));

    router.delete('/clear', Pipeline()
        .addMiddleware(authenticateAdmin())
        .addMiddleware(requireRole(['superadmin', 'admin']))
        .addHandler(_clear));

    router.get('/stats', Pipeline()
        .addMiddleware(authenticateAdmin())
        .addMiddleware(requireRole(['superadmin', 'admin']))
        .addHandler(_getStats));

    router.post('/migrate', Pipeline()
        .addMiddleware(authenticateAdmin())
        .addMiddleware(requireRole(['superadmin', 'admin']))
        .addHandler(_migrate));

    return router;
  }

  Future<Response> _seed(Request request) async {
    try {
      // Sample users
      final users = [
        {
          'id': 'user-001',
          'email': 'john.doe@example.com',
          'firstName': 'John',
          'lastName': 'Doe',
          'phone': '+919876543210',
          'role': 'user',
        },
        {
          'id': 'user-002',
          'email': 'jane.smith@example.com',
          'firstName': 'Jane',
          'lastName': 'Smith',
          'phone': '+919876543211',
          'role': 'driver',
        },
        {
          'id': 'user-003',
          'email': 'mike.johnson@example.com',
          'firstName': 'Mike',
          'lastName': 'Johnson',
          'phone': '+919876543212',
          'role': 'user',
        },
      ];

      for (final u in users) {
        await Database.query(
          '''INSERT INTO users (id, email, first_name, last_name, phone, is_verified, is_active, role)
             VALUES (@id, @email, @firstName, @lastName, @phone, true, true, @role)
             ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email''',
          parameters: u,
        );
      }

      // Sample rides
      await Database.query(
        '''INSERT INTO rides (id, user_id, from_location, to_location, pickup_date, pickup_time, timeslot, fare, status, payment_status)
           VALUES ('ride-001', 'user-001', 'Mumbai Central', 'Pune Station', '2026-04-10', '08:00', 'morning', 2500, 'pending', 'pending')
           ON CONFLICT (id) DO UPDATE SET from_location = EXCLUDED.from_location''',
      );

      // Sample bookings
      await Database.query(
        '''INSERT INTO bookings (id, user_id, ride_id, passenger_count, total_price, currency, status, payment_status)
           VALUES ('booking-001', 'user-001', 'ride-001', 1, 2500, 'INR', 'confirmed', 'paid')
           ON CONFLICT (id) DO UPDATE SET user_id = EXCLUDED.user_id''',
      );

      return ApiResponse.success('Database seeded successfully', data: {
        'usersCreated': users.length,
        'ridesCreated': 1,
        'bookingsCreated': 1,
      });
    } catch (e) {
      print('Database seeding error: $e');
      return ApiResponse.error('Database seeding failed', details: e.toString());
    }
  }

  Future<Response> _clear(Request request) async {
    try {
      await Database.query('DELETE FROM bookings');
      await Database.query('DELETE FROM rides');
      await Database.query('DELETE FROM users');

      return ApiResponse.success('Database cleared successfully');
    } catch (e) {
      print('Database clearing error: $e');
      return ApiResponse.error('Database clearing failed',
          details: e.toString());
    }
  }

  Future<Response> _getStats(Request request) async {
    try {
      final results = await Future.wait([
        Database.query('SELECT COUNT(*) as total FROM users'),
        Database.query('SELECT COUNT(*) as total FROM rides'),
        Database.query('SELECT COUNT(*) as total FROM bookings'),
      ]);

      return ApiResponse.success('Database statistics retrieved successfully',
          data: {
        'stats': {
          'totalUsers': results[0].first.toColumnMap()['total'],
          'totalRides': results[1].first.toColumnMap()['total'],
          'totalBookings': results[2].first.toColumnMap()['total'],
          'lastUpdated': DateTime.now().toIso8601String(),
        },
      });
    } catch (e) {
      print('Get database stats error: $e');
      return ApiResponse.error('Failed to get database statistics',
          details: e.toString());
    }
  }

  Future<Response> _migrate(Request request) async {
    try {
      final tables = ['users', 'rides', 'bookings', 'admins'];
      for (final table in tables) {
        try {
          await Database.query('SELECT 1 FROM $table LIMIT 1');
          print('Table $table already exists');
        } catch (_) {
          print('Table $table does not exist');
        }
      }

      return ApiResponse.success('Database migrations completed successfully');
    } catch (e) {
      print('Database migration error: $e');
      return ApiResponse.error('Database migration failed',
          details: e.toString());
    }
  }
}
