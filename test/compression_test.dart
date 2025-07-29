import 'package:test/test.dart';
import 'package:emoji_transcoder/emoji_transcoder.dart';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  group('Compression Module', () {
    group('Basic compression functionality', () {
      test('should compress and decompress strings correctly', () {
        const testMessage = 'Hello, this is a test message that should compress well because it has repeated words and patterns.';
        
        final compressed = compressString(testMessage);
        final decompressed = decompressString(compressed);
        
        expect(decompressed, equals(testMessage));
      });
      
      test('should handle empty strings', () {
        const emptyMessage = '';
        
        final compressed = compressString(emptyMessage);
        final decompressed = decompressString(compressed);
        
        expect(compressed.isEmpty, isTrue);
        expect(decompressed, equals(emptyMessage));
      });
      
      test('should handle Unicode characters', () {
        const unicodeMessage = 'Hello 世界! Émojis: 😀😃😄 Math: π ≈ 3.14159';
        
        final compressed = compressString(unicodeMessage);
        final decompressed = decompressString(compressed);
        
        expect(decompressed, equals(unicodeMessage));
      });
      
      test('should compress large repeated content efficiently', () {
        final largeMessage = 'Hello World! ' * 100; // 1300 characters
        
        final compressed = compressString(largeMessage);
        final originalBytes = utf8.encode(largeMessage);
        
        expect(compressed.length, lessThan(originalBytes.length));
        
        final decompressed = decompressString(compressed);
        expect(decompressed, equals(largeMessage));
      });
    });
    
    group('Compression decision logic', () {
      test('should detect when compression is beneficial', () {
        const shortMessage = 'Hi';
        final longRepeatedMessage = 'This is a long message with repeated content. ' * 10;
        const randomMessage = 'abcdefghijklmnopqrstuvwxyz1234567890';
        
        expect(shouldCompress(shortMessage), isFalse);
        expect(shouldCompress(longRepeatedMessage), isTrue);
        expect(shouldCompress(randomMessage), isFalse);
        // Random data doesn't compress well.
      });
      
      test('should handle edge cases in compression decision', () {
        expect(shouldCompress(''), isFalse);
        expect(shouldCompress('a'), isFalse);
        expect(shouldCompress('ab'), isFalse);
        
        // Very short but repeated
        expect(shouldCompress('aa'), isFalse);
        expect(shouldCompress('aaa'), isFalse);
      });
    });
    
    group('Compression statistics', () {
      test('should provide accurate compression stats', () {
        final message = 'Hello World! ' * 20; // 260 characters.
        
        final stats = getCompressionStats(message);
        
        expect(stats['originalSize'], equals(utf8.encode(message).length));
        expect(stats['compressedSize'], greaterThan(0));
        expect(stats['compressionRatio'], greaterThan(0.0));
        expect(stats['compressionRatio'], lessThan(1.0));
        expect(stats['spaceSaved'], greaterThan(0));
        expect(stats['beneficial'], isTrue);
      });
      
      test('should handle empty string stats', () {
        final stats = getCompressionStats('');
        
        expect(stats['originalSize'], equals(0));
        expect(stats['compressedSize'], equals(0));
        expect(stats['compressionRatio'], equals(0.0));
        expect(stats['spaceSaved'], equals(0));
        expect(stats['beneficial'], isFalse);
      });
      
      test('should detect when compression is not beneficial', () {
        const randomString = 'abcdefghijklmnopqrstuvwxyz0123456789'; // Random data.
        
        final stats = getCompressionStats(randomString);
        
        expect(stats['originalSize'], greaterThan(0));
        expect(stats['beneficial'], isFalse);
      });
    });
    
    group('Error handling', () {
      test('should throw CompressionException for invalid data', () {
        // Create invalid compressed data
        final invalidData = Uint8List.fromList([1, 2, 3, 4, 5]);
        
        expect(() => decompressString(invalidData), 
               throwsA(isA<CompressionException>()));
      });
      
      test('should handle compression failures gracefully', () {
        // shouldCompress should return false on compression failure
        // This is hard to test directly, but we can verify the function doesn't crash.
        expect(() => shouldCompress('test'), returnsNormally);
      });
    });
  });
  
  group('Integration with Encoding/Decoding', () {
    group('Compression in encoding', () {
      test('should encode with compression when enabled', () {
        final message = 'This is a repeated message. ' * 10;
        const baseChar = '😊';
        
        final encodedUncompressed = EmojiTranscoder.encode(baseChar, message, compress: false);
        final encodedCompressed = EmojiTranscoder.encode(baseChar, message, compress: true);
        
        // Compressed version should be shorter (fewer variation selectors)
        expect(encodedCompressed.length, lessThan(encodedUncompressed.length));
        
        // Both should decode to the same message
        final decodedUncompressed = EmojiTranscoder.decode(encodedUncompressed);
        final decodedCompressed = EmojiTranscoder.decode(encodedCompressed);
        
        expect(decodedUncompressed, equals(message));
        expect(decodedCompressed, equals(message));
      });
      
      test('should not compress when not beneficial', () {
        const shortMessage = 'Hi';
        const baseChar = '😊';
        
        final encodedUncompressed = EmojiTranscoder.encode(baseChar, shortMessage, compress: false);
        final encodedCompressed = EmojiTranscoder.encode(baseChar, shortMessage, compress: true);
        
        // Should be similar length since compression wasn't beneficial
        // (both will have the marker byte, so lengths should be close).
        expect((encodedCompressed.length - encodedUncompressed.length).abs(), lessThan(3));
        
        final decoded = EmojiTranscoder.decode(encodedCompressed);
        expect(decoded, equals(shortMessage));
      });
      
      test('should handle UTF-8 edge cases with compression', () {
        final testCases = [
          'Émojis: 😀😃😄😆 ' * 5,
          'Math: π ≈ 3.14159 ∞ ∑ ∆ ' * 3,
          '中文测试 ' * 8,
          'Mixed: ABC123 中文 🚀 ' * 4,
        ];
        
        for (final message in testCases) {
          final encoded = EmojiTranscoder.encode('📝', message, compress: true);
          final decoded = EmojiTranscoder.decode(encoded);
          
          expect(decoded, equals(message), 
                 reason: 'Failed with message: $message');
        }
      });
    });
    
    group('Multiple message compression', () {
      test('should handle multiple compressed messages', () {
        final messages = {
          '😊': 'Hello world! ' * 10,
          '🌟': 'Goodbye world! ' * 10,
          '🎯': 'Test message ' * 8,
        };
        
        final encodedUncompressed = EmojiTranscoder.encodeMultiple(messages, compress: false);
        final encodedCompressed = EmojiTranscoder.encodeMultiple(messages, compress: true);
        
        expect(encodedCompressed.length, lessThan(encodedUncompressed.length));
        
        final decodedMessages = EmojiTranscoder.decodeAll(encodedCompressed);
        
        expect(decodedMessages.length, equals(3));
        for (final decodedMsg in decodedMessages) {
          expect(messages[decodedMsg.baseCharacter], equals(decodedMsg.message));
        }
      });
      
      test('should handle mixed compressible and non-compressible messages', () {
        final messages = {
          '😊': 'Short', // Won't compress.
          '🌟': 'This is a much longer message that will benefit from compression. ' * 5, // Will compress.
          '🎯': 'Also short', // Won't compress.
        };
        
        final encoded = EmojiTranscoder.encodeMultiple(messages, compress: true);
        final decoded = EmojiTranscoder.decodeAll(encoded);
        
        expect(decoded.length, equals(3));
        for (final decodedMsg in decoded) {
          expect(messages[decodedMsg.baseCharacter], equals(decodedMsg.message));
        }
      });
    });
    
    group('Default encoding with compression', () {
      test('should support compression with default base character', () {
        final message = 'Default encoding test message with compression. ' * 8;
        
        final encoded = EmojiTranscoder.encodeWithDefault(message, compress: true);
        final decoded = EmojiTranscoder.decode(encoded);
        
        expect(decoded, equals(message));
        expect(EmojiTranscoder.getVisibleText(encoded), equals('😊'));
      });
      
      test('should support compression with custom base character', () {
        final message = 'Custom base character test. ' * 6;
        const customBase = '🎯';
        
        final encoded = EmojiTranscoder.encodeWithDefault(
          message, 
          baseCharacter: customBase, 
          compress: true
        );
        final decoded = EmojiTranscoder.decode(encoded);
        
        expect(decoded, equals(message));
        expect(EmojiTranscoder.getVisibleText(encoded), equals(customBase));
      });
    });
    
    group('Backward compatibility', () {
      test('should decode legacy uncompressed data correctly', () {
        // Create data using the old format (without compression).
        const message = 'Legacy test message';
        const baseChar = '😊';
        
        final legacyEncoded = EmojiTranscoder.encode(baseChar, message, compress: false);
        final decoded = EmojiTranscoder.decode(legacyEncoded);
        
        expect(decoded, equals(message));
      });
      
      test('should handle mixed legacy and compressed data', () {
        const message1 = 'Legacy message';
        final message2 = 'Compressed message that is longer and benefits from compression. ' * 3;
        
        final legacyEncoded = EmojiTranscoder.encode('😊', message1, compress: false);
        final compressedEncoded = EmojiTranscoder.encode('🌟', message2, compress: true);
        final mixedText = legacyEncoded + compressedEncoded;
        
        final decoded = EmojiTranscoder.decodeAll(mixedText);
        
        expect(decoded.length, equals(2));
        expect(decoded[0].message, equals(message1));
        expect(decoded[1].message, equals(message2));
      });
    });
    
    group('Performance and edge cases', () {
      test('should handle very large messages with compression', () {
        final largeMessage = 'Large repeated content for testing compression performance. ' * 200; // ~11KB.
        
        final encoded = EmojiTranscoder.encode('📝', largeMessage, compress: true);
        final decoded = EmojiTranscoder.decode(encoded);
        
        expect(decoded, equals(largeMessage));
      });
      
      test('should handle binary-like data', () {
        // Create a message with all possible byte values.
        final binaryMessage = String.fromCharCodes(List.generate(256, (i) => i % 256));
        
        final encoded = EmojiTranscoder.encode('💾', binaryMessage, compress: true);
        final decoded = EmojiTranscoder.decode(encoded);
        
        expect(decoded.codeUnits, equals(binaryMessage.codeUnits));
      });
      
      test('should preserve exact byte sequences through compression', () {
        final testCases = [
          '\u{1F600}', // 😀 (4-byte UTF-8).
          '\u{00E9}',  // é (2-byte UTF-8).
          '\u{4E2D}',  // 中 (3-byte UTF-8).
          '\u{0041}',  // A (1-byte UTF-8).
        ];
        
        for (final message in testCases) {
          final encoded = EmojiTranscoder.encode('📝', message, compress: true);
          final decoded = EmojiTranscoder.decode(encoded);
          
          expect(decoded, equals(message));
          expect(decoded.codeUnits, equals(message.codeUnits));
        }
      });
    });
  });
}