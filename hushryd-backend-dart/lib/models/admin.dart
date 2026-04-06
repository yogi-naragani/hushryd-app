import 'dart:convert';
import 'package:hushryd_backend/config/database.dart';

/// Admin model with MySQL queries.
class Admin {
  final String id;
  final String? email;
  final String? password;
  final String? firstName;
  final String? lastName;
  final String role;
  final List<String> permissions;
  final bool isActive;
  final String? lastLogin;
  final String? createdAt;
  final String? updatedAt;

  Admin({
    required this.id, this.email, this.password, this.firstName, this.lastName,
    this.role = 'admin', this.permissions = const [], this.isActive = true,
    this.lastLogin, this.createdAt, this.updatedAt,
  });

  factory Admin.fromRow(Map<String, String?> row) {
    List<String> perms = [];
    if (row['permissions'] != null) {
      try { perms = (jsonDecode(row['permissions']!) as List).map((e) => e.toString()).toList(); } catch (_) {}
    }
    return Admin(
      id: row['id'] ?? '', email: row['email'], password: row['password'],
      firstName: row['first_name'], lastName: row['last_name'],
      role: row['role'] ?? 'admin', permissions: perms,
      isActive: row['is_active'] == '1',
      lastLogin: row['last_login'], createdAt: row['created_at'],
      updatedAt: row['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'email': email, 'firstName': firstName, 'lastName': lastName,
    'role': role, 'permissions': permissions, 'isActive': isActive,
    'lastLogin': lastLogin, 'createdAt': createdAt, 'updatedAt': updatedAt,
  };

  static Future<Admin?> findById(String id) async {
    final result = await Database.query('SELECT * FROM admins WHERE id = :id', {'id': id});
    final rows = result.rows.toList();
    if (rows.isEmpty) return null;
    return Admin.fromRow(rows.first.assoc());
  }

  static Future<Admin?> findByEmail(String email) async {
    final result = await Database.query('SELECT * FROM admins WHERE email = :email', {'email': email});
    final rows = result.rows.toList();
    if (rows.isEmpty) return null;
    return Admin.fromRow(rows.first.assoc());
  }

  static Future<Admin> create(Map<String, dynamic> data) async {
    await Database.query(
      '''INSERT INTO admins (id, email, password, first_name, last_name, role, permissions, is_active)
         VALUES (:id, :email, :password, :firstName, :lastName, :role, :permissions, :isActive)''',
      {
        'id': data['id'], 'email': data['email'], 'password': data['password'],
        'firstName': data['firstName'], 'lastName': data['lastName'],
        'role': data['role'] ?? 'admin',
        'permissions': jsonEncode(data['permissions'] ?? []),
        'isActive': data['isActive'] != false ? '1' : '0',
      },
    );
    return (await findById(data['id'] as String))!;
  }

  static Future<List<Admin>> findAll({int page = 1, int limit = 10,
      String? role, bool? isActive}) async {
    var sql = 'SELECT * FROM admins WHERE 1=1';
    final params = <String, dynamic>{};
    if (role != null) { sql += ' AND role = :role'; params['role'] = role; }
    if (isActive != null) { sql += ' AND is_active = :isActive'; params['isActive'] = isActive ? '1' : '0'; }
    sql += ' ORDER BY created_at DESC LIMIT :lim OFFSET :off';
    params['lim'] = limit.toString();
    params['off'] = ((page - 1) * limit).toString();
    final result = await Database.query(sql, params);
    return result.rows.map((r) => Admin.fromRow(r.assoc())).toList();
  }

  Future<Admin> update(Map<String, dynamic> data) async {
    final mapping = {'firstName': 'first_name', 'lastName': 'last_name',
      'email': 'email', 'role': 'role', 'isActive': 'is_active'};
    final sets = <String>[]; final params = <String, dynamic>{};
    for (final e in data.entries) {
      if (mapping.containsKey(e.key) && e.value != null) {
        sets.add('${mapping[e.key]} = :${e.key}');
        params[e.key] = e.value.toString();
      }
    }
    if (data['permissions'] != null) {
      sets.add('permissions = :permissions');
      params['permissions'] = jsonEncode(data['permissions']);
    }
    if (sets.isEmpty) throw Exception('No valid fields to update');
    sets.add('updated_at = CURRENT_TIMESTAMP');
    params['id'] = id;
    await Database.query('UPDATE admins SET ${sets.join(', ')} WHERE id = :id', params);
    return (await findById(id))!;
  }

  Future<void> delete() async =>
      Database.query('DELETE FROM admins WHERE id = :id', {'id': id});

  static Future<Map<String, String?>> getStats() async {
    final result = await Database.query('''
      SELECT COUNT(*) as totalAdmins,
        COUNT(CASE WHEN role = 'superadmin' THEN 1 END) as superAdmins,
        COUNT(CASE WHEN role = 'admin' THEN 1 END) as admins,
        COUNT(CASE WHEN is_active = 1 THEN 1 END) as activeAdmins,
        COUNT(CASE WHEN is_active = 0 THEN 1 END) as inactiveAdmins
      FROM admins
    ''');
    return result.rows.first.assoc();
  }
}
