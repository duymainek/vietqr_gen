import 'dart:convert';

/// CRC-16/CCITT-FALSE calculation for VietQR checksum.
/// This implementation follows the NAPAS specification requirements.
String calculateCRC16(String data) {
  int crc = 0xFFFF;
  final bytes = utf8.encode(data);

  for (final byte in bytes) {
    crc ^= (byte << 8);
    for (int i = 0; i < 8; i++) {
      if ((crc & 0x8000) != 0) {
        crc = (crc << 1) ^ 0x1021;
      } else {
        crc <<= 1;
      }
      crc &= 0xFFFF; // Keep only 16 bits
    }
  }

  final crcValue = (crc & 0xFFFF).toRadixString(16).toUpperCase();
  return crcValue.padLeft(4, '0');
}
