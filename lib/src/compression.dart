/// Compression utilities for reducing data size before encoding.
library compression;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Exception thrown when compression or decompression fails.
class CompressionException implements Exception {
  final String message;
  const CompressionException(this.message);
  
  @override
  String toString() => 'CompressionException: $message';
}

/// Compresses a string using gzip compression.
/// 
/// Returns the compressed bytes. For small strings, compression may actually
/// increase the size due to compression overhead.
/// 
/// Throws [CompressionException] if compression fails.
Uint8List compressString(String input) {
  if (input.isEmpty) {
    return Uint8List(0);
  }
  
  try {
    final utf8Bytes = utf8.encode(input);
    final compressed = gzip.encode(utf8Bytes);
    return Uint8List.fromList(compressed);
  } catch (e) {
    throw CompressionException('Failed to compress string: $e');
  }
}

/// Decompresses gzip-compressed bytes back to a string.
/// 
/// Returns the original string.
/// 
/// Throws [CompressionException] if decompression fails.
String decompressString(Uint8List compressedBytes) {
  if (compressedBytes.isEmpty) {
    return '';
  }
  
  try {
    final decompressed = gzip.decode(compressedBytes);
    return utf8.decode(decompressed);
  } catch (e) {
    throw CompressionException('Failed to decompress data: $e');
  }
}

/// Determines if compression would be beneficial for the given input.
/// 
/// Returns true if the compressed size is smaller than the original size.
/// This accounts for the compression overhead and is useful for deciding
/// whether to use compression.
bool shouldCompress(String input) {
  if (input.isEmpty || input.length < 10) {
    return false;  // Very short strings rarely benefit from compression
  }
  
  try {
    final originalBytes = utf8.encode(input);
    final compressedBytes = compressString(input);
    
    // Add a small buffer (5%) to account for encoding overhead
    return compressedBytes.length < (originalBytes.length * 0.95);
  } catch (e) {
    return false;  // If compression fails, don't use it
  }
}

/// Gets compression statistics for a string.
/// 
/// Returns a map containing:
/// - 'originalSize': Size of the original UTF-8 encoded string in bytes
/// - 'compressedSize': Size after gzip compression in bytes
/// - 'compressionRatio': Ratio of compressed size to original size (0.0 to 1.0)
/// - 'spaceSaved': Number of bytes saved through compression
/// - 'beneficial': Whether compression reduces the size
Map<String, dynamic> getCompressionStats(String input) {
  if (input.isEmpty) {
    return {
      'originalSize': 0,
      'compressedSize': 0,
      'compressionRatio': 0.0,
      'spaceSaved': 0,
      'beneficial': false,
    };
  }
  
  try {
    final originalBytes = utf8.encode(input);
    final compressedBytes = compressString(input);
    
    final originalSize = originalBytes.length;
    final compressedSize = compressedBytes.length;
    final compressionRatio = compressedSize / originalSize;
    final spaceSaved = originalSize - compressedSize;
    final beneficial = compressedSize < originalSize;
    
    return {
      'originalSize': originalSize,
      'compressedSize': compressedSize,
      'compressionRatio': compressionRatio,
      'spaceSaved': spaceSaved,
      'beneficial': beneficial,
    };
  } catch (e) {
    return {
      'originalSize': utf8.encode(input).length,
      'compressedSize': -1,
      'compressionRatio': -1.0,
      'spaceSaved': -1,
      'beneficial': false,
    };
  }
}