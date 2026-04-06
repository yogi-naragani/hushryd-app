class Validators {
  static final _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final _phoneRegex = RegExp(r'^[+]?[0-9]{10,15}$');

  static bool isValidEmail(String email) => _emailRegex.hasMatch(email);
  static bool isValidPhone(String phone) =>
      _phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s-]'), ''));

  static String? validateRequired(Map<String, dynamic> data, List<String> fields) {
    for (final f in fields) {
      if (!data.containsKey(f) || data[f] == null ||
          (data[f] is String && (data[f] as String).isEmpty)) {
        return '$f is required';
      }
    }
    return null;
  }

  static String sanitize(String input) =>
      input.replaceAll(RegExp(r'<[^>]*>'), '').trim();
}
