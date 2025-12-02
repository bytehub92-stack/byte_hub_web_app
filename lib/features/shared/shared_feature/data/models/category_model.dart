import 'package:admin_panel/features/shared/shared_feature/domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.merchandiserId,
    required super.name,
    super.imageThumbnail,
    super.image,
    required super.sortOrder,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required super.productCount,
    required super.subCategoryCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      merchandiserId: json['merchandiser_id'] as String,
      name: _parseJsonbField(json['name']),
      imageThumbnail: json['image_thumbnail'] as String?,
      image: json['image'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      subCategoryCount: json['sub_category_count'] as int? ?? 0, // Add this
      productCount: json['product_count'] as int? ?? 0, // Add this
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchandiser_id': merchandiserId,
      'name': name,
      'image_thumbnail': imageThumbnail,
      'image': image,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static Map<String, String> _parseJsonbField(dynamic field) {
    if (field == null) return {};
    if (field is Map<String, dynamic>) {
      return field.cast<String, String>();
    }
    if (field is String) {
      return {'en': field};
    }
    return {};
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
        id: category.id,
        merchandiserId: category.merchandiserId,
        name: category.name,
        sortOrder: category.sortOrder,
        image: category.image,
        imageThumbnail: category.imageThumbnail,
        isActive: category.isActive,
        createdAt: category.createdAt,
        updatedAt: category.createdAt,
        productCount: category.productCount,
        subCategoryCount: category.subCategoryCount);
  }
}
