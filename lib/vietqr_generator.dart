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
/// - 🏦 **Comprehensive Bank List**: Includes a type-safe `Bank` enum for all major Vietnamese banks
/// - 🔒 **Type-Safe**: Avoids common errors by using required parameters and enums
/// - 🚀 **Lightweight**: No external dependencies
/// - 💻 **Cross-Platform**: Pure Dart code that runs everywhere Flutter and Dart do
///
/// ## Usage
///
/// ```dart
/// import 'package:vietqr_gen/vietqr_generator.dart';
///
/// // Static QR (user enters amount)
/// final staticPayload = VietQR.generate(
///   bank: Bank.techcombank,
///   accountNumber: '9602091996',
/// );
///
/// // Dynamic QR (pre-filled amount and message)
/// final dynamicPayload = VietQR.generate(
///   bank: Bank.mbBank,
///   accountNumber: '0962091996',
///   amount: 150000.0,
///   message: 'Thanh toan don hang',
/// );
/// ```
library vietqr_gen;

export 'src/vietqr.dart';
export 'src/bank.dart';
