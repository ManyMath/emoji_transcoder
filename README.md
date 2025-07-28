# Emoji Transcoder

A Dart package for encoding and decoding arbitrary data into emojis using Unicode variation selectors. Hide text within any Unicode character invisibly.

[![Pub Version](https://img.shields.io/pub/v/emoji_transcoder)](https://pub.dev/packages/emoji_transcoder)
[![License](https://img.shields.io/github/license/example/emoji_transcoder)](https://github.com/example/emoji_transcoder/blob/main/LICENSE)

## ⚠️ Warning

This technique abuses the Unicode specification and should not be used in production systems. It can bypass visual content filters and has potential for malicious use. This package is provided for educational and research purposes only.

## Features

- 🎭 **Invisible Encoding**: Hide text messages within any Unicode character
- 🔍 **Multi-message Support**: Encode multiple messages in a single text string
- 🌐 **Unicode Compatible**: Full support for Unicode characters including emojis
- 📊 **Text Analysis**: Get statistics about encoded text
- 🔧 **Detection Tools**: Check if text contains hidden data
- 📋 **Copy-paste Safe**: Hidden data survives copy/paste operations

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  emoji_transcoder: ^0.0.1
```

Then run:

```bash
dart pub get
```

## Basic Usage

### Simple Encoding and Decoding

```dart
import 'package:emoji_transcoder/emoji_transcoder.dart';

void main() {
  // Encode a message
  final encoded = EmojiTranscoder.encode('😊', 'Hello, World!');
  print(encoded); // Looks like just '😊' but contains hidden data
  
  // Decode the message
  final decoded = EmojiTranscoder.decode(encoded);
  print(decoded); // 'Hello, World!'
}
```

### Multiple Messages

```dart
// Encode multiple messages
final multipleMessages = {
  '😊': 'Hello',
  '🌟': 'World',
  '🎯': 'Secret',
};

final encoded = EmojiTranscoder.encodeMultiple(multipleMessages);
print(encoded); // Looks like: '😊🌟🎯'

// Decode all messages
final messages = EmojiTranscoder.decodeAll(encoded);
for (final msg in messages) {
  print('${msg.baseCharacter}: ${msg.message}');
}
// Output:
// 😊: Hello
// 🌟: World
// 🎯: Secret
```

### Detection and Analysis

```dart
final text = EmojiTranscoder.encode('🔐', 'secret data');

// Check if text contains hidden data
bool hasHidden = EmojiTranscoder.hasHiddenData(text);
print('Has hidden data: $hasHidden'); // true

// Get visible text only
String visible = EmojiTranscoder.getVisibleText(text);
print('Visible: $visible'); // '🔐'

// Get detailed statistics
Map<String, int> stats = EmojiTranscoder.getStats(text);
print('Total length: ${stats['totalLength']}');
print('Visible length: ${stats['visibleLength']}');
print('Hidden bytes: ${stats['hiddenBytes']}');
print('Message count: ${stats['messageCount']}');
```

### Unicode Support

```dart
// Works with any Unicode characters
final unicodeMessage = 'Héllo 世界! 🚀✨';
final encoded = EmojiTranscoder.encode('📝', unicodeMessage);
final decoded = EmojiTranscoder.decode(encoded);

print(unicodeMessage == decoded); // true
```

## API Reference

### EmojiTranscoder Class

#### Static Methods

- `encode(String baseCharacter, String message)` - Encode a message into a base character
- `decode(String encodedText)` - Decode the first hidden message
- `decodeAll(String encodedText)` - Decode all hidden messages
- `encodeMultiple(Map<String, String> messages)` - Encode multiple messages
- `encodeWithDefault(String message, {String? baseCharacter})` - Encode with default base character
- `hasHiddenData(String text)` - Check if text contains encoded data
- `getVisibleText(String encodedText)` - Extract visible characters only
- `getStats(String encodedText)` - Get text statistics

### DecodedMessage Class

Represents a decoded message with its base character:

```dart
class DecodedMessage {
  final String baseCharacter;
  final String message;
}
```

### Exceptions

- `EncodingException` - Thrown when encoding fails
- `DecodingException` - Thrown when decoding fails
- `InvalidByteException` - Thrown for invalid byte values
- `InvalidVariationSelectorException` - Thrown for invalid variation selectors

## How It Works

This package uses Unicode variation selectors (U+FE00 to U+FE0F) to encode binary data. Each byte of the input message is mapped to a specific variation selector codepoint, which is then appended to the base character. These variation selectors are invisible when rendered but preserved during text operations.

The encoding process:
1. Convert message text to UTF-8 bytes
2. Map each byte to a variation selector codepoint
3. Append variation selectors to the base character
4. Add a null terminator (U+FE0F)

The decoding process reverses this by extracting variation selectors and converting them back to the original message.

## Examples

See the `example/` directory for complete usage examples:

- `example/basic_usage.dart` - Comprehensive demonstration of all features

## Testing

Run the test suite:

```bash
dart test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run tests and ensure they pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

This software is provided for educational and research purposes only. The authors are not responsible for any misuse of this technology. Users should be aware of the ethical and legal implications of using steganographic techniques.
