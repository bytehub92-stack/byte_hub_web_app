import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Offer Entity', () {
    test('should create offer with all properties', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 12, 31);
      final details = const BundleOfferDetails(
        items: [],
        bundlePrice: 100.0,
        originalTotalPrice: 150.0,
      );

      // Act
      final offer = Offer(
        id: '1',
        merchandiserId: 'merch_1',
        title: {'en': 'Test Offer', 'ar': 'عرض تجريبي'},
        description: {'en': 'Description', 'ar': 'وصف'},
        imageUrl: 'https://example.com/image.jpg',
        type: OfferType.bundle,
        startDate: startDate,
        endDate: endDate,
        isActive: true,
        sortOrder: 1,
        details: details,
      );

      // Assert
      expect(offer.id, '1');
      expect(offer.merchandiserId, 'merch_1');
      expect(offer.title['en'], 'Test Offer');
      expect(offer.title['ar'], 'عرض تجريبي');
      expect(offer.type, OfferType.bundle);
      expect(offer.isActive, true);
      expect(offer.sortOrder, 1);
      expect(offer.details, details);
    });

    test('getTitle should return correct locale or fallback to en', () {
      // Arrange
      final offer = Offer(
        id: '1',
        merchandiserId: 'merch_1',
        title: {'en': 'English Title', 'ar': 'عنوان عربي'},
        description: {'en': 'Description'},
        imageUrl: 'https://example.com/image.jpg',
        type: OfferType.bundle,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
        sortOrder: 1,
        details: const BundleOfferDetails(
          items: [],
          bundlePrice: 100.0,
          originalTotalPrice: 150.0,
        ),
      );

      // Assert
      expect(offer.getTitle('en'), 'English Title');
      expect(offer.getTitle('ar'), 'عنوان عربي');
      expect(offer.getTitle('fr'), 'English Title'); // Falls back to en
    });

    test('getDescription should return correct locale or fallback', () {
      // Arrange
      final offer = Offer(
        id: '1',
        merchandiserId: 'merch_1',
        title: {'en': 'Title'},
        description: {'en': 'English Desc', 'ar': 'وصف عربي'},
        imageUrl: 'https://example.com/image.jpg',
        type: OfferType.bundle,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
        sortOrder: 1,
        details: const BundleOfferDetails(
          items: [],
          bundlePrice: 100.0,
          originalTotalPrice: 150.0,
        ),
      );

      // Assert
      expect(offer.getDescription('en'), 'English Desc');
      expect(offer.getDescription('ar'), 'وصف عربي');
      expect(offer.getDescription('es'), 'English Desc');
    });

    test('copyWith should create new instance with updated values', () {
      // Arrange
      final original = Offer(
        id: '1',
        merchandiserId: 'merch_1',
        title: {'en': 'Original'},
        description: {'en': 'Original Desc'},
        imageUrl: 'https://example.com/original.jpg',
        type: OfferType.bundle,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        isActive: true,
        sortOrder: 1,
        details: const BundleOfferDetails(
          items: [],
          bundlePrice: 100.0,
          originalTotalPrice: 150.0,
        ),
      );

      // Act
      final updated = original.copyWith(
        title: {'en': 'Updated'},
        isActive: false,
        sortOrder: 2,
      );

      // Assert
      expect(updated.id, original.id); // Unchanged
      expect(updated.merchandiserId, original.merchandiserId); // Unchanged
      expect(updated.title['en'], 'Updated'); // Changed
      expect(updated.isActive, false); // Changed
      expect(updated.sortOrder, 2); // Changed
      expect(updated.imageUrl, original.imageUrl); // Unchanged
    });

    test('two offers with same properties should be equal', () {
      // Arrange
      final details = const BundleOfferDetails(
        items: [],
        bundlePrice: 100.0,
        originalTotalPrice: 150.0,
      );

      final offer1 = Offer(
        id: '1',
        merchandiserId: 'merch_1',
        title: {'en': 'Test'},
        description: {'en': 'Desc'},
        imageUrl: 'https://example.com/image.jpg',
        type: OfferType.bundle,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        isActive: true,
        sortOrder: 1,
        details: details,
      );

      final offer2 = Offer(
        id: '1',
        merchandiserId: 'merch_1',
        title: {'en': 'Test'},
        description: {'en': 'Desc'},
        imageUrl: 'https://example.com/image.jpg',
        type: OfferType.bundle,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        isActive: true,
        sortOrder: 1,
        details: details,
      );

      // Assert
      expect(offer1, equals(offer2));
    });
  });

  group('BundleOfferDetails', () {
    test('should calculate savings correctly', () {
      // Arrange
      final details = const BundleOfferDetails(
        items: [],
        bundlePrice: 100.0,
        originalTotalPrice: 150.0,
      );

      // Assert
      expect(details.savingsAmount, 50.0);
      expect(details.savingsPercentage, closeTo(33.33, 0.01));
    });

    test('should handle zero original price', () {
      // Arrange
      const details = BundleOfferDetails(
        items: [],
        bundlePrice: 0.0,
        originalTotalPrice: 0.0,
      );

      // Assert
      expect(details.savingsAmount, 0.0);
      expect(details.savingsPercentage.isNaN, true);
    });

    test('BundleItem should have correct properties', () {
      // Arrange
      const item = BundleItem(
        productId: 'prod_1',
        quantity: 2,
        productName: 'Product 1',
        productImage: 'https://example.com/product.jpg',
        productPrice: 50.0,
      );

      // Assert
      expect(item.productId, 'prod_1');
      expect(item.quantity, 2);
      expect(item.productName, 'Product 1');
      expect(item.productPrice, 50.0);
    });
  });

  group('BOGOOfferDetails', () {
    test('should create BOGO offer with all properties', () {
      // Arrange
      const bogo = BOGOOfferDetails(
        buyProductId: 'prod_1',
        buyQuantity: 2,
        getProductId: 'prod_2',
        getQuantity: 1,
        buyProductName: 'Buy Product',
        getProductName: 'Free Product',
        buyProductImage: 'https://example.com/buy.jpg',
        getProductImage: 'https://example.com/get.jpg',
      );

      // Assert
      expect(bogo.buyProductId, 'prod_1');
      expect(bogo.buyQuantity, 2);
      expect(bogo.getProductId, 'prod_2');
      expect(bogo.getQuantity, 1);
      expect(bogo.buyProductName, 'Buy Product');
      expect(bogo.getProductName, 'Free Product');
    });
  });

  group('DiscountOfferDetails', () {
    test('should identify product-specific discount', () {
      // Arrange
      const discount = DiscountOfferDetails(
        productId: 'prod_1',
        discountValue: 20.0,
        isPercentage: true,
      );

      // Assert
      expect(discount.isProductSpecific, true);
      expect(discount.isCategorySpecific, false);
      expect(discount.isSubCategorySpecific, false);
    });

    test('should identify category-specific discount', () {
      // Arrange
      const discount = DiscountOfferDetails(
        categoryId: 'cat_1',
        discountValue: 15.0,
        isPercentage: true,
      );

      // Assert
      expect(discount.isProductSpecific, false);
      expect(discount.isCategorySpecific, true);
      expect(discount.isSubCategorySpecific, false);
    });

    test('should identify sub-category-specific discount', () {
      // Arrange
      const discount = DiscountOfferDetails(
        subCategoryId: 'sub_1',
        discountValue: 10.0,
        isPercentage: false,
      );

      // Assert
      expect(discount.isProductSpecific, false);
      expect(discount.isCategorySpecific, false);
      expect(discount.isSubCategorySpecific, true);
    });

    test('should handle percentage discount with limits', () {
      // Arrange
      const discount = DiscountOfferDetails(
        productId: 'prod_1',
        discountValue: 20.0,
        isPercentage: true,
        maxDiscountAmount: 50.0,
        minPurchaseAmount: 100.0,
      );

      // Assert
      expect(discount.discountValue, 20.0);
      expect(discount.isPercentage, true);
      expect(discount.maxDiscountAmount, 50.0);
      expect(discount.minPurchaseAmount, 100.0);
    });
  });

  group('MinPurchaseOfferDetails', () {
    test('should calculate percentage discount correctly', () {
      // Arrange
      const details = MinPurchaseOfferDetails(
        minPurchaseAmount: 100.0,
        discountValue: 10.0,
        isPercentage: true,
      );

      // Act & Assert
      expect(details.calculateDiscount(50.0), 0.0); // Below minimum
      expect(details.calculateDiscount(150.0), 15.0); // 10% of 150
      expect(details.calculateDiscount(200.0), 20.0); // 10% of 200
    });

    test('should calculate fixed discount correctly', () {
      // Arrange
      const details = MinPurchaseOfferDetails(
        minPurchaseAmount: 100.0,
        discountValue: 25.0,
        isPercentage: false,
      );

      // Act & Assert
      expect(details.calculateDiscount(50.0), 0.0); // Below minimum
      expect(details.calculateDiscount(150.0), 25.0); // Fixed amount
      expect(details.calculateDiscount(200.0), 25.0); // Fixed amount
    });

    test('should return zero when no discount value provided', () {
      // Arrange
      const details = MinPurchaseOfferDetails(
        minPurchaseAmount: 100.0,
        freeShipping: true,
      );

      // Act & Assert
      expect(details.calculateDiscount(150.0), 0.0);
    });

    test('should handle free shipping option', () {
      // Arrange
      const details = MinPurchaseOfferDetails(
        minPurchaseAmount: 100.0,
        freeShipping: true,
      );

      // Assert
      expect(details.freeShipping, true);
      expect(details.discountValue, null);
    });
  });

  group('FreeItemOfferDetails', () {
    test('should create free item offer with options', () {
      // Arrange
      const freeItems = [
        FreeItemOption(
          productId: 'prod_1',
          productName: 'Free Product 1',
          productImage: 'https://example.com/free1.jpg',
          quantity: 1,
        ),
        FreeItemOption(
          productId: 'prod_2',
          productName: 'Free Product 2',
          productImage: 'https://example.com/free2.jpg',
          quantity: 2,
        ),
      ];

      const details = FreeItemOfferDetails(
        minPurchaseAmount: 200.0,
        freeItems: freeItems,
      );

      // Assert
      expect(details.minPurchaseAmount, 200.0);
      expect(details.freeItems.length, 2);
      expect(details.freeItems[0].productName, 'Free Product 1');
      expect(details.freeItems[1].quantity, 2);
    });
  });
}
