import 'bank.dart';
import 'utils/crc16.dart';
import 'utils/string_sanitizer.dart';
import 'vietqr_parsed_data.dart';

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
  /// - [bank]: The beneficiary bank from the [Bank] enum (optional if [bankBin] is provided)
  /// - [accountNumber]: The beneficiary's account number
  /// - [amount]: (Optional) The transaction amount in VND. If provided, creates a dynamic QR
  /// - [message]: (Optional) A message or purpose for the transaction
  /// - [bankBin]: (Optional) Custom Bank Identification Number (6 digits). Use this for banks not in the [Bank] enum
  ///
  /// Returns a string that can be used to generate a QR code.
  ///
  /// Example:
  /// ```dart
  /// // Static QR using Bank enum (user enters amount)
  /// final payload = VietQR.generate(
  ///   bank: Bank.techcombank,
  ///   accountNumber: '9602091996',
  /// );
  ///
  /// // Dynamic QR using Bank enum (pre-filled amount and message)
  /// final payload = VietQR.generate(
  ///   bank: Bank.mbBank,
  ///   accountNumber: '0962091996',
  ///   amount: 150000.0,
  ///   message: 'Thanh toan don hang',
  /// );
  ///
  /// // Using custom BIN for unsupported banks
  /// final payload = VietQR.generate(
  ///   accountNumber: '1234567890',
  ///   bankBin: '970999', // Custom bank BIN
  ///   amount: 100000.0,
  ///   message: 'Payment to custom bank',
  /// );
  /// ```
  static String generate({
    Bank? bank,
    required String accountNumber,
    double? amount,
    String? message,
    String? bankBin,
  }) {
    // Validate inputs
    if (accountNumber.isEmpty) {
      throw ArgumentError('Account number cannot be empty');
    }

    if (amount != null && amount < 0) {
      throw ArgumentError('Amount must be greater than or equal to 0');
    }

    // Validate that either bank or bankBin is provided, but not both
    if (bank == null && bankBin == null) {
      throw ArgumentError('Either bank or bankBin must be provided');
    }

    if (bank != null && bankBin != null) {
      throw ArgumentError('Cannot provide both bank and bankBin parameters');
    }

    // Validate custom BIN format if provided
    if (bankBin != null) {
      if (bankBin.isEmpty) {
        throw ArgumentError('Bank BIN cannot be empty');
      }
      if (!RegExp(r'^\d{6}$').hasMatch(bankBin)) {
        throw ArgumentError('Bank BIN must be exactly 6 digits');
      }
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
    final binToUse = bank?.bin ?? bankBin!;
    payload.write(_buildMerchantAccountInfo(binToUse, accountNumber));

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

  /// Parses a VietQR payload string and extracts all the information.
  ///
  /// This method analyzes a VietQR payload string and returns a [VietQRParsedData]
  /// object containing all the extracted information including bank details,
  /// account number, amount, message, and other metadata.
  ///
  /// Parameters:
  /// - [payload]: The VietQR payload string to parse
  ///
  /// Returns a [VietQRParsedData] object with all parsed information.
  ///
  /// Throws [FormatException] if the payload is malformed or invalid.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final parsedData = VietQR.parse('0002010102113802A000000727...');
  ///   print('Bank: ${parsedData.bankName}');
  ///   print('Account: ${parsedData.accountNumber}');
  ///   print('Amount: ${parsedData.formattedAmount}');
  /// } catch (e) {
  ///   print('Invalid VietQR payload: $e');
  /// }
  /// ```
  static VietQRParsedData parse(String payload) {
    if (payload.isEmpty) {
      throw FormatException('Payload cannot be empty');
    }

    // Validate CRC first
    _validateCRC(payload);

    final fields = <String, String>{};
    int index = 0;

    // Parse all TLV fields
    while (index < payload.length - 4) {
      final fieldId = payload.substring(index, index + 2);
      final lengthStr = payload.substring(index + 2, index + 4);

      if (!RegExp(r'^\d{2}$').hasMatch(lengthStr)) {
        throw FormatException('Invalid length format at position $index');
      }

      final length = int.parse(lengthStr);

      if (index + 4 + length > payload.length) {
        throw FormatException('Field $fieldId extends beyond payload length');
      }

      final value = payload.substring(index + 4, index + 4 + length);
      fields[fieldId] = value;

      index += 4 + length;
    }

    // Extract and validate required fields
    final payloadFormat = fields['00'] ?? '';
    final pointOfInitiation = fields['01'] ?? '';
    final merchantAccount = fields['38'] ?? '';
    final currency = fields['53'] ?? '';
    final amount = fields['54'];
    final countryCode = fields['58'] ?? '';
    final additionalData = fields['62'];
    final crc = fields['63'] ?? '';

    // Validate required fields
    if (payloadFormat != '01') {
      throw FormatException('Invalid payload format: $payloadFormat');
    }

    if (pointOfInitiation != '11' && pointOfInitiation != '12') {
      throw FormatException('Invalid point of initiation: $pointOfInitiation');
    }

    if (currency != '704') {
      throw FormatException('Invalid currency code: $currency');
    }

    if (countryCode != 'VN') {
      throw FormatException('Invalid country code: $countryCode');
    }

    // Parse merchant account information
    final merchantInfo = _parseMerchantAccountInfo(merchantAccount);

    // Parse additional data (message)
    String? message;
    if (additionalData != null && additionalData.isNotEmpty) {
      message = _parseAdditionalData(additionalData);
    }

    // Parse amount
    double? parsedAmount;
    if (amount != null && amount.isNotEmpty) {
      try {
        parsedAmount = double.parse(amount);
      } catch (e) {
        throw FormatException('Invalid amount format: $amount');
      }
    }

    // Determine if dynamic QR
    final isDynamic = pointOfInitiation == '12';

    // Find matching bank
    Bank? bank;
    try {
      bank = Bank.values.firstWhere(
        (b) => b.bin == merchantInfo['bankBin'],
        orElse: () => throw StateError('Bank not found'),
      );
    } catch (e) {
      // Bank not found in enum, will be null
    }

    return VietQRParsedData(
      bank: bank,
      bankBin: merchantInfo['bankBin']!,
      accountNumber: merchantInfo['accountNumber']!,
      amount: parsedAmount,
      message: message,
      isDynamic: isDynamic,
      payloadFormat: payloadFormat,
      pointOfInitiation: pointOfInitiation,
      currency: currency,
      countryCode: countryCode,
      crc: crc,
    );
  }

  /// Validates the CRC checksum of the payload.
  static void _validateCRC(String payload) {
    if (payload.length < 8) {
      throw FormatException('Payload too short to contain valid CRC');
    }

    // Extract CRC field (last 8 characters: 2 for field ID, 2 for length, 4 for CRC)
    final crcField = payload.substring(payload.length - 8);
    final crcFieldId = crcField.substring(0, 2);
    final crcLength = crcField.substring(2, 4);
    final providedCrc = crcField.substring(4, 8);

    if (crcFieldId != '63') {
      throw FormatException('Invalid CRC field ID: $crcFieldId');
    }

    if (crcLength != '04') {
      throw FormatException('Invalid CRC length: $crcLength');
    }

    // Calculate expected CRC
    final payloadWithoutCrc = payload.substring(0, payload.length - 4);
    final expectedCrc = calculateCRC16(payloadWithoutCrc);

    if (providedCrc != expectedCrc) {
      throw FormatException(
          'CRC checksum mismatch. Expected: $expectedCrc, Got: $providedCrc');
    }
  }

  /// Parses the merchant account information field (ID 38).
  static Map<String, String> _parseMerchantAccountInfo(String merchantAccount) {
    if (merchantAccount.isEmpty) {
      throw FormatException('Merchant account information is empty');
    }

    int index = 0;
    String? bankBin;
    String? accountNumber;

    while (index < merchantAccount.length - 4) {
      final subFieldId = merchantAccount.substring(index, index + 2);
      final lengthStr = merchantAccount.substring(index + 2, index + 4);

      if (!RegExp(r'^\d{2}$').hasMatch(lengthStr)) {
        throw FormatException(
            'Invalid sub-field length format at position $index');
      }

      final length = int.parse(lengthStr);

      if (index + 4 + length > merchantAccount.length) {
        throw FormatException(
            'Sub-field $subFieldId extends beyond merchant account length');
      }

      final value = merchantAccount.substring(index + 4, index + 4 + length);

      if (subFieldId == '01') {
        // Beneficiary information - contains nested bank BIN and account number
        final beneficiaryInfo = _parseBeneficiaryInfo(value);
        bankBin = beneficiaryInfo['bankBin'];
        accountNumber = beneficiaryInfo['accountNumber'];
      }

      index += 4 + length;
    }

    if (bankBin == null || accountNumber == null) {
      throw FormatException(
          'Could not extract bank BIN or account number from merchant account info');
    }

    return {
      'bankBin': bankBin,
      'accountNumber': accountNumber,
    };
  }

  /// Parses the beneficiary information sub-field.
  static Map<String, String> _parseBeneficiaryInfo(String beneficiaryInfo) {
    int index = 0;
    String? bankBin;
    String? accountNumber;

    while (index < beneficiaryInfo.length - 4) {
      final subFieldId = beneficiaryInfo.substring(index, index + 2);
      final lengthStr = beneficiaryInfo.substring(index + 2, index + 4);

      if (!RegExp(r'^\d{2}$').hasMatch(lengthStr)) {
        throw FormatException(
            'Invalid beneficiary sub-field length format at position $index');
      }

      final length = int.parse(lengthStr);

      if (index + 4 + length > beneficiaryInfo.length) {
        throw FormatException(
            'Beneficiary sub-field $subFieldId extends beyond length');
      }

      final value = beneficiaryInfo.substring(index + 4, index + 4 + length);

      if (subFieldId == '00') {
        bankBin = value;
      } else if (subFieldId == '01') {
        accountNumber = value;
      }

      index += 4 + length;
    }

    if (bankBin == null || accountNumber == null) {
      throw FormatException(
          'Could not extract bank BIN or account number from beneficiary info');
    }

    return {
      'bankBin': bankBin,
      'accountNumber': accountNumber,
    };
  }

  /// Parses the additional data field (ID 62) to extract the message.
  static String? _parseAdditionalData(String additionalData) {
    int index = 0;

    while (index < additionalData.length - 4) {
      final subFieldId = additionalData.substring(index, index + 2);
      final lengthStr = additionalData.substring(index + 2, index + 4);

      if (!RegExp(r'^\d{2}$').hasMatch(lengthStr)) {
        throw FormatException(
            'Invalid additional data sub-field length format at position $index');
      }

      final length = int.parse(lengthStr);

      if (index + 4 + length > additionalData.length) {
        throw FormatException(
            'Additional data sub-field $subFieldId extends beyond length');
      }

      final value = additionalData.substring(index + 4, index + 4 + length);

      if (subFieldId == '08') {
        // Purpose of transaction (message)
        return value;
      }

      index += 4 + length;
    }

    return null;
  }
}
