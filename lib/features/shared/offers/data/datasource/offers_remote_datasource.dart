// lib/features/offers/data/datasources/offers_remote_datasource.dart
import 'package:admin_panel/core/services/auth_service.dart';
import 'package:admin_panel/features/shared/offers/data/models/offer_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class OffersRemoteDataSource {
  Future<List<OfferModel>> getOffers();
  Future<OfferModel> getOfferById(String offerId);
  Future<void> createOffer(OfferModel offer);
  Future<void> updateOffer(OfferModel offer);
  Future<void> deleteOffer(String offerId);
  Future<void> toggleOfferStatus(String offerId, bool isActive);
}

class OffersRemoteDataSourceImpl implements OffersRemoteDataSource {
  final SupabaseClient supabaseClient;
  final AuthService authService;

  OffersRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.authService,
  });

  Future<String> get _merchandiserId async {
    final id = await authService.getMerchandiserId();
    if (id == null) throw Exception('Merchandiser ID not found');
    return id;
  }

  @override
  Future<List<OfferModel>> getOffers() async {
    try {
      final merchandiserId = await _merchandiserId;

      // Get offers from app_settings table
      final response = await supabaseClient
          .from('app_settings')
          .select('setting_value')
          .eq('merchandiser_id', merchandiserId)
          .eq('setting_key', 'active_offers')
          .maybeSingle();

      if (response == null || response['setting_value'] == null) {
        return [];
      }

      final offersList = response['setting_value'] as List;
      return offersList.map((json) => OfferModel.fromJson(json)).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    } catch (e) {
      print('OffersDataSource: Error loading offers: $e');
      rethrow;
    }
  }

  @override
  Future<OfferModel> getOfferById(String offerId) async {
    try {
      final offers = await getOffers();
      return offers.firstWhere(
        (offer) => offer.id == offerId,
        orElse: () => throw Exception('Offer not found'),
      );
    } catch (e) {
      print('OffersDataSource: Error loading offer: $e');
      rethrow;
    }
  }

  @override
  Future<void> createOffer(OfferModel offer) async {
    try {
      final merchandiserId = await _merchandiserId;

      // Get existing offers
      final existingOffers = await getOffers();

      // Add new offer
      final updatedOffers = [...existingOffers, offer];

      // Convert to JSON
      final offersJson = updatedOffers
          .map(
            (o) => OfferModel(
              id: o.id,
              merchandiserId: o.merchandiserId,
              title: o.title,
              description: o.description,
              imageUrl: o.imageUrl,
              type: o.type,
              startDate: o.startDate,
              endDate: o.endDate,
              isActive: o.isActive,
              sortOrder: o.sortOrder,
              details: o.details,
            ).toJson(),
          )
          .toList();

      // Check if record exists first
      final existingRecord = await supabaseClient
          .from('app_settings')
          .select('id')
          .eq('merchandiser_id', merchandiserId)
          .eq('setting_key', 'active_offers')
          .maybeSingle();

      if (existingRecord != null) {
        // Record exists - UPDATE it
        await supabaseClient
            .from('app_settings')
            .update({
              'setting_value': offersJson,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('merchandiser_id', merchandiserId)
            .eq('setting_key', 'active_offers');
      } else {
        // Record doesn't exist - INSERT it
        await supabaseClient.from('app_settings').insert({
          'merchandiser_id': merchandiserId,
          'setting_key': 'active_offers',
          'setting_value': offersJson,
          'description': {
            'en': 'Active promotional offers',
            'ar': 'العروض الترويجية النشطة',
          },
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('OffersDataSource: Error creating offer: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateOffer(OfferModel offer) async {
    try {
      final merchandiserId = await _merchandiserId;

      // Get existing offers
      final existingOffers = await getOffers();

      // Update the offer
      final updatedOffers = existingOffers.map((o) {
        if (o.id == offer.id) {
          return offer;
        }
        return o;
      }).toList();

      // Convert to JSON
      final offersJson = updatedOffers
          .map(
            (o) => OfferModel(
              id: o.id,
              merchandiserId: o.merchandiserId,
              title: o.title,
              description: o.description,
              imageUrl: o.imageUrl,
              type: o.type,
              startDate: o.startDate,
              endDate: o.endDate,
              isActive: o.isActive,
              sortOrder: o.sortOrder,
              details: o.details,
            ).toJson(),
          )
          .toList();

      // Update in app_settings
      await supabaseClient
          .from('app_settings')
          .update({
            'setting_value': offersJson,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .match({
            'merchandiser_id': merchandiserId,
            'setting_key': 'active_offers',
          });
    } catch (e) {
      print('OffersDataSource: Error updating offer: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteOffer(String offerId) async {
    try {
      final merchandiserId = await _merchandiserId;

      // Get existing offers
      final existingOffers = await getOffers();

      // Remove the offer
      final updatedOffers = existingOffers
          .where((o) => o.id != offerId)
          .toList();

      // Convert to JSON
      final offersJson = updatedOffers
          .map(
            (o) => OfferModel(
              id: o.id,
              merchandiserId: o.merchandiserId,
              title: o.title,
              description: o.description,
              imageUrl: o.imageUrl,
              type: o.type,
              startDate: o.startDate,
              endDate: o.endDate,
              isActive: o.isActive,
              sortOrder: o.sortOrder,
              details: o.details,
            ).toJson(),
          )
          .toList();

      // Update in app_settings
      await supabaseClient
          .from('app_settings')
          .update({
            'setting_value': offersJson,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .match({
            'merchandiser_id': merchandiserId,
            'setting_key': 'active_offers',
          });
    } catch (e) {
      print('OffersDataSource: Error deleting offer: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleOfferStatus(String offerId, bool isActive) async {
    try {
      final offer = await getOfferById(offerId);
      final updatedOffer = OfferModel(
        id: offer.id,
        merchandiserId: offer.merchandiserId,
        title: offer.title,
        description: offer.description,
        imageUrl: offer.imageUrl,
        type: offer.type,
        startDate: offer.startDate,
        endDate: offer.endDate,
        isActive: isActive,
        sortOrder: offer.sortOrder,
        details: offer.details,
      );
      await updateOffer(updatedOffer);
    } catch (e) {
      print('OffersDataSource: Error toggling offer status: $e');
      rethrow;
    }
  }
}
