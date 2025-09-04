import 'package:vietqr_gen/vietqr_generator.dart';

void main() {
  print('=== VietQR Parsing Examples ===\n');

  // Example 1: Generate and Parse Static QR
  print('1. Generate and Parse Static QR:');
  final staticPayload = VietQR.generate(
    bank: Bank.techcombank,
    accountNumber: '9602091996',
  );
  print('   Generated payload: ${staticPayload.substring(0, 50)}...');

  final parsedStatic = VietQR.parse(staticPayload);
  print('   Parsed data:');
  print('     Bank: ${parsedStatic.bankName}');
  print('     Account: ${parsedStatic.accountNumber}');
  print('     Amount: ${parsedStatic.formattedAmount}');
  print('     Type: ${parsedStatic.isDynamic ? "Dynamic" : "Static"} QR\n');

  // Example 2: Generate and Parse Dynamic QR with Amount
  print('2. Generate and Parse Dynamic QR with Amount:');
  final dynamicPayload = VietQR.generate(
    bank: Bank.mbBank,
    accountNumber: '0962091996',
    amount: 150000.0,
  );
  print('   Generated payload: ${dynamicPayload.substring(0, 50)}...');

  final parsedDynamic = VietQR.parse(dynamicPayload);
  print('   Parsed data:');
  print('     Bank: ${parsedDynamic.bankName}');
  print('     Account: ${parsedDynamic.accountNumber}');
  print('     Amount: ${parsedDynamic.formattedAmount}');
  print('     Type: ${parsedDynamic.isDynamic ? "Dynamic" : "Static"} QR\n');

  // Example 3: Generate and Parse Dynamic QR with Amount and Message
  print('3. Generate and Parse Dynamic QR with Amount and Message:');
  final fullPayload = VietQR.generate(
    bank: Bank.vietcombank,
    accountNumber: '1234567890',
    amount: 50000.0,
    message: 'Thanh toan don hang cafe',
  );
  print('   Generated payload: ${fullPayload.substring(0, 50)}...');

  final parsedFull = VietQR.parse(fullPayload);
  print('   Parsed data:');
  print('     Bank: ${parsedFull.bankName}');
  print('     Account: ${parsedFull.accountNumber}');
  print('     Amount: ${parsedFull.formattedAmount}');
  print('     Message: ${parsedFull.message}');
  print('     Type: ${parsedFull.isDynamic ? "Dynamic" : "Static"} QR\n');

  // Example 4: Parse QR with Vietnamese Message
  print('4. Parse QR with Vietnamese Message:');
  final vietnamesePayload = VietQR.generate(
    bank: Bank.bidv,
    accountNumber: '9876543210',
    amount: 25000.0,
    message: 'Thanh toán đơn hàng café với gia vị đặc biệt',
  );
  print('   Original message: "Thanh toán đơn hàng café với gia vị đặc biệt"');

  final parsedVietnamese = VietQR.parse(vietnamesePayload);
  print('   Parsed message: "${parsedVietnamese.message}"');
  print('   Note: Vietnamese characters are sanitized during generation\n');

  // Example 5: Parse QR with Custom BIN
  print('5. Parse QR with Custom BIN:');
  final customBinPayload = VietQR.generate(
    accountNumber: '5555555555',
    bankBin: '970999',
    amount: 100000.0,
    message: 'Payment to custom bank',
  );
  print('   Generated payload: ${customBinPayload.substring(0, 50)}...');

  final parsedCustom = VietQR.parse(customBinPayload);
  print('   Parsed data:');
  print('     Bank: ${parsedCustom.bankName}');
  print('     BIN: ${parsedCustom.bankBin}');
  print('     Account: ${parsedCustom.accountNumber}');
  print('     Amount: ${parsedCustom.formattedAmount}');
  print('     Message: ${parsedCustom.message}\n');

  // Example 6: Convert to Map
  print('6. Convert Parsed Data to Map:');
  final mapData = parsedFull.toMap();
  print('   Map representation:');
  mapData.forEach((key, value) {
    print('     $key: $value');
  });
  print('');

  // Example 7: Error Handling
  print('7. Error Handling Examples:');

  // Test with empty payload
  try {
    VietQR.parse('');
  } catch (e) {
    print('   Empty payload error: ${e.toString()}');
  }

  // Test with malformed payload
  try {
    VietQR.parse('invalid_payload');
  } catch (e) {
    print('   Malformed payload error: ${e.toString()}');
  }

  // Test with wrong CRC
  try {
    final wrongCrcPayload =
        staticPayload.substring(0, staticPayload.length - 4) + '9999';
    VietQR.parse(wrongCrcPayload);
  } catch (e) {
    print('   Wrong CRC error: ${e.toString()}');
  }
  print('');

  // Example 8: Round-trip Verification
  print('8. Round-trip Verification:');
  final originalBank = Bank.agribank;
  final originalAccount = '1111111111';
  final originalAmount = 200000.0;
  final originalMessage = 'Round-trip test';

  final roundTripPayload = VietQR.generate(
    bank: originalBank,
    accountNumber: originalAccount,
    amount: originalAmount,
    message: originalMessage,
  );

  final roundTripParsed = VietQR.parse(roundTripPayload);

  print(
      '   Original: ${originalBank.name}, $originalAccount, $originalAmount, "$originalMessage"');
  print(
      '   Parsed: ${roundTripParsed.bankName}, ${roundTripParsed.accountNumber}, ${roundTripParsed.amount}, "${roundTripParsed.message}"');
  print(
      '   Match: ${roundTripParsed.bank == originalBank && roundTripParsed.accountNumber == originalAccount && roundTripParsed.amount == originalAmount && roundTripParsed.message == originalMessage}');
  print('');

  // Example 9: Different QR Types
  print('9. Different QR Types:');
  final banks = [Bank.techcombank, Bank.vietcombank, Bank.mbBank, Bank.bidv];

  for (final bank in banks) {
    final payload = VietQR.generate(
      bank: bank,
      accountNumber: '1234567890',
      amount: 10000.0,
    );

    final parsed = VietQR.parse(payload);
    print(
        '   ${bank.name}: ${parsed.isDynamic ? "Dynamic" : "Static"} QR, Amount: ${parsed.formattedAmount}');
  }
  print('');

  print('=== All parsing examples completed successfully! ===');
  print('\nNote: The parsing functionality allows you to:');
  print('- Extract all information from any VietQR payload');
  print('- Validate payload integrity through CRC checking');
  print('- Handle both static and dynamic QR codes');
  print('- Work with custom bank BINs');
  print('- Convert parsed data to various formats (Map, String)');
  print('- Implement payment verification and data extraction features');
}
