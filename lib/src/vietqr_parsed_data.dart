import 'bank.dart';

/// Represents the parsed data from a VietQR payload string.
///
/// This class contains all the information extracted from a VietQR payload,
/// including bank details, account information, transaction amount, and message.
class VietQRParsedData {
  /// The bank information if the BIN matches a known bank, null otherwise.
  final Bank? bank;

  /// The Bank Identification Number (BIN) used in the QR code.
  final String bankBin;

  /// The beneficiary's account number.
  final String accountNumber;

  /// The transaction amount in VND, null if not specified (static QR).
  final double? amount;

  /// The transaction message/purpose, null if not specified.
  final String? message;

  /// Whether this is a dynamic QR (with pre-filled amount) or static QR.
  final bool isDynamic;

  /// The original payload format indicator (should be "01" for VietQR).
  final String payloadFormat;

  /// The point of initiation method ("11" for static, "12" for dynamic).
  final String pointOfInitiation;

  /// The transaction currency code (should be "704" for VND).
  final String currency;

  /// The country code (should be "VN" for Vietnam).
  final String countryCode;

  /// The CRC checksum from the original payload.
  final String crc;

  /// Creates a new instance of [VietQRParsedData].
  const VietQRParsedData({
    required this.bank,
    required this.bankBin,
    required this.accountNumber,
    required this.amount,
    required this.message,
    required this.isDynamic,
    required this.payloadFormat,
    required this.pointOfInitiation,
    required this.currency,
    required this.countryCode,
    required this.crc,
  });

  /// Returns the bank name, either from the matched [Bank] enum or the BIN if unknown.
  String get bankName => bank?.name ?? 'Unknown Bank ($bankBin)';

  /// Returns a formatted string representation of the amount, or "Not specified" for static QR.
  String get formattedAmount {
    if (amount == null) return 'Not specified';
    return '${amount!.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )} VND';
  }

  /// Returns a summary of the parsed data.
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('VietQR Parsed Data:');
    buffer.writeln('  Bank: $bankName');
    buffer.writeln('  Account: $accountNumber');
    buffer.writeln('  Amount: $formattedAmount');
    buffer.writeln('  Message: ${message ?? "Not specified"}');
    buffer.writeln('  Type: ${isDynamic ? "Dynamic" : "Static"} QR');
    buffer.writeln('  Currency: $currency');
    buffer.writeln('  Country: $countryCode');
    return buffer.toString();
  }

  /// Returns a JSON-like map representation of the parsed data.
  Map<String, dynamic> toMap() {
    return {
      'bank': bank?.name,
      'bankBin': bankBin,
      'accountNumber': accountNumber,
      'amount': amount,
      'message': message,
      'isDynamic': isDynamic,
      'payloadFormat': payloadFormat,
      'pointOfInitiation': pointOfInitiation,
      'currency': currency,
      'countryCode': countryCode,
      'crc': crc,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VietQRParsedData &&
        other.bank == bank &&
        other.bankBin == bankBin &&
        other.accountNumber == accountNumber &&
        other.amount == amount &&
        other.message == message &&
        other.isDynamic == isDynamic &&
        other.payloadFormat == payloadFormat &&
        other.pointOfInitiation == pointOfInitiation &&
        other.currency == currency &&
        other.countryCode == countryCode &&
        other.crc == crc;
  }

  @override
  int get hashCode {
    return Object.hash(
      bank,
      bankBin,
      accountNumber,
      amount,
      message,
      isDynamic,
      payloadFormat,
      pointOfInitiation,
      currency,
      countryCode,
      crc,
    );
  }
}
