import 'package:vietqr_gen/vietqr_generator.dart';

void main() {
  print('=== VietQR Generator Examples ===\n');

  // Example 1: Static QR Code
  print('1. Static QR Code (user enters amount):');
  final staticPayload = VietQR.generate(
    bank: Bank.techcombank,
    accountNumber: '9602091996',
  );
  print('   Bank: ${Bank.techcombank.name} (${Bank.techcombank.bin})');
  print('   Account: 9602091996');
  print('   Payload: $staticPayload');
  print('   Length: ${staticPayload.length} characters\n');

  // Example 2: Dynamic QR Code with Amount
  print('2. Dynamic QR Code with Amount:');
  final dynamicWithAmount = VietQR.generate(
    bank: Bank.mbBank,
    accountNumber: '0962091996',
    amount: 150000.0,
  );
  print('   Bank: ${Bank.mbBank.name} (${Bank.mbBank.bin})');
  print('   Account: 0962091996');
  print('   Amount: 150,000 VND');
  print('   Payload: $dynamicWithAmount');
  print('   Length: ${dynamicWithAmount.length} characters\n');

  // Example 3: Dynamic QR Code with Amount and Message
  print('3. Dynamic QR Code with Amount and Message:');
  final dynamicFull = VietQR.generate(
    bank: Bank.vietcombank,
    accountNumber: '1234567890',
    amount: 50000.0,
    message: 'Thanh toan don hang cafe',
  );
  print('   Bank: ${Bank.vietcombank.name} (${Bank.vietcombank.bin})');
  print('   Account: 1234567890');
  print('   Amount: 50,000 VND');
  print('   Message: "Thanh toan don hang cafe"');
  print('   Payload: $dynamicFull');
  print('   Length: ${dynamicFull.length} characters\n');

  // Example 4: Vietnamese Text Sanitization
  print('4. Vietnamese Text Sanitization:');
  final vietnameseText = VietQR.generate(
    bank: Bank.bidv,
    accountNumber: '9876543210',
    amount: 25000.0,
    message: 'Thanh toán đơn hàng café với gia vị đặc biệt',
  );
  print('   Original message: "Thanh toán đơn hàng café với gia vị đặc biệt"');
  print('   Sanitized message: "Thanh toan don hang cafe voi gia vi dac biet"');
  print('   Payload: $vietnameseText');
  print('   Length: ${vietnameseText.length} characters\n');

  // Example 5: Different Banks
  print('5. Examples with Different Banks:');
  final banks = [
    Bank.agribank,
    Bank.vietinbank,
    Bank.hdBank,
    Bank.tpBank,
    Bank.acb,
  ];

  for (final bank in banks) {
    final payload = VietQR.generate(
      bank: bank,
      accountNumber: '1111111111',
      amount: 10000.0,
    );
    print('   ${bank.name} (${bank.bin}): ${payload.substring(0, 50)}...');
  }

  print('\n=== All examples completed successfully! ===');
  print('\nNote: These payload strings can be used with any QR code generator');
  print('library like qr_flutter to create scannable QR codes.');
}
