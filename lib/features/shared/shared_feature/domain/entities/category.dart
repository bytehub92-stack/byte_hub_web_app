import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String merchandiserId;
  final Map<String, String> name;
  final String? imageThumbnail;
  final String? image;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int subCategoryCount;
  final int productCount;

  const Category({
    required this.id,
    required this.merchandiserId,
    required this.name,
    this.imageThumbnail,
    this.image,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.productCount,
    required this.subCategoryCount,
  });

  @override
  List<Object?> get props => [
        id,
        merchandiserId,
        name,
        imageThumbnail,
        image,
        sortOrder,
        isActive,
        createdAt,
        updatedAt,
        productCount,
        subCategoryCount
      ];
}
