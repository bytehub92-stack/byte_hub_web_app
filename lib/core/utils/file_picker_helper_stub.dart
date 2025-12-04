// lib/core/utils/file_picker_helper_stub.dart

import 'file_picker_helper.dart';

/// Stub implementation for unsupported platforms or tests
class FilePickerHelperStub implements FilePickerHelper {
  @override
  Future<PickedFile?> pickImage() async {
    throw UnsupportedError(
      'File picking is not supported on this platform',
    );
  }

  @override
  Future<PickedFile?> pickFile({List<String>? allowedExtensions}) async {
    throw UnsupportedError(
      'File picking is not supported on this platform',
    );
  }

  @override
  Future<List<PickedFile>> pickMultipleFiles({
    List<String>? allowedExtensions,
  }) async {
    throw UnsupportedError(
      'File picking is not supported on this platform',
    );
  }
}

/// Factory function for conditional imports
FilePickerHelper getFilePickerHelper() => FilePickerHelperStub();
