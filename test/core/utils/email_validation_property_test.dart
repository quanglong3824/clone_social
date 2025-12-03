import 'package:flutter_test/flutter_test.dart' hide test, group, expect;
import 'package:glados/glados.dart';
import 'package:vibe_social/core/utils/validation_utils.dart';

/// **Feature: social-app-complete-redesign, Property 1: Email Validation Rejection**
/// **Validates: Requirements 1.2**
///
/// Property: For any string that does not match email regex pattern, the
/// validation function SHALL return false and display error message.

void main() {
  group('Property 1: Email Validation Rejection', () {
    /// **Feature: social-app-complete-redesign, Property 1: Email Validation Rejection**
    /// **Validates: Requirements 1.2**

    // Property test: For any arbitrary string, if it doesn't match email pattern,
    // validation should reject it
    Glados(any.letterOrDigits).test(
      'arbitrary strings without valid email format are rejected',
      (arbitraryString) {
        // Check if the string matches a valid email pattern
        final emailRegex = RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        );
        final isValidFormat = emailRegex.hasMatch(arbitraryString);
        
        // If the string is NOT a valid email format, validation should reject it
        if (!isValidFormat) {
          final result = ValidationUtils.isValidEmail(arbitraryString);
          expect(result, isFalse,
              reason: 'isValidEmail should return false for invalid email: "$arbitraryString"');
          
          final errorMessage = ValidationUtils.validateEmail(arbitraryString);
          expect(errorMessage, isNotNull,
              reason: 'validateEmail should return error message for invalid email: "$arbitraryString"');
        }
      },
    );

    // Property test: For any valid email structure, validation should accept it
    Glados2(any.letterOrDigits, any.letterOrDigits).test(
      'properly structured emails are accepted',
      (localPart, domain) {
        // Filter to only test with non-empty alphanumeric strings
        if (localPart.isEmpty || domain.isEmpty) return;
        if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(localPart)) return;
        if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(domain)) return;
        
        // Construct a valid email
        final validEmail = '$localPart@$domain.com';
        
        final result = ValidationUtils.isValidEmail(validEmail);
        expect(result, isTrue,
            reason: 'isValidEmail should return true for valid email: "$validEmail"');
        
        final errorMessage = ValidationUtils.validateEmail(validEmail);
        expect(errorMessage, isNull,
            reason: 'validateEmail should return null for valid email: "$validEmail"');
      },
    );

    // Test specific edge cases
    test('empty string is rejected', () {
      expect(ValidationUtils.isValidEmail(''), isFalse);
      expect(ValidationUtils.validateEmail(''), equals('Email is required'));
    });

    test('null value returns required error', () {
      expect(ValidationUtils.validateEmail(null), equals('Email is required'));
    });

    test('email without @ is rejected', () {
      expect(ValidationUtils.isValidEmail('userexample.com'), isFalse);
      expect(ValidationUtils.validateEmail('userexample.com'), 
          equals('Please enter a valid email'));
    });

    test('email without domain is rejected', () {
      expect(ValidationUtils.isValidEmail('user@'), isFalse);
      expect(ValidationUtils.validateEmail('user@'), 
          equals('Please enter a valid email'));
    });

    test('email with spaces is rejected', () {
      expect(ValidationUtils.isValidEmail('user @example.com'), isFalse);
      expect(ValidationUtils.validateEmail('user @example.com'), 
          equals('Please enter a valid email'));
    });

    test('valid email is accepted', () {
      expect(ValidationUtils.isValidEmail('user@example.com'), isTrue);
      expect(ValidationUtils.validateEmail('user@example.com'), isNull);
    });

    test('valid email with dots in local part is accepted', () {
      expect(ValidationUtils.isValidEmail('user.name@example.com'), isTrue);
      expect(ValidationUtils.validateEmail('user.name@example.com'), isNull);
    });

    test('valid email with plus sign is accepted', () {
      expect(ValidationUtils.isValidEmail('user+tag@example.com'), isTrue);
      expect(ValidationUtils.validateEmail('user+tag@example.com'), isNull);
    });

    test('email with only @ symbol is rejected', () {
      expect(ValidationUtils.isValidEmail('@'), isFalse);
      expect(ValidationUtils.validateEmail('@'), 
          equals('Please enter a valid email'));
    });

    test('email with multiple @ symbols is rejected', () {
      expect(ValidationUtils.isValidEmail('user@mid@domain.com'), isFalse);
      expect(ValidationUtils.validateEmail('user@mid@domain.com'), 
          equals('Please enter a valid email'));
    });

    test('email with TLD too short is rejected', () {
      expect(ValidationUtils.isValidEmail('user@domain.c'), isFalse);
      expect(ValidationUtils.validateEmail('user@domain.c'), 
          equals('Please enter a valid email'));
    });
  });
}
