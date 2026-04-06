import 'package:hushryd_backend/config/database.dart';

/// Booking model with MySQL queries.
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
  final String? createdAt;
  final String? updatedAt;

  Booking({
    required this.id, this.userId, this.rideId, this.passengerCount,
    this.totalPrice, this.currency = 'INR', this.status = 'pending',
    this.paymentStatus = 'pending', this.paymentMethod, this.specialRequests,
    this.createdAt, this.updatedAt,
  });

  factory Booking.fromRow(Map<String, String?> row) => Booking(
    id: row['id'] ?? '', userId: row['user_id'], rideId: row['ride_id'],
    passengerCount: int.tryParse(row['passenger_count'] ?? ''),
    totalPrice: double.tryParse(row['total_price'] ?? ''),
    currency: row['currency'] ?? 'INR',
    status: row['status'] ?? 'pending',
    paymentStatus: row['payment_status'] ?? 'pending',
    paymentMethod: row['payment_method'],
    specialRequests: row['special_requests'],
    createdAt: row['created_at'], updatedAt: row['updated_at'],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'userId': userId, 'rideId': rideId,
    'passengerCount': passengerCount, 'totalPrice': totalPrice,
    'currency': currency, 'status': status, 'paymentStatus': paymentStatus,
    'paymentMethod': paymentMethod, 'specialRequests': specialRequests,
    'createdAt': createdAt, 'updatedAt': updatedAt,
  };

  static Future<Booking?> findById(String id) async {
    final result = await Database.query('SELECT * FROM bookings WHERE id = :id', {'id': id});
    final rows = result.rows.toList();
    if (rows.isEmpty) return null;
    return Booking.fromRow(rows.first.assoc());
  }

  static Future<Booking> create(Map<String, dynamic> data) async {
    await Database.query(
      '''INSERT INTO bookings (id, user_id, ride_id, passenger_count, total_price,
         currency, status, payment_status, payment_method, special_requests)
         VALUES (:id, :userId, :rideId, :passengerCount, :totalPrice,
         :currency, :status, :paymentStatus, :paymentMethod, :specialRequests)''',
      {
        'id': data['id'], 'userId': data['userId'], 'rideId': data['rideId'],
        'passengerCount': data['passengerCount']?.toString(),
        'totalPrice': data['totalPrice']?.toString(),
        'currency': data['currency'] ?? 'INR', 'status': data['status'] ?? 'pending',
        'paymentStatus': data['paymentStatus'] ?? 'pending',
        'paymentMethod': data['paymentMethod'],
        'specialRequests': data['specialRequests'],
      },
    );
    return (await findById(data['id'] as String))!;
  }

  static Future<List<Booking>> findByUserId(String userId) async {
    final result = await Database.query(
      'SELECT * FROM bookings WHERE user_id = :userId ORDER BY created_at DESC',
      {'userId': userId});
    return result.rows.map((r) => Booking.fromRow(r.assoc())).toList();
  }

  static Future<List<Map<String, dynamic>>> findAllWithDetails({
    int page = 1, int limit = 10,
    String? userId, String? rideId, String? status, String? paymentStatus,
  }) async {
    var sql = '''
      SELECT b.*, u.first_name, u.last_name, u.email as passenger_email,
        u.phone as passenger_phone, r.from_location, r.to_location,
        r.pickup_date, r.pickup_time
      FROM bookings b
      LEFT JOIN users u ON b.user_id = u.id
      LEFT JOIN rides r ON b.ride_id = r.id WHERE 1=1
    ''';
    final params = <String, dynamic>{};
    if (userId != null) { sql += ' AND b.user_id = :userId'; params['userId'] = userId; }
    if (rideId != null) { sql += ' AND b.ride_id = :rideId'; params['rideId'] = rideId; }
    if (status != null) { sql += ' AND b.status = :status'; params['status'] = status; }
    if (paymentStatus != null) { sql += ' AND b.payment_status = :paymentStatus'; params['paymentStatus'] = paymentStatus; }
    sql += ' ORDER BY b.created_at DESC LIMIT :lim OFFSET :off';
    params['lim'] = limit.toString();
    params['off'] = ((page - 1) * limit).toString();

    final result = await Database.query(sql, params);
    return result.rows.map((r) {
      final row = r.assoc();
      return <String, dynamic>{
        'id': row['id'], 'userId': row['user_id'], 'rideId': row['ride_id'],
        'passengerName': '${row['first_name'] ?? ''} ${row['last_name'] ?? ''}'.trim(),
        'passengerPhone': row['passenger_phone'] ?? 'N/A',
        'passengerEmail': row['passenger_email'] ?? 'N/A',
        'from': row['from_location'] ?? 'N/A', 'to': row['to_location'] ?? 'N/A',
        'rideDate': row['pickup_date'] ?? '', 'rideTime': row['pickup_time'] ?? '',
        'seatsBooked': row['passenger_count'],
        'totalAmount': double.tryParse(row['total_price'] ?? '') ?? 0,
        'status': row['status'] ?? 'pending', 'paymentStatus': row['payment_status'] ?? 'pending',
        'specialRequests': row['special_requests'],
      };
    }).toList();
  }

  Future<Booking> update(Map<String, dynamic> data) async {
    final mapping = {
      'passengerCount': 'passenger_count', 'totalPrice': 'total_price',
      'currency': 'currency', 'status': 'status',
      'paymentStatus': 'payment_status', 'paymentMethod': 'payment_method',
      'specialRequests': 'special_requests',
    };
    final sets = <String>[]; final params = <String, dynamic>{};
    for (final e in data.entries) {
      if (mapping.containsKey(e.key)) {
        sets.add('${mapping[e.key]} = :${e.key}');
        params[e.key] = e.value?.toString();
      }
    }
    if (sets.isEmpty) throw Exception('No valid fields to update');
    sets.add('updated_at = CURRENT_TIMESTAMP');
    params['id'] = id;
    await Database.query('UPDATE bookings SET ${sets.join(', ')} WHERE id = :id', params);
    return (await findById(id))!;
  }

  Future<Booking> cancel() async {
    await Database.query(
      "UPDATE bookings SET status = 'cancelled', updated_at = CURRENT_TIMESTAMP WHERE id = :id",
      {'id': id});
    if (rideId != null && passengerCount != null) {
      await Database.query(
        'UPDATE rides SET available_seats = available_seats + :count WHERE id = :rideId',
        {'count': passengerCount.toString(), 'rideId': rideId!});
    }
    return (await findById(id))!;
  }

  Future<void> delete() async {
    if (rideId != null && passengerCount != null) {
      await Database.query(
        'UPDATE rides SET available_seats = available_seats + :count WHERE id = :rideId',
        {'count': passengerCount.toString(), 'rideId': rideId!});
    }
    await Database.query('DELETE FROM bookings WHERE id = :id', {'id': id});
  }

  static Future<Map<String, String?>> getStats() async {
    final result = await Database.query('''
      SELECT COUNT(*) as totalBookings,
        COUNT(CASE WHEN status = 'pending' THEN 1 END) as pendingBookings,
        COUNT(CASE WHEN status = 'confirmed' THEN 1 END) as confirmedBookings,
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelledBookings,
        COUNT(CASE WHEN status = 'completed' THEN 1 END) as completedBookings,
        COUNT(CASE WHEN payment_status = 'paid' THEN 1 END) as paidBookings,
        COALESCE(SUM(total_price), 0) as totalRevenue,
        COALESCE(AVG(total_price), 0) as averageBookingValue
      FROM bookings
    ''');
    return result.rows.first.assoc();
  }
}
