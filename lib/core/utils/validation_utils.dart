import 'package:email_validator/email_validator.dart';

class ValidationUtils {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  // Post content validation
  static String? validatePostContent(String? value) {
    if (value == null || value.isEmpty) {
      return 'Post content cannot be empty';
    }
    if (value.length > 5000) {
      return 'Post content is too long (max 5000 characters)';
    }
    return null;
  }

  // Comment validation
  static String? validateComment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Comment cannot be empty';
    }
    if (value.length > 500) {
      return 'Comment is too long (max 500 characters)';
    }
    return null;
  }

  // Message validation
  static String? validateMessage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Message cannot be empty';
    }
    if (value.length > 1000) {
      return 'Message is too long (max 1000 characters)';
    }
    return null;
  }

  // Bio validation
  static String? validateBio(String? value) {
    if (value != null && value.length > 150) {
      return 'Bio is too long (max 150 characters)';
    }
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
