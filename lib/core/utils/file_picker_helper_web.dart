// lib/core/utils/file_picker_helper_web.dart

import 'dart:html' as html;
import 'dart:async';
import 'dart:typed_data';
import 'file_picker_helper.dart';

/// Web implementation using dart:html (NO universal_html needed!)
class FilePickerHelperWeb implements FilePickerHelper {
  @override
  Future<PickedFile?> pickImage() async {
    return _pickFileWithInput(accept: 'image/*');
  }

  @override
  Future<PickedFile?> pickFile({List<String>? allowedExtensions}) async {
    final accept = allowedExtensions != null
        ? allowedExtensions.map((e) => '.$e').join(',')
        : null;
    return _pickFileWithInput(accept: accept);
  }

  @override
  Future<List<PickedFile>> pickMultipleFiles({
    List<String>? allowedExtensions,
  }) async {
    final accept = allowedExtensions != null
        ? allowedExtensions.map((e) => '.$e').join(',')
        : null;
    return _pickMultipleFilesWithInput(accept: accept);
  }

  /// Pick single file using HTML input element
  Future<PickedFile?> _pickFileWithInput({String? accept}) async {
    final completer = Completer<PickedFile?>();

    // Create input element
    final input = html.FileUploadInputElement();
    if (accept != null) {
      input.accept = accept;
    }

    // Listen for file selection
    input.onChange.listen((event) async {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }

      final file = files.first;
      final bytes = await _readFileAsBytes(file);

      if (bytes != null) {
        completer.complete(PickedFile(
          name: file.name,
          bytes: bytes,
          mimeType: file.type,
          size: file.size,
        ));
      } else {
        completer.complete(null);
      }
    });

    // Trigger file picker
    input.click();

    return completer.future;
  }

  /// Pick multiple files using HTML input element
  Future<List<PickedFile>> _pickMultipleFilesWithInput({
    String? accept,
  }) async {
    final completer = Completer<List<PickedFile>>();

    // Create input element
    final input = html.FileUploadInputElement();
    input.multiple = true;
    if (accept != null) {
      input.accept = accept;
    }

    // Listen for file selection
    input.onChange.listen((event) async {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete([]);
        return;
      }

      final pickedFiles = <PickedFile>[];
      for (final file in files) {
        final bytes = await _readFileAsBytes(file);
        if (bytes != null) {
          pickedFiles.add(PickedFile(
            name: file.name,
            bytes: bytes,
            mimeType: file.type,
            size: file.size,
          ));
        }
      }

      completer.complete(pickedFiles);
    });

    // Trigger file picker
    input.click();

    return completer.future;
  }

  /// Read file as bytes
  Future<Uint8List?> _readFileAsBytes(html.File file) async {
    final reader = html.FileReader();
    final completer = Completer<Uint8List?>();

    reader.onLoadEnd.listen((event) {
      if (reader.result != null) {
        completer.complete(reader.result as Uint8List);
      } else {
        completer.complete(null);
      }
    });

    reader.onError.listen((event) {
      completer.complete(null);
    });

    reader.readAsArrayBuffer(file);

    return completer.future;
  }
}

/// Factory function for conditional imports
FilePickerHelper getFilePickerHelper() => FilePickerHelperWeb();
