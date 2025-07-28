/// Constants and utilities for Unicode variation selectors.
/// 
/// Unicode variation selectors are invisible codepoints that modify the
/// presentation of the preceding character. This library uses them to encode
/// arbitrary byte data by mapping each byte (0-255) to a specific variation
/// selector codepoint.
library variation_selectors;

/// VS1-VS16 range: U+FE00 to U+FE0F (16 selectors for bytes 0-15).
const int _variationSelectorStart = 0xFE00;
const int _variationSelectorEnd = 0xFE0F;

/// VS17-VS256 range: U+E0100 to U+E01EF (240 selectors for bytes 16-255).
const int _variationSelectorSupplementStart = 0xE0100;
const int _variationSelectorSupplementEnd = 0xE01EF;

/// Exception thrown when byte value is out of valid range (0-255).
class InvalidByteException implements Exception {
  final int byte;
  const InvalidByteException(this.byte);
  
  @override
  String toString() => 'InvalidByteException: Byte value $byte is out of range (0-255)';
}

/// Exception thrown when codepoint is not a valid variation selector.
class InvalidVariationSelectorException implements Exception {
  final int codepoint;
  const InvalidVariationSelectorException(this.codepoint);
  
  @override
  String toString() => 'InvalidVariationSelectorException: Codepoint 0x${codepoint.toRadixString(16).toUpperCase()} is not a valid variation selector';
}

/// Converts a byte value (0-255) to its corresponding variation selector
/// character.
/// 
/// Bytes 0-15 map to VS1-VS16 (U+FE00 to U+FE0F).
/// Bytes 16-255 map to VS17-VS256 (U+E0100 to U+E01EF).
/// 
/// Throws [InvalidByteException] if byte is outside the valid range.
String byteToVariationSelector(int byte) {
  if (byte < 0 || byte > 255) {
    throw InvalidByteException(byte);
  }
  
  if (byte < 16) {
    return String.fromCharCode(_variationSelectorStart + byte);
  } else {
    return String.fromCharCode(_variationSelectorSupplementStart + byte - 16);
  }
}

/// Converts a variation selector codepoint back to its corresponding byte value.
/// 
/// Returns the byte value (0-255) if the codepoint is a valid variation
/// selector, or null if it's not a variation selector.
int? variationSelectorToByte(int codepoint) {  
  if (codepoint >= _variationSelectorStart && codepoint <= _variationSelectorEnd) {
    return codepoint - _variationSelectorStart;
  } else if (codepoint >= _variationSelectorSupplementStart && codepoint <= _variationSelectorSupplementEnd) {
    return codepoint - _variationSelectorSupplementStart + 16;
  }
  
  return null;
}

/// Checks if a codepoint is a valid variation selector.
bool isVariationSelector(int codepoint) {
  return (codepoint >= _variationSelectorStart && codepoint <= _variationSelectorEnd) ||
         (codepoint >= _variationSelectorSupplementStart && codepoint <= _variationSelectorSupplementEnd);
}

/// Gets the Unicode codepoint for a character.
/// 
/// For most characters this is straightforward, but handles surrogate pairs
/// for characters outside the Basic Multilingual Plane.
int getCodepoint(String char) {
  if (char.isEmpty) {
    throw ArgumentError('Character string cannot be empty');
  }
  
  final runes = char.runes.toList();
  if (runes.length != 1) {
    throw ArgumentError('String must contain exactly one Unicode character');
  }
  
  return runes.first;
}