import 'package:admin_panel/features/shared/offers/data/services/offer_notification_service.dart';

class FakeOfferNotificationService extends OfferNotificationService {
  final List<Map<String, dynamic>> sentNotifications = [];
  bool shouldThrowError = false;
  String? errorMessage;

  // Pass a null SupabaseClient since we won't use it
  FakeOfferNotificationService() : super(null);

  void clear() {
    sentNotifications.clear();
    shouldThrowError = false;
    errorMessage = null;
  }

  void setError(String message) {
    shouldThrowError = true;
    errorMessage = message;
  }

  @override
  Future<void> sendOfferCreatedNotification({
    required String merchandiserId,
    required String offerTitle,
    required String offerDescription,
    required String offerId,
  }) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to send notification');
    }

    sentNotifications.add({
      'type': 'offer_created',
      'merchandiser_id': merchandiserId,
      'offer_title': offerTitle,
      'offer_description': offerDescription,
      'offer_id': offerId,
      'timestamp': DateTime.now(),
    });
  }

  @override
  Future<void> sendOfferUpdatedNotification({
    required String merchandiserId,
    required String offerTitle,
    required String offerId,
  }) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to send notification');
    }

    sentNotifications.add({
      'type': 'offer_updated',
      'merchandiser_id': merchandiserId,
      'offer_title': offerTitle,
      'offer_id': offerId,
      'timestamp': DateTime.now(),
    });
  }

  @override
  Future<void> sendOfferEndingSoonNotification({
    required String merchandiserId,
    required String offerTitle,
    required String offerId,
    required int hoursRemaining,
  }) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to send notification');
    }

    sentNotifications.add({
      'type': 'offer_ending_soon',
      'merchandiser_id': merchandiserId,
      'offer_title': offerTitle,
      'offer_id': offerId,
      'hours_remaining': hoursRemaining,
      'timestamp': DateTime.now(),
    });
  }

  // Helper methods for testing
  bool hasNotificationBeenSent({
    required String type,
    required String offerId,
  }) {
    return sentNotifications.any(
      (notification) =>
          notification['type'] == type && notification['offer_id'] == offerId,
    );
  }

  int getNotificationCount() => sentNotifications.length;

  Map<String, dynamic>? getLastNotification() {
    return sentNotifications.isEmpty ? null : sentNotifications.last;
  }
}
