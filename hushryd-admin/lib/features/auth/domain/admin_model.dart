class AdminUser {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String role;
  final List<String> permissions;
  final bool isActive;

  AdminUser({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.role = 'admin',
    this.permissions = const [],
    this.isActive = true,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      role: json['role'] as String? ?? 'admin',
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? true,
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
      };
}
