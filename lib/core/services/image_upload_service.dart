import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class ImageUploadService {
  Future<Uint8List?> pickImage();

  Future<Either<Failure, Map<String, String>>> uploadCategoryImage({
    required String merchandiserId,
    required String categoryId,
    required Uint8List imageBytes,
  });

  Future<Either<Failure, List<String>>> uploadProductImages({
    required String merchandiserId,
    required String productId,
    required List<Uint8List> imageBytesList,
  });
}
