import 'package:test/test.dart';
import 'package:emoji_transcoder/emoji_transcoder.dart';

void main() {
  group('Clipboard Operations', () {
    test('encode and write to clipboard, then read and decode', () async {
      const testMessage = 'Test clipboard message';
      const testEmoji = '🧪';
      
      // Write encoded message to clipboard
      await encodeAndWriteToClipboard(testEmoji, testMessage);
      
      // Read and verify the message
      final decodedMessage = await readAndDecodeFromClipboard();
      expect(decodedMessage, equals(testMessage));
    });
    
    test('encode multiple messages to clipboard and read all', () async {
      final testMessages = {
        '🌟': 'Star message',
        '🚀': 'Rocket message',
        '🎯': 'Target message',
      };
      
      // Write multiple messages to clipboard
      await encodeMultipleAndWriteToClipboard(testMessages);
      
      // Read all messages back
      final decodedMessages = await readAndDecodeAllFromClipboard();
      
      expect(decodedMessages.length, equals(3));
      
      // Check each message
      final messageMap = <String, String>{};
      for (final msg in decodedMessages) {
        messageMap[msg.baseCharacter] = msg.message;
      }
      
      expect(messageMap['🌟'], equals('Star message'));
      expect(messageMap['🚀'], equals('Rocket message'));
      expect(messageMap['🎯'], equals('Target message'));
    });
    
    test('safe encoding to clipboard preserves data', () async {
      const testMessage = 'Safe clipboard test';
      const testEmoji = '🔒';
      
      // Write safe-encoded message to clipboard
      await encodeSafeAndWriteToClipboard(testEmoji, testMessage);
      
      // Read using safe decoding
      final safeDecoded = await readAndDecodeSafeFromClipboard();
      expect(safeDecoded, equals(testMessage));
      
      // Verify it's detected as safe-encoded
      final hasSafeData = await clipboardHasSafeHiddenData();
      expect(hasSafeData, isTrue);
    });
    
    test('clipboard detection functions work correctly', () async {
      // Test with plain text
      await setRawClipboardText('Plain text without encoding');
      
      final hasHidden1 = await clipboardHasHiddenData();
      final hasSafeHidden1 = await clipboardHasSafeHiddenData();
      expect(hasHidden1, isFalse);
      expect(hasSafeHidden1, isFalse);
      
      // Test with encoded text
      await encodeAndWriteToClipboard('📊', 'Hidden data');
      
      final hasHidden2 = await clipboardHasHiddenData();
      expect(hasHidden2, isTrue);
      
      // Test with safe-encoded text
      await encodeSafeAndWriteToClipboard('🔐', 'Safe hidden data');
      
      final hasSafeHidden2 = await clipboardHasSafeHiddenData();
      expect(hasSafeHidden2, isTrue);
    });
    
    test('clipboard statistics are accurate', () async {
      final testMessages = {
        '😊': 'Hello',
        '🌟': 'World',
      };
      
      await encodeMultipleAndWriteToClipboard(testMessages);
      
      final stats = await getClipboardStats();
      
      expect(stats['messageCount'], equals(2));
      expect(stats['visibleLength'], equals(2)); // Two emojis visible
      expect(stats['hiddenBytes'], greaterThan(0)); // Should have hidden data
      expect(stats['totalLength'], greaterThan(stats['visibleLength']!));
    });
    
    test('raw clipboard operations work correctly', () async {
      const testText = 'Raw clipboard test 🌈';
      
      await setRawClipboardText(testText);
      final retrieved = await getRawClipboardText();
      
      expect(retrieved, equals(testText));
    });
    
    test('empty clipboard handling', () async {
      // Set empty clipboard
      await setRawClipboardText('');
      
      final decodedEmpty = await readAndDecodeFromClipboard();
      expect(decodedEmpty, equals(''));
      
      final allEmpty = await readAndDecodeAllFromClipboard();
      expect(allEmpty, isEmpty);
      
      final safeEmpty = await readAndDecodeSafeFromClipboard();
      expect(safeEmpty, equals(''));
    });
    
    test('EmojiTranscoder class clipboard methods work', () async {
      const testMessage = 'EmojiTranscoder test';
      const testEmoji = '🏷️';
      
      // Test EmojiTranscoder convenience methods
      await EmojiTranscoder.writeToClipboard(testEmoji, testMessage);
      final decoded = await EmojiTranscoder.readFromClipboard();
      expect(decoded, equals(testMessage));
      
      // Test multiple messages
      final multiMessages = {'🔥': 'Fire', '💧': 'Water'};
      await EmojiTranscoder.writeMultipleToClipboard(multiMessages);
      final allDecoded = await EmojiTranscoder.readAllFromClipboard();
      expect(allDecoded.length, equals(2));
      
      // Test safe methods
      await EmojiTranscoder.writeSafeToClipboard('🛡️', 'Shield message');
      final safeDecoded = await EmojiTranscoder.readSafeFromClipboard();
      expect(safeDecoded, equals('Shield message'));
    });
    
    test('error handling for clipboard exceptions', () async {
      // These tests depend on the specific clipboard implementation
      // and may need to be adjusted based on the actual clipboard library behavior
      
      // Test that methods handle clipboard access gracefully
      expect(() async => await getRawClipboardText(), returnsNormally);
      expect(() async => await setRawClipboardText('test'), returnsNormally);
    });
    
    test('unicode support in clipboard operations', () async {
      const unicodeMessage = 'Unicode test: Héllo 世界! 🚀✨ émojis';
      const unicodeEmoji = '🌍';
      
      await encodeAndWriteToClipboard(unicodeEmoji, unicodeMessage);
      final decoded = await readAndDecodeFromClipboard();
      
      expect(decoded, equals(unicodeMessage));
    });
    
    test('large message handling in clipboard', () async {
      // Test with a reasonably large message
      final largeMessage = 'A' * 1000 + ' Unicode: 世界 🌟 ' + 'B' * 1000;
      const emoji = '📦';
      
      await encodeAndWriteToClipboard(emoji, largeMessage);
      final decoded = await readAndDecodeFromClipboard();
      
      expect(decoded, equals(largeMessage));
    });
  });
}