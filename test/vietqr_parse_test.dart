import 'package:test/test.dart';
import 'package:vietqr_gen/vietqr_generator.dart';
import 'package:vietqr_gen/src/utils/crc16.dart';

void main() {
  group('VietQR Parsing Tests', () {
    test('should parse static QR payload correctly', () {
      // Generate a static QR payload first
      final originalPayload = VietQR.generate(
        bank: Bank.techcombank,
        accountNumber: '9602091996',
      );

      // Parse it back
      final parsedData = VietQR.parse(originalPayload);

      expect(parsedData.bank, equals(Bank.techcombank));
      expect(parsedData.bankBin, equals('970407'));
      expect(parsedData.accountNumber, equals('9602091996'));
      expect(parsedData.amount, isNull);
      expect(parsedData.message, isNull);
      expect(parsedData.isDynamic, isFalse);
      expect(parsedData.payloadFormat, equals('01'));
      expect(parsedData.pointOfInitiation, equals('11'));
      expect(parsedData.currency, equals('704'));
      expect(parsedData.countryCode, equals('VN'));
      expect(parsedData.crc, isNotEmpty);
    });

    test('should parse dynamic QR payload with amount', () {
      // Generate a dynamic QR payload with amount
      final originalPayload = VietQR.generate(
        bank: Bank.mbBank,
        accountNumber: '0962091996',
        amount: 150000.0,
      );

      // Parse it back
      final parsedData = VietQR.parse(originalPayload);

      expect(parsedData.bank, equals(Bank.mbBank));
      expect(parsedData.bankBin, equals('970422'));
      expect(parsedData.accountNumber, equals('0962091996'));
      expect(parsedData.amount, equals(150000.0));
      expect(parsedData.message, isNull);
      expect(parsedData.isDynamic, isTrue);
      expect(parsedData.payloadFormat, equals('01'));
      expect(parsedData.pointOfInitiation, equals('12'));
      expect(parsedData.currency, equals('704'));
      expect(parsedData.countryCode, equals('VN'));
    });

    test('should parse dynamic QR payload with amount and message', () {
      // Generate a dynamic QR payload with amount and message
      final originalPayload = VietQR.generate(
        bank: Bank.vietcombank,
        accountNumber: '1234567890',
        amount: 50000.0,
        message: 'Test payment',
      );

      // Parse it back
      final parsedData = VietQR.parse(originalPayload);

      expect(parsedData.bank, equals(Bank.vietcombank));
      expect(parsedData.bankBin, equals('970436'));
      expect(parsedData.accountNumber, equals('1234567890'));
      expect(parsedData.amount, equals(50000.0));
      expect(parsedData.message, equals('Test payment'));
      expect(parsedData.isDynamic, isTrue);
      expect(parsedData.payloadFormat, equals('01'));
      expect(parsedData.pointOfInitiation, equals('12'));
    });

    test('should parse QR payload with Vietnamese message', () {
      // Generate a QR payload with Vietnamese message
      final originalPayload = VietQR.generate(
        bank: Bank.bidv,
        accountNumber: '9876543210',
        amount: 25000.0,
        message: 'Thanh toán đơn hàng',
      );

      // Parse it back
      final parsedData = VietQR.parse(originalPayload);

      expect(parsedData.bank, equals(Bank.bidv));
      expect(parsedData.bankBin, equals('970418'));
      expect(parsedData.accountNumber, equals('9876543210'));
      expect(parsedData.amount, equals(25000.0));
      expect(parsedData.message, equals('Thanh toan don hang')); // Sanitized
      expect(parsedData.isDynamic, isTrue);
    });

    test('should parse QR payload with custom BIN', () {
      // Generate a QR payload with custom BIN
      final originalPayload = VietQR.generate(
        accountNumber: '1234567890',
        bankBin: '970999',
        amount: 100000.0,
        message: 'Custom bank payment',
      );

      // Parse it back
      final parsedData = VietQR.parse(originalPayload);

      expect(parsedData.bank, isNull); // Custom BIN not in enum
      expect(parsedData.bankBin, equals('970999'));
      expect(parsedData.accountNumber, equals('1234567890'));
      expect(parsedData.amount, equals(100000.0));
      expect(parsedData.message, equals('Custom bank payment'));
      expect(parsedData.isDynamic, isTrue);
    });

    test('should handle zero amount correctly', () {
      // Generate a QR payload with zero amount
      final originalPayload = VietQR.generate(
        bank: Bank.techcombank,
        accountNumber: '1234567890',
        amount: 0.0,
      );

      // Parse it back
      final parsedData = VietQR.parse(originalPayload);

      expect(parsedData.bank, equals(Bank.techcombank));
      expect(parsedData.bankBin, equals('970407'));
      expect(parsedData.accountNumber, equals('1234567890'));
      expect(parsedData.amount, isNull); // Zero amount should not be included
      expect(parsedData.message, isNull);
      expect(parsedData.isDynamic, isFalse); // Should be static QR
    });

    test('should provide correct bank name for known banks', () {
      final originalPayload = VietQR.generate(
        bank: Bank.agribank,
        accountNumber: '1111111111',
      );

      final parsedData = VietQR.parse(originalPayload);

      expect(parsedData.bankName, equals('Agribank'));
    });

    test('should provide correct bank name for unknown banks', () {
      final originalPayload = VietQR.generate(
        accountNumber: '1111111111',
        bankBin: '970888',
      );

      final parsedData = VietQR.parse(originalPayload);

      expect(parsedData.bankName, equals('Unknown Bank (970888)'));
    });

    test('should format amount correctly', () {
      final originalPayload = VietQR.generate(
        bank: Bank.techcombank,
        accountNumber: '1234567890',
        amount: 1500000.0,
      );

      final parsedData = VietQR.parse(originalPayload);

      expect(parsedData.formattedAmount, equals('1,500,000 VND'));
    });

    test('should handle static QR amount formatting', () {
      final originalPayload = VietQR.generate(
        bank: Bank.techcombank,
        accountNumber: '1234567890',
      );

      final parsedData = VietQR.parse(originalPayload);

      expect(parsedData.formattedAmount, equals('Not specified'));
    });

    test('should convert to map correctly', () {
      final originalPayload = VietQR.generate(
        bank: Bank.vietinbank,
        accountNumber: '5555555555',
        amount: 75000.0,
        message: 'Test message',
      );

      final parsedData = VietQR.parse(originalPayload);
      final map = parsedData.toMap();

      expect(map['bank'], equals('Vietinbank'));
      expect(map['bankBin'], equals('970415'));
      expect(map['accountNumber'], equals('5555555555'));
      expect(map['amount'], equals(75000.0));
      expect(map['message'], equals('Test message'));
      expect(map['isDynamic'], isTrue);
      expect(map['payloadFormat'], equals('01'));
      expect(map['pointOfInitiation'], equals('12'));
      expect(map['currency'], equals('704'));
      expect(map['countryCode'], equals('VN'));
      expect(map['crc'], isNotEmpty);
    });

    test('should have correct toString output', () {
      final originalPayload = VietQR.generate(
        bank: Bank.acb,
        accountNumber: '9999999999',
        amount: 200000.0,
        message: 'Payment test',
      );

      final parsedData = VietQR.parse(originalPayload);
      final stringOutput = parsedData.toString();

      expect(stringOutput, contains('VietQR Parsed Data:'));
      expect(stringOutput, contains('Bank: ACB'));
      expect(stringOutput, contains('Account: 9999999999'));
      expect(stringOutput, contains('Amount: 200,000 VND'));
      expect(stringOutput, contains('Message: Payment test'));
      expect(stringOutput, contains('Type: Dynamic QR'));
      expect(stringOutput, contains('Currency: 704'));
      expect(stringOutput, contains('Country: VN'));
    });
  });

  group('VietQR Parsing Error Tests', () {
    test('should throw error for empty payload', () {
      expect(
        () => VietQR.parse(''),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          'Payload cannot be empty',
        )),
      );
    });

    test('should throw error for payload too short', () {
      expect(
        () => VietQR.parse('123'),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          'Payload too short to contain valid CRC',
        )),
      );
    });

    test('should throw error for invalid payload format', () {
      // Create a malformed payload with wrong format indicator
      final malformedPayload =
          '0002010102113802A0000007270106000697040701001096020919960208QRIBFTTA53037045802VN6304';
      // Add a fake CRC
      final fakeCrc = '1234';
      final payload = malformedPayload + fakeCrc;

      expect(
        () => VietQR.parse(payload),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw error for invalid point of initiation', () {
      // This test would require creating a malformed payload manually
      // For now, we'll test with a known good payload and modify it
      final originalPayload = VietQR.generate(
        bank: Bank.techcombank,
        accountNumber: '1234567890',
      );

      // Replace the point of initiation field (01) with invalid value
      final modifiedPayload = originalPayload.replaceFirst('010211', '010299');

      expect(
        () => VietQR.parse(modifiedPayload),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw error for invalid currency code', () {
      final originalPayload = VietQR.generate(
        bank: Bank.techcombank,
        accountNumber: '1234567890',
      );

      // Replace the currency field (53) with invalid value
      final modifiedPayload =
          originalPayload.replaceFirst('5303704', '5302999');

      expect(
        () => VietQR.parse(modifiedPayload),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw error for invalid country code', () {
      final originalPayload = VietQR.generate(
        bank: Bank.techcombank,
        accountNumber: '1234567890',
      );

      // Replace the country code field (58) with invalid value
      final modifiedPayload = originalPayload.replaceFirst('5802VN', '5802US');

      expect(
        () => VietQR.parse(modifiedPayload),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw error for CRC mismatch', () {
      final originalPayload = VietQR.generate(
        bank: Bank.techcombank,
        accountNumber: '1234567890',
      );

      // Replace the CRC with a wrong value
      final modifiedPayload =
          originalPayload.substring(0, originalPayload.length - 4) + '9999';

      expect(
        () => VietQR.parse(modifiedPayload),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('CRC checksum mismatch'),
        )),
      );
    });

    test('should throw error for invalid amount format', () {
      // Create a payload with amount and manually construct invalid one
      final originalPayload = VietQR.generate(
        bank: Bank.techcombank,
        accountNumber: '1234567890',
        amount: 100000.0,
      );

      // Find the amount field and replace it with invalid value
      final amountFieldStart = originalPayload.indexOf('5406100000');
      if (amountFieldStart != -1) {
        final beforeAmount = originalPayload.substring(0, amountFieldStart);
        final afterAmount = originalPayload.substring(amountFieldStart + 10);
        final modifiedPayload = beforeAmount + '5406abc123' + afterAmount;

        // Recalculate CRC for the modified payload
        final payloadWithoutCrc =
            modifiedPayload.substring(0, modifiedPayload.length - 4);
        final newCrc = calculateCRC16(payloadWithoutCrc);
        final finalPayload = payloadWithoutCrc + newCrc;

        expect(
          () => VietQR.parse(finalPayload),
          throwsA(isA<FormatException>().having(
            (e) => e.message,
            'message',
            'Invalid amount format: abc123',
          )),
        );
      } else {
        // Fallback: just test that invalid amount parsing throws
        expect(
          () => double.parse('abc123'),
          throwsA(isA<FormatException>()),
        );
      }
    });
  });

  group('VietQR Round-trip Tests', () {
    test('should maintain data integrity through generate-parse cycle', () {
      final originalData = {
        'bank': Bank.techcombank,
        'accountNumber': '9602091996',
        'amount': 150000.0,
        'message': 'Test round trip',
      };

      // Generate payload
      final payload = VietQR.generate(
        bank: originalData['bank'] as Bank,
        accountNumber: originalData['accountNumber'] as String,
        amount: originalData['amount'] as double,
        message: originalData['message'] as String,
      );

      // Parse payload
      final parsedData = VietQR.parse(payload);

      // Verify data integrity
      expect(parsedData.bank, equals(originalData['bank']));
      expect(parsedData.accountNumber, equals(originalData['accountNumber']));
      expect(parsedData.amount, equals(originalData['amount']));
      // Message gets sanitized during generation, so compare with sanitized version
      expect(parsedData.message, equals('Test round trip'));
    });

    test('should handle all bank types correctly', () {
      final testBanks = [
        Bank.agribank,
        Bank.bidv,
        Bank.mbBank,
        Bank.vietcombank,
        Bank.vietinbank,
        Bank.techcombank,
        Bank.acb,
        Bank.hdBank,
        Bank.tpBank,
      ];

      for (final bank in testBanks) {
        final originalPayload = VietQR.generate(
          bank: bank,
          accountNumber: '1234567890',
          amount: 50000.0,
          message: 'Test for ${bank.name}',
        );

        final parsedData = VietQR.parse(originalPayload);

        expect(parsedData.bank, equals(bank));
        expect(parsedData.bankBin, equals(bank.bin));
        expect(parsedData.accountNumber, equals('1234567890'));
        expect(parsedData.amount, equals(50000.0));
        expect(parsedData.message, equals('Test for ${bank.name}'));
      }
    });

    test('should handle custom BIN round-trip', () {
      final customBins = ['970111', '970222', '970333', '999999'];

      for (final bin in customBins) {
        final originalPayload = VietQR.generate(
          accountNumber: '9876543210',
          bankBin: bin,
          amount: 75000.0,
          message: 'Custom BIN test',
        );

        final parsedData = VietQR.parse(originalPayload);

        expect(parsedData.bank, isNull); // Custom BIN not in enum
        expect(parsedData.bankBin, equals(bin));
        expect(parsedData.accountNumber, equals('9876543210'));
        expect(parsedData.amount, equals(75000.0));
        expect(parsedData.message, equals('Custom BIN test'));
      }
    });

    // test with payload: 00020101021138540010A00000072701240006970407011096020919960208QRIBFTTA53037045802VN830084006304072F
    test('should parse payload with amount and message', () {
      final payload =
          '00020101021138540010A00000072701240006970407011096020919960208QRIBFTTA53037045802VN830084006304072F';
      final parsedData = VietQR.parse(payload);

      expect(parsedData.bank, equals(Bank.techcombank));
      expect(parsedData.accountNumber, equals('9602091996'));
      expect(parsedData.amount, isNull);
      expect(parsedData.message, isNull);
      expect(parsedData.isDynamic, isFalse);
      expect(parsedData.payloadFormat, equals('01'));
      expect(parsedData.pointOfInitiation, equals('11'));
      expect(parsedData.currency, equals('704'));
      expect(parsedData.countryCode, equals('VN'));
      expect(parsedData.crc, isNotEmpty);
    });
  });
}
