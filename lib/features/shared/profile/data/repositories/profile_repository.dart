// lib/features/profile/data/repositories/profile_repository.dart
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/merchandiser_profile_model.dart';
import '../../../../../core/services/web_image_compression_service.dart';

class ProfileRepository {
  final SupabaseClient _supabase;
  final WebImageCompressionService _compressionService;

  ProfileRepository(this._supabase, this._compressionService);

  /// Fetch merchandiser profile with profile information
  Future<MerchandiserProfileModel?> getMerchandiserProfile(
    String profileId,
  ) async {
    try {
      final response = await _supabase
          .from('merchandisers')
          .select('''
            *,
            profiles!inner(
              email,
              full_name,
              phone_number,
              website
            )
          ''')
          .eq('profile_id', profileId)
          .maybeSingle();

      if (response == null) return null;

      final flattenedData = {
        ...response,
        'email': response['profiles']['email'],
        'full_name': response['profiles']['full_name'],
        'phone_number': response['profiles']['phone_number'],
        'website': response['profiles']['website'],
      };

      flattenedData.remove('profiles');

      return MerchandiserProfileModel.fromJson(flattenedData);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// Update merchandiser profile
  Future<void> updateMerchandiserProfile({
    required String merchandiserId,
    required String profileId,
    String? phoneNumber,
    String? fullName,
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
  }) async {
    try {
      // Update profiles table
      final profileUpdates = <String, dynamic>{};
      if (phoneNumber != null) profileUpdates['phone_number'] = phoneNumber;
      if (fullName != null) profileUpdates['full_name'] = fullName;
      if (website != null) profileUpdates['website'] = website;

      if (profileUpdates.isNotEmpty) {
        profileUpdates['updated_at'] = DateTime.now().toIso8601String();
        await _supabase
            .from('profiles')
            .update(profileUpdates)
            .eq('id', profileId);
      }

      // Update merchandisers table
      final merchandiserUpdates = <String, dynamic>{};
      if (businessName != null) {
        merchandiserUpdates['business_name'] = businessName;
      }
      if (businessType != null) {
        merchandiserUpdates['business_type'] = businessType;
      }
      if (description != null) merchandiserUpdates['description'] = description;
      if (address != null) merchandiserUpdates['address'] = address;
      if (city != null) merchandiserUpdates['city'] = city;
      if (state != null) merchandiserUpdates['state'] = state;
      if (country != null) merchandiserUpdates['country'] = country;
      if (logoUrl != null) merchandiserUpdates['logo_url'] = logoUrl;
      if (postalCode != null) merchandiserUpdates['postal_code'] = postalCode;
      if (taxId != null) merchandiserUpdates['tax_id'] = taxId;

      if (merchandiserUpdates.isNotEmpty) {
        merchandiserUpdates['updated_at'] = DateTime.now().toIso8601String();
        await _supabase
            .from('merchandisers')
            .update(merchandiserUpdates)
            .eq('id', merchandiserId);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Upload logo image
  Future<String> uploadLogo(String merchandiserId, Uint8List imageBytes) async {
    try {
      // Compress the logo
      final compressed = await _compressionService.compressLargeImage(
        imageBytes,
      );

      if (compressed == null) {
        throw Exception('Image compression failed');
      }

      final fileName =
          'logo_${merchandiserId}_${DateTime.now().millisecondsSinceEpoch}.webp';
      final path = 'merchandisers/$merchandiserId/logo/$fileName';

      await _supabase.storage
          .from('logos')
          .uploadBinary(
            path,
            compressed,
            fileOptions: const FileOptions(
              contentType: 'image/webp',
              upsert: true,
            ),
          );

      final publicUrl = _supabase.storage.from('logos').getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload logo: $e');
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // First verify current password by attempting to sign in
      final user = _supabase.auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User not authenticated');
      }

      // Sign in with current password to verify it
      try {
        await _supabase.auth.signInWithPassword(
          email: user.email!,
          password: currentPassword,
        );
      } catch (e) {
        throw Exception('Current password is incorrect');
      }

      // Update to new password
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));

      // Update must_change_password flag if it was set
      await _supabase
          .from('profiles')
          .update({'must_change_password': false})
          .eq('id', user.id);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}
