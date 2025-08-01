/// Copy/paste safe encoding using Zero Width Joiner sequences.
/// 
/// This alternative encoding method uses ZWJ (U+200D) combined with invisible
/// Unicode characters to create sequences that are more likely to survive
/// copy/paste operations across different applications.
library zwj_encoder;

import 'dart:convert';

/// Zero Width Joiner character - used to create stable invisible sequences
const int _zwj = 0x200D;

/// Zero Width Non-Joiner - alternative invisible character
const int _zwnj = 0x200C; 

/// Invisible Separator - another stable invisible character  
const int _invisibleSeparator = 0x2063;

/// Word Joiner - non-breaking invisible character  
const int _wordJoiner = 0x2060;

/// Function Application - used as end marker
const int _functionApplication = 0x2061;

/// Exception thrown when ZWJ encoding fails.
class ZWJEncodingException implements Exception {
  final String message;
  const ZWJEncodingException(this.message);
  
  @override
  String toString() => 'ZWJEncodingException: $message';
}

/// Encodes a message using ZWJ sequences that survive copy/paste.
/// 
/// Uses ZWJ combined with invisible Unicode characters to encode each byte.
/// This method uses a simpler binary encoding that's more reliable.
String encodeWithZWJ(String baseCharacter, String message) {
  if (baseCharacter.isEmpty) {
    throw ArgumentError('Base character cannot be empty');
  }
  
  if (message.isEmpty) {
    throw ArgumentError('Message cannot be empty');
  }
  
  // Ensure base character is a single Unicode character
  final baseRunes = baseCharacter.runes.toList();
  if (baseRunes.length != 1) {
    throw ArgumentError('Base character must be exactly one Unicode character');
  }
  
  try {
    // Convert message to UTF-8 bytes
    final messageBytes = utf8.encode(message);
    
    // Start with the base character
    final buffer = StringBuffer(baseCharacter);
    
    // Add start marker: ZWJ + invisible separator
    buffer.writeCharCode(_zwj);
    buffer.writeCharCode(_invisibleSeparator);
    
    // Encode each byte as 8 bits using ZWJ + two different invisible chars
    for (final byte in messageBytes) {
      for (int bit = 7; bit >= 0; bit--) {
        buffer.writeCharCode(_zwj);
        if ((byte >> bit) & 1 == 1) {
          buffer.writeCharCode(_zwnj); // 1 bit
        } else {
          buffer.writeCharCode(_wordJoiner); // 0 bit
        }
      }
    }
    
    // Add end marker: ZWJ + function application
    buffer.writeCharCode(_zwj);
    buffer.writeCharCode(_functionApplication);
    
    return buffer.toString();
    
  } catch (e) {
    throw ZWJEncodingException('Failed to encode message: $e');
  }
}

/// Decodes a ZWJ-encoded message.
String decodeZWJ(String encodedText) {
  try {
    final runes = encodedText.runes.toList();
    final bytes = <int>[];
    
    // Find the start marker
    int startIndex = -1;
    for (int i = 0; i < runes.length - 1; i++) {
      if (runes[i] == _zwj && runes[i + 1] == _invisibleSeparator) {
        startIndex = i + 2; // Start after the marker
        break;
      }
    }
    
    if (startIndex == -1) {
      return ''; // No ZWJ-encoded data found
    }
    
    // Find the end marker  
    int endIndex = -1;
    for (int i = startIndex; i < runes.length - 1; i++) {
      if (runes[i] == _zwj && runes[i + 1] == _functionApplication) {
        endIndex = i;
        break;
      }
    }
    
    if (endIndex == -1) {
      return ''; // No proper end marker found
    }
    
    // Decode bits between markers
    final bits = <int>[];
    for (int i = startIndex; i < endIndex; i += 2) {
      if (i + 1 < endIndex && runes[i] == _zwj) {
        if (runes[i + 1] == _zwnj) {
          bits.add(1); // 1 bit
        } else if (runes[i + 1] == _wordJoiner) {
          bits.add(0); // 0 bit
        }
      }
    }
    
    // Convert bits to bytes (8 bits per byte)
    for (int i = 0; i < bits.length; i += 8) {
      if (i + 7 < bits.length) {
        int byte = 0;
        for (int j = 0; j < 8; j++) {
          byte = (byte << 1) | bits[i + j];
        }
        bytes.add(byte);
      }
    }
    
    return utf8.decode(bytes);
    
  } catch (e) {
    return '';
  }
}


/// Checks if text contains ZWJ-encoded data.
bool hasZWJEncodedData(String text) {
  final runes = text.runes.toList();
  
  for (int i = 0; i < runes.length - 1; i++) {
    if (runes[i] == _zwj && runes[i + 1] == _invisibleSeparator) {
      return true;
    }
  }
  
  return false;
}

/// Gets just the visible characters from ZWJ-encoded text.
String getZWJVisibleText(String encodedText) {
  final buffer = StringBuffer();
  final runes = encodedText.runes.toList();
  bool inSequence = false;
  
  for (int i = 0; i < runes.length; i++) {
    final rune = runes[i];
    
    // Check for sequence start
    if (rune == _zwj && i + 1 < runes.length && runes[i + 1] == _invisibleSeparator) {
      inSequence = true;
      i++; // Skip invisible separator
      continue;
    }
    
    // Check for sequence end
    if (rune == _zwj && i + 1 < runes.length && runes[i + 1] == _wordJoiner) {
      inSequence = false;
      i++; // Skip word joiner
      continue;
    }
    
    // Only add visible characters (not in sequence)
    if (!inSequence && !_isInvisibleCharacter(rune)) {
      buffer.writeCharCode(rune);
    }
  }
  
  return buffer.toString();
}

/// Checks if a character is one of our invisible encoding characters.
bool _isInvisibleCharacter(int rune) {
  return rune == _zwj || 
         rune == _zwnj || 
         rune == _invisibleSeparator || 
         rune == _wordJoiner ||
         rune == _functionApplication ||
         (rune >= 0x2060 && rune <= 0x2069); // Various invisible characters
}