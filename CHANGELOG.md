# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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