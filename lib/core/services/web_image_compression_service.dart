import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:web/web.dart' as web;

/// Web-only image compression/encoding helper.
///
/// - Resizes using `package:image` (pure Dart).
/// - Uses browser Canvas via `package:web` to encode the final result to WebP.
class WebImageCompressionService {
  /// Create a thumbnail (resized to fit within 400x400) and return WebP bytes.
  Future<Uint8List?> compressThumbnail(Uint8List imageBytes) async {
    // Delegate to the generic converter with target size
    return convertToWebPUsingCanvas(
      imageBytes,
      quality: 0.75,
      maxWidth: 400,
      maxHeight: 400,
    );
  }

  /// Create a large image (resized to fit within 1200x1200) and return WebP bytes.
  Future<Uint8List?> compressLargeImage(Uint8List imageBytes) async {
    return convertToWebPUsingCanvas(
      imageBytes,
      quality: 0.8,
      maxWidth: 1200,
      maxHeight: 1200,
    );
  }

  /// Convert raw image bytes to WebP using an HTML canvas.
  ///
  /// Steps:
  ///  1. Decode with `package:image`.
  ///  2. Resize with `package:image` to fit within maxWidth/maxHeight (preserve aspect ratio).
  ///  3. Encode resized image to PNG (so browser can load it reliably).
  ///  4. Create an `HTMLImageElement` from the PNG Data URL, draw it on a `<canvas>`,
  ///     then call `canvas.toDataURL('image/webp', quality)` to get WebP data URL.
  ///  5. Return decoded WebP bytes.
  ///
  /// Note: This function is intended for web (browser) usage.
  Future<Uint8List?> convertToWebPUsingCanvas(
    Uint8List imageBytes, {
    double quality = 0.8, // 0.0 - 1.0 (browser expects 0..1)
    int? maxWidth,
    int? maxHeight,
  }) async {
    // 1) Decode using package:image
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) return null;

    // 2) Compute target size (preserve aspect ratio)
    int targetWidth = decoded.width;
    int targetHeight = decoded.height;

    if (maxWidth != null || maxHeight != null) {
      final double widthRatio = maxWidth != null
          ? (maxWidth / decoded.width)
          : double.infinity;
      final double heightRatio = maxHeight != null
          ? (maxHeight / decoded.height)
          : double.infinity;
      final ratio = [
        widthRatio,
        heightRatio,
        1.0,
      ].reduce((a, b) => a < b ? a : b);
      if (ratio < 1.0) {
        targetWidth = (decoded.width * ratio).round().clamp(1, decoded.width);
        targetHeight = (decoded.height * ratio).round().clamp(
          1,
          decoded.height,
        );
      }
    }

    // If resizing is needed, use package:image copyResize
    img.Image resized = decoded;
    if (targetWidth != decoded.width || targetHeight != decoded.height) {
      resized = img.copyResize(
        decoded,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.average,
      );
    }

    // 3) Encode resized image to PNG (safe to load in browser)
    final resizedPng = img.encodePng(resized);
    final dataUrl = 'data:image/png;base64,${base64Encode(resizedPng)}';

    // 4) Create an HTMLImageElement and wait for it to load
    final completer = Completer<Uint8List?>();
    final htmlImage = web.HTMLImageElement();
    htmlImage.src = dataUrl;

    htmlImage.onLoad.listen(
      (_) {
        try {
          // create canvas sized to resized image
          final canvas = web.HTMLCanvasElement();
          canvas.width = resized.width;
          canvas.height = resized.height;

          // get 2d context
          final ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D?;

          if (ctx == null) {
            completer.completeError(
              Exception('Could not get CanvasRenderingContext2D'),
            );
            return;
          }

          // draw the image onto the canvas (image and canvas are same size)
          ctx.drawImage(htmlImage, 0, 0);

          // Some versions/interop provide `toDataUrl` or `toDataURL`,
          // try both (use dynamic to avoid static errors).
          String webpDataUrl;
          try {
            webpDataUrl = (canvas as dynamic).toDataUrl('image/webp', quality);
          } catch (_) {
            // fallback to different casing
            webpDataUrl = (canvas as dynamic).toDataURL('image/webp', quality);
          }

          // 5) Convert data URL -> bytes
          final base64Part = webpDataUrl.split(',').last;
          final webpBytes = base64Decode(base64Part);

          completer.complete(Uint8List.fromList(webpBytes));
        } catch (e) {
          completer.completeError(e);
        }
      },
      onError: (e) {
        completer.completeError(e ?? Exception('Image load error'));
      },
    );

    // Also handle image load error (some browsers may never call onError in package:web)
    htmlImage.onError.listen((ev) {
      if (!completer.isCompleted) {
        completer.completeError(
          Exception('Failed to load intermediate image.'),
        );
      }
    });

    return completer.future;
  }

  /// Return file size in KB (with two decimals).
  double getFileSizeKB(Uint8List bytes) {
    final kb = bytes.length / 1024;
    return double.parse(kb.toStringAsFixed(2));
  }
}
