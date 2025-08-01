import 'package:test/test.dart';
import '../lib/emoji_cli.dart';
import 'package:emoji_transcoder/emoji_transcoder.dart';

void main() {
  group('ClipboardTranscoder', () {
    late ClipboardTranscoder transcoder;
    
    setUp(() {
      transcoder = ClipboardTranscoder();
    });
    
    test('hasHiddenData returns correct result', () {
      const plainText = 'Hello World';
      const encodedText = '😊\uFE00\uFE01\uFE02\uFE03\uFE04\uFE01\uFE02\uFE00\uFE03\uFE03\uFE04\uFE04';
      
      expect(transcoder.hasHiddenData(plainText), isFalse);
      expect(transcoder.hasHiddenData(encodedText), isTrue);
    });
    
    test('getVisibleText extracts visible characters', () {
      const encodedText = '😊\uFE00\uFE01\uFE02\uFE03\uFE04\uFE01\uFE02\uFE00\uFE03\uFE03\uFE04\uFE04';
      const expected = '😊';
      
      expect(transcoder.getVisibleText(encodedText), equals(expected));
    });
    
    test('encoding and decoding work correctly', () {
      const baseChar = '😊';
      const message = 'Hello, World!';
      
      final encoded = EmojiTranscoder.encode(baseChar, message);
      final decoded = EmojiTranscoder.decode(encoded);
      
      expect(decoded, equals(message));
      expect(EmojiTranscoder.getVisibleText(encoded), equals(baseChar));
      expect(EmojiTranscoder.hasHiddenData(encoded), isTrue);
    });
    
    test('multiple message encoding works', () {
      final messages = {
        '😊': 'hello',
        '🌟': 'world',
        '🔐': 'secret',
      };
      
      final encoded = EmojiTranscoder.encodeMultiple(messages);
      final decoded = EmojiTranscoder.decodeAll(encoded);
      
      expect(decoded.length, equals(3));
      expect(decoded[0].baseCharacter, equals('😊'));
      expect(decoded[0].message, equals('hello'));
      expect(decoded[1].baseCharacter, equals('🌟'));
      expect(decoded[1].message, equals('world'));
      expect(decoded[2].baseCharacter, equals('🔐'));
      expect(decoded[2].message, equals('secret'));
    });
    
    test('stats calculation works correctly', () {
      const baseChar = '😊';
      const message = 'Hello';
      
      final encoded = EmojiTranscoder.encode(baseChar, message);
      final stats = EmojiTranscoder.getStats(encoded);
      
      expect(stats['visibleLength'], equals(1)); // 😊 counts as 1 visible character
      expect(stats['messageCount'], equals(1));
      expect(stats['hiddenBytes'], greaterThan(0));
      expect(stats['totalLength'], greaterThan(stats['visibleLength']!));
    });
  });
}