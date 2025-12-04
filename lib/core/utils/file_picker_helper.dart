// lib/core/utils/file_picker_helper.dart

import 'dart:typed_data';

// ✅ CRITICAL: Import the factory function conditionally
import 'file_picker_helper_stub.dart'
    if (dart.library.html) 'file_picker_helper_web.dart'
    if (dart.library.io) 'file_picker_helper_mobile.dart';

/// Abstract interface for file picking
abstract class FilePickerHelper {
  /// Pick an image file
  Future<PickedFile?> pickImage();

  /// Pick any file
  Future<PickedFile?> pickFile({List<String>? allowedExtensions});

  /// Pick multiple files
  Future<List<PickedFile>> pickMultipleFiles({List<String>? allowedExtensions});
}

/// Represents a picked file
class PickedFile {
  final String name;
  final Uint8List bytes;
  final String? mimeType;
  final int size;

  PickedFile({
    required this.name,
    required this.bytes,
    this.mimeType,
    required this.size,
  });

  /// File extension
  String get extension => name.split('.').last.toLowerCase();

  /// Is this an image?
  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);

  /// Size in KB
  double get sizeInKB => size / 1024;

  /// Size in MB
  double get sizeInMB => sizeInKB / 1024;
}

/// Factory to get platform-specific implementation
class FilePicker {
  static FilePickerHelper? _instance;

  static FilePickerHelper get instance {
    // ✅ Call the factory function from conditional imports
    _instance ??= getFilePickerHelper();
    return _instance!;
  }
}
