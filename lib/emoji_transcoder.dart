/// A Dart package for encoding and decoding arbitrary data into emojis using Unicode variation selectors.
/// 
/// This library allows you to hide text messages within any Unicode character
/// (including emojis) by appending invisible variation selector codepoints.
/// The hidden data is preserved during copy/paste operations but remains
/// invisible to users.
/// 
/// **⚠️ WARNING: This technique abuses the Unicode specification and should not
/// be used in production systems. It can bypass visual content filters and
/// has potential for malicious use.**
/// 
/// ## Basic Usage
/// 
/// ```dart
/// import 'package:emoji_transcoder/emoji_transcoder.dart';
/// 
/// // Encode a message (with optional compression)
/// final encoded = EmojiTranscoder.encode('😊', 'Hello, World!', compress: true);
/// print(encoded); // Looks like just '😊' but contains hidden data
/// 
/// // Decode the message (automatically handles decompression)
/// final decoded = EmojiTranscoder.decode(encoded);
/// print(decoded); // 'Hello, World!'
/// ```
/// 
/// ## Multi-block Decoding
/// 
/// ```dart
/// final text = EmojiTranscoder.encode('😊', 'hello') + 
///              EmojiTranscoder.encode('🌟', 'world');
/// 
/// final messages = EmojiTranscoder.decodeAll(text);
/// // Returns [DecodedMessage('😊', 'hello'), DecodedMessage('🌟', 'world')]
/// ```
library emoji_transcoder;

import 'src/encoder.dart' as encoder;
import 'src/decoder.dart' as decoder;
import 'src/decoder.dart' show DecodedMessage;

export 'src/encoder.dart' show
    encode,
    encodeMultiple,
    encodeWithDefault,
    getVisualLength,
    hasEncodedData,
    EncodingException;

export 'src/decoder.dart' show
    decode,
    decodeAll,
    getVisibleText,
    containsEncodedData,
    getEncodedTextStats,
    DecodedMessage,
    DecodingException;

export 'src/variation_selectors.dart' show
    byteToVariationSelector,
    variationSelectorToByte,
    isVariationSelector,
    getCodepoint,
    InvalidByteException,
    InvalidVariationSelectorException;

export 'src/compression.dart' show
    compressString,
    decompressString,
    shouldCompress,
    getCompressionStats,
    CompressionException;

/// Main class providing an API for emoji transcoding operations.
/// 
/// This class provides static methods that wrap the core encoding and decoding
/// functionality into one interface.
class EmojiTranscoder {
  // Private constructor to prevent instantiation.
  EmojiTranscoder._();
  
  /// Encodes a message into a base character using Unicode variation selectors.
  /// 
  /// The [baseCharacter] is the visible character (emoji, letter, etc.) that
  /// will appear in the output. The [message] is hidden within the character.
  /// If [compress] is true, the message will be compressed before encoding if beneficial.
  /// 
  /// Example:
  /// ```dart
  /// final encoded = EmojiTranscoder.encode('😊', 'secret message', compress: true);
  /// ```
  /// 
  /// Throws [EncodingException] if encoding fails.
  /// Throws [ArgumentError] if inputs are invalid.
  static String encode(String baseCharacter, String message, {bool compress = false}) {
    return encoder.encode(baseCharacter, message, compress: compress);
  }
  
  /// Decodes the first hidden message from encoded text.
  /// 
  /// Returns the decoded message or an empty string if no encoded data is found.
  /// Automatically handles decompression if the data was compressed.
  /// 
  /// Example:
  /// ```dart
  /// final decoded = EmojiTranscoder.decode(encodedText);
  /// ```
  /// 
  /// Throws [DecodingException] if decoding fails.
  static String decode(String encodedText) {
    return decoder.decode(encodedText);
  }
  
  /// Decodes all hidden messages from encoded text.
  /// 
  /// Returns a list of [DecodedMessage] objects containing both the base
  /// character and decoded message for each found sequence.
  /// Automatically handles decompression if the data was compressed.
  /// 
  /// Example:
  /// ```dart
  /// final messages = EmojiTranscoder.decodeAll(text);
  /// for (final msg in messages) {
  ///   print('${msg.baseCharacter}: ${msg.message}');
  /// }
  /// ```
  static List<DecodedMessage> decodeAll(String encodedText) {
    return decoder.decodeAll(encodedText);
  }
  
  /// Checks if text contains any encoded data.
  /// 
  /// Returns true if the text contains variation selectors that could
  /// represent hidden messages.
  static bool hasHiddenData(String text) {
    return decoder.containsEncodedData(text);
  }
  
  /// Extracts just the visible characters from encoded text.
  /// 
  /// Returns the text with all variation selectors removed, showing only
  /// the characters that would be visible to a user.
  /// 
  /// Example:
  /// ```dart
  /// final visible = EmojiTranscoder.getVisibleText(encodedText);
  /// ```
  static String getVisibleText(String encodedText) {
    return decoder.getVisibleText(encodedText);
  }
  
  /// Gets statistics about encoded text.
  /// 
  /// Returns a map containing information about the text structure:
  /// - 'totalLength': Total character count including variation selectors.
  /// - 'visibleLength': Count of visible characters.
  /// - 'hiddenBytes': Count of variation selectors (hidden bytes).
  /// - 'messageCount': Number of decoded messages found.
  static Map<String, int> getStats(String encodedText) {
    return decoder.getEncodedTextStats(encodedText);
  }
  
  /// Encodes multiple messages into a single text string.
  /// 
  /// Each message is encoded with its own base character. This allows
  /// multiple hidden messages to coexist in the same text.
  /// If [compress] is true, each message will be compressed before encoding if beneficial.
  /// 
  /// Example:
  /// ```dart
  /// final encoded = EmojiTranscoder.encodeMultiple({
  ///   '😊': 'hello',
  ///   '🌟': 'world',
  /// }, compress: true);
  /// ```
  static String encodeMultiple(Map<String, String> messages, {bool compress = false}) {
    return encoder.encodeMultiple(messages, compress: compress);
  }
  
  /// Encodes a message with a default base character.
  /// 
  /// Convenience method that uses '😊' as the default base character if none provided.
  /// If [compress] is true, the message will be compressed before encoding if beneficial.
  /// 
  /// Example:
  /// ```dart
  /// final encoded = EmojiTranscoder.encodeWithDefault('secret', compress: true);
  /// // Equivalent to EmojiTranscoder.encode('😊', 'secret', compress: true)
  /// ```
  static String encodeWithDefault(String message, {String? baseCharacter, bool compress = false}) {
    return encoder.encodeWithDefault(message, baseCharacter: baseCharacter, compress: compress);
  }
}
