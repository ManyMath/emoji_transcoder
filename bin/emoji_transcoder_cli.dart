#!/usr/bin/env dart

/// Command-line interface for the emoji_transcoder package.
/// 
/// This CLI tool demonstrates the clipboard functionality of the emoji transcoder,
/// allowing users to encode messages to clipboard and decode from clipboard.
/// 
/// Usage examples:
/// - dart run bin/emoji_transcoder_cli.dart encode "😊" "Hello World"
/// - dart run bin/emoji_transcoder_cli.dart decode-clipboard
/// - dart run bin/emoji_transcoder_cli.dart write-clipboard "🔐" "Secret message"
/// - dart run bin/emoji_transcoder_cli.dart read-clipboard

import 'dart:io';
import 'package:emoji_transcoder/emoji_transcoder.dart';

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    printUsage();
    exit(1);
  }

  final command = arguments[0].toLowerCase();

  try {
    switch (command) {
      case 'encode':
        await handleEncode(arguments);
        break;
      case 'decode':
        await handleDecode(arguments);
        break;
      case 'write-clipboard':
      case 'write-clip':
      case 'wc':
        await handleWriteClipboard(arguments);
        break;
      case 'read-clipboard':
      case 'read-clip':
      case 'rc':
        await handleReadClipboard(arguments);
        break;
      case 'read-all-clipboard':
      case 'read-all-clip':
      case 'rac':
        await handleReadAllClipboard(arguments);
        break;
      case 'write-safe-clipboard':
      case 'write-safe-clip':
      case 'wsc':
        await handleWriteSafeClipboard(arguments);
        break;
      case 'read-safe-clipboard':
      case 'read-safe-clip':
      case 'rsc':
        await handleReadSafeClipboard(arguments);
        break;
      case 'write-multiple-clipboard':
      case 'write-multi-clip':
      case 'wmc':
        await handleWriteMultipleClipboard(arguments);
        break;
      case 'check-clipboard':
      case 'check-clip':
      case 'cc':
        await handleCheckClipboard(arguments);
        break;
      case 'stats-clipboard':
      case 'stats-clip':
      case 'sc':
        await handleStatsClipboard(arguments);
        break;
      case 'demo':
        await handleDemo();
        break;
      case 'help':
      case '--help':
      case '-h':
        printUsage();
        break;
      default:
        print('Unknown command: $command');
        printUsage();
        exit(1);
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

void printUsage() {
  print('Emoji Transcoder CLI - Hide messages in emojis and clipboard operations');
  print('');
  print('BASIC COMMANDS:');
  print('  encode <emoji> <message>     Encode message into emoji');
  print('  decode <encoded_text>        Decode message from encoded text');
  print('');
  print('CLIPBOARD COMMANDS:');
  print('  write-clipboard <emoji> <message>        Encode and write to clipboard');
  print('  read-clipboard                           Read and decode from clipboard');
  print('  read-all-clipboard                       Read all messages from clipboard');
  print('');
  print('SAFE CLIPBOARD COMMANDS (copy/paste resistant):');
  print('  write-safe-clipboard <emoji> <message>   Safe encode to clipboard');
  print('  read-safe-clipboard                      Read safe-encoded from clipboard');
  print('');
  print('ADVANCED CLIPBOARD COMMANDS:');
  print('  write-multiple-clipboard                 Interactive multi-message input');
  print('  check-clipboard                          Check if clipboard has hidden data');
  print('  stats-clipboard                          Show clipboard statistics');
  print('');
  print('OTHER:');
  print('  demo                         Run interactive demo');
  print('  help                         Show this help message');
  print('');
  print('SHORT ALIASES:');
  print('  wc = write-clipboard    rc = read-clipboard    rac = read-all-clipboard');
  print('  wsc = write-safe-clipboard    rsc = read-safe-clipboard');
  print('  wmc = write-multiple-clipboard    cc = check-clipboard    sc = stats-clipboard');
  print('');
  print('Examples:');
  print('  dart run bin/emoji_transcoder_cli.dart encode "😊" "Hello World"');
  print('  dart run bin/emoji_transcoder_cli.dart wc "🔐" "Secret message"');
  print('  dart run bin/emoji_transcoder_cli.dart rc');
  print('  dart run bin/emoji_transcoder_cli.dart demo');
}

Future<void> handleEncode(List<String> arguments) async {
  if (arguments.length < 3) {
    print('Usage: encode <emoji> <message>');
    print('Example: encode "😊" "Hello World"');
    exit(1);
  }

  final emoji = arguments[1];
  final message = arguments.sublist(2).join(' ');

  final encoded = EmojiTranscoder.encode(emoji, message);
  print('Encoded: $encoded');
  print('Visible: ${EmojiTranscoder.getVisibleText(encoded)}');
}

Future<void> handleDecode(List<String> arguments) async {
  if (arguments.length < 2) {
    print('Usage: decode <encoded_text>');
    exit(1);
  }

  final encodedText = arguments.sublist(1).join(' ');
  final decoded = EmojiTranscoder.decode(encodedText);
  
  if (decoded.isEmpty) {
    print('No hidden message found in the provided text.');
  } else {
    print('Decoded: $decoded');
  }
}

Future<void> handleWriteClipboard(List<String> arguments) async {
  if (arguments.length < 3) {
    print('Usage: write-clipboard <emoji> <message>');
    print('Example: write-clipboard "😊" "Hello World"');
    exit(1);
  }

  final emoji = arguments[1];
  final message = arguments.sublist(2).join(' ');

  await EmojiTranscoder.writeToClipboard(emoji, message);
  print('✅ Encoded message written to clipboard!');
  print('Visible text: $emoji');
  print('Hidden message: $message');
}

Future<void> handleReadClipboard(List<String> arguments) async {
  final message = await EmojiTranscoder.readFromClipboard();
  
  if (message.isEmpty) {
    print('No hidden message found in clipboard.');
  } else {
    print('📋 Hidden message from clipboard: $message');
  }
}

Future<void> handleReadAllClipboard(List<String> arguments) async {
  final messages = await EmojiTranscoder.readAllFromClipboard();
  
  if (messages.isEmpty) {
    print('No hidden messages found in clipboard.');
  } else {
    print('📋 All hidden messages from clipboard:');
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      print('  ${i + 1}. ${msg.baseCharacter}: "${msg.message}"');
    }
  }
}

Future<void> handleWriteSafeClipboard(List<String> arguments) async {
  if (arguments.length < 3) {
    print('Usage: write-safe-clipboard <emoji> <message>');
    print('Example: write-safe-clipboard "🔐" "Secret message"');
    exit(1);
  }

  final emoji = arguments[1];
  final message = arguments.sublist(2).join(' ');

  await EmojiTranscoder.writeSafeToClipboard(emoji, message);
  print('✅ Safe-encoded message written to clipboard!');
  print('Visible text: $emoji');
  print('Hidden message: $message');
  print('💡 This encoding survives copy/paste operations.');
}

Future<void> handleReadSafeClipboard(List<String> arguments) async {
  final message = await EmojiTranscoder.readSafeFromClipboard();
  
  if (message.isEmpty) {
    print('No safe-encoded hidden message found in clipboard.');
  } else {
    print('📋 Safe-encoded message from clipboard: $message');
  }
}

Future<void> handleWriteMultipleClipboard(List<String> arguments) async {
  print('📝 Interactive multiple message input:');
  print('Enter emoji-message pairs (press Enter twice when done)');
  print('Format: <emoji> <message>');
  print('');

  final messages = <String, String>{};
  
  while (true) {
    stdout.write('> ');
    final input = stdin.readLineSync()?.trim();
    
    if (input == null || input.isEmpty) {
      break;
    }
    
    final parts = input.split(' ');
    if (parts.length < 2) {
      print('Invalid format. Use: <emoji> <message>');
      continue;
    }
    
    final emoji = parts[0];
    final message = parts.sublist(1).join(' ');
    messages[emoji] = message;
    print('Added: $emoji -> "$message"');
  }
  
  if (messages.isEmpty) {
    print('No messages entered.');
    return;
  }
  
  await EmojiTranscoder.writeMultipleToClipboard(messages);
  print('✅ ${messages.length} messages encoded and written to clipboard!');
  
  final visibleText = messages.keys.join('');
  print('Visible text: $visibleText');
}

Future<void> handleCheckClipboard(List<String> arguments) async {
  final hasHidden = await clipboardHasHiddenData();
  final hasSafeHidden = await clipboardHasSafeHiddenData();
  
  print('📋 Clipboard analysis:');
  print('  Has hidden data (variation selectors): $hasHidden');
  print('  Has safe hidden data (ZWJ): $hasSafeHidden');
  
  if (!hasHidden && !hasSafeHidden) {
    print('  ✅ Clipboard appears to contain only visible text.');
  } else {
    print('  ⚠️  Clipboard contains hidden data!');
  }
}

Future<void> handleStatsClipboard(List<String> arguments) async {
  final stats = await getClipboardStats();
  final rawText = await getRawClipboardText();
  
  print('📊 Clipboard Statistics:');
  print('  Total length: ${stats['totalLength']} characters');
  print('  Visible length: ${stats['visibleLength']} characters');
  print('  Hidden bytes: ${stats['hiddenBytes']} bytes');
  print('  Message count: ${stats['messageCount']} messages');
  print('');
  print('Raw clipboard content preview:');
  final preview = rawText.length > 100 ? '${rawText.substring(0, 100)}...' : rawText;
  print('  "$preview"');
}

Future<void> handleDemo() async {
  print('🎭 Emoji Transcoder Clipboard Demo');
  print('==================================');
  print('');
  
  // Demo 1: Basic clipboard operations
  print('Demo 1: Basic Clipboard Operations');
  print('----------------------------------');
  
  const testMessage = 'Hello from clipboard demo!';
  const testEmoji = '🎪';
  
  print('Encoding "$testMessage" with emoji $testEmoji...');
  await EmojiTranscoder.writeToClipboard(testEmoji, testMessage);
  print('✅ Written to clipboard');
  
  print('Reading back from clipboard...');
  final readMessage = await EmojiTranscoder.readFromClipboard();
  print('📋 Read: "$readMessage"');
  print('Match: ${testMessage == readMessage}');
  print('');
  
  // Demo 2: Safe encoding
  print('Demo 2: Copy/Paste Safe Encoding');
  print('--------------------------------');
  
  const safeMessage = 'Copy/paste safe message!';
  const safeEmoji = '🔒';
  
  print('Safe-encoding "$safeMessage" with emoji $safeEmoji...');
  await EmojiTranscoder.writeSafeToClipboard(safeEmoji, safeMessage);
  print('✅ Safe-encoded and written to clipboard');
  
  print('Reading safe-encoded from clipboard...');
  final readSafeMessage = await EmojiTranscoder.readSafeFromClipboard();
  print('📋 Read: "$readSafeMessage"');
  print('Match: ${safeMessage == readSafeMessage}');
  print('');
  
  // Demo 3: Multiple messages
  print('Demo 3: Multiple Messages');
  print('------------------------');
  
  final multiMessages = {
    '🌟': 'Star message',
    '🚀': 'Rocket message',
    '🎯': 'Target message',
  };
  
  print('Encoding multiple messages...');
  await EmojiTranscoder.writeMultipleToClipboard(multiMessages);
  print('✅ Multiple messages written to clipboard');
  
  print('Reading all messages from clipboard...');
  final allMessages = await EmojiTranscoder.readAllFromClipboard();
  print('📋 Found ${allMessages.length} messages:');
  for (final msg in allMessages) {
    print('   ${msg.baseCharacter}: "${msg.message}"');
  }
  print('');
  
  // Demo 4: Statistics
  print('Demo 4: Clipboard Statistics');
  print('---------------------------');
  
  final stats = await getClipboardStats();
  print('📊 Current clipboard stats:');
  print('   Total length: ${stats['totalLength']} characters');
  print('   Visible length: ${stats['visibleLength']} characters');
  print('   Hidden bytes: ${stats['hiddenBytes']} bytes');
  print('   Message count: ${stats['messageCount']} messages');
  print('');
  
  print('🎉 Demo complete!');
  print('');
  print('Try copying the clipboard content and pasting it elsewhere,');
  print('then run this demo again to see if the hidden data survives!');
}