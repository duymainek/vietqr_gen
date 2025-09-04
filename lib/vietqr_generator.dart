/// A zero-dependency, type-safe Dart package for generating VietQR payload strings.
///
/// This package strictly follows the **NAPAS 247** specification to create payloads
/// for both **static** and **dynamic** QR codes, which can then be rendered by any
/// QR code generation library (like `qr_flutter`).
///
/// ## Features
///
/// - ✅ **NAPAS Compliant**: Follows the official specification for VietQR
/// - 🔄 **Static & Dynamic QR**: Generate QR codes for both simple transfers (static) and transfers with a pre-filled amount and message (dynamic)
/// - 🔍 **QR Parsing**: Parse and extract information from existing VietQR payloads (NEW!)
/// - 🏦 **Comprehensive Bank List**: Includes a type-safe `Bank` enum for all major Vietnamese banks
/// - 🎯 **Custom BIN Support**: Use custom Bank Identification Numbers for unsupported banks
/// - 🔒 **Type-Safe**: Avoids common errors by using required parameters and enums
/// - 🚀 **Lightweight**: No external dependencies
/// - 💻 **Cross-Platform**: Pure Dart code that runs everywhere Flutter and Dart do
///
/// ## Usage
///
/// ```dart
/// import 'package:vietqr_gen/vietqr_generator.dart';
///
/// // Static QR using Bank enum (user enters amount)
/// final staticPayload = VietQR.generate(
///   bank: Bank.techcombank,
///   accountNumber: '9602091996',
/// );
///
/// // Dynamic QR using Bank enum (pre-filled amount and message)
/// final dynamicPayload = VietQR.generate(
///   bank: Bank.mbBank,
///   accountNumber: '0962091996',
///   amount: 150000.0,
///   message: 'Thanh toan don hang',
/// );
///
/// // Using custom BIN for unsupported banks
/// final customBinPayload = VietQR.generate(
///   accountNumber: '1234567890',
///   bankBin: '970999', // Custom bank BIN (6 digits)
///   amount: 100000.0,
///   message: 'Payment to custom bank',
/// );
///
/// // Parsing VietQR payloads (NEW FEATURE!)
/// try {
///   final parsedData = VietQR.parse(qrPayloadString);
///   print('Bank: ${parsedData.bankName}');
///   print('Account: ${parsedData.accountNumber}');
///   print('Amount: ${parsedData.formattedAmount}');
///   print('Message: ${parsedData.message}');
///   print('Type: ${parsedData.isDynamic ? "Dynamic" : "Static"} QR');
/// } catch (e) {
///   print('Invalid VietQR payload: $e');
/// }
/// ```
library vietqr_gen;

export 'src/vietqr.dart';
export 'src/bank.dart';
export 'src/vietqr_parsed_data.dart';
