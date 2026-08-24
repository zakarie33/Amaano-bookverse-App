import 'package:flutter_test/flutter_test.dart';
import 'package:amaano_bookverse_app/core/utils/validators.dart';

void main() {
  group('fullName', () {
    test('requires first and last name', () {
      expect(FormValidators.fullName('John'), isNotNull);
      expect(FormValidators.fullName('John Doe'), isNull);
    });

    test('rejects invalid characters', () {
      expect(FormValidators.fullName('John2 Doe'), isNotNull);
    });
  });

  group('email', () {
    test('accepts valid email', () {
      expect(FormValidators.email('user@bookverse.com'), isNull);
    });

    test('rejects invalid email', () {
      expect(FormValidators.email('not-an-email'), isNotNull);
    });
  });

  group('phone', () {
    test('accepts international format', () {
      expect(FormValidators.phone('+252 61 123 4567'), isNull);
    });

    test('rejects too few digits', () {
      expect(FormValidators.phone('12345'), isNotNull);
    });
  });

  group('password', () {
    test('requires mixed character classes', () {
      expect(FormValidators.password('short'), isNotNull);
      expect(FormValidators.password('Password1!'), isNull);
    });

    test('rejects passwords with spaces', () {
      expect(FormValidators.password('Pass word1!'), isNotNull);
    });
  });

  group('confirmPassword', () {
    test('must match password', () {
      expect(
        FormValidators.confirmPassword('abc', 'xyz'),
        isNotNull,
      );
      expect(
        FormValidators.confirmPassword('Secure1!', 'Secure1!'),
        isNull,
      );
    });
  });

  group('agreements', () {
    test('requires both checkboxes', () {
      expect(
        FormValidators.agreements(
          privacyAccepted: false,
          termsAccepted: false,
        ),
        isNotNull,
      );
      expect(
        FormValidators.agreements(
          privacyAccepted: true,
          termsAccepted: true,
        ),
        isNull,
      );
    });
  });

  group('passwordRequirements', () {
    test('tracks rule completion', () {
      final rules = FormValidators.passwordRequirements('Aa1!');
      expect(rules.every((r) => r.met), isFalse);
      final strong = FormValidators.passwordRequirements('Secure1!');
      expect(strong.where((r) => !r.met), isEmpty);
    });
  });
}
