#!/usr/bin/env dart

import 'package:vietqr_gen/vietqr_generator.dart';

void main(List<String> args) {
  print('🧪 Quick VietQR Test');
  print('==================');

  try {
    // Test 1: Static QR
    print('\n1️⃣ Testing Static QR...');
    final staticQR = VietQR.generate(
      bank: Bank.techcombank,
      accountNumber: '1234567890',
    );
    print('✅ Static QR generated: ${staticQR.length} chars');
    print('   Payload: ${staticQR.substring(0, 50)}...');

    // Test 2: Dynamic QR with amount
    print('\n2️⃣ Testing Dynamic QR with amount...');
    final dynamicQR = VietQR.generate(
      bank: Bank.vietcombank,
      accountNumber: '9876543210',
      amount: 100000.0,
    );
    print('✅ Dynamic QR generated: ${dynamicQR.length} chars');
    print('   Payload: ${dynamicQR.substring(0, 50)}...');

    // Test 3: Vietnamese text sanitization
    print('\n3️⃣ Testing Vietnamese text sanitization...');
    final vietnameseQR = VietQR.generate(
      bank: Bank.mbBank,
      accountNumber: '5555555555',
      amount: 50000.0,
      message: 'Thanh toán đơn hàng café',
    );
    print('✅ Vietnamese text sanitized');
    print(
        '   Contains sanitized text: ${vietnameseQR.contains('Thanh toan don hang cafe')}');

    // Test 4: Error handling
    print('\n4️⃣ Testing error handling...');
    try {
      VietQR.generate(
        bank: Bank.bidv,
        accountNumber: '',
      );
      print('❌ Should have thrown error for empty account');
    } catch (e) {
      print('✅ Error handling works: ${e.toString()}');
    }

    print('\n🎉 All quick tests passed!');
  } catch (e, stackTrace) {
    print('❌ Test failed: $e');
    print('Stack trace: $stackTrace');
  }
}
