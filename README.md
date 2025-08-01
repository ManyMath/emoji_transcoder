# Emoji Transcoder
A Dart package for encoding and decoding arbitrary data into emojis using Unicode variation selectors.  Hide text within any Unicode character invisibly.

Based on the method specified in [this article by Paul Butler](https://paulbutler.org/2025/smuggling-arbitrary-data-through-an-emoji/) and written to make [this `emoji-encoder` implementation](https://github.com/paulgb/emoji-encoder).

[![Pub Version](https://img.shields.io/pub/v/emoji_transcoder)](https://pub.dev/packages/emoji_transcoder)
[![License](https://img.shields.io/github/license/example/emoji_transcoder)](https://github.com/cypherstack/emoji_transcoder/blob/main/LICENSE)

## ⚠️ Warning
This technique abuses the Unicode specification and should not be used in production systems.  It can bypass visual content filters and has potential for malicious use.  This package is provided for educational and research purposes only.

## Features
- 🎭 **Invisible Encoding**: Hide text messages within any Unicode character.
- 🔍 **Multi-message Support**: Encode multiple messages in a single text string.
- 🌐 **Unicode Compatible**: Full support for Unicode characters including emojis.
- 📊 **Text Analysis**: Get statistics about encoded text.
- 🔧 **Detection Tools**: Check if text contains hidden data.
- 📋 **Copy-paste Safe**: Hidden data survives copy/paste operations.
- 🗃️ **Clipboard Integration**: Direct read/write operations to system clipboard.
- ⚡ **Command Line Interface**: Full-featured CLI for encoding/decoding operations.

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

### Clipboard System Requirements

For clipboard functionality to work, you need one of the following clipboard managers installed on your system:

#### Linux
- **xsel** (recommended): `sudo apt install xsel` or `sudo dnf install xsel`
- **wl-clipboard** (for Wayland): `sudo apt install wl-clipboard` or `sudo dnf install wl-clipboard`

#### macOS
- Built-in clipboard support (no additional packages needed)

#### Windows
- Built-in clipboard support (no additional packages needed)

**Note**: If no clipboard manager is found on Linux, you'll get an error like "No clipboard manager found install either xsel or wl-clipboard". The basic encoding/decoding functionality works without clipboard managers.

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

// Check if text contains hidden data.
bool hasHidden = EmojiTranscoder.hasHiddenData(text);
print('Has hidden data: $hasHidden'); // true

// Get visible text only.
String visible = EmojiTranscoder.getVisibleText(text);
print('Visible: $visible'); // '🔐'.

// Get detailed statistics.
Map<String, int> stats = EmojiTranscoder.getStats(text);
print('Total length: ${stats['totalLength']}');
print('Visible length: ${stats['visibleLength']}');
print('Hidden bytes: ${stats['hiddenBytes']}');
print('Message count: ${stats['messageCount']}');
```

### Unicode Support
```dart
// Works with any Unicode characters.
final unicodeMessage = 'Héllo 世界! 🚀✨';
final encoded = EmojiTranscoder.encode('📝', unicodeMessage);
final decoded = EmojiTranscoder.decode(encoded);

print(unicodeMessage == decoded); // true.
```

## Clipboard Operations

### Direct Clipboard Integration
```dart
import 'package:emoji_transcoder/emoji_transcoder.dart';

void main() async {
  // Write encoded message to clipboard
  await EmojiTranscoder.writeToClipboard('😊', 'Hidden message');
  
  // Read and decode from clipboard
  final message = await EmojiTranscoder.readFromClipboard();
  print('Hidden message: $message'); // 'Hidden message'
  
  // Write multiple messages to clipboard
  await EmojiTranscoder.writeMultipleToClipboard({
    '🌟': 'Star message',
    '🚀': 'Rocket message',
  });
  
  // Read all messages from clipboard
  final allMessages = await EmojiTranscoder.readAllFromClipboard();
  for (final msg in allMessages) {
    print('${msg.baseCharacter}: ${msg.message}');
  }
}
```

### Copy/Paste Safe Encoding
For better reliability across different applications and platforms:

```dart
// Use safe encoding that survives copy/paste operations
await EmojiTranscoder.writeSafeToClipboard('🔐', 'Persistent data');

// Read safe-encoded data
final safeMessage = await EmojiTranscoder.readSafeFromClipboard();
print('Safe message: $safeMessage');
```

### Advanced Clipboard Functions
```dart
// Check if clipboard contains hidden data
bool hasHidden = await clipboardHasHiddenData();
print('Clipboard has hidden data: $hasHidden');

// Get clipboard statistics
Map<String, int> stats = await getClipboardStats();
print('Hidden messages: ${stats['messageCount']}');
print('Total characters: ${stats['totalLength']}');

// Direct clipboard access
await setRawClipboardText('Plain text');
String raw = await getRawClipboardText();
```

## Command Line Interface

The package includes a full-featured CLI for clipboard operations:

### Basic Commands
```bash
# Encode a message
dart run bin/emoji_transcoder_cli.dart encode "😊" "Hello World"

# Decode a message
dart run bin/emoji_transcoder_cli.dart decode "😊󠄸󠅕󠅜󠅜󠅟"

# Show help
dart run bin/emoji_transcoder_cli.dart help
```

### Clipboard Commands
```bash
# Write to clipboard (short alias: wc)
dart run bin/emoji_transcoder_cli.dart write-clipboard "🔐" "Secret message"

# Read from clipboard (short alias: rc)
dart run bin/emoji_transcoder_cli.dart read-clipboard

# Read all messages from clipboard (short alias: rac)
dart run bin/emoji_transcoder_cli.dart read-all-clipboard

# Safe encoding for copy/paste (short alias: wsc)
dart run bin/emoji_transcoder_cli.dart write-safe-clipboard "🛡️" "Protected data"

# Read safe-encoded data (short alias: rsc)
dart run bin/emoji_transcoder_cli.dart read-safe-clipboard
```

### Advanced Clipboard Commands
```bash
# Interactive multi-message input (short alias: wmc)
dart run bin/emoji_transcoder_cli.dart write-multiple-clipboard

# Check if clipboard has hidden data (short alias: cc)
dart run bin/emoji_transcoder_cli.dart check-clipboard

# Show clipboard statistics (short alias: sc)
dart run bin/emoji_transcoder_cli.dart stats-clipboard

# Run interactive demo
dart run bin/emoji_transcoder_cli.dart demo
```

## API Reference
### EmojiTranscoder Class
#### Static Methods

- `encode(String baseCharacter, String message)` - Encode a message into a base character.
- `decode(String encodedText)` - Decode the first hidden message.
- `decodeAll(String encodedText)` - Decode all hidden messages.
- `encodeMultiple(Map<String, String> messages)` - Encode multiple messages.
- `encodeWithDefault(String message, {String? baseCharacter})` - Encode with default base character.
- `hasHiddenData(String text)` - Check if text contains encoded data.
- `getVisibleText(String encodedText)` - Extract visible characters only.
- `getStats(String encodedText)` - Get text statistics.

#### Clipboard Methods
- `readFromClipboard()` - Read and decode first hidden message from clipboard.
- `readAllFromClipboard()` - Read and decode all hidden messages from clipboard.
- `writeToClipboard(String baseCharacter, String message)` - Encode message and write to clipboard.
- `writeMultipleToClipboard(Map<String, String> messages)` - Encode multiple messages to clipboard.
- `writeSafeToClipboard(String baseCharacter, String message)` - Safe encode to clipboard (copy/paste resistant).
- `readSafeFromClipboard()` - Read and decode safe-encoded message from clipboard.

### DecodedMessage Class
Represents a decoded message with its base character:

```dart
class DecodedMessage {
  final String baseCharacter;
  final String message;
}
```

### Exceptions
- `EncodingException` - Thrown when encoding fails.
- `DecodingException` - Thrown when decoding fails.
- `InvalidByteException` - Thrown for invalid byte values.
- `InvalidVariationSelectorException` - Thrown for invalid variation selectors.
- `ClipboardException` - Thrown when clipboard operations fail.

### Additional Clipboard Functions
Direct access to clipboard utilities:
- `readAndDecodeFromClipboard()` - Read and decode first message from clipboard.
- `readAndDecodeAllFromClipboard()` - Read and decode all messages from clipboard.
- `encodeAndWriteToClipboard(String baseCharacter, String message)` - Encode and write to clipboard.
- `clipboardHasHiddenData()` - Check if clipboard contains encoded data.
- `getClipboardStats()` - Get statistics about clipboard content.
- `getRawClipboardText()` / `setRawClipboardText(String text)` - Raw clipboard access.

## How It Works
This package uses Unicode variation selectors (U+FE00 to U+FE0F) to encode binary data.  Each byte of the input message is mapped to a specific variation selector codepoint, which is then appended to the base character.  These variation selectors are invisible when rendered but preserved during text operations.

The encoding process:
1. Convert message text to UTF-8 bytes.
2. Map each byte to a variation selector codepoint.
3. Append variation selectors to the base character.
4. Add a null terminator (U+FE0F).

The decoding process reverses this by extracting variation selectors and converting them back to the original message.

## Dependencies

This package uses the following dependencies for clipboard functionality:

- **[daniboard](https://pub.dev/packages/daniboard)** - Pure Dart clipboard library for CLI applications
  - Works without Flutter dependencies
  - Supports Windows, macOS, and Linux
  - Requires system clipboard managers on Linux (xsel or wl-clipboard)

## Examples
See the `example/` directory for complete usage examples:

- `example/emoji_transcoder_example.dart` - Comprehensive demonstration of all features
- `bin/emoji_transcoder_cli.dart` - Full-featured command-line interface

## Testing
Run the test suite:

```bash
dart test
```

**Note**: Clipboard tests require a system clipboard manager to be installed. On Linux, install `xsel` or `wl-clipboard`:
```bash
# Ubuntu/Debian
sudo apt install xsel

# Fedora/RedHat
sudo dnf install xsel

# Wayland users
sudo apt install wl-clipboard  # or sudo dnf install wl-clipboard
```

## Contributing
1. Fork the repository.
2. Create a feature branch.
3. Make your changes.
4. Add tests for new functionality.
5. Run tests and ensure they pass.
6. Submit a pull request.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
