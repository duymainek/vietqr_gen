import 'package:test/test.dart';
import 'package:vietqr_gen/vietqr_generator.dart';

void main() {
  group('VietQR Generator Tests', () {
    test('should generate static QR payload correctly', () {
      final payload = VietQR.generate(
        bank: Bank.techcombank,
        accountNumber: '9602091996',
      );

      expect(payload, isNotEmpty);
      expect(payload, startsWith('00020101021138'));
      expect(payload, contains('970407')); // Techcombank BIN
      expect(payload, contains('9602091996')); // Account number
      expect(payload, contains('QRIBFTTA')); // Service code
    });

    test('should generate dynamic QR payload with amount', () {
      final payload = VietQR.generate(
        bank: Bank.mbBank,
        accountNumber: '0962091996',
        amount: 150000.0,
      );

      expect(payload, isNotEmpty);
      expect(payload, startsWith('00020101021238')); // Dynamic QR
      expect(payload, contains('970422')); // MBBank BIN
      expect(payload, contains('0962091996')); // Account number
      expect(payload, contains('150000')); // Amount
    });

    test('should generate dynamic QR payload with amount and message', () {
      final payload = VietQR.generate(
        bank: Bank.vietcombank,
        accountNumber: '1234567890',
        amount: 50000.0,
        message: 'Test payment',
      );

      expect(payload, isNotEmpty);
      expect(payload, startsWith('00020101021238')); // Dynamic QR
      expect(payload, contains('970436')); // Vietcombank BIN
      expect(payload, contains('1234567890')); // Account number
      expect(payload, contains('50000')); // Amount
      expect(payload, contains('Test payment')); // Message
    });

    test('should sanitize Vietnamese text in message', () {
      final payload = VietQR.generate(
        bank: Bank.bidv,
        accountNumber: '1111111111',
        amount: 10000.0,
        message: 'Thanh toán đơn hàng',
      );

      expect(payload, contains('Thanh toan don hang'));
      expect(payload, isNot(contains('Thanh toán đơn hàng')));
    });

    test('should throw error for empty account number', () {
      expect(
        () => VietQR.generate(
          bank: Bank.techcombank,
          accountNumber: '',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw error for negative amount', () {
      expect(
        () => VietQR.generate(
          bank: Bank.techcombank,
          accountNumber: '1234567890',
          amount: -100.0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle zero amount correctly', () {
      final payload = VietQR.generate(
        bank: Bank.techcombank,
        accountNumber: '1234567890',
        amount: 0.0,
      );

      // Should be treated as static QR (no amount field)
      expect(payload, startsWith('00020101021138'));

      // Parse the payload to check fields
      var hasAmountField = false;
      var index = 0;
      while (index < payload.length - 4) {
        final fieldId = payload.substring(index, index + 2);
        final lengthStr = payload.substring(index + 2, index + 4);
        final length = int.parse(lengthStr);

        if (fieldId == '54') {
          hasAmountField = true;
          break;
        }

        if (index + 4 + length <= payload.length) {
          index += 4 + length;
        } else {
          break;
        }
      }

      expect(hasAmountField, isFalse,
          reason: 'Should not have amount field (54) for zero amount');
    });

    test('should include all required fields', () {
      final payload = VietQR.generate(
        bank: Bank.agribank,
        accountNumber: '9876543210',
      );

      // Check for required field IDs
      expect(payload, contains('00')); // Payload Format
      expect(payload, contains('01')); // Point of Initiation
      expect(payload, contains('38')); // Merchant Account
      expect(payload, contains('53')); // Currency
      expect(payload, contains('58')); // Country Code
      expect(payload, contains('63')); // CRC
    });

    test('should have correct payload length', () {
      final payload = VietQR.generate(
        bank: Bank.techcombank,
        accountNumber: '1234567890',
      );

      // Payload should be reasonable length (not too short or too long)
      expect(payload.length, greaterThan(50));
      expect(payload.length, lessThan(200));
    });
  });

  group('Bank Enum Tests', () {
    test('should have correct bank information', () {
      expect(Bank.techcombank.name, equals('Techcombank'));
      expect(Bank.techcombank.bin, equals('970407'));

      expect(Bank.vietcombank.name, equals('Vietcombank'));
      expect(Bank.vietcombank.bin, equals('970436'));

      expect(Bank.mbBank.name, equals('MBBank'));
      expect(Bank.mbBank.bin, equals('970422'));
    });

    test('should have unique BIN codes', () {
      final bins = Bank.values.map((bank) => bank.bin).toList();
      final uniqueBins = bins.toSet();

      expect(bins.length, equals(uniqueBins.length));
    });
  });
}
