/// Clipboard utilities for reading from and writing to the system clipboard.
/// 
/// This module provides functions to read encoded text from the clipboard,
/// decode it using the emoji transcoder, encode text with emoji transcoding,
/// and write it back to the clipboard.
/// 
/// Example usage:
/// ```dart
/// final transcoder = ClipboardTranscoder();
/// 
/// // Read and decode from clipboard
/// final decodedText = await transcoder.readAndDecodeFromClipboard();
/// 
/// // Encode and write to clipboard
/// await transcoder.encodeAndWriteToClipboard('😊', 'Hello, World!');
/// ```

import 'package:daniboard/daniboard.dart' as daniboard;
import 'package:emoji_transcoder/emoji_transcoder.dart';

/// Exception thrown when clipboard operations fail.
class ClipboardException implements Exception {
  final String message;
  const ClipboardException(this.message);
  
  @override
  String toString() => 'ClipboardException: $message';
}

/// A wrapper class that provides clipboard functionality for emoji transcoding.
class ClipboardTranscoder {
  /// Reads text from the clipboard and attempts to decode any hidden messages.
  /// 
  /// Returns the first decoded message found in the clipboard text, or an empty
  /// string if no encoded data is found or the clipboard is empty.
  /// 
  /// Throws [ClipboardException] if clipboard access fails.
  /// 
  /// Example:
  /// ```dart
  /// final transcoder = ClipboardTranscoder();
  /// final decodedMessage = await transcoder.readAndDecodeFromClipboard();
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
  /// final transcoder = ClipboardTranscoder();
  /// final messages = await transcoder.readAndDecodeAllFromClipboard();
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
  /// final transcoder = ClipboardTranscoder();
  /// await transcoder.encodeAndWriteToClipboard('😊', 'Secret message');
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
  /// final transcoder = ClipboardTranscoder();
  /// await transcoder.encodeMultipleAndWriteToClipboard({
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
  /// Note: This uses the same encoding method as the regular encode since
  /// the emoji_transcoder package doesn't have separate ZWJ methods.
  /// 
  /// Throws [ClipboardException] if clipboard access fails.
  /// Throws [EncodingException] if the encoding process fails.
  /// 
  /// Example:
  /// ```dart
  /// final transcoder = ClipboardTranscoder();
  /// await transcoder.encodeSafeAndWriteToClipboard('😊', 'Persistent message');
  /// ```
  Future<void> encodeSafeAndWriteToClipboard(String baseCharacter, String message) async {
    try {
      // Note: Using regular encode method as emoji_transcoder doesn't have separate ZWJ methods
      final encodedText = EmojiTranscoder.encode(baseCharacter, message);
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
  /// Note: This uses the same decoding method as the regular decode since
  /// the emoji_transcoder package doesn't have separate ZWJ methods.
  /// 
  /// Throws [ClipboardException] if clipboard access fails.
  /// 
  /// Example:
  /// ```dart
  /// final transcoder = ClipboardTranscoder();
  /// final safeDecoded = await transcoder.readAndDecodeSafeFromClipboard();
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
      
      // Note: Using regular hasHiddenData/decode as emoji_transcoder doesn't have separate ZWJ methods
      if (!EmojiTranscoder.hasHiddenData(clipboardText)) {
        return '';
      }
      
      return EmojiTranscoder.decode(clipboardText);
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
  /// final transcoder = ClipboardTranscoder();
  /// final rawText = await transcoder.getRawClipboardText();
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
  /// final transcoder = ClipboardTranscoder();
  /// await transcoder.setRawClipboardText('Plain text message');
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
  /// final transcoder = ClipboardTranscoder();
  /// if (await transcoder.clipboardHasHiddenData()) {
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
  /// Note: This uses the same method as hasHiddenData since emoji_transcoder 
  /// doesn't have separate ZWJ detection methods.
  /// 
  /// Throws [ClipboardException] if clipboard access fails.
  /// 
  /// Example:
  /// ```dart
  /// final transcoder = ClipboardTranscoder();
  /// if (await transcoder.clipboardHasSafeHiddenData()) {
  ///   print('Clipboard contains ZWJ-encoded data');
  /// }
  /// ```
  Future<bool> clipboardHasSafeHiddenData() async {
    try {
      final clipboardText = await daniboard.read();
      // Note: Using regular hasHiddenData as emoji_transcoder doesn't have separate ZWJ methods
      return EmojiTranscoder.hasHiddenData(clipboardText);
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
  /// final transcoder = ClipboardTranscoder();
  /// final stats = await transcoder.getClipboardStats();
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

  /// Extracts just the visible characters from text.
  /// 
  /// Returns the text with all variation selectors removed, showing only
  /// the characters that would be visible to a user.
  /// 
  /// This is a convenience method that doesn't require clipboard access.
  /// 
  /// Example:
  /// ```dart
  /// final transcoder = ClipboardTranscoder();
  /// final visible = transcoder.getVisibleText(encodedText);
  /// ```
  String getVisibleText(String encodedText) {
    return EmojiTranscoder.getVisibleText(encodedText);
  }

  /// Checks if text contains any encoded data.
  /// 
  /// Returns true if the text contains variation selectors that could
  /// represent hidden messages.
  /// 
  /// This is a convenience method that doesn't require clipboard access.
  /// 
  /// Example:
  /// ```dart
  /// final transcoder = ClipboardTranscoder();
  /// if (transcoder.hasHiddenData(text)) {
  ///   print('Text contains hidden data');
  /// }
  /// ```
  bool hasHiddenData(String text) {
    return EmojiTranscoder.hasHiddenData(text);
  }
}