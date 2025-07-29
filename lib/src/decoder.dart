/// Core decoding logic for extracting hidden text data from Unicode characters.
library decoder;

import 'dart:convert';
import 'dart:typed_data';
import 'variation_selectors.dart';
import 'compression.dart';

/// Exception thrown when decoding fails.
class DecodingException implements Exception {
  final String message;
  const DecodingException(this.message);
  
  @override
  String toString() => 'DecodingException: $message';
}

/// Represents a decoded message with its associated base character.
class DecodedMessage {
  /// The base character that contained the hidden message.
  final String baseCharacter;
  
  /// The decoded hidden message.
  final String message;
  
  const DecodedMessage(this.baseCharacter, this.message);
  
  @override
  String toString() => 'DecodedMessage(baseCharacter: "$baseCharacter", message: "$message")';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecodedMessage &&
          runtimeType == other.runtimeType &&
          baseCharacter == other.baseCharacter &&
          message == other.message;
  
  @override
  int get hashCode => baseCharacter.hashCode ^ message.hashCode;
}

/// Decodes the first hidden message from encoded text.
/// 
/// Scans through the text looking for variation selectors, extracts the
/// corresponding bytes, and converts them back to a UTF-8 string.
/// Automatically handles decompression if the data was compressed.
/// 
/// Returns the decoded message or an empty string if no encoded data is found.
/// 
/// Example:
/// ```dart
/// final encoded = encode('😊', 'hello');
/// final decoded = decode(encoded); // Returns 'hello'.
/// ```
/// 
/// Throws [DecodingException] if the decoding process fails.
String decode(String encodedText) {
  if (encodedText.isEmpty) {
    return '';
  }
  
  try {
    final bytes = <int>[];
    bool foundVariationSelector = false;
    
    for (final rune in encodedText.runes) {
      final byte = variationSelectorToByte(rune);
      
      if (byte != null) {
        bytes.add(byte);
        foundVariationSelector = true;
      } else if (foundVariationSelector) {
        // Hit a non-variation selector after finding some, stop decoding.
        break;
      }
      // Continue scanning if we haven't found any variation selectors yet.
    }
    
    if (bytes.isEmpty) {
      return '';
    }
    
    // Check for compression marker
    if (bytes.isNotEmpty) {
      final marker = bytes[0];
      final dataBytes = Uint8List.fromList(bytes.skip(1).toList());
      
      if (marker == 0) {
        // Data is compressed
        return decompressString(dataBytes);
      } else if (marker == 1) {
        // Data is uncompressed
        return utf8.decode(dataBytes);
      } else {
        // Legacy format without marker - assume uncompressed
        return utf8.decode(bytes);
      }
    }
    
    return utf8.decode(bytes);
    
  } catch (e) {
    throw DecodingException('Failed to decode message: $e');
  }
}

/// Decodes all hidden messages from encoded text.
/// 
/// Scans through the entire text and extracts all sequences of variation
/// selectors, treating each sequence as a separate encoded message.
/// 
/// Returns a list of [DecodedMessage] objects containing both the base
/// character and decoded message for each found sequence.
/// 
/// Example:
/// ```dart
/// final text = encode('😊', 'hello') + encode('🌟', 'world');
/// final messages = decodeAll(text);
/// // Returns [DecodedMessage('😊', 'hello'), DecodedMessage('🌟', 'world')].
/// ```
List<DecodedMessage> decodeAll(String encodedText) {
  if (encodedText.isEmpty) {
    return [];
  }
  
  final messages = <DecodedMessage>[];
  final textRunes = encodedText.runes.toList();
  
  String? currentBaseCharacter;
  final currentBytes = <int>[];
  
  for (int i = 0; i < textRunes.length; i++) {
    final rune = textRunes[i];
    final byte = variationSelectorToByte(rune);
    
    if (byte != null) {
      // This is a variation selector.
      currentBytes.add(byte);
    } else {
      // This is not a variation selector.
      if (currentBytes.isNotEmpty && currentBaseCharacter != null) {
        // We have accumulated bytes, decode them.
        try {
          String message;
          if (currentBytes.isNotEmpty) {
            final marker = currentBytes[0];
            final dataBytes = Uint8List.fromList(currentBytes.skip(1).toList());
            
            if (marker == 0) {
              // Data is compressed
              message = decompressString(dataBytes);
            } else if (marker == 1) {
              // Data is uncompressed
              message = utf8.decode(dataBytes);
            } else {
              // Legacy format without marker - assume uncompressed
              message = utf8.decode(currentBytes);
            }
          } else {
            message = '';
          }
          messages.add(DecodedMessage(currentBaseCharacter, message));
        } catch (e) {
          // Skip invalid sequences.
        }
        currentBytes.clear();
      }
      
      // This character could be the start of a new encoded sequence.
      currentBaseCharacter = String.fromCharCode(rune);
    }
  }
  
  // Handle any remaining bytes at the end.
  if (currentBytes.isNotEmpty && currentBaseCharacter != null) {
    try {
      String message;
      if (currentBytes.isNotEmpty) {
        final marker = currentBytes[0];
        final dataBytes = Uint8List.fromList(currentBytes.skip(1).toList());
        
        if (marker == 0) {
          // Data is compressed
          message = decompressString(dataBytes);
        } else if (marker == 1) {
          // Data is uncompressed
          message = utf8.decode(dataBytes);
        } else {
          // Legacy format without marker - assume uncompressed
          message = utf8.decode(currentBytes);
        }
      } else {
        message = '';
      }
      messages.add(DecodedMessage(currentBaseCharacter, message));
    } catch (e) {
      // Skip invalid sequences.
    }
  }
  
  return messages;
}

/// Extracts just the base characters from encoded text.
/// 
/// Returns the text with all variation selectors removed, showing only the
/// visible characters that would be seen by a user.
/// 
/// Example:
/// ```dart
/// final encoded = encode('😊', 'hello') + encode('🌟', 'world');
/// final visible = getVisibleText(encoded); // Returns '😊🌟'.
/// ```
String getVisibleText(String encodedText) {
  final buffer = StringBuffer();
  
  for (final rune in encodedText.runes) {
    if (!isVariationSelector(rune)) {
      buffer.writeCharCode(rune);
    }
  }
  
  return buffer.toString();
}

/// Checks if text contains any encoded data.
/// 
/// Returns true if the text contains variation selectors that could
/// represent hidden messages.
bool containsEncodedData(String text) {
  for (final rune in text.runes) {
    if (isVariationSelector(rune)) {
      return true;
    }
  }
  return false;
}

/// Gets statistics about encoded text.
/// 
/// Returns a map containing:
/// - 'totalLength': Total character count including variation selectors.
/// - 'visibleLength': Count of visible (non-variation selector) characters.
/// - 'hiddenBytes': Count of variation selectors (hidden bytes).
/// - 'messageCount': Number of decoded messages found.
Map<String, int> getEncodedTextStats(String encodedText) {
  int totalLength = 0;
  int visibleLength = 0;
  int hiddenBytes = 0;
  
  for (final rune in encodedText.runes) {
    totalLength++;
    if (isVariationSelector(rune)) {
      hiddenBytes++;
    } else {
      visibleLength++;
    }
  }
  
  final messageCount = decodeAll(encodedText).length;
  
  return {
    'totalLength': totalLength,
    'visibleLength': visibleLength, 
    'hiddenBytes': hiddenBytes,
    'messageCount': messageCount,
  };
}
