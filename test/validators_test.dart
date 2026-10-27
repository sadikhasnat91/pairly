import 'package:flutter_test/flutter_test.dart';
import 'package:pairly/core/utils/validator.dart';

void main() {
  group('Validators Tests', () {
    test('Email validator accepts valid emails and rejects invalid ones', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
      expect(Validators.validateEmail('test.name+tag@sub.domain.co'), isNull);
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('user@'), isNotNull);
      expect(Validators.validateEmail('@domain.com'), isNotNull);
    });

    test('Password validator requires minimum 6 characters', () {
      expect(Validators.validatePassword('password123'), isNull);
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('12345'), isNotNull);
      expect(Validators.validatePassword(''), isNotNull);
    });

    test('Confirm password validator ensures equality', () {
      expect(Validators.validateConfirmPassword('pass123', 'pass123'), isNull);
      expect(
        Validators.validateConfirmPassword('pass456', 'pass123'),
        isNotNull,
      );
    });

    test('Name validator enforces minimum 2 characters', () {
      expect(Validators.validateName('Alex'), isNull);
      expect(Validators.validateName('J'), isNotNull);
      expect(Validators.validateName(''), isNotNull);
    });

    test('Invite code validator enforces 6 characters', () {
      expect(Validators.validateInviteCode('A1B2C3'), isNull);
      expect(Validators.validateInviteCode('12345'), isNotNull);
      expect(Validators.validateInviteCode('1234567'), isNotNull);
      expect(Validators.validateInviteCode(''), isNotNull);
    });
  });
}
