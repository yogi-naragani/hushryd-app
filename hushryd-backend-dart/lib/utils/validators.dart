/// Input validation utilities.
class Validators {
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final _phoneRegex = RegExp(r'^[+]?[0-9]{10,15}$');

  static bool isValidEmail(String email) => _emailRegex.hasMatch(email);

  static bool isValidPhone(String phone) =>
      _phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s-]'), ''));

  static bool isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }

  /// Sanitize input string to prevent XSS.
  static String sanitize(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .trim();
  }

  /// Validate required fields in a map.
  static String? validateRequired(
      Map<String, dynamic> data, List<String> fields) {
    for (final field in fields) {
      if (!data.containsKey(field) ||
          data[field] == null ||
          (data[field] is String && (data[field] as String).isEmpty)) {
        return '$field is required';
      }
    }
    return null;
  }
}
