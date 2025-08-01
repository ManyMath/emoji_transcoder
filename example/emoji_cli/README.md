# Emoji CLI - Clipboard Transcoder
A command-line application that demonstrates clipboard functionality with the emoji_transcoder package.  Hide messages in clipboard text using Unicode variation selectors.

## Features
- **Command-line interface** with comprehensive argument parsing.
- **Interactive mode** when no arguments are provided.
- **Multiple encoding methods** including safe ZWJ encoding.
- **Batch operations** for encoding multiple messages.
- **Statistics and analysis** of clipboard content.
- **Cross-platform clipboard support** via daniboard.

## Installation
1. Navigate to the CLI directory:
```bash
cd example/emoji_cli
```

2. Install dependencies:
```bash
dart pub get
```

3. Run the application:
```bash
dart run bin/main.dart
```

Or install globally:
```bash
dart pub global activate --source path .
emoji_cli --help
```

## Usage
### Command Line Mode
```bash
# Encode a message into an emoji.
emoji_cli --encode "😊:Hello World"

# Decode first message from clipboard.
emoji_cli --decode

# Decode all messages from clipboard.
emoji_cli --decode-all

# Check if clipboard contains hidden data.
emoji_cli --check

# Show clipboard statistics.
emoji_cli --stats

# Show raw clipboard content.
emoji_cli --raw

# Show only visible characters.
emoji_cli --visible

# Set clipboard to plain text.
emoji_cli --set "Plain text message"

# Encode multiple messages.
emoji_cli --encode-multiple "😊:hello,🌟:world,🔐:secret"
```

### Interactive Mode
Run without arguments to enter interactive mode:
```bash
emoji_cli
```

Available interactive commands:
- `encode <base> <message>` - Encode message into base character.
- `decode` - Decode first message from clipboard.
- `decode-all` - Decode all messages from clipboard.
- `check` - Check if clipboard has hidden data.
- `stats` - Show clipboard statistics.
- `raw` - Show raw clipboard content.
- `visible` - Show only visible characters.
- `set <text>` - Set clipboard to plain text.
- `clear` - Clear clipboard.
- `help` - Show help.
- `quit` - Exit.

## Examples
### Basic Encoding/Decoding
```bash
# Encode a secret message
$ emoji_cli --encode "😊:This is a secret message"
✓ Encoded "This is a secret message" into 😊 and copied to clipboard

# Check what's in clipboard (looks normal)
$ emoji_cli --raw
Raw clipboard content:
"😊"

# But it contains hidden data
$ emoji_cli --check
✓ Clipboard contains hidden data

# Decode the hidden message
$ emoji_cli --decode
Decoded message: This is a secret message
```

### Multiple Messages
```bash
# Encode multiple messages
$ emoji_cli --encode-multiple "😊:hello,🌟:world,🔐:secret"
✓ Encoded 3 messages and copied to clipboard
  😊: "hello"
  🌟: "world"
  🔐: "secret"

# Decode all messages
$ emoji_cli --decode-all
Found 3 hidden message(s):
  1. 😊: "hello"
  2. 🌟: "world"
  3. 🔐: "secret"
```

### Statistics
```bash
$ emoji_cli --stats
Clipboard Statistics:
  Total length: 27 characters
  Visible length: 3 characters
  Hidden bytes: 24
  Message count: 3
```

### Interactive Session
```bash
$ emoji_cli
🔤 Emoji Transcoder CLI - Interactive Mode
Hide messages in clipboard text using emoji steganography
Type "help" for commands or "quit" to exit.

emoji_cli> encode 🎉 Happy New Year!
✓ Encoded "Happy New Year!" into 🎉

emoji_cli> stats
Stats: 1 visible, 15 hidden, 1 messages

emoji_cli> decode
Decoded: "Happy New Year!"

emoji_cli> quit
Goodbye! 👋
```

## API Reference
The CLI uses the `ClipboardTranscoder` class which provides:

### Encoding Methods
- `encodeAndWriteToClipboard(baseChar, message)` - Basic encoding.
- `encodeMultipleAndWriteToClipboard(messages)` - Multiple messages.

### Decoding Methods
- `readAndDecodeFromClipboard()` - Decode first message.
- `readAndDecodeAllFromClipboard()` - Decode all messages.

### Utility Methods
- `clipboardHasHiddenData()` - Check for hidden data.
- `getClipboardStats()` - Get statistics.
- `getRawClipboardText()` - Get raw content.
- `setRawClipboardText(text)` - Set raw content.
- `getVisibleText(text)` - Extract visible characters.

## Dependencies

- `emoji_transcoder` - Core encoding/decoding functionality.
- `daniboard` - Cross-platform clipboard access.
- `args` - Command-line argument parsing.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
