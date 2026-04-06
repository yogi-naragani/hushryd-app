import 'package:hushryd_backend/config/database.dart';

/// User model with MySQL queries using :name parameters.
class User {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final bool isVerified;
  final bool isActive;
  final String role;
  final String? profileImage;
  final String? emergencyContact;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? bio;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id, this.email, this.firstName, this.lastName, this.phone,
    this.isVerified = false, this.isActive = true, this.role = 'user',
    this.profileImage, this.emergencyContact, this.address, this.city,
    this.state, this.pincode, this.bio, this.createdAt, this.updatedAt,
  });

  factory User.fromRow(Map<String, String?> row) => User(
    id: row['id'] ?? '',
    email: row['email'],
    firstName: row['first_name'],
    lastName: row['last_name'],
    phone: row['phone'],
    isVerified: row['is_verified'] == '1',
    isActive: row['is_active'] == '1',
    role: row['role'] ?? 'user',
    profileImage: row['profile_image'],
    emergencyContact: row['emergency_contact'],
    address: row['address'],
    city: row['city'],
    state: row['state'],
    pincode: row['pincode'],
    bio: row['bio'],
    createdAt: row['created_at'],
    updatedAt: row['updated_at'],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'email': email, 'firstName': firstName, 'lastName': lastName,
    'phone': phone, 'isVerified': isVerified, 'isActive': isActive,
    'role': role, 'profileImage': profileImage,
    'emergencyContact': emergencyContact, 'address': address, 'city': city,
    'state': state, 'pincode': pincode, 'bio': bio,
    'createdAt': createdAt, 'updatedAt': updatedAt,
  };

  static Future<User?> findById(String id) async {
    final result = await Database.query(
      'SELECT * FROM users WHERE id = :id', {'id': id});
    final rows = result.rows.toList();
    if (rows.isEmpty) return null;
    return User.fromRow(rows.first.assoc());
  }

  static Future<User?> findByEmail(String email) async {
    final result = await Database.query(
      'SELECT * FROM users WHERE email = :email', {'email': email});
    final rows = result.rows.toList();
    if (rows.isEmpty) return null;
    return User.fromRow(rows.first.assoc());
  }

  static Future<User> create(Map<String, dynamic> data) async {
    await Database.query(
      '''INSERT INTO users (id, email, first_name, last_name, phone, is_verified, is_active, role, profile_image)
         VALUES (:id, :email, :firstName, :lastName, :phone, :isVerified, :isActive, :role, :profileImage)''',
      {
        'id': data['id'], 'email': data['email'],
        'firstName': data['firstName'], 'lastName': data['lastName'],
        'phone': data['phone'],
        'isVerified': data['isVerified'] == true ? '1' : '0',
        'isActive': data['isActive'] != false ? '1' : '0',
        'role': data['role'] ?? 'user',
        'profileImage': data['profileImage'],
      },
    );
    return (await findById(data['id'] as String))!;
  }

  static Future<List<User>> findAll({int page = 1, int limit = 10,
      String? role, bool? isActive, bool? isVerified}) async {
    // Build dynamic query (mysql_client doesn't support dynamic WHERE with named params well)
    // So we use string interpolation for filter values that we control (not user input for injection)
    var sql = 'SELECT * FROM users WHERE 1=1';
    final params = <String, dynamic>{};

    if (role != null) { sql += ' AND role = :role'; params['role'] = role; }
    if (isActive != null) { sql += ' AND is_active = :isActive'; params['isActive'] = isActive ? '1' : '0'; }
    if (isVerified != null) { sql += ' AND is_verified = :isVerified'; params['isVerified'] = isVerified ? '1' : '0'; }

    final offset = (page - 1) * limit;
    sql += ' ORDER BY created_at DESC LIMIT :lim OFFSET :off';
    params['lim'] = limit.toString();
    params['off'] = offset.toString();

    final result = await Database.query(sql, params);
    return result.rows.map((r) => User.fromRow(r.assoc())).toList();
  }

  Future<User> update(Map<String, dynamic> data) async {
    final mapping = {
      'firstName': 'first_name', 'lastName': 'last_name', 'phone': 'phone',
      'email': 'email', 'isVerified': 'is_verified', 'isActive': 'is_active',
      'role': 'role', 'profileImage': 'profile_image',
      'emergencyContact': 'emergency_contact', 'address': 'address',
      'city': 'city', 'state': 'state', 'pincode': 'pincode', 'bio': 'bio',
    };

    final sets = <String>[]; final params = <String, dynamic>{};
    for (final e in data.entries) {
      if (mapping.containsKey(e.key) && e.value != null) {
        sets.add('${mapping[e.key]} = :${e.key}');
        params[e.key] = e.value.toString();
      }
    }
    if (sets.isEmpty) throw Exception('No valid fields to update');

    sets.add('updated_at = CURRENT_TIMESTAMP');
    params['id'] = id;
    await Database.query('UPDATE users SET ${sets.join(', ')} WHERE id = :id', params);
    return (await findById(id))!;
  }

  Future<void> delete() async =>
      Database.query('DELETE FROM users WHERE id = :id', {'id': id});

  static Future<Map<String, String?>> getStats() async {
    final result = await Database.query('''
      SELECT COUNT(*) as totalUsers,
        COUNT(CASE WHEN role = 'user' THEN 1 END) as totalRegularUsers,
        COUNT(CASE WHEN role = 'driver' THEN 1 END) as totalDrivers,
        COUNT(CASE WHEN is_verified = 1 THEN 1 END) as verifiedUsers,
        COUNT(CASE WHEN is_active = 1 THEN 1 END) as activeUsers,
        COUNT(CASE WHEN is_active = 0 THEN 1 END) as inactiveUsers
      FROM users
    ''');
    return result.rows.first.assoc();
  }
}
