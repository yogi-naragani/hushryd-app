import 'package:hushryd_backend/config/database.dart';

/// Ride model with MySQL queries.
class Ride {
  final String id;
  final String? userId;
  final String? driverId;
  final String? fromLocation;
  final String? toLocation;
  final String? pickupDate;
  final String? pickupTime;
  final String? timeslot;
  final double? fare;
  final double? distance;
  final int? duration;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  Ride({
    required this.id, this.userId, this.driverId, this.fromLocation,
    this.toLocation, this.pickupDate, this.pickupTime, this.timeslot,
    this.fare, this.distance, this.duration, this.status = 'pending',
    this.paymentStatus = 'pending', this.paymentMethod, this.notes,
    this.createdAt, this.updatedAt,
  });

  factory Ride.fromRow(Map<String, String?> row) => Ride(
    id: row['id'] ?? '', userId: row['user_id'], driverId: row['driver_id'],
    fromLocation: row['from_location'], toLocation: row['to_location'],
    pickupDate: row['pickup_date'], pickupTime: row['pickup_time'],
    timeslot: row['timeslot'],
    fare: double.tryParse(row['fare'] ?? ''),
    distance: double.tryParse(row['distance'] ?? ''),
    duration: int.tryParse(row['duration'] ?? ''),
    status: row['status'] ?? 'pending',
    paymentStatus: row['payment_status'] ?? 'pending',
    paymentMethod: row['payment_method'], notes: row['notes'],
    createdAt: row['created_at'], updatedAt: row['updated_at'],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'userId': userId, 'driverId': driverId,
    'fromLocation': fromLocation, 'toLocation': toLocation,
    'pickupDate': pickupDate, 'pickupTime': pickupTime, 'timeslot': timeslot,
    'fare': fare, 'distance': distance, 'duration': duration,
    'status': status, 'paymentStatus': paymentStatus,
    'paymentMethod': paymentMethod, 'notes': notes,
    'createdAt': createdAt, 'updatedAt': updatedAt,
  };

  static Future<Ride?> findById(String id) async {
    final result = await Database.query('SELECT * FROM rides WHERE id = :id', {'id': id});
    final rows = result.rows.toList();
    if (rows.isEmpty) return null;
    return Ride.fromRow(rows.first.assoc());
  }

  static Future<Ride> create(Map<String, dynamic> data) async {
    await Database.query(
      '''INSERT INTO rides (id, user_id, driver_id, from_location, to_location,
         pickup_date, pickup_time, timeslot, fare, distance, duration, status,
         payment_status, payment_method, notes)
         VALUES (:id, :userId, :driverId, :fromLocation, :toLocation,
         :pickupDate, :pickupTime, :timeslot, :fare, :distance, :duration,
         :status, :paymentStatus, :paymentMethod, :notes)''',
      {
        'id': data['id'], 'userId': data['userId'], 'driverId': data['driverId'],
        'fromLocation': data['fromLocation'], 'toLocation': data['toLocation'],
        'pickupDate': data['pickupDate'], 'pickupTime': data['pickupTime'],
        'timeslot': data['timeslot'], 'fare': data['fare']?.toString(),
        'distance': data['distance']?.toString(), 'duration': data['duration']?.toString(),
        'status': data['status'] ?? 'pending', 'paymentStatus': data['paymentStatus'] ?? 'pending',
        'paymentMethod': data['paymentMethod'], 'notes': data['notes'],
      },
    );
    return (await findById(data['id'] as String))!;
  }

  static Future<List<Ride>> findAll({int page = 1, int limit = 10,
      String? status, String? userId, String? driverId, String? pickupDate}) async {
    var sql = 'SELECT * FROM rides WHERE 1=1';
    final params = <String, dynamic>{};
    if (status != null) { sql += ' AND status = :status'; params['status'] = status; }
    if (userId != null) { sql += ' AND user_id = :userId'; params['userId'] = userId; }
    if (driverId != null) { sql += ' AND driver_id = :driverId'; params['driverId'] = driverId; }
    if (pickupDate != null) { sql += ' AND pickup_date = :pickupDate'; params['pickupDate'] = pickupDate; }
    sql += ' ORDER BY created_at DESC LIMIT :lim OFFSET :off';
    params['lim'] = limit.toString();
    params['off'] = ((page - 1) * limit).toString();
    final result = await Database.query(sql, params);
    return result.rows.map((r) => Ride.fromRow(r.assoc())).toList();
  }

  Future<Ride> update(Map<String, dynamic> data) async {
    final mapping = {
      'userId': 'user_id', 'driverId': 'driver_id',
      'fromLocation': 'from_location', 'toLocation': 'to_location',
      'pickupDate': 'pickup_date', 'pickupTime': 'pickup_time',
      'timeslot': 'timeslot', 'fare': 'fare', 'distance': 'distance',
      'duration': 'duration', 'status': 'status',
      'paymentStatus': 'payment_status', 'paymentMethod': 'payment_method', 'notes': 'notes',
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
    await Database.query('UPDATE rides SET ${sets.join(', ')} WHERE id = :id', params);
    return (await findById(id))!;
  }

  Future<void> delete() async =>
      Database.query('DELETE FROM rides WHERE id = :id', {'id': id});

  static Future<Map<String, String?>> getStats() async {
    final result = await Database.query('''
      SELECT COUNT(*) as totalRides,
        COUNT(CASE WHEN status = 'pending' THEN 1 END) as pendingRides,
        COUNT(CASE WHEN status = 'completed' THEN 1 END) as completedRides,
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelledRides,
        COALESCE(SUM(CASE WHEN status = 'completed' THEN fare ELSE 0 END), 0) as totalRevenue,
        COALESCE(AVG(CASE WHEN status = 'completed' THEN fare ELSE NULL END), 0) as averageFare
      FROM rides
    ''');
    return result.rows.first.assoc();
  }
}
