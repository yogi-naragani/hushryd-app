import 'dart:convert';
import '../config/database.dart';

class Admin {
  final String id;
  final String? email;
  final String? password;
  final String? firstName;
  final String? lastName;
  final String role;
  final List<String> permissions;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Admin({
    required this.id,
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.role = 'admin',
    this.permissions = const [],
    this.isActive = true,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
  });

  factory Admin.fromRow(Map<String, dynamic> row) {
    List<String> perms = [];
    if (row['permissions'] != null) {
      final p = row['permissions'];
      if (p is String) {
        try {
          perms = List<String>.from(jsonDecode(p));
        } catch (_) {
          perms = [];
        }
      } else if (p is List) {
        perms = List<String>.from(p);
      }
    }

    return Admin(
      id: row['id'] as String,
      email: row['email'] as String?,
      password: row['password'] as String?,
      firstName: row['first_name'] as String?,
      lastName: row['last_name'] as String?,
      role: row['role'] as String? ?? 'admin',
      permissions: perms,
      isActive: row['is_active'] as bool? ?? true,
      lastLogin: row['last_login'] as DateTime?,
      createdAt: row['created_at'] as DateTime?,
      updatedAt: row['updated_at'] as DateTime?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'permissions': permissions,
        'isActive': isActive,
        'lastLogin': lastLogin?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static Future<Admin?> findById(String id) async {
    final result = await Database.query(
      'SELECT * FROM admins WHERE id = @id',
      parameters: {'id': id},
    );
    if (result.isEmpty) return null;
    return Admin.fromRow(result.first.toColumnMap());
  }

  static Future<Admin?> findByEmail(String email) async {
    final result = await Database.query(
      'SELECT * FROM admins WHERE email = @email',
      parameters: {'email': email},
    );
    if (result.isEmpty) return null;
    return Admin.fromRow(result.first.toColumnMap());
  }

  static Future<Admin> create(Map<String, dynamic> data) async {
    await Database.query(
      '''INSERT INTO admins (id, email, password, first_name, last_name, role, permissions, is_active)
         VALUES (@id, @email, @password, @firstName, @lastName, @role, @permissions, @isActive)''',
      parameters: {
        'id': data['id'],
        'email': data['email'],
        'password': data['password'],
        'firstName': data['firstName'],
        'lastName': data['lastName'],
        'role': data['role'] ?? 'admin',
        'permissions': jsonEncode(data['permissions'] ?? []),
        'isActive': data['isActive'] ?? true,
      },
    );
    return (await findById(data['id'] as String))!;
  }

  static Future<List<Admin>> findAll({
    int page = 1,
    int limit = 10,
    String? role,
    bool? isActive,
  }) async {
    var sql = 'SELECT * FROM admins WHERE 1=1';
    final params = <String, dynamic>{};

    if (role != null) {
      sql += ' AND role = @role';
      params['role'] = role;
    }
    if (isActive != null) {
      sql += ' AND is_active = @isActive';
      params['isActive'] = isActive;
    }

    final offset = (page - 1) * limit;
    sql += ' ORDER BY created_at DESC LIMIT @limit OFFSET @offset';
    params['limit'] = limit;
    params['offset'] = offset;

    final result = await Database.query(sql, parameters: params);
    return result.map((r) => Admin.fromRow(r.toColumnMap())).toList();
  }

  Future<Admin> update(Map<String, dynamic> data) async {
    final fieldMapping = {
      'firstName': 'first_name',
      'lastName': 'last_name',
      'email': 'email',
      'role': 'role',
      'isActive': 'is_active',
    };

    final sets = <String>[];
    final params = <String, dynamic>{'id': id};

    for (final entry in data.entries) {
      if (fieldMapping.containsKey(entry.key) && entry.value != null) {
        final dbKey = fieldMapping[entry.key]!;
        sets.add('$dbKey = @${entry.key}');
        params[entry.key] = entry.value;
      }
    }

    if (data.containsKey('permissions') && data['permissions'] != null) {
      sets.add('permissions = @permissions');
      params['permissions'] = jsonEncode(data['permissions']);
    }

    if (sets.isEmpty) throw Exception('No valid fields to update');

    sets.add('updated_at = CURRENT_TIMESTAMP');
    await Database.query(
      'UPDATE admins SET ${sets.join(', ')} WHERE id = @id',
      parameters: params,
    );
    return (await findById(id))!;
  }

  Future<void> delete() async {
    await Database.query('DELETE FROM admins WHERE id = @id',
        parameters: {'id': id});
  }

  static Future<Map<String, dynamic>> getStats() async {
    final result = await Database.query('''
      SELECT
        COUNT(*) as "totalAdmins",
        COUNT(CASE WHEN role = 'superadmin' THEN 1 END) as "superAdmins",
        COUNT(CASE WHEN role = 'admin' THEN 1 END) as "admins",
        COUNT(CASE WHEN role = 'support' THEN 1 END) as "supportAdmins",
        COUNT(CASE WHEN is_active = true THEN 1 END) as "activeAdmins",
        COUNT(CASE WHEN is_active = false THEN 1 END) as "inactiveAdmins"
      FROM admins
    ''');
    return result.first.toColumnMap();
  }
}
