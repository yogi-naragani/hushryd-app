import 'package:postgres/postgres.dart';
import '../config/database.dart';

class Booking {
  final String id;
  final String? userId;
  final String? rideId;
  final int? passengerCount;
  final double? totalPrice;
  final String currency;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final String? specialRequests;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Booking({
    required this.id,
    this.userId,
    this.rideId,
    this.passengerCount,
    this.totalPrice,
    this.currency = 'INR',
    this.status = 'pending',
    this.paymentStatus = 'pending',
    this.paymentMethod,
    this.specialRequests,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromRow(Map<String, dynamic> row) {
    return Booking(
      id: row['id'] as String,
      userId: row['user_id'] as String?,
      rideId: row['ride_id'] as String?,
      passengerCount: row['passenger_count'] as int?,
      totalPrice: _toDouble(row['total_price']),
      currency: row['currency'] as String? ?? 'INR',
      status: row['status'] as String? ?? 'pending',
      paymentStatus: row['payment_status'] as String? ?? 'pending',
      paymentMethod: row['payment_method'] as String?,
      specialRequests: row['special_requests'] as String?,
      createdAt: row['created_at'] as DateTime?,
      updatedAt: row['updated_at'] as DateTime?,
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'rideId': rideId,
        'passengerCount': passengerCount,
        'totalPrice': totalPrice,
        'currency': currency,
        'status': status,
        'paymentStatus': paymentStatus,
        'paymentMethod': paymentMethod,
        'specialRequests': specialRequests,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static Future<Booking?> findById(String id) async {
    final result = await Database.query(
      'SELECT * FROM bookings WHERE id = @id',
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return Booking.fromRow(result.first.toColumnMap());
  }

  static Future<Booking> create(Map<String, dynamic> data) async {
    return await Database.transaction((session) async {
      // Check seat availability
      final rideResult = await session.execute(
        Sql.named('SELECT available_seats, max_passengers FROM rides WHERE id = @rideId'),
        parameters: {'rideId': data['rideId']},
      );
      if (rideResult.isNotEmpty) {
        final ride = rideResult.first.toColumnMap();
        final available = ride['available_seats'] as int?;
        final count = data['passengerCount'] as int;
        if (available != null && available < count) {
          throw Exception('Not enough available seats');
        }
      }

      // Create booking
      await session.execute(
        Sql.named('''INSERT INTO bookings (id, user_id, ride_id, passenger_count, total_price, currency, status, payment_status, payment_method, special_requests)
           VALUES (@id, @userId, @rideId, @passengerCount, @totalPrice, @currency, @status, @paymentStatus, @paymentMethod, @specialRequests)'''),
        parameters: {
          'id': data['id'],
          'userId': data['userId'],
          'rideId': data['rideId'],
          'passengerCount': data['passengerCount'],
          'totalPrice': data['totalPrice'],
          'currency': data['currency'] ?? 'INR',
          'status': data['status'] ?? 'pending',
          'paymentStatus': data['paymentStatus'] ?? 'pending',
          'paymentMethod': data['paymentMethod'],
          'specialRequests': data['specialRequests'],
        },
      );

      // Update available seats
      if (rideResult.isNotEmpty) {
        await session.execute(
          Sql.named('UPDATE rides SET available_seats = available_seats - @count WHERE id = @rideId'),
          parameters: {'count': data['passengerCount'], 'rideId': data['rideId']},
        );
      }

      final created = await session.execute(
        Sql.named('SELECT * FROM bookings WHERE id = @id'),
        parameters: {'id': data['id']},
      );
      return Booking.fromRow(created.first.toColumnMap());
    });
  }

  static Future<List<Booking>> findAll({
    int page = 1,
    int limit = 10,
    String? userId,
    String? rideId,
    String? status,
    String? paymentStatus,
  }) async {
    var sql = 'SELECT * FROM bookings WHERE 1=1';
    final params = <String, dynamic>{};

    if (userId != null) {
      sql += ' AND user_id = @userId';
      params['userId'] = userId;
    }
    if (rideId != null) {
      sql += ' AND ride_id = @rideId';
      params['rideId'] = rideId;
    }
    if (status != null) {
      sql += ' AND status = @status';
      params['status'] = status;
    }
    if (paymentStatus != null) {
      sql += ' AND payment_status = @paymentStatus';
      params['paymentStatus'] = paymentStatus;
    }

    final offset = (page - 1) * limit;
    sql += ' ORDER BY created_at DESC LIMIT @limit OFFSET @offset';
    params['limit'] = limit;
    params['offset'] = offset;

    final result = await Database.query(sql, parameters: params);
    return result.map((r) => Booking.fromRow(r.toColumnMap())).toList();
  }

  static Future<List<Booking>> findByUserId(String userId) async {
    final result = await Database.query(
      'SELECT * FROM bookings WHERE user_id = @userId ORDER BY created_at DESC',
      parameters: {'userId': userId},
    );
    return result.map((r) => Booking.fromRow(r.toColumnMap())).toList();
  }

  /// Get all bookings with JOINs for admin view (matching Express backend).
  static Future<List<Map<String, dynamic>>> findAllWithDetails({
    int page = 1,
    int limit = 10,
    String? userId,
    String? rideId,
    String? status,
    String? paymentStatus,
  }) async {
    var sql = '''
      SELECT
        b.*,
        u.first_name, u.last_name, u.email as passenger_email, u.phone as passenger_phone,
        r.from_location, r.to_location, r.pickup_date, r.pickup_time
      FROM bookings b
      LEFT JOIN users u ON b.user_id = u.id
      LEFT JOIN rides r ON b.ride_id = r.id
      WHERE 1=1
    ''';
    final params = <String, dynamic>{};

    if (userId != null) {
      sql += ' AND b.user_id = @userId';
      params['userId'] = userId;
    }
    if (rideId != null) {
      sql += ' AND b.ride_id = @rideId';
      params['rideId'] = rideId;
    }
    if (status != null) {
      sql += ' AND b.status = @status';
      params['status'] = status;
    }
    if (paymentStatus != null) {
      sql += ' AND b.payment_status = @paymentStatus';
      params['paymentStatus'] = paymentStatus;
    }

    final offset = (page - 1) * limit;
    sql += ' ORDER BY b.created_at DESC LIMIT @limit OFFSET @offset';
    params['limit'] = limit;
    params['offset'] = offset;

    final result = await Database.query(sql, parameters: params);
    return result.map((r) {
      final row = r.toColumnMap();
      return {
        'id': row['id'],
        'userId': row['user_id'],
        'rideId': row['ride_id'],
        'passengerName':
            '${row['first_name'] ?? ''} ${row['last_name'] ?? ''}'.trim(),
        'passengerPhone': row['passenger_phone'] ?? 'N/A',
        'passengerEmail': row['passenger_email'] ?? 'N/A',
        'from': row['from_location'] ?? 'N/A',
        'to': row['to_location'] ?? 'N/A',
        'pickupLocation': row['from_location'] ?? 'N/A',
        'dropLocation': row['to_location'] ?? 'N/A',
        'bookingDate': (row['created_at'] as DateTime?)?.toIso8601String().split('T')[0] ?? '',
        'rideDate': row['pickup_date']?.toString() ?? '',
        'rideTime': row['pickup_time']?.toString() ?? '',
        'seatsBooked': row['passenger_count'],
        'totalAmount': _toDouble(row['total_price']) ?? 0,
        'status': row['status'] ?? 'pending',
        'paymentStatus': row['payment_status'] ?? 'pending',
        'specialRequests': row['special_requests'],
        'createdAt': (row['created_at'] as DateTime?)?.toIso8601String(),
        'updatedAt': (row['updated_at'] as DateTime?)?.toIso8601String(),
      };
    }).toList();
  }

  Future<Booking> update(Map<String, dynamic> data) async {
    final fieldMapping = {
      'passengerCount': 'passenger_count',
      'totalPrice': 'total_price',
      'currency': 'currency',
      'status': 'status',
      'paymentStatus': 'payment_status',
      'paymentMethod': 'payment_method',
      'specialRequests': 'special_requests',
    };

    final sets = <String>[];
    final params = <String, dynamic>{'id': id};

    for (final entry in data.entries) {
      if (fieldMapping.containsKey(entry.key)) {
        final dbKey = fieldMapping[entry.key]!;
        sets.add('$dbKey = @${entry.key}');
        params[entry.key] = entry.value;
      }
    }

    if (sets.isEmpty) throw Exception('No valid fields to update');

    sets.add('updated_at = CURRENT_TIMESTAMP');
    await Database.query(
      'UPDATE bookings SET ${sets.join(', ')} WHERE id = @id',
      parameters: params,
    );
    return (await findById(id))!;
  }

  Future<Booking> cancel() async {
    return await Database.transaction((session) async {
      await session.execute(
        Sql.named("UPDATE bookings SET status = 'cancelled', updated_at = CURRENT_TIMESTAMP WHERE id = @id"),
        parameters: {'id': id},
      );
      if (rideId != null && passengerCount != null) {
        await session.execute(
          Sql.named('UPDATE rides SET available_seats = available_seats + @count WHERE id = @rideId'),
          parameters: {'count': passengerCount, 'rideId': rideId},
        );
      }
      final result = await session.execute(
        Sql.named('SELECT * FROM bookings WHERE id = @id'),
        parameters: {'id': id},
      );
      return Booking.fromRow(result.first.toColumnMap());
    });
  }

  Future<void> delete() async {
    await Database.transaction((session) async {
      if (rideId != null && passengerCount != null) {
        await session.execute(
          Sql.named('UPDATE rides SET available_seats = available_seats + @count WHERE id = @rideId'),
          parameters: {'count': passengerCount, 'rideId': rideId},
        );
      }
      await session.execute(
        Sql.named('DELETE FROM bookings WHERE id = @id'),
        parameters: {'id': id},
      );
    });
  }

  static Future<Map<String, dynamic>> getStats() async {
    final result = await Database.query('''
      SELECT
        COUNT(*) as "totalBookings",
        COUNT(CASE WHEN status = 'pending' THEN 1 END) as "pendingBookings",
        COUNT(CASE WHEN status = 'confirmed' THEN 1 END) as "confirmedBookings",
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as "cancelledBookings",
        COUNT(CASE WHEN status = 'completed' THEN 1 END) as "completedBookings",
        COUNT(CASE WHEN payment_status = 'paid' THEN 1 END) as "paidBookings",
        COALESCE(SUM(total_price), 0) as "totalRevenue",
        COALESCE(AVG(total_price), 0) as "averageBookingValue"
      FROM bookings
    ''');
    return result.first.toColumnMap();
  }
}
