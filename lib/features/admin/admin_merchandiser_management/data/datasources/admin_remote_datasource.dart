import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/helpers/jsonb_helper.dart';
import '../../domain/entities/create_merchandiser_request.dart';
import '../models/merchandiser_model.dart';

abstract class AdminMerchandiserManagementRemoteDataSource {
  Future<List<MerchandiserModel>> getMerchandisers();
  Future<MerchandiserModel> getMerchandiserById(String id);
  Future<String> createMerchandiser(CreateMerchandiserRequest request);
  Future<void> updateMerchandiserStatus(String id, bool isActive);
}

class MerchandiserRemoteDataSourceImpl
    implements AdminMerchandiserManagementRemoteDataSource {
  final SupabaseClient supabaseClient;

  MerchandiserRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<MerchandiserModel>> getMerchandisers() async {
    try {
      final response = await supabaseClient
          .from('merchandiser_details_view')
          .select()
          .order('created_at', ascending: false);

      return response
          .map<MerchandiserModel>((json) => MerchandiserModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to fetch merchandisers: ${e.message}',
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<MerchandiserModel> getMerchandiserById(String merchandiserId) async {
    try {
      final response = await supabaseClient
          .from('merchandiser_details_view')
          .select()
          .eq('id', merchandiserId)
          .single();

      return MerchandiserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to fetch merchandiser: ${e.message}',
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<String> createMerchandiser(CreateMerchandiserRequest request) async {
    try {
      // Generate temporary password
      final tempPassword = _generateTempPassword();
      // Create auth user
      final authResponse = await supabaseClient.auth.signUp(
        email: request.email,
        password: tempPassword,
        data: {'full_name': request.fullName, 'user_type': 'merchandiser'},
      );
      await supabaseClient.rpc(
        'confirm_user_email',
        params: {'user_email': request.email},
      );
      if (authResponse.user == null) {
        throw ServerException(message: 'Failed to create auth user');
      }
      // Update profile
      await supabaseClient.from('profiles').update({
        'user_type': 'merchandiser',
        'is_approved': true,
        'must_change_password': true,
        'phone_number': request.phoneNumber,
        'email_verified': true,
      }).eq('id', authResponse.user!.id);
      // Create merchandiser record
      await supabaseClient.from('merchandisers').insert({
        'profile_id': authResponse.user!.id,
        'business_name': JsonbHelper.createBilingualJson(
          request.businessName,
          arabicValue: request.businessNameArabic,
        ),
        'business_type': JsonbHelper.createBilingualJson(
          request.businessType,
          arabicValue: request.businessTypeArabic,
        ),
        'description': JsonbHelper.createBilingualJson(
          request.description,
          arabicValue: request.descriptionArabic,
        ),
      });
      return tempPassword;
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateMerchandiserStatus(String id, bool isActive) async {
    try {
      // First, get the profile_id from the merchandiser
      final merchandiserResponse = await supabaseClient
          .from('merchandisers')
          .select('profile_id')
          .eq('id', id)
          .single();

      final profileId = merchandiserResponse['profile_id'] as String;

      // Update the is_active status in the profiles table
      await supabaseClient
          .from('profiles')
          .update({'is_active': isActive}).eq('id', profileId);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to update status: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  String _generateTempPassword() {
    return 'Temp${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}!';
  }
}
