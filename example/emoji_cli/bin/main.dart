#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import '../lib/emoji_cli.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Show this help message')
    ..addOption('encode', abbr: 'e', help: 'Encode message into clipboard with specified base character (format: base:message)')
    ..addOption('encode-safe', help: 'Encode message using safe ZWJ method (format: base:message)')
    ..addFlag('decode', abbr: 'd', help: 'Decode first message from clipboard')
    ..addFlag('decode-all', help: 'Decode all messages from clipboard')
    ..addFlag('decode-safe', help: 'Decode ZWJ-encoded message from clipboard')
    ..addFlag('check', abbr: 'c', help: 'Check if clipboard contains hidden data')
    ..addFlag('check-safe', help: 'Check if clipboard contains ZWJ-encoded data')
    ..addFlag('stats', abbr: 's', help: 'Show clipboard statistics')
    ..addFlag('raw', abbr: 'r', help: 'Show raw clipboard content')
    ..addFlag('visible', abbr: 'v', help: 'Show only visible text from clipboard')
    ..addOption('set', help: 'Set raw clipboard content to specified text')
    ..addOption('encode-multiple', help: 'Encode multiple messages (format: base1:msg1,base2:msg2,...)');

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      _showHelp(parser);
      return;
    }

    // If no arguments provided, enter interactive mode
    if (arguments.isEmpty) {
      await _interactiveMode();
      return;
    }

    final clipboardTranscoder = ClipboardTranscoder();

    // Handle different operations
    if (results['encode'] != null) {
      await _handleEncode(clipboardTranscoder, results['encode'] as String);
    } else if (results['encode-safe'] != null) {
      await _handleEncodeSafe(clipboardTranscoder, results['encode-safe'] as String);
    } else if (results['decode'] as bool) {
      await _handleDecode(clipboardTranscoder);
    } else if (results['decode-all'] as bool) {
      await _handleDecodeAll(clipboardTranscoder);
    } else if (results['decode-safe'] as bool) {
      await _handleDecodeSafe(clipboardTranscoder);
    } else if (results['check'] as bool) {
      await _handleCheck(clipboardTranscoder);
    } else if (results['check-safe'] as bool) {
      await _handleCheckSafe(clipboardTranscoder);
    } else if (results['stats'] as bool) {
      await _handleStats(clipboardTranscoder);
    } else if (results['raw'] as bool) {
      await _handleRaw(clipboardTranscoder);
    } else if (results['visible'] as bool) {
      await _handleVisible(clipboardTranscoder);
    } else if (results['set'] != null) {
      await _handleSet(clipboardTranscoder, results['set'] as String);
    } else if (results['encode-multiple'] != null) {
      await _handleEncodeMultiple(clipboardTranscoder, results['encode-multiple'] as String);
    } else {
      print('No valid operation specified. Use --help for usage information.');
      exit(1);
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

void _showHelp(ArgParser parser) {
  print('Emoji Transcoder CLI - Hide messages in clipboard text using emoji steganography');
  print('');
  print('Usage: emoji_cli [options]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print('  emoji_cli --encode "😊:Hello World"     # Encode message into 😊');
  print('  emoji_cli --decode                      # Decode first message from clipboard');
  print('  emoji_cli --decode-all                  # Decode all messages from clipboard');
  print('  emoji_cli --check                       # Check if clipboard has hidden data');
  print('  emoji_cli --stats                       # Show clipboard statistics');
  print('  emoji_cli --raw                         # Show raw clipboard content');
  print('  emoji_cli --visible                     # Show only visible characters');
  print('  emoji_cli --set "Plain text"            # Set clipboard to plain text');
  print('  emoji_cli                               # Interactive mode');
}

Future<void> _handleEncode(ClipboardTranscoder transcoder, String input) async {
  final parts = input.split(':');
  if (parts.length < 2) {
    throw ArgumentError('Encode format should be "base:message"');
  }
  
  final baseChar = parts[0];
  final message = parts.sublist(1).join(':'); // Rejoin in case message contains ':'
  
  await transcoder.encodeAndWriteToClipboard(baseChar, message);
  print('✓ Encoded "$message" into $baseChar and copied to clipboard');
}

Future<void> _handleEncodeSafe(ClipboardTranscoder transcoder, String input) async {
  final parts = input.split(':');
  if (parts.length < 2) {
    throw ArgumentError('Encode format should be "base:message"');
  }
  
  final baseChar = parts[0];
  final message = parts.sublist(1).join(':');
  
  await transcoder.encodeSafeAndWriteToClipboard(baseChar, message);
  print('✓ Safe-encoded "$message" into $baseChar and copied to clipboard');
}

Future<void> _handleDecode(ClipboardTranscoder transcoder) async {
  final decoded = await transcoder.readAndDecodeFromClipboard();
  if (decoded.isEmpty) {
    print('No hidden messages found in clipboard');
  } else {
    print('Decoded message: $decoded');
  }
}

Future<void> _handleDecodeAll(ClipboardTranscoder transcoder) async {
  final messages = await transcoder.readAndDecodeAllFromClipboard();
  if (messages.isEmpty) {
    print('No hidden messages found in clipboard');
  } else {
    print('Found ${messages.length} hidden message(s):');
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      print('  ${i + 1}. ${msg.baseCharacter}: "${msg.message}"');
    }
  }
}

Future<void> _handleDecodeSafe(ClipboardTranscoder transcoder) async {
  final decoded = await transcoder.readAndDecodeSafeFromClipboard();
  if (decoded.isEmpty) {
    print('No ZWJ-encoded messages found in clipboard');
  } else {
    print('ZWJ-decoded message: $decoded');
  }
}

Future<void> _handleCheck(ClipboardTranscoder transcoder) async {
  final hasHidden = await transcoder.clipboardHasHiddenData();
  print(hasHidden ? '✓ Clipboard contains hidden data' : '✗ No hidden data found in clipboard');
}

Future<void> _handleCheckSafe(ClipboardTranscoder transcoder) async {
  final hasSafeHidden = await transcoder.clipboardHasSafeHiddenData();
  print(hasSafeHidden ? '✓ Clipboard contains ZWJ-encoded data' : '✗ No ZWJ-encoded data found in clipboard');
}

Future<void> _handleStats(ClipboardTranscoder transcoder) async {
  final stats = await transcoder.getClipboardStats();
  print('Clipboard Statistics:');
  print('  Total length: ${stats['totalLength']} characters');
  print('  Visible length: ${stats['visibleLength']} characters');
  print('  Hidden bytes: ${stats['hiddenBytes']}');
  print('  Message count: ${stats['messageCount']}');
}

Future<void> _handleRaw(ClipboardTranscoder transcoder) async {
  final raw = await transcoder.getRawClipboardText();
  if (raw.isEmpty) {
    print('Clipboard is empty');
  } else {
    print('Raw clipboard content:');
    print('"$raw"');
  }
}

Future<void> _handleVisible(ClipboardTranscoder transcoder) async {
  final raw = await transcoder.getRawClipboardText();
  if (raw.isEmpty) {
    print('Clipboard is empty');
  } else {
    final visible = transcoder.getVisibleText(raw);
    print('Visible text:');
    print('"$visible"');
  }
}

Future<void> _handleSet(ClipboardTranscoder transcoder, String text) async {
  await transcoder.setRawClipboardText(text);
  print('✓ Set clipboard to: "$text"');
}

Future<void> _handleEncodeMultiple(ClipboardTranscoder transcoder, String input) async {
  final messages = <String, String>{};
  final pairs = input.split(',');
  
  for (final pair in pairs) {
    final parts = pair.split(':');
    if (parts.length < 2) {
      throw ArgumentError('Each message should be in format "base:message"');
    }
    final baseChar = parts[0];
    final message = parts.sublist(1).join(':');
    messages[baseChar] = message;
  }
  
  await transcoder.encodeMultipleAndWriteToClipboard(messages);
  print('✓ Encoded ${messages.length} messages and copied to clipboard');
  for (final entry in messages.entries) {
    print('  ${entry.key}: "${entry.value}"');
  }
}

Future<void> _interactiveMode() async {
  final transcoder = ClipboardTranscoder();
  
  print('🔤 Emoji Transcoder CLI - Interactive Mode');
  print('Hide messages in clipboard text using emoji steganography');
  print('Type "help" for commands or "quit" to exit.\n');
  
  while (true) {
    stdout.write('emoji_cli> ');
    final input = stdin.readLineSync()?.trim() ?? '';
    
    if (input.isEmpty) continue;
    
    final parts = input.split(' ');
    final command = parts[0].toLowerCase();
    
    try {
      switch (command) {
        case 'quit':
        case 'exit':
        case 'q':
          print('Goodbye! 👋');
          return;
          
        case 'help':
        case 'h':
          _showInteractiveHelp();
          break;
          
        case 'encode':
        case 'e':
          if (parts.length < 3) {
            print('Usage: encode <base_char> <message>');
            break;
          }
          final baseChar = parts[1];
          final message = parts.sublist(2).join(' ');
          await transcoder.encodeAndWriteToClipboard(baseChar, message);
          print('✓ Encoded "$message" into $baseChar');
          break;
          
        case 'encode-safe':
        case 'es':
          if (parts.length < 3) {
            print('Usage: encode-safe <base_char> <message>');
            break;
          }
          final baseChar = parts[1];
          final message = parts.sublist(2).join(' ');
          await transcoder.encodeSafeAndWriteToClipboard(baseChar, message);
          print('✓ Safe-encoded "$message" into $baseChar');
          break;
          
        case 'decode':
        case 'd':
          final decoded = await transcoder.readAndDecodeFromClipboard();
          if (decoded.isEmpty) {
            print('No hidden messages found');
          } else {
            print('Decoded: "$decoded"');
          }
          break;
          
        case 'decode-all':
        case 'da':
          final messages = await transcoder.readAndDecodeAllFromClipboard();
          if (messages.isEmpty) {
            print('No hidden messages found');
          } else {
            print('Found ${messages.length} message(s):');
            for (int i = 0; i < messages.length; i++) {
              final msg = messages[i];
              print('  ${i + 1}. ${msg.baseCharacter}: "${msg.message}"');
            }
          }
          break;
          
        case 'decode-safe':
        case 'ds':
          final decoded = await transcoder.readAndDecodeSafeFromClipboard();
          if (decoded.isEmpty) {
            print('No ZWJ-encoded messages found');
          } else {
            print('ZWJ-decoded: "$decoded"');
          }
          break;
          
        case 'check':
        case 'c':
          final hasHidden = await transcoder.clipboardHasHiddenData();
          print(hasHidden ? '✓ Has hidden data' : '✗ No hidden data');
          break;
          
        case 'check-safe':
        case 'cs':
          final hasSafe = await transcoder.clipboardHasSafeHiddenData();
          print(hasSafe ? '✓ Has ZWJ-encoded data' : '✗ No ZWJ-encoded data');
          break;
          
        case 'stats':
        case 's':
          final stats = await transcoder.getClipboardStats();
          print('Stats: ${stats['visibleLength']} visible, ${stats['hiddenBytes']} hidden, ${stats['messageCount']} messages');
          break;
          
        case 'raw':
        case 'r':
          final raw = await transcoder.getRawClipboardText();
          if (raw.isEmpty) {
            print('Clipboard is empty');
          } else {
            print('Raw: "$raw"');
          }
          break;
          
        case 'visible':
        case 'v':
          final raw = await transcoder.getRawClipboardText();
          if (raw.isEmpty) {
            print('Clipboard is empty');
          } else {
            final visible = transcoder.getVisibleText(raw);
            print('Visible: "$visible"');
          }
          break;
          
        case 'set':
          if (parts.length < 2) {
            print('Usage: set <text>');
            break;
          }
          final text = parts.sublist(1).join(' ');
          await transcoder.setRawClipboardText(text);
          print('✓ Set clipboard to: "$text"');
          break;
          
        case 'clear':
          await transcoder.setRawClipboardText('');
          print('✓ Cleared clipboard');
          break;
          
        default:
          print('Unknown command: $command');
          print('Type "help" for available commands');
      }
    } catch (e) {
      print('Error: $e');
    }
    
    print(''); // Empty line for readability
  }
}

void _showInteractiveHelp() {
  print('''
Available commands:
  encode <base> <message>    (e)  - Encode message into base character
  encode-safe <base> <msg>   (es) - Encode using safe ZWJ method
  decode                     (d)  - Decode first message from clipboard
  decode-all                 (da) - Decode all messages from clipboard
  decode-safe                (ds) - Decode ZWJ-encoded message
  check                      (c)  - Check if clipboard has hidden data
  check-safe                 (cs) - Check if clipboard has ZWJ-encoded data
  stats                      (s)  - Show clipboard statistics
  raw                        (r)  - Show raw clipboard content
  visible                    (v)  - Show only visible characters
  set <text>                      - Set clipboard to plain text
  clear                           - Clear clipboard
  help                       (h)  - Show this help
  quit                       (q)  - Exit interactive mode

Examples:
  encode 😊 Hello World
  decode-all
  stats
''');
}