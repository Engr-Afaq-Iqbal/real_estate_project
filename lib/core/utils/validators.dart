class Validators {
  Validators._();

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'\s|-'), '');
    final pkRegex = RegExp(r'^(\+92|0092|0)?3[0-9]{9}$');
    if (!pkRegex.hasMatch(cleaned)) {
      return 'Enter a valid Pakistani phone number';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? cnic(String? value) {
    if (value == null || value.trim().isEmpty) return 'CNIC is required';
    final cleaned = value.replaceAll('-', '');
    if (cleaned.length != 13 || !RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'Enter a valid CNIC (XXXXX-XXXXXXX-X)';
    }
    return null;
  }

  static String? amount(String? value, [String fieldName = 'Amount']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    final cleaned = value.replaceAll(RegExp(r'[,\s]'), '');
    final amount = double.tryParse(cleaned);
    if (amount == null) return 'Enter a valid amount';
    if (amount <= 0) return '$fieldName must be greater than 0';
    return null;
  }

  static String? minLength(String? value, int min, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    if (value.trim().length < min) return '$fieldName must be at least $min characters';
    return null;
  }

  static String? maxLength(String? value, int max, [String fieldName = 'This field']) {
    if (value != null && value.length > max) {
      return '$fieldName must not exceed $max characters';
    }
    return null;
  }

  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  }
}
