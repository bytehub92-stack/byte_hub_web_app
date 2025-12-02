// test/helpers/mock_file_picker_helper.dart

import 'dart:typed_data';
import 'package:mocktail/mocktail.dart';
import 'package:admin_panel/core/utils/file_picker_helper.dart';

/// Mock implementation for testing
class MockFilePickerHelper extends Mock implements FilePickerHelper {}

/// Fake PickedFile for testing
class FakePickedFile extends Fake implements PickedFile {
  @override
  final String name;

  @override
  final Uint8List bytes;

  @override
  final String? mimeType;

  @override
  final int size;

  FakePickedFile({
    required this.name,
    required this.bytes,
    this.mimeType,
    required this.size,
  });

  @override
  String get extension => name.split('.').last.toLowerCase();

  @override
  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);

  @override
  double get sizeInKB => size / 1024;

  @override
  double get sizeInMB => sizeInKB / 1024;
}

/// Test helper to create fake files
class TestFileFactory {
  /// Create a fake image file
  static PickedFile createFakeImage({
    String name = 'test_image.png',
    int size = 1024,
  }) {
    return FakePickedFile(
      name: name,
      bytes: Uint8List.fromList(List.generate(size, (i) => i % 256)),
      mimeType: 'image/png',
      size: size,
    );
  }

  /// Create a fake PDF file
  static PickedFile createFakePDF({
    String name = 'test_document.pdf',
    int size = 2048,
  }) {
    return FakePickedFile(
      name: name,
      bytes: Uint8List.fromList(List.generate(size, (i) => i % 256)),
      mimeType: 'application/pdf',
      size: size,
    );
  }

  /// Create a fake text file
  static PickedFile createFakeTextFile({
    String name = 'test.txt',
    String content = 'Test content',
  }) {
    final bytes = Uint8List.fromList(content.codeUnits);
    return FakePickedFile(
      name: name,
      bytes: bytes,
      mimeType: 'text/plain',
      size: bytes.length,
    );
  }

  /// Create multiple fake files
  static List<PickedFile> createMultipleFakeFiles(int count) {
    return List.generate(
      count,
      (i) => createFakeImage(name: 'test_$i.png'),
    );
  }
}
