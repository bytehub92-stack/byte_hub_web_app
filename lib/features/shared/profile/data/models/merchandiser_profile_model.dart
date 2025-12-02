class MerchandiserProfileModel {
  final String id;
  final String profileId;
  final String email; // Read-only, from profiles table
  final String fullName; // From profiles table
  final String? phoneNumber; // From profiles table
  final String? avatarUrl; // From profiles table
  final String? website; // From profiles table

  // Business Information (JSONB fields)
  final Map<String, dynamic>? businessName;
  final Map<String, dynamic>? businessType;
  final Map<String, dynamic>? description;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? city;
  final Map<String, dynamic>? state;
  final Map<String, dynamic>? country;

  // Other fields
  final String? logoUrl;
  final String? postalCode;
  final String? taxId;
  final String? merchandiserCode;
  final bool isActive;

  MerchandiserProfileModel({
    required this.id,
    required this.profileId,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.website,
    this.businessName,
    this.businessType,
    this.description,
    this.address,
    this.city,
    this.state,
    this.country,
    this.logoUrl,
    this.postalCode,
    this.taxId,
    this.merchandiserCode,
    required this.isActive,
  });

  factory MerchandiserProfileModel.fromJson(Map<String, dynamic> json) {
    return MerchandiserProfileModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      website: json['website'] as String?,
      businessName: json['business_name'] as Map<String, dynamic>?,
      businessType: json['business_type'] as Map<String, dynamic>?,
      description: json['description'] as Map<String, dynamic>?,
      address: json['address'] as Map<String, dynamic>?,
      city: json['city'] as Map<String, dynamic>?,
      state: json['state'] as Map<String, dynamic>?,
      country: json['country'] as Map<String, dynamic>?,
      logoUrl: json['logo_url'] as String?,
      postalCode: json['postal_code'] as String?,
      taxId: json['tax_id'] as String?,
      merchandiserCode: json['merchandiser_code'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'website': website,
      'business_name': businessName,
      'business_type': businessType,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'logo_url': logoUrl,
      'postal_code': postalCode,
      'tax_id': taxId,
    };
  }

  // Helper methods to get localized values
  String getBusinessName(String locale) {
    return businessName?[locale] as String? ??
        businessName?['en'] as String? ??
        '';
  }

  String getBusinessType(String locale) {
    return businessType?[locale] as String? ??
        businessType?['en'] as String? ??
        '';
  }

  String getDescription(String locale) {
    return description?[locale] as String? ??
        description?['en'] as String? ??
        '';
  }

  String getAddress(String locale) {
    return address?[locale] as String? ?? address?['en'] as String? ?? '';
  }

  String getCity(String locale) {
    return city?[locale] as String? ?? city?['en'] as String? ?? 'Cairo';
  }

  String getState(String locale) {
    return state?[locale] as String? ?? state?['en'] as String? ?? '';
  }

  String getCountry(String locale) {
    return country?[locale] as String? ?? country?['en'] as String? ?? 'Egypt';
  }

  MerchandiserProfileModel copyWith({
    String? id,
    String? profileId,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? website,
    Map<String, dynamic>? businessName,
    Map<String, dynamic>? businessType,
    Map<String, dynamic>? description,
    Map<String, dynamic>? address,
    Map<String, dynamic>? city,
    Map<String, dynamic>? state,
    Map<String, dynamic>? country,
    String? logoUrl,
    String? postalCode,
    String? taxId,
    String? merchandiserCode,
    bool? isActive,
  }) {
    return MerchandiserProfileModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      website: website ?? this.website,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      logoUrl: logoUrl ?? this.logoUrl,
      postalCode: postalCode ?? this.postalCode,
      taxId: taxId ?? this.taxId,
      merchandiserCode: merchandiserCode ?? this.merchandiserCode,
      isActive: isActive ?? this.isActive,
    );
  }
}
