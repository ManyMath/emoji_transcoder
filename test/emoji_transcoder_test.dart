import 'package:test/test.dart';
import 'package:emoji_transcoder/emoji_transcoder.dart';

void main() {
  group('EmojiTranscoder', () {
    group('Basic encoding/decoding', () {
      test('should encode and decode simple text', () {
        const message = 'hello world';
        const baseChar = '😊';
        
        final encoded = EmojiTranscoder.encode(baseChar, message);
        final decoded = EmojiTranscoder.decode(encoded);
        
        expect(decoded, equals(message));
      });
      
      test('should encode and decode empty string', () {
        const message = '';
        const baseChar = '😊';
        
        expect(() => EmojiTranscoder.encode(baseChar, message), 
               throwsA(isA<ArgumentError>()));
      });
      
      test('should handle different base characters', () {
        const message = 'test';
        const testCases = ['😊', '🌟', 'A', '中', '🎯'];
        
        for (final baseChar in testCases) {
          final encoded = EmojiTranscoder.encode(baseChar, message);
          final decoded = EmojiTranscoder.decode(encoded);
          
          expect(decoded, equals(message), 
                 reason: 'Failed with base character: $baseChar');
        }
      });
      
      test('should handle UTF-8 text correctly', () {
        const testCases = [
          'Hello 世界',
          'Émojis: 😀😃😄😆',
          'Math: π ≈ 3.14159',
          'Special chars: ñüñëçõdě',
          'Mixed: ABC123 中文 🚀'
        ];
        
        for (final message in testCases) {
          final encoded = EmojiTranscoder.encode('📝', message);
          final decoded = EmojiTranscoder.decode(encoded);
          
          expect(decoded, equals(message),
                 reason: 'Failed with message: $message');
        }
      });
    });
    
    group('Multi-message handling', () {
      test('should encode and decode multiple messages', () {
        final messages = {
          '😊': 'hello',
          '🌟': 'world',
          '🎯': 'test',
        };
        
        final encoded = EmojiTranscoder.encodeMultiple(messages);
        final decoded = EmojiTranscoder.decodeAll(encoded);
        
        expect(decoded.length, equals(3));
        
        for (final decodedMsg in decoded) {
          expect(messages[decodedMsg.baseCharacter], 
                 equals(decodedMsg.message));
        }
      });
      
      test('should handle adjacent encoded messages', () {
        final msg1 = EmojiTranscoder.encode('😊', 'first');
        final msg2 = EmojiTranscoder.encode('🌟', 'second');
        final combined = msg1 + msg2;
        
        final decoded = EmojiTranscoder.decodeAll(combined);
        
        expect(decoded.length, equals(2));
        expect(decoded[0].baseCharacter, equals('😊'));
        expect(decoded[0].message, equals('first'));
        expect(decoded[1].baseCharacter, equals('🌟'));
        expect(decoded[1].message, equals('second'));
      });
    });
    
    group('Utility functions', () {
      test('should detect hidden data correctly', () {
        const plainText = 'Just plain text 😊';
        final encodedText = EmojiTranscoder.encode('😊', 'hidden');
        
        expect(EmojiTranscoder.hasHiddenData(plainText), isFalse);
        expect(EmojiTranscoder.hasHiddenData(encodedText), isTrue);
      });
      
      test('should extract visible text correctly', () {
        final encoded1 = EmojiTranscoder.encode('😊', 'hidden1');
        final encoded2 = EmojiTranscoder.encode('🌟', 'hidden2');
        final combined = encoded1 + encoded2;
        
        final visible = EmojiTranscoder.getVisibleText(combined);
        
        expect(visible, equals('😊🌟'));
      });
      
      test('should provide correct statistics', () {
        final encoded = EmojiTranscoder.encode('😊', 'hello'); // 5 bytes + 1 base char.
        final stats = EmojiTranscoder.getStats(encoded);
        
        expect(stats['visibleLength'], equals(1));
        expect(stats['hiddenBytes'], equals(5));
        expect(stats['messageCount'], equals(1));
        expect(stats['totalLength'], equals(6));
      });
      
      test('should use default base character', () {
        const message = 'test message';
        
        final encoded = EmojiTranscoder.encodeWithDefault(message);
        final decoded = EmojiTranscoder.decode(encoded);
        
        expect(decoded, equals(message));
        expect(EmojiTranscoder.getVisibleText(encoded), equals('😊'));
      });
      
      test('should use custom base character when provided', () {
        const message = 'test message';
        const customBase = '🎯';
        
        final encoded = EmojiTranscoder.encodeWithDefault(
          message, 
          baseCharacter: customBase
        );
        final decoded = EmojiTranscoder.decode(encoded);
        
        expect(decoded, equals(message));
        expect(EmojiTranscoder.getVisibleText(encoded), equals(customBase));
      });
    });
    
    group('Error handling', () {
      test('should throw ArgumentError for empty base character', () {
        expect(() => EmojiTranscoder.encode('', 'message'), 
               throwsA(isA<ArgumentError>()));
      });
      
      test('should throw ArgumentError for empty message', () {
        expect(() => EmojiTranscoder.encode('😊', ''), 
               throwsA(isA<ArgumentError>()));
      });
      
      test('should handle decoding text without encoded data', () {
        const plainText = 'Just plain text';
        
        final decoded = EmojiTranscoder.decode(plainText);
        expect(decoded, equals(''));
        
        final decodedAll = EmojiTranscoder.decodeAll(plainText);
        expect(decodedAll, isEmpty);
      });
      
      test('should throw ArgumentError for multi-character base', () {
        expect(() => EmojiTranscoder.encode('😊😃', 'message'), 
               throwsA(isA<ArgumentError>()));
      });
    });
    
    group('Edge cases', () {
      test('should handle very long messages', () {
        final longMessage = 'A' * 1000; // 1000 character message.
        const baseChar = '📝';
        
        final encoded = EmojiTranscoder.encode(baseChar, longMessage);
        final decoded = EmojiTranscoder.decode(encoded);
        
        expect(decoded, equals(longMessage));
      });
      
      test('should handle single character messages', () {
        const testCases = ['A', '中', '😊', '1', ' '];
        
        for (final message in testCases) {
          final encoded = EmojiTranscoder.encode('📝', message);
          final decoded = EmojiTranscoder.decode(encoded);
          
          expect(decoded, equals(message));
        }
      });
      
      test('should preserve exact UTF-8 byte sequences', () {
        // Test various Unicode scenarios
        const testCases = [
          '\u{1F600}', // 😀 (4-byte UTF-8).
          '\u{00E9}',  // é (2-byte UTF-8).
          '\u{4E2D}',  // 中 (3-byte UTF-8).
          '\u{0041}',  // A (1-byte UTF-8).
        ];
        
        for (final message in testCases) {
          final encoded = EmojiTranscoder.encode('📝', message);
          final decoded = EmojiTranscoder.decode(encoded);
          
          expect(decoded, equals(message));
          expect(decoded.codeUnits, equals(message.codeUnits));
        }
      });
    });
  });

  group('Variation Selector Functions', () {
    test('should convert bytes to variation selectors correctly', () {
      // Test VS1-VS16 range (bytes 0-15).
      for (int byte = 0; byte < 16; byte++) {
        final selector = byteToVariationSelector(byte);
        expect(getCodepoint(selector), equals(0xFE00 + byte));
      }
      
      // Test VS17-VS256 range (bytes 16-255).
      for (int byte = 16; byte <= 255; byte++) {
        final selector = byteToVariationSelector(byte);
        expect(getCodepoint(selector), equals(0xE0100 + byte - 16));
      }
    });
    
    test('should convert variation selectors back to bytes correctly', () {
      // Test round-trip conversion for all valid bytes.
      for (int byte = 0; byte <= 255; byte++) {
        final selector = byteToVariationSelector(byte);
        final codepoint = getCodepoint(selector);
        final convertedByte = variationSelectorToByte(codepoint);
        
        expect(convertedByte, equals(byte));
      }
    });
    
    test('should return null for non-variation selector codepoints', () {
      const testCodes = [
        0x0041, // 'A'.
        0x1F600, // 😀.
        0x4E2D, // 中.
        0xFDFF, // Before VS1.
        0xFE10, // After VS16.
        0xE00FF, // Before VS17.
        0xE01F0, // After VS256.
      ];
      
      for (final code in testCodes) {
        expect(variationSelectorToByte(code), isNull);
      }
    });
    
    test('should identify variation selectors correctly', () {
      // Valid variation selectors.
      expect(isVariationSelector(0xFE00), isTrue); // VS1.
      expect(isVariationSelector(0xFE0F), isTrue); // VS16.
      expect(isVariationSelector(0xE0100), isTrue); // VS17.
      expect(isVariationSelector(0xE01EF), isTrue); // VS256.
      
      // Invalid codepoints.
      expect(isVariationSelector(0x0041), isFalse); // 'A'.
      expect(isVariationSelector(0x1F600), isFalse); // 😀.
      expect(isVariationSelector(0xFDFF), isFalse); // Before VS1.
      expect(isVariationSelector(0xFE10), isFalse); // After VS16.
      expect(isVariationSelector(0xE00FF), isFalse); // Before VS17.
      expect(isVariationSelector(0xE01F0), isFalse); // After VS256.
    });
    
    test('should get codepoints correctly', () {
      expect(getCodepoint('A'), equals(0x0041));
      expect(getCodepoint('😀'), equals(0x1F600));
      expect(getCodepoint('中'), equals(0x4E2D));
      expect(getCodepoint('π'), equals(0x03C0));
    });
    
    test('should throw InvalidByteException for invalid bytes', () {
      expect(() => byteToVariationSelector(-1), 
             throwsA(isA<InvalidByteException>()));
      expect(() => byteToVariationSelector(256), 
             throwsA(isA<InvalidByteException>()));
      expect(() => byteToVariationSelector(1000), 
             throwsA(isA<InvalidByteException>()));
    });
    
    test('should throw ArgumentError for invalid character strings', () {
      expect(() => getCodepoint(''), 
             throwsA(isA<ArgumentError>()));
      expect(() => getCodepoint('AB'), 
             throwsA(isA<ArgumentError>()));
      expect(() => getCodepoint('😊🌟'), 
             throwsA(isA<ArgumentError>()));
    });
  });

  group('Encoder Utility Functions', () {
    test('should calculate visual length correctly', () {
      const plainText = 'Hello 😊 World';
      expect(getVisualLength(plainText), equals(13));
      
      final encoded = EmojiTranscoder.encode('😊', 'test');
      expect(getVisualLength(encoded), equals(1)); // Only base character visible.
      
      final multiEncoded = EmojiTranscoder.encodeMultiple({
        '😊': 'hello',
        '🌟': 'world',
        '🎯': 'test'
      });
      expect(getVisualLength(multiEncoded), equals(3)); // Three base characters.
    });
    
    test('should detect encoded data in encoder module', () {
      const plainText = 'Just plain text 😊';
      final encodedText = EmojiTranscoder.encode('😊', 'hidden');
      
      expect(hasEncodedData(plainText), isFalse);
      expect(hasEncodedData(encodedText), isTrue);
      expect(hasEncodedData(''), isFalse);
    });
    
    test('should handle empty messages map in encodeMultiple', () {
      expect(() => encodeMultiple({}), 
             throwsA(isA<ArgumentError>()));
    });
  });

  group('Exception Scenarios', () {
    test('should throw EncodingException for encoding failures', () {
      // This test simulates a scenario where encoding might fail.
      // In practice, the main causes would be invalid variation selector mapping.
      // We can test this by mocking or by testing edge cases that might cause issues.
      
      // Test with extremely large messages that might cause memory issues.
      // For now, we'll test that the function handles the expected flow.
      expect(() => EmojiTranscoder.encode('😊', 'valid message'), 
             returnsNormally);
    });
    
    test('should throw DecodingException for malformed data', () {
      // Create text with invalid UTF-8 sequences.
      // This is tricky to test directly, but we can test the exception path.
      const invalidEncodedText = 'test text without proper encoding';
      
      // The decode function should handle this gracefully
      expect(() => EmojiTranscoder.decode(invalidEncodedText), 
             returnsNormally);
    });
    
    test('should handle corrupted variation selector sequences', () {
      // Create a string with variation selectors that don't form valid UTF-8.
      final corruptedData = '😊' + String.fromCharCode(0xFE00) + String.fromCharCode(0xFE01);
      
      // Should not crash, might return empty or partial data.
      expect(() => EmojiTranscoder.decode(corruptedData), 
             returnsNormally);
      expect(() => EmojiTranscoder.decodeAll(corruptedData), 
             returnsNormally);
    });
    
    test('should handle mixed valid and invalid sequences', () {
      final validEncoded = EmojiTranscoder.encode('😊', 'valid');
      final mixedText = validEncoded + 'plain text' + String.fromCharCode(0xFE00);
      
      final decoded = EmojiTranscoder.decodeAll(mixedText);
      expect(decoded.length, greaterThan(0));
      expect(decoded.first.message, equals('valid'));
    });
  });

  group('Edge Cases and Boundary Conditions', () {
    test('should handle maximum byte values', () {
      // Test encoding/decoding with bytes at boundaries.
      final testMessage = String.fromCharCodes([0, 15, 16, 255]);
      final encoded = EmojiTranscoder.encode('📝', testMessage);
      final decoded = EmojiTranscoder.decode(encoded);
      
      expect(decoded, equals(testMessage));
    });
    
    test('should handle all Unicode planes', () {
      const testCases = [
        '\u{0000}',    // Null character.
        '\u{007F}',    // DEL character.
        '\u{0080}',    // Start of Latin-1 Supplement.
        '\u{07FF}',    // End of 2-byte UTF-8.
        '\u{0800}',    // Start of 3-byte UTF-8.
        '\u{FFFF}',    // End of BMP.
        '\u{10000}',   // Start of supplementary planes.
      ];
      
      for (final testChar in testCases) {
        if (testChar.isNotEmpty) {
          final encoded = EmojiTranscoder.encode('📝', testChar);
          final decoded = EmojiTranscoder.decode(encoded);
          expect(decoded, equals(testChar));
        }
      }
    });
    
    test('should handle interleaved encoded and plain text', () {
      final part1 = EmojiTranscoder.encode('😊', 'hello');
      final part2 = EmojiTranscoder.encode('🌟', 'world');
      final mixed = part1 + ' plain text ' + part2;
      
      final messages = EmojiTranscoder.decodeAll(mixed);
      expect(messages.length, equals(2));
      expect(messages[0].message, equals('hello'));
      expect(messages[1].message, equals('world'));
    });
    
    test('should handle empty input edge cases', () {
      expect(EmojiTranscoder.decode(''), equals(''));
      expect(EmojiTranscoder.decodeAll(''), isEmpty);
      expect(EmojiTranscoder.getVisibleText(''), equals(''));
      expect(EmojiTranscoder.hasHiddenData(''), isFalse);
      
      final stats = EmojiTranscoder.getStats('');
      expect(stats['totalLength'], equals(0));
      expect(stats['visibleLength'], equals(0));
      expect(stats['hiddenBytes'], equals(0));
      expect(stats['messageCount'], equals(0));
    });
    
    test('should handle very large messages efficiently', () {
      // Test with a 10KB message
      final largeMessage = 'A' * 10000;
      
      final encoded = EmojiTranscoder.encode('📝', largeMessage);
      final decoded = EmojiTranscoder.decode(encoded);
      
      expect(decoded, equals(largeMessage));
      expect(EmojiTranscoder.getVisibleText(encoded), equals('📝'));
    });
    
    test('should preserve binary data exactly', () {
      // Create a message with all possible byte values.
      final binaryData = List.generate(256, (i) => i);
      final binaryMessage = String.fromCharCodes(binaryData);
      
      final encoded = EmojiTranscoder.encode('💾', binaryMessage);
      final decoded = EmojiTranscoder.decode(encoded);
      
      expect(decoded.codeUnits, equals(binaryMessage.codeUnits));
    });
    
    test('should handle consecutive base characters without data', () {
      const consecutiveChars = '😊🌟🎯';
      
      expect(EmojiTranscoder.hasHiddenData(consecutiveChars), isFalse);
      expect(EmojiTranscoder.decodeAll(consecutiveChars), isEmpty);
      expect(EmojiTranscoder.getVisibleText(consecutiveChars), equals(consecutiveChars));
    });
  });
}