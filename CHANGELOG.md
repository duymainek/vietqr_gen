# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2024-12-19

### Added
- **QR Parsing Feature**: Added `VietQR.parse()` method to extract information from VietQR payloads
- **VietQRParsedData Class**: New data model to hold parsed QR information
- Comprehensive TLV (Tag-Length-Value) parsing logic following NAPAS 247 specification
- CRC validation for payload integrity verification
- Support for parsing both static and dynamic QR codes
- Automatic bank detection from BIN codes
- Formatted amount display with thousand separators
- Data conversion to Map format for easy serialization
- Detailed error handling for malformed payloads
- Round-trip testing to ensure data integrity

### Features
- Parse bank information, account numbers, amounts, and messages
- Validate payload format, currency, country code, and CRC checksums
- Handle custom BIN codes for unsupported banks
- Extract metadata like QR type (static/dynamic), currency, and country
- Comprehensive test coverage with 23+ test cases

## [1.1.0] - 2024-12-19

### Added
- **Custom BIN Support**: Added `bankBin` parameter to `VietQR.generate()` method
- Support for custom Bank Identification Numbers (6 digits) for unsupported banks
- Comprehensive validation for custom BIN format (exactly 6 digits)
- Enhanced flexibility to work with any NAPAS-compliant bank not in the Bank enum

### Changed
- `bank` parameter in `VietQR.generate()` is now optional when `bankBin` is provided
- Updated documentation with examples for custom BIN usage
- Enhanced error messages for better developer experience

### Features
- Use either `Bank` enum or custom `bankBin` string (mutually exclusive)
- Full backward compatibility with existing code
- Comprehensive test coverage for custom BIN functionality

## [1.0.1] - 2024-12-19

### Fixed
- Fixed missing Vietnamese character mappings for 'ô' and 'Ô' (o with circumflex) in StringSanitizer
- Added comprehensive test case for Vietnamese name sanitization

### Added
- Test case for "Tô Thị Ánh Nguyệt chuyển khoản" transfer message to ensure proper text sanitization

## [1.0.0] - 2024-01-XX

### Added
- Initial release of VietQR Generator package
- Support for generating NAPAS 247 compliant VietQR payload strings
- Static QR code generation (user enters amount)
- Dynamic QR code generation (pre-filled amount and message)
- Comprehensive Bank enum with all major Vietnamese banks and their BIN codes
- Vietnamese text sanitization for QR code compatibility
- CRC-16 checksum calculation for payload validation
- Type-safe API with proper error handling
- Zero external dependencies
- Complete documentation and examples

### Features
- 33+ supported Vietnamese banks
- Automatic Vietnamese accent removal
- Input validation for account numbers and amounts
- TLV (Tag-Length-Value) format implementation
- Cross-platform compatibility (Flutter, Dart VM, Web)