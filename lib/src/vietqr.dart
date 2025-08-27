import 'dart:convert';
import 'bank.dart';
import 'utils/crc16.dart';
import 'utils/string_sanitizer.dart';

/// A class for generating VietQR payload strings according to NAPAS 247 specification.
///
/// This class provides static methods to generate QR code payload strings that are
/// compliant with the Vietnamese National Payment Corporation (NAPAS) 247 standard.
///
/// The generated payload strings can be used with any QR code generation library
/// to create scannable QR codes for bank transfers in Vietnam.
class VietQR {
  // Field IDs from the NAPAS specification
  static const _idPayloadFormat = '00';
  static const _idPointOfInitiation = '01';
  static const _idMerchantAccount = '38';
  static const _idTransactionCurrency = '53';
  static const _idTransactionAmount = '54';
  static const _idCountryCode = '58';
  static const _idAdditionalData = '62';
  static const _idCRC = '63';

  // Sub-field IDs for Merchant Account Information (Field 38)
  static const _subIdMerchantGUID = '00';
  static const _subIdBeneficiary = '01';
  static const _subIdService = '02';

  // Sub-field IDs for Beneficiary Information
  static const _subBeneficiaryIdBank = '00';
  static const _subBeneficiaryIdAccount = '01';

  // Sub-field ID for Additional Data (Field 62)
  static const _subIdPurposeOfTransaction = '08';

  /// Generates a VietQR payload string compliant with NAPAS 247 specification.
  ///
  /// Parameters:
  /// - [bank]: The beneficiary bank from the [Bank] enum
  /// - [accountNumber]: The beneficiary's account number
  /// - [amount]: (Optional) The transaction amount in VND. If provided, creates a dynamic QR
  /// - [message]: (Optional) A message or purpose for the transaction
  ///
  /// Returns a string that can be used to generate a QR code.
  ///
  /// Example:
  /// ```dart
  /// // Static QR (user enters amount)
  /// final payload = VietQR.generate(
  ///   bank: Bank.techcombank,
  ///   accountNumber: '9602091996',
  /// );
  ///
  /// // Dynamic QR (pre-filled amount and message)
  /// final payload = VietQR.generate(
  ///   bank: Bank.mbBank,
  ///   accountNumber: '0962091996',
  ///   amount: 150000.0,
  ///   message: 'Thanh toan don hang',
  /// );
  /// ```
  static String generate({
    required Bank bank,
    required String accountNumber,
    double? amount,
    String? message,
  }) {
    // Validate inputs
    if (accountNumber.isEmpty) {
      throw ArgumentError('Account number cannot be empty');
    }

    if (amount != null && amount < 0) {
      throw ArgumentError('Amount must be greater than or equal to 0');
    }

    final bool isDynamic = (amount != null && amount > 0) ||
        (message != null && message.isNotEmpty);

    final payload = StringBuffer();

    // Field 00: Payload Format Indicator (always "01")
    payload.write(_buildTLV(_idPayloadFormat, '01'));

    // Field 01: Point of Initiation Method
    // "11" = Static QR (user enters amount)
    // "12" = Dynamic QR (amount pre-filled)
    payload.write(_buildTLV(_idPointOfInitiation, isDynamic ? '12' : '11'));

    // Field 38: Merchant Account Information
    payload.write(_buildMerchantAccountInfo(bank.bin, accountNumber));

    // Field 53: Transaction Currency (704 = Vietnamese Dong)
    payload.write(_buildTLV(_idTransactionCurrency, '704'));

    // Field 54: Transaction Amount (only for dynamic QR)
    if (amount != null && amount > 0) {
      // Convert to integer (VND doesn't use decimal places)
      final amountString = amount.toInt().toString();
      payload.write(_buildTLV(_idTransactionAmount, amountString));
    }

    // Field 58: Country Code (VN = Vietnam)
    payload.write(_buildTLV(_idCountryCode, 'VN'));

    // Field 62: Additional Data Field (optional message)
    if (message != null && message.isNotEmpty) {
      payload.write(_buildAdditionalData(message));
    }

    // Field 63: CRC Checksum
    // First add the field ID and length placeholder
    payload.write('${_idCRC}04');

    // Calculate CRC on the entire payload so far
    final crc = calculateCRC16(payload.toString());
    payload.write(crc);

    return payload.toString();
  }

  /// Builds a TLV (Tag-Length-Value) formatted string component.
  ///
  /// Format: [ID][LENGTH][VALUE]
  /// - ID: 2-digit field identifier
  /// - LENGTH: 2-digit length of the value (padded with leading zeros)
  /// - VALUE: the actual data
  static String _buildTLV(String id, String value) {
    final length = value.length.toString().padLeft(2, '0');
    return '$id$length$value';
  }

  /// Builds the complex Merchant Account Information field (ID 38).
  ///
  /// This field contains nested sub-fields:
  /// - Sub-field 00: NAPAS GUID ("A000000727")
  /// - Sub-field 01: Beneficiary info (bank BIN + account number)
  /// - Sub-field 02: Service code ("QRIBFTTA" for account transfer)
  static String _buildMerchantAccountInfo(
      String bankBin, String accountNumber) {
    // Sub-field 00: NAPAS GUID (fixed value)
    const guid = 'A000000727';
    final guidTLV = _buildTLV(_subIdMerchantGUID, guid);

    // Sub-field 01: Beneficiary Information
    // Contains nested bank BIN and account number
    final bankBinTLV = _buildTLV(_subBeneficiaryIdBank, bankBin);
    final accountNumberTLV = _buildTLV(_subBeneficiaryIdAccount, accountNumber);
    final beneficiaryInfo =
        _buildTLV(_subIdBeneficiary, '$bankBinTLV$accountNumberTLV');

    // Sub-field 02: Service Code (QRIBFTTA = QR Instant Bank Transfer To Account)
    const service = 'QRIBFTTA';
    final serviceTLV = _buildTLV(_subIdService, service);

    // Combine all sub-fields
    final combinedValue = '$guidTLV$beneficiaryInfo$serviceTLV';
    return _buildTLV(_idMerchantAccount, combinedValue);
  }

  /// Builds the Additional Data field (ID 62) containing the transaction message.
  ///
  /// This field can contain various sub-fields, but we primarily use:
  /// - Sub-field 08: Purpose of Transaction (the message)
  static String _buildAdditionalData(String message) {
    // Sanitize the message to remove Vietnamese accents and special characters
    final sanitizedMessage = StringSanitizer.sanitize(message);

    // Build the purpose of transaction sub-field
    final purposeTLV = _buildTLV(_subIdPurposeOfTransaction, sanitizedMessage);

    // Wrap in the additional data field
    return _buildTLV(_idAdditionalData, purposeTLV);
  }
}
