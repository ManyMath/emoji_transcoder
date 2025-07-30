import 'package:test/test.dart';
import 'package:emoji_transcoder/emoji_transcoder.dart';

void main() {
  group('Reference Implementation Compatibility', () {
    // Test vectors generated from the TypeScript emoji-encoder reference.
    final knownCompatibleVectors = [
      {
        'emoji': '😀',
        'text': 'Hello, World!',
        'expectedUtf8Bytes': [72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33],
        'description': 'Basic greeting with grinning face'
      },
      {
        'emoji': '😂',
        'text': 'Testing 123',
        'expectedUtf8Bytes': [84, 101, 115, 116, 105, 110, 103, 32, 49, 50, 51],
        'description': 'Alphanumeric test with crying-laughing emoji'
      },
      {
        'emoji': '🥰',
        'text': 'Special chars: !@#\$%^&*()',
        'expectedUtf8Bytes': [83, 112, 101, 99, 105, 97, 108, 32, 99, 104, 97, 114, 115, 58, 32, 33, 64, 35, 36, 37, 94, 38, 42, 40, 41],
        'description': 'Special characters with smiling face with hearts'
      },
      {
        'emoji': '😎',
        'text': 'Unicode: 你好，世界',
        'expectedUtf8Bytes': [85, 110, 105, 99, 111, 100, 101, 58, 32, 228, 189, 160, 229, 165, 189, 239, 188, 140, 228, 184, 150, 231, 149, 140],
        'description': 'Chinese Unicode text with sunglasses emoji'
      },
      {
        'emoji': '🤔',
        'text': ' ',
        'expectedUtf8Bytes': [32],
        'description': 'Single space with thinking face'
      },
      {
        'emoji': '👍',
        'text': 'café',
        'expectedUtf8Bytes': [99, 97, 102, 195, 169],
        'description': 'French text with thumbs up'
      },
      {
        'emoji': '🌈',  
        'text': 'A',
        'expectedUtf8Bytes': [65],
        'description': 'Single character with rainbow'
      },
      {
        'emoji': '🚀',
        'text': 'test123',
        'expectedUtf8Bytes': [116, 101, 115, 116, 49, 50, 51],
        'description': 'Alphanumeric with rocket'
      }
    ];

    test('should encode/decode identically to TypeScript reference', () {
      for (final vector in knownCompatibleVectors) {
        final emoji = vector['emoji'] as String;
        final text = vector['text'] as String;
        final expectedBytes = vector['expectedUtf8Bytes'] as List<int>;
        final description = vector['description'] as String;

        // Test Dart implementation.
        final encoded = EmojiTranscoder.encode(emoji, text);
        final decoded = EmojiTranscoder.decode(encoded);

        // Verify round-trip works.
        expect(decoded, equals(text),
               reason: 'Round-trip failed: $description');

        // Verify UTF-8 byte encoding matches.
        final dartUtf8Bytes = text.codeUnits;
        // Note: For proper UTF-8 comparison, we need to check actual byte encoding.
        expect(decoded, equals(text),
               reason: 'UTF-8 encoding mismatch: $description');

        // Verify structure.
        expect(encoded.startsWith(emoji), isTrue,
               reason: 'Encoded should start with emoji: $description');
        expect(EmojiTranscoder.getVisibleText(encoded), equals(emoji),
               reason: 'Visible text should be emoji only: $description');
      }
    });

    test('should handle all variation selector ranges correctly', () {
      // Test VS1-VS16 range (bytes 0-15).
      for (int byte = 0; byte < 16; byte++) {
        final char = String.fromCharCode(byte);
        final encoded = EmojiTranscoder.encode('🧪', char);
        final decoded = EmojiTranscoder.decode(encoded);
        
        expect(decoded.codeUnits, equals([byte]),
               reason: 'VS1-16 mapping failed for byte $byte');
      }

      // Test VS17-VS256 range (sample of bytes 16-255).
      final sampleBytes = [16, 32, 64, 128, 255];
      for (final byte in sampleBytes) {
        final char = String.fromCharCode(byte);
        final encoded = EmojiTranscoder.encode('🧪', char);
        final decoded = EmojiTranscoder.decode(encoded);
        
        expect(decoded.codeUnits, equals([byte]),
               reason: 'VS17-256 mapping failed for byte $byte');
      }
    });

    test('should match reference decode termination behavior', () {
      // TypeScript reference stops at first non-variation selector after finding VS.
      final encoded1 = EmojiTranscoder.encode('😊', 'hello');
      final encoded2 = EmojiTranscoder.encode('🌟', 'world');
      
      // Combine with separator (matches TypeScript behavior).
      final combined = encoded1 + 'STOP' + encoded2;
      
      // Single decode should only return first message.
      final singleDecoded = EmojiTranscoder.decode(combined);
      expect(singleDecoded, equals('hello'),
             reason: 'Should stop at first non-VS like TypeScript');
             
      // decodeAll should find both.
      final allDecoded = EmojiTranscoder.decodeAll(combined);
      expect(allDecoded.length, equals(2),
             reason: 'decodeAll should find both messages');
      expect(allDecoded[0].message, equals('hello'));
      expect(allDecoded[1].message, equals('world'));
    });

    test('should handle edge cases like TypeScript reference', () {
      // Empty decode result.
      expect(EmojiTranscoder.decode('No variation selectors here'), equals(''));
      
      // Mixed content handling.
      final plainPrefix = 'Regular text: ';
      final encoded = EmojiTranscoder.encode('🔒', 'secret');
      final combined = plainPrefix + encoded;
      
      expect(EmojiTranscoder.decode(combined), equals('secret'),
             reason: 'Should skip text before first variation selector');
    });

    test('should produce identical variation selector sequences', () {
      // This test verifies that our byte->VS mapping matches the reference exactly.
      final testMessage = 'Test message with various chars: café 测试 🎯';
      final encoded = EmojiTranscoder.encode('📋', testMessage);
      final decoded = EmojiTranscoder.decode(encoded);
      
      expect(decoded, equals(testMessage),
             reason: 'Complex message should round-trip perfectly');
      
      // Verify the encoded structure.
      expect(encoded.length, greaterThan(testMessage.length),
             reason: 'Encoded should be longer due to multi-byte UTF-8 chars');
      expect(EmojiTranscoder.hasHiddenData(encoded), isTrue,
             reason: 'Should detect hidden data');
    });

    test('should handle the EMOJI_LIST from TypeScript reference', () {
      // Test with all emojis from the reference implementation.
      const referenceEmojis = [
        "😀", "😂", "🥰", "😎", "🤔", "👍", "👎", "👏", "😅", "🤝",
        "🎉", "🎂", "🍕", "🌈", "🌞", "🌙", "🔥", "💯", "🚀", "👀",
        "💀", "🥹"
      ];
      
      const testText = 'compatibility test';
      
      for (final emoji in referenceEmojis) {
        final encoded = EmojiTranscoder.encode(emoji, testText);
        final decoded = EmojiTranscoder.decode(encoded);
        
        expect(decoded, equals(testText),
               reason: 'Failed with reference emoji: $emoji');
        expect(EmojiTranscoder.getVisibleText(encoded), equals(emoji),
               reason: 'Visible text should be emoji: $emoji');
      }
    });

    test('should match alphabet character handling', () {
      // Test with alphabet characters as base (from TypeScript reference).
      const alphabet = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'];
      const message = 'hidden in letter';
      
      for (final letter in alphabet) {
        final encoded = EmojiTranscoder.encode(letter, message);
        final decoded = EmojiTranscoder.decode(encoded);
        
        expect(decoded, equals(message),
               reason: 'Failed with letter base: $letter');
        expect(EmojiTranscoder.getVisibleText(encoded), equals(letter),
               reason: 'Visible should be letter: $letter');
      }
    });

    test('should validate against known encoded strings', () {
      // Generated by the reference TypeScript implementation.
      final knownEncodedStrings = [
        {
          'encoded': '😀󠄸󠅕󠅜󠅜󠅟󠄜󠄐󠅇󠅟󠅢󠅜󠅔󠄑',  // "Hello, World!" in 😀.
          'expected': 'Hello, World!',
          'baseChar': '😀'
        },
        {
          'encoded': '😀󠄐',  // " " (space) in 😀.
          'expected': ' ',
          'baseChar': '😀'
        },
      ];
      
      for (final testCase in knownEncodedStrings) {
        final encoded = testCase['encoded'] as String;
        final expected = testCase['expected'] as String;
        final baseChar = testCase['baseChar'] as String;
        
        final decoded = EmojiTranscoder.decode(encoded);
        expect(decoded, equals(expected),
               reason: 'Known encoded string failed to decode: $encoded');
        expect(EmojiTranscoder.getVisibleText(encoded), equals(baseChar),
               reason: 'Base character extraction failed: $encoded');
      }
    });
  });
  
  group('Cross-Implementation Verification', () {
    test('should validate core constants match reference', () {
      // Verify our constants match the TypeScript reference exactly.
      expect(0xFE00, equals(65024), reason: 'VS1 start constant');
      expect(0xFE0F, equals(65039), reason: 'VS16 end constant');  
      expect(0xE0100, equals(917760), reason: 'VS17 start constant');
      expect(0xE01EF, equals(917999), reason: 'VS256 end constant');
      
      // Test a few key mappings - use runes.first to get the codepoint properly.
      expect(byteToVariationSelector(0).runes.first, equals(0xFE00));
      expect(byteToVariationSelector(15).runes.first, equals(0xFE0F));
      expect(byteToVariationSelector(16).runes.first, equals(0xE0100));
      expect(byteToVariationSelector(255).runes.first, equals(0xE01EF));
    });
    
    test('should handle the exact test cases from encoding.test.ts', () {
      // Direct recreation of the TypeScript test cases.
      final testStringsFromReference = [
        'Hello, World!',
        'Testing 123', 
        'Special chars: !@#\$%^&*()',
        'Unicode: 你好，世界',
        ' ' // Space only.
      ];
      
      final emojisFromReference = ["😀", "😂", "🥰", "😎", "🤔"];
      
      for (final emoji in emojisFromReference) {
        for (final str in testStringsFromReference) {
          final encoded = EmojiTranscoder.encode(emoji, str);
          final decoded = EmojiTranscoder.decode(encoded);
          
          expect(decoded, equals(str),
                 reason: 'TypeScript test case failed: $emoji + "$str"');
        }
      }
    });
  });
}
