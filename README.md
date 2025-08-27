# VietQR Generator

[![pub package](https://img.shields.io/pub/v/vietqr_gen.svg)](https://pub.dev/packages/vietqr_gen)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A zero-dependency, type-safe Dart package for generating VietQR payload strings. This package strictly follows the **NAPAS 247** specification to create payloads for both **static** and **dynamic** QR codes, which can then be rendered by any QR code generation library (like `qr_flutter`).

## Features

- ✅ **NAPAS Compliant**: Follows the official specification for VietQR
- 🔄 **Static & Dynamic QR**: Generate QR codes for both simple transfers (static) and transfers with a pre-filled amount and message (dynamic)
- 🏦 **Comprehensive Bank List**: Includes a type-safe `Bank` enum for all major Vietnamese banks, preventing typos in bank names
- 🔒 **Type-Safe**: Avoids common errors by using required parameters and enums
- 🚀 **Lightweight**: No external dependencies
- 💻 **Cross-Platform**: Pure Dart code that runs everywhere Flutter and Dart do

## Getting Started

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  vietqr_gen: ^1.0.0 # Replace with the latest version
```

Then, run `flutter pub get` or `dart pub get`.

## Usage

Import the package in your Dart file:

```dart
import 'package:vietqr_gen/vietqr_generator.dart';
```

Now you can use the generated payload string with your favorite QR code widget, like `qr_flutter`.

### 1. Generating a Static QR Code

A **static** QR code contains only the bank and account number. The person scanning the QR will have to enter the amount and message themselves.

```dart
// 1. Define the bank information
final bank = Bank.techcombank; // Use the convenient Bank enum
final accountNumber = '9602091996';

// 2. Generate the payload string
final String qrPayload = VietQR.generate(
  bank: bank,
  accountNumber: accountNumber,
);

// 3. Print or use the payload with a QR widget
print(qrPayload);
// Output: 00020101021138540010A00000072701240006970407011096020919960208QRIBFTTA53037045802VN630434A0

// 4. Use with qr_flutter
// QrImageView(
//   data: qrPayload,
//   version: QrVersions.auto,
//   size: 200.0,
// );
```

### 2. Generating a Dynamic QR Code

A **dynamic** QR code pre-fills the transaction amount and/or a message for the user, making payments faster and less error-prone. Just provide the optional `amount` and `message` parameters.

```dart
// 1. Define the full transaction details
final bank = Bank.mbBank;
final accountNumber = '0962091996';
final double amount = 150000.0;
final String message = 'Thanh toan don hang';

// 2. Generate the dynamic payload string
final String qrPayload = VietQR.generate(
  bank: bank,
  accountNumber: accountNumber,
  amount: amount,
  message: message,
);

// 3. Print or use the payload
print(qrPayload);
// Output: 00020101021238530010A00000072701230006970422011009620919960208QRIBFTTA530370454061500005802VN62220818Thanh toan don hang6304E3A3

// 4. Use with qr_flutter
// QrImageView(
//   data: qrPayload,
//   version: QrVersions.auto,
//   size: 200.0,
// );
```

### 3. Using with QR Flutter

Here's a complete example using the popular `qr_flutter` package:

```dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vietqr_gen/vietqr_generator.dart';

class PaymentQRScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Generate VietQR payload
    final qrPayload = VietQR.generate(
      bank: Bank.techcombank,
      accountNumber: '9602091996',
      amount: 50000,
      message: 'Coffee payment',
    );

    return Scaffold(
      appBar: AppBar(title: Text('Payment QR Code')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrPayload,
              version: QrVersions.auto,
              size: 200.0,
            ),
            SizedBox(height: 20),
            Text('Scan to pay 50,000 VND'),
            Text('Account: Techcombank - 9602091996'),
          ],
        ),
      ),
    );
  }
}
```

## Supported Banks

The `Bank` enum provides a convenient and type-safe way to specify the bank. Here are some of the supported banks:

| Enum Value | Bank Name | BIN |
|---|---|---|
| `Bank.agribank` | Agribank | 970405 |
| `Bank.vietinbank` | Vietinbank | 970415 |
| `Bank.bidv` | BIDV | 970418 |
| `Bank.vietcombank` | Vietcombank | 970436 |
| `Bank.techcombank` | Techcombank | 970407 |
| `Bank.mbBank` | MBBank | 970422 |
| `Bank.vpBank` | VPBank | 970432 |
| `Bank.acb` | ACB | 970416 |
| `Bank.sacombank` | Sacombank | 970403 |
| `Bank.hdBank` | HDBank | 970437 |
| `Bank.tpBank` | TPBank | 970423 |
| `Bank.vib` | VIB | 970441 |

...and many more! See the [Bank enum](lib/src/bank.dart) for the complete list.

## Payload Breakdown

Ever wondered what that long string means? Here's a breakdown of a dynamic QR payload, as specified by NAPAS:

`00020101021238530010A000000727012300069704220110096209199602...`

| ID | Length | Value | Description |
|---|---|---|---|
| `00` | `02` | `01` | Payload Format Indicator |
| `01` | `02` | `12` | Point of Initiation (11=Static, 12=Dynamic) |
| `38` | `53` | `0010A0...` | Merchant Account Info (contains sub-fields) |
| | | `00` `10` `A000000727` | (sub) GUID for NAPAS |
| | | `01` `27` `000697...` | (sub) Beneficiary Info (Bank BIN + Account No) |
| | | `02` `08` `QRIBFTTA` | (sub) Service Code (Transfer to Account) |
| `53` | `03` | `704` | Transaction Currency (VND) |
| `54` | `06` | `150000` | Transaction Amount |
| `58` | `02` | `VN` | Country Code |
| `62` | `22` | `0818...` | Additional Data (contains sub-fields) |
| | | `08` `18` `thanh toan don hang` | (sub) Purpose of Transaction |
| `63` | `04` | `E3A3` | **CRC Checksum** (Calculated on all prior fields) |

## Error Handling

The package includes validation to help prevent common errors:

```dart
// This will throw an ArgumentError
VietQR.generate(
  bank: Bank.techcombank,
  accountNumber: '', // Empty account number
);

// This will throw an ArgumentError
VietQR.generate(
  bank: Bank.techcombank,
  accountNumber: '1234567890',
  amount: -100, // Negative amount
);
```

## Vietnamese Text Handling

The package automatically sanitizes Vietnamese text in messages by:
- Removing accents (á → a, ế → e, etc.)
- Removing special characters
- Preserving spaces and alphanumeric characters

```dart
VietQR.generate(
  bank: Bank.techcombank,
  accountNumber: '1234567890',
  message: 'Thanh toán đơn hàng café', // Input with Vietnamese accents
);
// Message becomes: "Thanh toan don hang cafe"
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built according to the NAPAS 247 specification
- Inspired by the need for a reliable, type-safe VietQR solution for Flutter developers
- Thanks to the Vietnamese developer community for feedback and testing
