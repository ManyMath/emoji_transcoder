import 'package:emoji_transcoder/emoji_transcoder.dart';

void main() {
  print('=== Emoji Transcoder Basic Usage ===\n');

  // Basic encoding and decoding.
  print('1. Basic Encoding/Decoding (Original Method):');
  const message = 'npub1say58k6hcfzpfu5f9ufz0qd7yx04ep93v74hjx8jecxe8x05gp8shghphd';
  const baseEmoji = '🐈';

  final encoded = EmojiTranscoder.encode(baseEmoji, message);
  print('Original message: "$message"');
  print('Encoded result: "$encoded"');
  print('Looks like just: "${EmojiTranscoder.getVisibleText(encoded)}"');

  final decoded = EmojiTranscoder.decode(encoded);
  print('Decoded message: "$decoded"');
  print('Messages match: ${message == decoded}');
  print('⚠️ Note: Copy/paste may lose hidden data with this method\n');

  // Copy/paste safe encoding.
  print('1b. Copy/Paste Safe Encoding:');
  final safeEncoded = EmojiTranscoder.encodeSafe(baseEmoji, message);
  print('Safe encoded result: "$safeEncoded"');
  print('Looks like just: "${EmojiTranscoder.getSafeVisibleText(safeEncoded)}"');

  final safeDecoded = EmojiTranscoder.decodeSafe(safeEncoded);
  print('Safe decoded message: "$safeDecoded"');
  print('Messages match: ${message == safeDecoded}');
  print('✅ This version preserves data during copy/paste\n');

  // Multi-message encoding.
  print('2. Multiple Messages:');
  final multipleMessages = {
    '😊': 'Hello',
    '🌟': 'World',
    '🎯': 'Secret',
  };

  final multiEncoded = EmojiTranscoder.encodeMultiple(multipleMessages);
  print('Multiple messages encoded: "$multiEncoded"');
  print('Visible text: "${EmojiTranscoder.getVisibleText(multiEncoded)}"');

  final allDecoded = EmojiTranscoder.decodeAll(multiEncoded);
  print('All decoded messages:');
  for (final msg in allDecoded) {
    print('  ${msg.baseCharacter}: "${msg.message}"');
  }
  print('');

  // Unicode and special characters.
  print('3. Unicode Support:');
  const unicodeMessage = 'Héllo 世界! 🚀✨';
  final unicodeEncoded = EmojiTranscoder.encode('📝', unicodeMessage);
  final unicodeDecoded = EmojiTranscoder.decode(unicodeEncoded);

  print('Unicode message: "$unicodeMessage"');
  print('Encoded: "$unicodeEncoded"');
  print('Decoded: "$unicodeDecoded"');
  print('Unicode preserved: ${unicodeMessage == unicodeDecoded}\n');

  // Statistics.
  print('4. Text Statistics:');
  final stats = EmojiTranscoder.getStats(multiEncoded);
  print('Statistics for multi-message text:');
  print('  Total length: ${stats['totalLength']} characters');
  print('  Visible length: ${stats['visibleLength']} characters');
  print('  Hidden bytes: ${stats['hiddenBytes']} bytes');
  print('  Message count: ${stats['messageCount']} messages\n');

  // Detection.
  print('5. Hidden Data Detection:');
  const plainText = 'This is just plain text 😊';
  final hiddenText = EmojiTranscoder.encode('😊', 'secret');

  print('Plain text: "$plainText"');
  print('Has hidden data: ${EmojiTranscoder.hasHiddenData(plainText)}');
  print('Hidden text: "$hiddenText"');
  print('Has hidden data: ${EmojiTranscoder.hasHiddenData(hiddenText)}\n');

  // Convenience method.
  print('6. Default Base Character:');
  final defaultEncoded = EmojiTranscoder.encodeWithDefault('Using default emoji');
  final defaultDecoded = EmojiTranscoder.decode(defaultEncoded);

  print('Message: "Using default emoji"');
  print('Encoded with default: "$defaultEncoded"');
  print('Visible: "${EmojiTranscoder.getVisibleText(defaultEncoded)}"');
  print('Decoded: "$defaultDecoded"\n');

  print('=== Copy/Paste Test ===');
  
  // Demonstrate copy/paste resilience
  print('7. Copy/Paste Resilience Test:');
  const testMessage = 'Test copy/paste data';
  final testSafeEncoded = EmojiTranscoder.encodeSafe('🔒', testMessage);
  
  print('Test message: "$testMessage"');
  print('Safe encoded: "$testSafeEncoded"');
  print('Copy the line above and paste it back into your code to test!');
  print('The hidden data should survive the copy/paste operation.\n');
  
  // Manual test with hardcoded safe-encoded string (will work after copy/paste)
  final testDecoded = EmojiTranscoder.decodeSafe(testSafeEncoded);
  print('Decoded from variable: "$testDecoded"');
  print('Decoding success: ${testMessage == testDecoded}\n');
  
  print('=== Demo Complete ===');

  // Warning message.
  print('\nWARNING: This technique abuses Unicode specification.');
  print('Do not use in production systems without understanding the implications.');
  print('\nTIP: Use encodeSafe() and decodeSafe() methods for copy/paste reliability.');
}
