import 'package:equatable/equatable.dart';

class SubCategory extends Equatable {
  final String id;
  final String categoryId;
  final String merchandiserId;
  final Map<String, String> name;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, String> subCategoryName;
  final int productCount;

  const SubCategory({
    required this.id,
    required this.categoryId,
    required this.merchandiserId,
    required this.name,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.subCategoryName,
    required this.productCount,
  });

  String getLocalizedName(String languageCode) {
    return name[languageCode] ?? name['en'] ?? 'Unknown Sub-Category';
  }

  String getLocalizedCategoryName(String languageCode) {
    return subCategoryName[languageCode] ??
        subCategoryName['en'] ??
        'Unknown Sub-Category';
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
