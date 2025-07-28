/// Core encoding logic for hiding text data in Unicode characters using
/// variation selectors.
library encoder;

import 'dart:convert';
import 'variation_selectors.dart';

/// Exception thrown when encoding fails.
class EncodingException implements Exception {
  final String message;
  const EncodingException(this.message);
  
  @override
  String toString() => 'EncodingException: $message';
}

/// Encodes a message into a base character using Unicode variation selectors.
/// 
/// The [baseCharacter] is the visible character (emoji, letter, etc.) that will
/// appear in the output. The [message] is the text to hide within the character.
/// 
/// The message is first converted to UTF-8 bytes, then each byte is converted
/// to its corresponding variation selector and appended after the base
/// character.
/// 
/// Example:
/// ```dart
/// final encoded = encode('😊', 'hello');
/// print(encoded); // Looks like just '😊' but contains hidden data.
/// ```
/// 
/// Throws [EncodingException] if the encoding process fails.
/// Throws [ArgumentError] if inputs are invalid.
String encode(String baseCharacter, String message) {
  // Validate inputs.
  if (baseCharacter.isEmpty) {
    throw ArgumentError('Base character cannot be empty');
  }
  
  if (message.isEmpty) {
    throw ArgumentError('Message cannot be empty');
  }
  
  // Ensure base character is a single Unicode character.
  final baseRunes = baseCharacter.runes.toList();
  if (baseRunes.length != 1) {
    throw ArgumentError('Base character must be exactly one Unicode character');
  }
  
  try {
    // Convert message to UTF-8 bytes.
    final messageBytes = utf8.encode(message);
    
    // Start with the base character.
    final buffer = StringBuffer(baseCharacter);
    
    // Convert each byte to a variation selector and append.
    for (final byte in messageBytes) {
      buffer.write(byteToVariationSelector(byte));
    }
    
    return buffer.toString();
    
  } catch (e) {
    throw EncodingException('Failed to encode message: $e');
  }
}

/// Encodes multiple messages into a single text string.
/// 
/// Each message is encoded with its own base character. This allows multiple
/// hidden messages to coexist in the same text.
/// 
/// The [messages] map contains base characters as keys and messages as values.
/// 
/// Example:
/// ```dart
/// final encoded = encodeMultiple({
///   '😊': 'hello',
///   '🌟': 'world',
/// });
/// // Result looks like '😊🌟' but contains two hidden messages.
/// ```
String encodeMultiple(Map<String, String> messages) {
  if (messages.isEmpty) {
    throw ArgumentError('Messages map cannot be empty');
  }
  
  final buffer = StringBuffer();
  
  for (final entry in messages.entries) {
    buffer.write(encode(entry.key, entry.value));
  }
  
  return buffer.toString();
}

/// Encodes a message with automatic base character selection.
/// 
/// If no [baseCharacter] is provided, uses a default emoji.
/// This is a convenience method for simple encoding scenarios.
String encodeWithDefault(String message, {String? baseCharacter}) {
  return encode(baseCharacter ?? '😊', message);
}

/// Estimates the visual length of encoded text.
/// 
/// Since variation selectors are invisible, the visual length is just the
/// number of base characters used, not the actual string length.
int getVisualLength(String encodedText) {
  int visualLength = 0;
  
  for (final rune in encodedText.runes) {
    if (!isVariationSelector(rune)) {
      visualLength++;
    }
  }
  
  return visualLength;
}

/// Checks if a string contains encoded data (has variation selectors).
bool hasEncodedData(String text) {
  for (final rune in text.runes) {
    if (isVariationSelector(rune)) {
      return true;
    }
  }
  return false;
}