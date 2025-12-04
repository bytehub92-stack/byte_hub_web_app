import 'package:admin_panel/features/shared/offers/data/datasource/offers_remote_datasource.dart';
import 'package:admin_panel/features/shared/offers/data/models/offer_model.dart';

class FakeOffersRemoteDataSource implements OffersRemoteDataSource {
  final List<OfferModel> _offers = [];
  bool shouldThrowError = false;
  String? errorMessage;

  // Helper method to add test data
  void addOffer(OfferModel offer) {
    _offers.add(offer);
  }

  // Helper method to clear all offers
  void clear() {
    _offers.clear();
    shouldThrowError = false;
    errorMessage = null;
  }

  // Helper to simulate errors
  void setError(String message) {
    shouldThrowError = true;
    errorMessage = message;
  }

  @override
  Future<List<OfferModel>> getOffers() async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get offers');
    }

    // Return sorted by sortOrder
    final sortedOffers = List<OfferModel>.from(_offers);
    sortedOffers.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sortedOffers;
  }

  @override
  Future<OfferModel> getOfferById(String offerId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to get offer');
    }

    try {
      return _offers.firstWhere((offer) => offer.id == offerId);
    } catch (e) {
      throw Exception('Offer not found');
    }
  }

  @override
  Future<void> createOffer(OfferModel offer) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to create offer');
    }

    // Check if offer with same ID already exists
    if (_offers.any((o) => o.id == offer.id)) {
      throw Exception('Offer with ID ${offer.id} already exists');
    }

    _offers.add(offer);
  }

  @override
  Future<void> updateOffer(OfferModel offer) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to update offer');
    }

    final index = _offers.indexWhere((o) => o.id == offer.id);
    if (index == -1) {
      throw Exception('Offer not found');
    }

    _offers[index] = offer;
  }

  @override
  Future<void> deleteOffer(String offerId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to delete offer');
    }

    final initialLength = _offers.length;
    _offers.removeWhere((o) => o.id == offerId);

    if (_offers.length == initialLength) {
      throw Exception('Offer not found');
    }
  }

  @override
  Future<void> toggleOfferStatus(String offerId, bool isActive) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Failed to toggle offer status');
    }

    final index = _offers.indexWhere((o) => o.id == offerId);
    if (index == -1) {
      throw Exception('Offer not found');
    }

    final offer = _offers[index];
    _offers[index] = OfferModel(
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
  }
}
