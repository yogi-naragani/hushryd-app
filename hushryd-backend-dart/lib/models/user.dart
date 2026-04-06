import '../config/database.dart';

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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.isVerified = false,
    this.isActive = true,
    this.role = 'user',
    this.profileImage,
    this.emergencyContact,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.bio,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromRow(Map<String, dynamic> row) {
    return User(
      id: row['id'] as String,
      email: row['email'] as String?,
      firstName: row['first_name'] as String?,
      lastName: row['last_name'] as String?,
      phone: row['phone'] as String?,
      isVerified: row['is_verified'] as bool? ?? false,
      isActive: row['is_active'] as bool? ?? true,
      role: row['role'] as String? ?? 'user',
      profileImage: row['profile_image'] as String?,
      emergencyContact: row['emergency_contact'] as String?,
      address: row['address'] as String?,
      city: row['city'] as String?,
      state: row['state'] as String?,
      pincode: row['pincode'] as String?,
      bio: row['bio'] as String?,
      createdAt: row['created_at'] as DateTime?,
      updatedAt: row['updated_at'] as DateTime?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'isVerified': isVerified,
        'isActive': isActive,
        'role': role,
        'profileImage': profileImage,
        'emergencyContact': emergencyContact,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
        'bio': bio,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static Future<User?> findById(String id) async {
    final result = await Database.query(
      'SELECT * FROM users WHERE id = @id',
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return User.fromRow(result.first.toColumnMap());
  }

  static Future<User?> findByEmail(String email) async {
    final result = await Database.query(
      'SELECT * FROM users WHERE email = @email',
      parameters: {'email': email},
    );
    if (result.isEmpty) return null;
    return User.fromRow(result.first.toColumnMap());
  }

  static Future<User> create(Map<String, dynamic> data) async {
    await Database.query(
      '''INSERT INTO users (id, email, first_name, last_name, phone, is_verified, is_active, role, profile_image)
         VALUES (@id, @email, @firstName, @lastName, @phone, @isVerified, @isActive, @role, @profileImage)''',
      parameters: {
        'id': data['id'],
        'email': data['email'],
        'firstName': data['firstName'],
        'lastName': data['lastName'],
        'phone': data['phone'],
        'isVerified': data['isVerified'] ?? false,
        'isActive': data['isActive'] ?? true,
        'role': data['role'] ?? 'user',
        'profileImage': data['profileImage'],
      },
    );
    return (await findById(data['id'] as String))!;
  }

  static Future<List<User>> findAll({
    int page = 1,
    int limit = 10,
    String? role,
    bool? isActive,
    bool? isVerified,
  }) async {
    var sql = 'SELECT * FROM users WHERE 1=1';
    final params = <String, dynamic>{};

    if (role != null) {
      sql += ' AND role = @role';
      params['role'] = role;
    }
    if (isActive != null) {
      sql += ' AND is_active = @isActive';
      params['isActive'] = isActive;
    }
    if (isVerified != null) {
      sql += ' AND is_verified = @isVerified';
      params['isVerified'] = isVerified;
    }

    final offset = (page - 1) * limit;
    sql += ' ORDER BY created_at DESC LIMIT @limit OFFSET @offset';
    params['limit'] = limit;
    params['offset'] = offset;

    final result = await Database.query(sql, parameters: params);
    return result.map((r) => User.fromRow(r.toColumnMap())).toList();
  }

  Future<User> update(Map<String, dynamic> data) async {
    final fieldMapping = {
      'firstName': 'first_name',
      'lastName': 'last_name',
      'phone': 'phone',
      'email': 'email',
      'isVerified': 'is_verified',
      'isActive': 'is_active',
      'role': 'role',
      'profileImage': 'profile_image',
      'emergencyContact': 'emergency_contact',
      'address': 'address',
      'city': 'city',
      'state': 'state',
      'pincode': 'pincode',
      'bio': 'bio',
    };

    final sets = <String>[];
    final params = <String, dynamic>{'id': id};

    for (final entry in data.entries) {
      final dbKey = fieldMapping[entry.key] ?? entry.key;
      if (fieldMapping.containsKey(entry.key) && entry.value != null) {
        sets.add('$dbKey = @${entry.key}');
        params[entry.key] = entry.value;
      }
    }

    if (sets.isEmpty) throw Exception('No valid fields to update');

    sets.add('updated_at = CURRENT_TIMESTAMP');
    await Database.query(
      'UPDATE users SET ${sets.join(', ')} WHERE id = @id',
      parameters: params,
    );
    return (await findById(id))!;
  }

  Future<void> delete() async {
    await Database.query('DELETE FROM users WHERE id = @id',
        parameters: {'id': id});
  }

  static Future<Map<String, dynamic>> getStats() async {
    final result = await Database.query('''
      SELECT
        COUNT(*) as "totalUsers",
        COUNT(CASE WHEN role = 'user' THEN 1 END) as "totalRegularUsers",
        COUNT(CASE WHEN role = 'driver' THEN 1 END) as "totalDrivers",
        COUNT(CASE WHEN is_verified = true THEN 1 END) as "verifiedUsers",
        COUNT(CASE WHEN is_active = true THEN 1 END) as "activeUsers",
        COUNT(CASE WHEN is_active = false THEN 1 END) as "inactiveUsers"
      FROM users
    ''');
    return result.first.toColumnMap();
  }
}
