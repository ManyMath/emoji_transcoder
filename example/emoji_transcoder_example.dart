import 'package:emoji_transcoder/emoji_transcoder.dart';

void main() {
  print('=== Emoji Transcoder Basic Usage ===\n');

  // Basic encoding and decoding.
  print('1. Basic Encoding/Decoding:');
  const message = 'Hello, World!';
  const baseEmoji = '😊';

  final encoded = EmojiTranscoder.encode(baseEmoji, message);
  print('Original message: "$message"');
  print('Encoded result: "$encoded"');
  print('Looks like just: "${EmojiTranscoder.getVisibleText(encoded)}"');

  final decoded = EmojiTranscoder.decode(encoded);
  print('Decoded message: "$decoded"');
  print('Messages match: ${message == decoded}\n');

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

  print('=== Demo Complete ===');

  // Warning message.
  print('\nWARNING: This technique abuses Unicode specification.');
  print('Do not use in production systems without understanding the implications.');
}
