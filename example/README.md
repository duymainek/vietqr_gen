# VietQR Generator Example

This example demonstrates how to use the `vietqr_gen` package to create VietQR payload strings.

## Running the Example

1. Make sure you're in the example directory:
   ```bash
   cd example
   ```

2. Install dependencies:
   ```bash
   dart pub get
   ```

3. Run the example:
   ```bash
   dart run example.dart
   ```

## What the Example Shows

The example demonstrates:

1. **Static QR Code**: Basic QR code with just bank and account number
2. **Dynamic QR Code with Amount**: QR code with pre-filled amount
3. **Dynamic QR Code with Amount and Message**: Complete QR code with amount and message
4. **Vietnamese Text Sanitization**: How Vietnamese characters are handled
5. **Different Banks**: Examples using various Vietnamese banks

## Expected Output

When you run the example, you'll see payload strings that can be used with any QR code generation library to create scannable VietQR codes.

The payload strings follow the NAPAS 247 specification and can be scanned by any Vietnamese banking app that supports VietQR.