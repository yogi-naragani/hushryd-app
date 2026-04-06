import '../config/database.dart';

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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Ride({
    required this.id,
    this.userId,
    this.driverId,
    this.fromLocation,
    this.toLocation,
    this.pickupDate,
    this.pickupTime,
    this.timeslot,
    this.fare,
    this.distance,
    this.duration,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    this.paymentMethod,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Ride.fromRow(Map<String, dynamic> row) {
    return Ride(
      id: row['id'] as String,
      userId: row['user_id'] as String?,
      driverId: row['driver_id'] as String?,
      fromLocation: row['from_location']?.toString(),
      toLocation: row['to_location']?.toString(),
      pickupDate: row['pickup_date']?.toString(),
      pickupTime: row['pickup_time']?.toString(),
      timeslot: row['timeslot'] as String?,
      fare: _toDouble(row['fare']),
      distance: _toDouble(row['distance']),
      duration: row['duration'] as int?,
      status: row['status'] as String? ?? 'pending',
      paymentStatus: row['payment_status'] as String? ?? 'pending',
      paymentMethod: row['payment_method'] as String?,
      notes: row['notes'] as String?,
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
        'driverId': driverId,
        'fromLocation': fromLocation,
        'toLocation': toLocation,
        'pickupDate': pickupDate,
        'pickupTime': pickupTime,
        'timeslot': timeslot,
        'fare': fare,
        'distance': distance,
        'duration': duration,
        'status': status,
        'paymentStatus': paymentStatus,
        'paymentMethod': paymentMethod,
        'notes': notes,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static Future<Ride?> findById(String id) async {
    final result = await Database.query(
      'SELECT * FROM rides WHERE id = @id',
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return Ride.fromRow(result.first.toColumnMap());
  }

  static Future<Ride> create(Map<String, dynamic> data) async {
    await Database.query(
      '''INSERT INTO rides (id, user_id, driver_id, from_location, to_location, pickup_date,
           pickup_time, timeslot, fare, distance, duration, status, payment_status, payment_method, notes)
         VALUES (@id, @userId, @driverId, @fromLocation, @toLocation, @pickupDate,
           @pickupTime, @timeslot, @fare, @distance, @duration, @status, @paymentStatus, @paymentMethod, @notes)''',
      parameters: {
        'id': data['id'],
        'userId': data['userId'],
        'driverId': data['driverId'],
        'fromLocation': data['fromLocation'],
        'toLocation': data['toLocation'],
        'pickupDate': data['pickupDate'],
        'pickupTime': data['pickupTime'],
        'timeslot': data['timeslot'],
        'fare': data['fare'],
        'distance': data['distance'],
        'duration': data['duration'],
        'status': data['status'] ?? 'pending',
        'paymentStatus': data['paymentStatus'] ?? 'pending',
        'paymentMethod': data['paymentMethod'],
        'notes': data['notes'],
      },
    );
    return (await findById(data['id'] as String))!;
  }

  static Future<List<Ride>> findAll({
    int page = 1,
    int limit = 10,
    String? status,
    String? userId,
    String? driverId,
    String? pickupDate,
  }) async {
    var sql = 'SELECT * FROM rides WHERE 1=1';
    final params = <String, dynamic>{};

    if (status != null) {
      sql += ' AND status = @status';
      params['status'] = status;
    }
    if (userId != null) {
      sql += ' AND user_id = @userId';
      params['userId'] = userId;
    }
    if (driverId != null) {
      sql += ' AND driver_id = @driverId';
      params['driverId'] = driverId;
    }
    if (pickupDate != null) {
      sql += ' AND pickup_date = @pickupDate';
      params['pickupDate'] = pickupDate;
    }

    final offset = (page - 1) * limit;
    sql += ' ORDER BY created_at DESC LIMIT @limit OFFSET @offset';
    params['limit'] = limit;
    params['offset'] = offset;

    final result = await Database.query(sql, parameters: params);
    return result.map((r) => Ride.fromRow(r.toColumnMap())).toList();
  }

  Future<Ride> update(Map<String, dynamic> data) async {
    final fieldMapping = {
      'userId': 'user_id',
      'driverId': 'driver_id',
      'fromLocation': 'from_location',
      'toLocation': 'to_location',
      'pickupDate': 'pickup_date',
      'pickupTime': 'pickup_time',
      'timeslot': 'timeslot',
      'fare': 'fare',
      'distance': 'distance',
      'duration': 'duration',
      'status': 'status',
      'paymentStatus': 'payment_status',
      'paymentMethod': 'payment_method',
      'notes': 'notes',
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
      'UPDATE rides SET ${sets.join(', ')} WHERE id = @id',
      parameters: params,
    );
    return (await findById(id))!;
  }

  Future<void> delete() async {
    await Database.query('DELETE FROM rides WHERE id = @id',
        parameters: {'id': id});
  }

  static Future<Map<String, dynamic>> getStats() async {
    final result = await Database.query('''
      SELECT
        COUNT(*) as "totalRides",
        COUNT(CASE WHEN status = 'pending' THEN 1 END) as "pendingRides",
        COUNT(CASE WHEN status = 'confirmed' THEN 1 END) as "confirmedRides",
        COUNT(CASE WHEN status = 'in_progress' THEN 1 END) as "inProgressRides",
        COUNT(CASE WHEN status = 'completed' THEN 1 END) as "completedRides",
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as "cancelledRides",
        COALESCE(SUM(CASE WHEN status = 'completed' THEN fare ELSE 0 END), 0) as "totalRevenue",
        COALESCE(AVG(CASE WHEN status = 'completed' THEN fare ELSE NULL END), 0) as "averageFare"
      FROM rides
    ''');
    return result.first.toColumnMap();
  }
}
