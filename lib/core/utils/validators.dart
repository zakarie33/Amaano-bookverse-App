class FormValidators {
  FormValidators._();

  static const int nameMinLength = 3;
  static const int nameMaxLength = 80;
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 128;
  static const int phoneMinDigits = 7;
  static const int phoneMaxDigits = 15;

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp _nameRegex = RegExp(r"^[a-zA-Z\s'.-]+$");
  static final RegExp _phoneDigits = RegExp(r'^[0-9+]+$');
  static final RegExp _uppercase = RegExp(r'[A-Z]');
  static final RegExp _lowercase = RegExp(r'[a-z]');
  static final RegExp _digit = RegExp(r'[0-9]');
  static final RegExp _special = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/]');

  static const Set<String> _weakPasswords = {
    'password',
    'password1',
    'password123',
    '12345678',
    'qwerty123',
    'bookverse',
    'amaano123',
  };

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Full name is required';
    if (v.length < nameMinLength) {
      return 'Name must be at least $nameMinLength characters';
    }
    if (v.length > nameMaxLength) {
      return 'Name must be at most $nameMaxLength characters';
    }
    if (!_nameRegex.hasMatch(v)) {
      return 'Name can only contain letters, spaces, apostrophes, and hyphens';
    }
    if (!v.contains(RegExp(r'\s+'))) {
      return 'Enter your first and last name';
    }
    final parts = v.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.any((p) => p.length < 2)) {
      return 'Each name part must be at least 2 characters';
    }
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (v.length > 254) return 'Email is too long';
    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  static String? phone(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return 'Phone number is required';
    final normalized = raw.replaceAll(RegExp(r'\s+'), '');
    if (!_phoneDigits.hasMatch(normalized)) {
      return 'Phone can only contain digits and +';
    }
    if (normalized.replaceAll('+', '').isEmpty) {
      return 'Enter a valid phone number';
    }
    if (normalized.contains('+') && !normalized.startsWith('+')) {
      return '+ must be at the start of the number';
    }
    final digits = normalized.replaceAll('+', '');
    if (digits.length < phoneMinDigits) {
      return 'Phone must be at least $phoneMinDigits digits';
    }
    if (digits.length > phoneMaxDigits) {
      return 'Phone must be at most $phoneMaxDigits digits';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.contains(' ')) return 'Password cannot contain spaces';
    if (v.length < passwordMinLength) {
      return 'Password must be at least $passwordMinLength characters';
    }
    if (v.length > passwordMaxLength) {
      return 'Password must be at most $passwordMaxLength characters';
    }
    if (!_uppercase.hasMatch(v)) {
      return 'Include at least one uppercase letter';
    }
    if (!_lowercase.hasMatch(v)) {
      return 'Include at least one lowercase letter';
    }
    if (!_digit.hasMatch(v)) return 'Include at least one number';
    if (!_special.hasMatch(v)) {
      return 'Include at least one special character (!@#\$%^&* etc.)';
    }
    if (_weakPasswords.contains(v.toLowerCase())) {
      return 'Choose a stronger password';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? agreements({
    required bool privacyAccepted,
    required bool termsAccepted,
  }) {
    if (!privacyAccepted && !termsAccepted) {
      return 'Accept the Privacy Policy and Terms to continue';
    }
    if (!privacyAccepted) return 'Accept the Privacy Policy to continue';
    if (!termsAccepted) return 'Accept the Terms and Conditions to continue';
    return null;
  }

  /// Live checklist for the registration password field.
  static List<PasswordRequirement> passwordRequirements(String value) {
    return [
      PasswordRequirement(
        'At least $passwordMinLength characters',
        value.length >= passwordMinLength && value.length <= passwordMaxLength,
      ),
      PasswordRequirement('One uppercase letter (A–Z)', _uppercase.hasMatch(value)),
      PasswordRequirement('One lowercase letter (a–z)', _lowercase.hasMatch(value)),
      PasswordRequirement('One number (0–9)', _digit.hasMatch(value)),
      PasswordRequirement(
        'One special character',
        _special.hasMatch(value),
      ),
      PasswordRequirement('No spaces', value.isEmpty || !value.contains(' ')),
      PasswordRequirement(
        'Not a common weak password',
        value.isEmpty ||
            !_weakPasswords.contains(value.toLowerCase()),
      ),
    ];
  }

  static bool isPasswordStrong(String value) =>
      password(value) == null;
}

class PasswordRequirement {
  const PasswordRequirement(this.label, this.met);

  final String label;
  final bool met;
}
