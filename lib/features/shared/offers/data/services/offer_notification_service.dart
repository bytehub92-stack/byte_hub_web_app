// lib/features/shared/offers/data/services/offer_notification_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class OfferNotificationService {
  final SupabaseClient? _supabase;

  OfferNotificationService(this._supabase);

  /// Send notification to all customers of a merchandiser when a new offer is created
  Future<void> sendOfferCreatedNotification({
    required String merchandiserId,
    required String offerTitle,
    required String offerDescription,
    required String offerId,
  }) async {
    try {
      print('=== Starting Offer Notification ===');
      print('Merchandiser ID: $merchandiserId');

      // ✅ FIX: Query profiles table directly for customers linked to this merchandiser
      // We need to find customers who have orders or are associated with this merchandiser
      // Since you don't have a customers table, we'll send to ALL active customer profiles
      // You might want to refine this based on your business logic
      if (_supabase == null) return;
      final customersResponse = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_type', 'customer')
          .eq('is_active', true);

      print('Query response: $customersResponse');

      final customerProfileIds =
          (customersResponse as List).map((e) => e['id'] as String).toList();

      print('Found ${customerProfileIds.length} active customers');

      if (customerProfileIds.isEmpty) {
        print('No active customers found');
        return;
      }

      // Create notifications for all customers
      final notifications = customerProfileIds.map((profileId) {
        return {
          'user_id': profileId,
          'title': {'en': 'New Offer Available! 🎉', 'ar': 'عرض جديد متاح! 🎉'},
          'body': {'en': offerTitle, 'ar': offerDescription},
          'type': 'offer',
          'reference_id': offerId,
          'is_read': false,
        };
      }).toList();

      print('Inserting ${notifications.length} notifications...');

      // Insert notifications in batches of 1000
      const batchSize = 1000;
      for (var i = 0; i < notifications.length; i += batchSize) {
        final end = (i + batchSize < notifications.length)
            ? i + batchSize
            : notifications.length;
        final batch = notifications.sublist(i, end);
        await _supabase.from('notifications').insert(batch);
        print('Batch ${i ~/ batchSize + 1} inserted');
      }

      print(
        'Sent offer notification to ${customerProfileIds.length} customers',
      );
    } catch (e) {
      print('Error sending offer notification: $e');
      // Don't throw - we don't want to fail the offer creation if notification fails
    }
  }

  /// Send notification when an offer is updated (optional)
  Future<void> sendOfferUpdatedNotification({
    required String merchandiserId,
    required String offerTitle,
    required String offerId,
  }) async {
    try {
      if (_supabase == null) return;
      // Send to all active customers
      final customersResponse = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_type', 'customer')
          .eq('is_active', true);

      final customerProfileIds =
          (customersResponse as List).map((e) => e['id'] as String).toList();

      if (customerProfileIds.isEmpty) return;

      final notifications = customerProfileIds.map((profileId) {
        return {
          'user_id': profileId,
          'title': {'en': 'Offer Updated', 'ar': 'تم تحديث العرض'},
          'body': {
            'en': '$offerTitle has been updated. Check it out!',
            'ar': 'تم تحديث $offerTitle. تحقق منه!',
          },
          'type': 'offer',
          'reference_id': offerId,
          'is_read': false,
        };
      }).toList();

      const batchSize = 1000;
      for (var i = 0; i < notifications.length; i += batchSize) {
        final end = (i + batchSize < notifications.length)
            ? i + batchSize
            : notifications.length;
        final batch = notifications.sublist(i, end);
        await _supabase.from('notifications').insert(batch);
      }
    } catch (e) {
      print('Error sending offer update notification: $e');
    }
  }

  /// Send notification when an offer is ending soon
  Future<void> sendOfferEndingSoonNotification({
    required String merchandiserId,
    required String offerTitle,
    required String offerId,
    required int hoursRemaining,
  }) async {
    try {
      if (_supabase == null) return;
      final customersResponse = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_type', 'customer')
          .eq('is_active', true);

      final customerProfileIds =
          (customersResponse as List).map((e) => e['id'] as String).toList();

      if (customerProfileIds.isEmpty) return;

      final notifications = customerProfileIds.map((profileId) {
        return {
          'user_id': profileId,
          'title': {
            'en': '⏰ Offer Ending Soon!',
            'ar': '⏰ العرض ينتهي قريباً!',
          },
          'body': {
            'en': '$offerTitle ends in $hoursRemaining hours. Don\'t miss out!',
            'ar': '$offerTitle ينتهي في $hoursRemaining ساعة. لا تفوت الفرصة!',
          },
          'type': 'offer',
          'reference_id': offerId,
          'is_read': false,
        };
      }).toList();

      const batchSize = 1000;
      for (var i = 0; i < notifications.length; i += batchSize) {
        final end = (i + batchSize < notifications.length)
            ? i + batchSize
            : notifications.length;
        final batch = notifications.sublist(i, end);
        await _supabase.from('notifications').insert(batch);
      }
    } catch (e) {
      print('Error sending offer ending notification: $e');
    }
  }
}
