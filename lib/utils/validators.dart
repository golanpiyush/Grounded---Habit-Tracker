// validators.dart

enum PasswordStrength { weak, medium, strong }

class Validators {
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegex.hasMatch(email);
  }

  static PasswordStrength getPasswordStrength(String password) {
    if (password.length < 6) return PasswordStrength.weak;

    bool hasLetters = password.contains(RegExp(r'[a-zA-Z]'));
    bool hasNumbers = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = 0;
    if (hasLetters) strength++;
    if (hasNumbers) strength++;
    if (hasSpecial) strength++;

    if (password.length >= 8 && strength >= 2) {
      return PasswordStrength.strong;
    } else if (password.length >= 6 && strength >= 1) {
      return PasswordStrength.medium;
    }

    return PasswordStrength.weak;
  }

  static bool passwordsMatch(String password, String confirmPassword) {
    return password.isNotEmpty && password == confirmPassword;
  }

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? confirmPasswordValidator(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (!passwordsMatch(password, value)) {
      return 'Passwords do not match';
    }
    return null;
  }
}
