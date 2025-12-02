import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';
import 'image_upload_service.dart';
import 'web_image_compression_service.dart';

class ImageUploadServiceImpl implements ImageUploadService {
  final SupabaseClient supabaseClient;
  final WebImageCompressionService compressionService;

  ImageUploadServiceImpl({
    required this.supabaseClient,
    required this.compressionService,
  });

  @override
  Future<Uint8List?> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first.bytes;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> uploadCategoryImage({
    required String merchandiserId,
    required String categoryId,
    required Uint8List imageBytes,
  }) async {
    try {
      // Verify user is authenticated
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        return const Left(ServerFailure(message: 'User not authenticated'));
      }

      // Compress both versions
      final thumbnail = await compressionService.compressThumbnail(imageBytes);
      final large = await compressionService.compressLargeImage(imageBytes);

      if (thumbnail == null || large == null) {
        return const Left(ServerFailure(message: 'Image compression failed'));
      }

      // Upload thumbnail
      final thumbnailPath =
          'merchandisers/$merchandiserId/categories/$categoryId/thumbnail.webp';

      try {
        await supabaseClient.storage
            .from('images')
            .uploadBinary(
              thumbnailPath,
              thumbnail,
              fileOptions: const FileOptions(
                contentType: 'image/webp',
                upsert: true,
              ),
            );
      } catch (storageError) {
        return Left(
          ServerFailure(message: 'Failed to upload thumbnail: $storageError'),
        );
      }

      // Upload large version
      final largePath =
          'merchandisers/$merchandiserId/categories/$categoryId/large.webp';

      try {
        await supabaseClient.storage
            .from('images')
            .uploadBinary(
              largePath,
              large,
              fileOptions: const FileOptions(
                contentType: 'image/webp',
                upsert: true,
              ),
            );
      } catch (storageError) {
        return Left(
          ServerFailure(message: 'Failed to upload large image: $storageError'),
        );
      }

      // Get public URLs
      final thumbnailUrl = supabaseClient.storage
          .from('images')
          .getPublicUrl(thumbnailPath);
      final largeUrl = supabaseClient.storage
          .from('images')
          .getPublicUrl(largePath);

      return Right({'thumbnail': thumbnailUrl, 'large': largeUrl});
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to upload image: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadProductImages({
    required String merchandiserId,
    required String productId,
    required List<Uint8List> imageBytesList,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        return const Left(ServerFailure(message: 'User not authenticated'));
      }

      final imageUrls = <String>[];

      for (var i = 0; i < imageBytesList.length; i++) {
        final compressed = await compressionService.compressLargeImage(
          imageBytesList[i],
        );

        if (compressed == null) {
          return Left(
            ServerFailure(
              message: 'Image compression failed for image ${i + 1}',
            ),
          );
        }

        final path =
            'merchandisers/$merchandiserId/products/$productId/image_$i.webp';

        try {
          await supabaseClient.storage
              .from('images')
              .uploadBinary(
                path,
                compressed,
                fileOptions: const FileOptions(
                  contentType: 'image/webp',
                  upsert: true,
                ),
              );

          final url = supabaseClient.storage.from('images').getPublicUrl(path);
          imageUrls.add(url);
        } catch (storageError) {
          return Left(
            ServerFailure(
              message: 'Failed to upload image ${i + 1}: $storageError',
            ),
          );
        }
      }

      return Right(imageUrls);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to upload images: ${e.toString()}'),
      );
    }
  }
}
