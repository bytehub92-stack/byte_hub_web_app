class CreateMerchandiserRequest {
  final String businessName;
  final String? businessNameArabic;
  final String businessType;
  final String? businessTypeArabic;
  final String description;
  final String? descriptionArabic;
  final String fullName;
  final String email;
  final String phoneNumber;

  const CreateMerchandiserRequest({
    required this.businessName,
    this.businessNameArabic,
    required this.businessType,
    this.businessTypeArabic,
    required this.description,
    this.descriptionArabic,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
  });
}
