import 'package:admin_panel/features/shared/shared_feature/domain/entities/sub_category.dart';

class SubCategoryModel extends SubCategory {
  const SubCategoryModel({
    required super.id,
    required super.categoryId,
    required super.merchandiserId,
    required super.name,
    required super.sortOrder,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required super.subCategoryName,
    required super.productCount,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      merchandiserId: json['merchandiser_id'] as String,
      name: _parseJsonbField(json['name']),
      sortOrder: json['sort_order'] as int,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      subCategoryName: _parseJsonbField(json['category_name']),
      productCount: json['product_count'] as int,
    );
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

  @override
  List<Object?> get props => [
        id,
        categoryId,
        merchandiserId,
        name,
        sortOrder,
        isActive,
        createdAt,
        updatedAt,
        subCategoryName,
        productCount
      ];
}
