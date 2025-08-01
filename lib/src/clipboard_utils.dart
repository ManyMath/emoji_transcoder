/// Clipboard utilities for reading from and writing to the system clipboard.
/// 
/// This module provides functions to read encoded text from the clipboard,
/// decode it using the emoji transcoder, encode text with emoji transcoding,
/// and write it back to the clipboard.
/// 
/// Example usage:
/// ```dart
/// // Read and decode from clipboard
/// final decodedText = await readAndDecodeFromClipboard();
/// 
/// // Encode and write to clipboard
/// await encodeAndWriteToClipboard('😊', 'Hello, World!');
/// ```

import 'package:daniboard/daniboard.dart' as daniboard;
import '../emoji_transcoder.dart';

/// Exception thrown when clipboard operations fail.
class ClipboardException implements Exception {
  final String message;
  const ClipboardException(this.message);
  
  @override
  String toString() => 'ClipboardException: $message';
}

/// Reads text from the clipboard and attempts to decode any hidden messages.
/// 
/// Returns the first decoded message found in the clipboard text, or an empty
/// string if no encoded data is found or the clipboard is empty.
/// 
/// Throws [ClipboardException] if clipboard access fails.
/// 
/// Example:
/// ```dart
/// final decodedMessage = await readAndDecodeFromClipboard();
/// if (decodedMessage.isNotEmpty) {
///   print('Hidden message: $decodedMessage');
/// }
/// ```
Future<String> readAndDecodeFromClipboard() async {
  try {
    final clipboardText = await daniboard.read();
    
    if (clipboardText.isEmpty) {
      return '';
    }
    
    // Check if the clipboard contains encoded data
    if (!EmojiTranscoder.hasHiddenData(clipboardText)) {
      return '';
    }
    
    // Decode the first hidden message
    return EmojiTranscoder.decode(clipboardText);
  } catch (e) {
    throw ClipboardException('Failed to read from clipboard: $e');
  }
}

/// Reads text from the clipboard and decodes all hidden messages.
/// 
/// Returns a list of [DecodedMessage] objects containing all decoded messages
/// found in the clipboard text. Returns an empty list if no encoded data is
/// found or the clipboard is empty.
/// 
/// Throws [ClipboardException] if clipboard access fails.
/// 
/// Example:
/// ```dart
/// final messages = await readAndDecodeAllFromClipboard();
/// for (final msg in messages) {
///   print('${msg.baseCharacter}: ${msg.message}');
/// }
/// ```
Future<List<DecodedMessage>> readAndDecodeAllFromClipboard() async {
  try {
    final clipboardText = await daniboard.read();
    
    if (clipboardText.isEmpty) {
      return [];
    }
    
    // Check if the clipboard contains encoded data
    if (!EmojiTranscoder.hasHiddenData(clipboardText)) {
      return [];
    }
    
    // Decode all hidden messages
    return EmojiTranscoder.decodeAll(clipboardText);
  } catch (e) {
    throw ClipboardException('Failed to read from clipboard: $e');
  }
}

/// Encodes a message into a base character and writes it to the clipboard.
/// 
/// The [baseCharacter] is the visible character that will appear in the
/// clipboard, and [message] is the text to hide within it.
/// 
/// Throws [ClipboardException] if clipboard access fails.
/// Throws [EncodingException] if the encoding process fails.
/// 
/// Example:
/// ```dart
/// await encodeAndWriteToClipboard('😊', 'Secret message');
/// // Clipboard now contains what looks like just '😊' but has hidden data
/// ```
Future<void> encodeAndWriteToClipboard(String baseCharacter, String message) async {
  try {
    final encodedText = EmojiTranscoder.encode(baseCharacter, message);
    await daniboard.write(encodedText);
  } catch (e) {
    throw ClipboardException('Failed to write to clipboard: $e');
  }
}

/// Encodes multiple messages and writes them to the clipboard.
/// 
/// Each key-value pair in [messages] represents a base character and its
/// hidden message. All messages are combined into a single encoded string.
/// 
/// Throws [ClipboardException] if clipboard access fails.
/// Throws [EncodingException] if the encoding process fails.
/// 
/// Example:
/// ```dart
/// await encodeMultipleAndWriteToClipboard({
///   '😊': 'Hello',
///   '🌟': 'World',
///   '🔐': 'Secret',
/// });
/// // Clipboard contains: '😊🌟🔐' with hidden messages
/// ```
Future<void> encodeMultipleAndWriteToClipboard(Map<String, String> messages) async {
  try {
    final encodedText = EmojiTranscoder.encodeMultiple(messages);
    await daniboard.write(encodedText);
  } catch (e) {
    throw ClipboardException('Failed to write to clipboard: $e');
  }
}

/// Encodes a message using the safe ZWJ method and writes it to the clipboard.
/// 
/// This method uses Zero Width Joiner sequences that are more likely to
/// survive copy/paste operations across different applications.
/// 
/// Throws [ClipboardException] if clipboard access fails.
/// Throws [ZWJEncodingException] if the encoding process fails.
/// 
/// Example:
/// ```dart
/// await encodeSafeAndWriteToClipboard('😊', 'Persistent message');
/// // Uses ZWJ encoding for better copy/paste compatibility
/// ```
Future<void> encodeSafeAndWriteToClipboard(String baseCharacter, String message) async {
  try {
    final encodedText = EmojiTranscoder.encodeSafe(baseCharacter, message);
    await daniboard.write(encodedText);
  } catch (e) {
    throw ClipboardException('Failed to write to clipboard: $e');
  }
}

/// Reads text from the clipboard and attempts to decode ZWJ-encoded messages.
/// 
/// Returns the decoded message from ZWJ encoding, or an empty string if no
/// ZWJ-encoded data is found or the clipboard is empty.
/// 
/// Throws [ClipboardException] if clipboard access fails.
/// 
/// Example:
/// ```dart
/// final safeDecoded = await readAndDecodeSafeFromClipboard();
/// if (safeDecoded.isNotEmpty) {
///   print('ZWJ-encoded message: $safeDecoded');
/// }
/// ```
Future<String> readAndDecodeSafeFromClipboard() async {
  try {
    final clipboardText = await daniboard.read();
    
    if (clipboardText.isEmpty) {
      return '';
    }
    
    // Check if the clipboard contains ZWJ-encoded data
    if (!EmojiTranscoder.hasSafeHiddenData(clipboardText)) {
      return '';
    }
    
    // Decode the ZWJ-encoded message
    return EmojiTranscoder.decodeSafe(clipboardText);
  } catch (e) {
    throw ClipboardException('Failed to read from clipboard: $e');
  }
}

/// Gets the current clipboard text without any processing.
/// 
/// Returns the raw clipboard content as a string, or an empty string if
/// the clipboard is empty.
/// 
/// Throws [ClipboardException] if clipboard access fails.
/// 
/// Example:
/// ```dart
/// final rawText = await getRawClipboardText();
/// print('Clipboard contains: $rawText');
/// ```
Future<String> getRawClipboardText() async {
  try {
    return await daniboard.read();
  } catch (e) {
    throw ClipboardException('Failed to read from clipboard: $e');
  }
}

/// Writes raw text to the clipboard without any encoding.
/// 
/// Throws [ClipboardException] if clipboard access fails.
/// 
/// Example:
/// ```dart
/// await setRawClipboardText('Plain text message');
/// ```
Future<void> setRawClipboardText(String text) async {
  try {
    await daniboard.write(text);
  } catch (e) {
    throw ClipboardException('Failed to write to clipboard: $e');
  }
}

/// Checks if the current clipboard content contains any encoded data.
/// 
/// Returns true if the clipboard contains variation selectors that could
/// represent hidden messages, false otherwise.
/// 
/// Throws [ClipboardException] if clipboard access fails.
/// 
/// Example:
/// ```dart
/// if (await clipboardHasHiddenData()) {
///   print('Clipboard contains hidden data');
/// }
/// ```
Future<bool> clipboardHasHiddenData() async {
  try {
    final clipboardText = await daniboard.read();
    return EmojiTranscoder.hasHiddenData(clipboardText);
  } catch (e) {
    throw ClipboardException('Failed to read from clipboard: $e');
  }
}

/// Checks if the current clipboard content contains ZWJ-encoded data.
/// 
/// Returns true if the clipboard contains ZWJ-encoded hidden data, false otherwise.
/// 
/// Throws [ClipboardException] if clipboard access fails.
/// 
/// Example:
/// ```dart
/// if (await clipboardHasSafeHiddenData()) {
///   print('Clipboard contains ZWJ-encoded data');
/// }
/// ```
Future<bool> clipboardHasSafeHiddenData() async {
  try {
    final clipboardText = await daniboard.read();
    return EmojiTranscoder.hasSafeHiddenData(clipboardText);
  } catch (e) {
    throw ClipboardException('Failed to read from clipboard: $e');
  }
}

/// Gets statistics about encoded text currently in the clipboard.
/// 
/// Returns a map containing information about the clipboard text structure:
/// - 'totalLength': Total character count including variation selectors.
/// - 'visibleLength': Count of visible characters.
/// - 'hiddenBytes': Count of variation selectors (hidden bytes).
/// - 'messageCount': Number of decoded messages found.
/// 
/// Throws [ClipboardException] if clipboard access fails.
/// 
/// Example:
/// ```dart
/// final stats = await getClipboardStats();
/// print('Hidden messages: ${stats['messageCount']}');
/// print('Visible text: ${stats['visibleLength']} chars');
/// ```
Future<Map<String, int>> getClipboardStats() async {
  try {
    final clipboardText = await daniboard.read();
    return EmojiTranscoder.getStats(clipboardText);
  } catch (e) {
    throw ClipboardException('Failed to read from clipboard: $e');
  }
}