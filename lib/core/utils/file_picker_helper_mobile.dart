// lib/core/utils/file_picker_helper_mobile.dart

import 'package:file_picker/file_picker.dart' as fp;
import 'file_picker_helper.dart';

/// Mobile implementation using file_picker package
class FilePickerHelperMobile implements FilePickerHelper {
  @override
  Future<PickedFile?> pickImage() async {
    final result = await fp.FilePicker.platform.pickFiles(
      type: fp.FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    if (file.bytes == null) return null;

    return PickedFile(
      name: file.name,
      bytes: file.bytes!,
      mimeType: file.extension != null ? 'image/${file.extension}' : null,
      size: file.size,
    );
  }

  @override
  Future<PickedFile?> pickFile({List<String>? allowedExtensions}) async {
    final result = await fp.FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? fp.FileType.custom : fp.FileType.any,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    if (file.bytes == null) return null;

    return PickedFile(
      name: file.name,
      bytes: file.bytes!,
      mimeType: file.extension,
      size: file.size,
    );
  }

  @override
  Future<List<PickedFile>> pickMultipleFiles({
    List<String>? allowedExtensions,
  }) async {
    final result = await fp.FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? fp.FileType.custom : fp.FileType.any,
      allowedExtensions: allowedExtensions,
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return [];

    return result.files
        .where((file) => file.bytes != null)
        .map((file) => PickedFile(
              name: file.name,
              bytes: file.bytes!,
              mimeType: file.extension,
              size: file.size,
            ))
        .toList();
  }
}

/// Factory function for conditional imports
FilePickerHelper getFilePickerHelper() => FilePickerHelperMobile();
