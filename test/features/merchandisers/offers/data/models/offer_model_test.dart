import 'package:admin_panel/features/shared/offers/data/models/offer_model.dart';
import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OfferModel', () {
    group('Bundle Offer', () {
      test('should deserialize bundle offer from JSON correctly', () {
        // Arrange
        final jsonMap = {
          'id': 'offer_1',
          'merchandiser_id': 'merch_1',
          'title': {'en': 'Bundle Offer', 'ar': 'عرض حزمة'},
          'description': {'en': 'Great bundle deal', 'ar': 'صفقة حزمة رائعة'},
          'image_url': 'https://example.com/bundle.jpg',
          'type': 'bundle',
          'start_date': '2024-01-01T00:00:00.000Z',
          'end_date': '2024-12-31T23:59:59.999Z',
          'is_active': true,
          'sort_order': 1,
          'details': {
            'items': [
              {
                'product_id': 'prod_1',
                'quantity': 2,
                'product_name': 'Product 1',
                'product_image': 'https://example.com/prod1.jpg',
                'product_price': 50.0,
              },
              {
                'product_id': 'prod_2',
                'quantity': 1,
                'product_name': 'Product 2',
                'product_image': 'https://example.com/prod2.jpg',
                'product_price': 75.0,
              },
            ],
            'bundle_price': 150.0,
            'original_total_price': 175.0,
          },
        };

        // Act
        final model = OfferModel.fromJson(jsonMap);

        // Assert
        expect(model.id, 'offer_1');
        expect(model.merchandiserId, 'merch_1');
        expect(model.title['en'], 'Bundle Offer');
        expect(model.type, OfferType.bundle);
        expect(model.isActive, true);
        expect(model.sortOrder, 1);

        final details = model.details as BundleOfferDetails;
        expect(details.items.length, 2);
        expect(details.bundlePrice, 150.0);
        expect(details.originalTotalPrice, 175.0);
        expect(details.items[0].productName, 'Product 1');
      });

      test('should serialize bundle offer to JSON correctly', () {
        // Arrange
        final model = OfferModel(
          id: 'offer_1',
          merchandiserId: 'merch_1',
          title: const {'en': 'Bundle Offer', 'ar': 'عرض حزمة'},
          description: const {'en': 'Great deal', 'ar': 'صفقة رائعة'},
          imageUrl: 'https://example.com/bundle.jpg',
          type: OfferType.bundle,
          startDate: DateTime.parse('2024-01-01T00:00:00.000Z'),
          endDate: DateTime.parse('2024-12-31T23:59:59.999Z'),
          isActive: true,
          sortOrder: 1,
          details: const BundleOfferDetails(
            items: [
              BundleItem(
                productId: 'prod_1',
                quantity: 2,
                productName: 'Product 1',
                productImage: 'https://example.com/prod1.jpg',
                productPrice: 50.0,
              ),
            ],
            bundlePrice: 100.0,
            originalTotalPrice: 150.0,
          ),
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 'offer_1');
        expect(json['merchandiser_id'], 'merch_1');
        expect(json['type'], 'bundle');
        expect(json['is_active'], true);
        expect(json['details']['bundle_price'], 100.0);
        expect(json['details']['items'], isA<List>());
      });
    });

    group('BOGO Offer', () {
      test('should deserialize BOGO offer from JSON correctly', () {
        // Arrange
        final jsonMap = {
          'id': 'offer_2',
          'merchandiser_id': 'merch_1',
          'title': {'en': 'BOGO Offer'},
          'description': {'en': 'Buy 2 Get 1 Free'},
          'image_url': 'https://example.com/bogo.jpg',
          'type': 'bogo',
          'start_date': '2024-01-01T00:00:00.000Z',
          'end_date': '2024-12-31T23:59:59.999Z',
          'is_active': true,
          'sort_order': 2,
          'details': {
            'buy_product_id': 'prod_1',
            'buy_quantity': 2,
            'get_product_id': 'prod_2',
            'get_quantity': 1,
            'buy_product_name': 'Buy Product',
            'get_product_name': 'Free Product',
            'buy_product_image': 'https://example.com/buy.jpg',
            'get_product_image': 'https://example.com/get.jpg',
          },
        };

        // Act
        final model = OfferModel.fromJson(jsonMap);

        // Assert
        expect(model.type, OfferType.bogo);
        final details = model.details as BOGOOfferDetails;
        expect(details.buyProductId, 'prod_1');
        expect(details.buyQuantity, 2);
        expect(details.getProductId, 'prod_2');
        expect(details.getQuantity, 1);
      });

      test('should serialize BOGO offer to JSON correctly', () {
        // Arrange
        final model = OfferModel(
          id: 'offer_2',
          merchandiserId: 'merch_1',
          title: const {'en': 'BOGO'},
          description: const {'en': 'Buy 2 Get 1'},
          imageUrl: 'https://example.com/bogo.jpg',
          type: OfferType.bogo,
          startDate: DateTime.parse('2024-01-01T00:00:00.000Z'),
          endDate: DateTime.parse('2024-12-31T23:59:59.999Z'),
          isActive: true,
          sortOrder: 1,
          details: const BOGOOfferDetails(
            buyProductId: 'prod_1',
            buyQuantity: 2,
            getProductId: 'prod_2',
            getQuantity: 1,
            buyProductName: 'Buy Product',
            getProductName: 'Free Product',
            buyProductImage: 'https://example.com/buy.jpg',
            getProductImage: 'https://example.com/get.jpg',
          ),
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['type'], 'bogo');
        expect(json['details']['buy_product_id'], 'prod_1');
        expect(json['details']['get_quantity'], 1);
      });
    });

    group('Discount Offer', () {
      test('should deserialize product discount from JSON', () {
        // Arrange
        final jsonMap = {
          'id': 'offer_3',
          'merchandiser_id': 'merch_1',
          'title': {'en': 'Product Discount'},
          'description': {'en': '20% off'},
          'image_url': 'https://example.com/discount.jpg',
          'type': 'discount',
          'start_date': '2024-01-01T00:00:00.000Z',
          'end_date': '2024-12-31T23:59:59.999Z',
          'is_active': true,
          'sort_order': 3,
          'details': {
            'product_id': 'prod_1',
            'category_id': null,
            'sub_category_id': null,
            'discount_value': 20.0,
            'is_percentage': true,
            'max_discount_amount': 50.0,
            'min_purchase_amount': null,
          },
        };

        // Act
        final model = OfferModel.fromJson(jsonMap);

        // Assert
        expect(model.type, OfferType.discount);
        final details = model.details as DiscountOfferDetails;
        expect(details.productId, 'prod_1');
        expect(details.discountValue, 20.0);
        expect(details.isPercentage, true);
        expect(details.maxDiscountAmount, 50.0);
      });

      test('should deserialize category discount from JSON', () {
        // Arrange
        final jsonMap = {
          'id': 'offer_4',
          'merchandiser_id': 'merch_1',
          'title': {'en': 'Category Discount'},
          'description': {'en': 'Save on electronics'},
          'image_url': 'https://example.com/category.jpg',
          'type': 'discount',
          'start_date': '2024-01-01T00:00:00.000Z',
          'end_date': '2024-12-31T23:59:59.999Z',
          'is_active': true,
          'sort_order': 1,
          'details': {
            'product_id': null,
            'category_id': 'cat_1',
            'sub_category_id': null,
            'discount_value': 15.0,
            'is_percentage': true,
            'max_discount_amount': null,
            'min_purchase_amount': 100.0,
          },
        };

        // Act
        final model = OfferModel.fromJson(jsonMap);

        // Assert
        final details = model.details as DiscountOfferDetails;
        expect(details.categoryId, 'cat_1');
        expect(details.productId, null);
        expect(details.minPurchaseAmount, 100.0);
      });
    });

    group('MinPurchase Offer', () {
      test('should deserialize min purchase offer from JSON', () {
        // Arrange
        final jsonMap = {
          'id': 'offer_5',
          'merchandiser_id': 'merch_1',
          'title': {'en': 'Min Purchase Deal'},
          'description': {'en': 'Spend 100 get 10 off'},
          'image_url': 'https://example.com/minpurchase.jpg',
          'type': 'min_purchase',
          'start_date': '2024-01-01T00:00:00.000Z',
          'end_date': '2024-12-31T23:59:59.999Z',
          'is_active': true,
          'sort_order': 1,
          'details': {
            'min_purchase_amount': 100.0,
            'discount_value': 10.0,
            'is_percentage': false,
            'free_shipping': false,
          },
        };

        // Act
        final model = OfferModel.fromJson(jsonMap);

        // Assert
        expect(model.type, OfferType.minPurchase);
        final details = model.details as MinPurchaseOfferDetails;
        expect(details.minPurchaseAmount, 100.0);
        expect(details.discountValue, 10.0);
        expect(details.isPercentage, false);
        expect(details.freeShipping, false);
      });

      test('should serialize min purchase offer to JSON', () {
        // Arrange
        final model = OfferModel(
          id: 'offer_5',
          merchandiserId: 'merch_1',
          title: const {'en': 'Min Purchase'},
          description: const {'en': 'Description'},
          imageUrl: 'https://example.com/min.jpg',
          type: OfferType.minPurchase,
          startDate: DateTime.parse('2024-01-01T00:00:00.000Z'),
          endDate: DateTime.parse('2024-12-31T23:59:59.999Z'),
          isActive: true,
          sortOrder: 1,
          details: const MinPurchaseOfferDetails(
            minPurchaseAmount: 150.0,
            discountValue: 20.0,
            isPercentage: true,
            freeShipping: true,
          ),
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['type'], 'min_purchase');
        expect(json['details']['min_purchase_amount'], 150.0);
        expect(json['details']['free_shipping'], true);
      });
    });

    group('FreeItem Offer', () {
      test('should deserialize free item offer from JSON', () {
        // Arrange
        final jsonMap = {
          'id': 'offer_6',
          'merchandiser_id': 'merch_1',
          'title': {'en': 'Free Gift'},
          'description': {'en': 'Spend 200 get free item'},
          'image_url': 'https://example.com/freegift.jpg',
          'type': 'free_item',
          'start_date': '2024-01-01T00:00:00.000Z',
          'end_date': '2024-12-31T23:59:59.999Z',
          'is_active': true,
          'sort_order': 1,
          'details': {
            'min_purchase_amount': 200.0,
            'free_items': [
              {
                'product_id': 'free_1',
                'product_name': 'Free Product 1',
                'product_image': 'https://example.com/free1.jpg',
                'quantity': 1,
              },
              {
                'product_id': 'free_2',
                'product_name': 'Free Product 2',
                'product_image': 'https://example.com/free2.jpg',
                'quantity': 2,
              },
            ],
          },
        };

        // Act
        final model = OfferModel.fromJson(jsonMap);

        // Assert
        expect(model.type, OfferType.freeItem);
        final details = model.details as FreeItemOfferDetails;
        expect(details.minPurchaseAmount, 200.0);
        expect(details.freeItems.length, 2);
        expect(details.freeItems[0].productName, 'Free Product 1');
        expect(details.freeItems[1].quantity, 2);
      });

      test('should serialize free item offer to JSON', () {
        // Arrange
        final model = OfferModel(
          id: 'offer_6',
          merchandiserId: 'merch_1',
          title: const {'en': 'Free Gift'},
          description: const {'en': 'Description'},
          imageUrl: 'https://example.com/free.jpg',
          type: OfferType.freeItem,
          startDate: DateTime.parse('2024-01-01T00:00:00.000Z'),
          endDate: DateTime.parse('2024-12-31T23:59:59.999Z'),
          isActive: true,
          sortOrder: 1,
          details: const FreeItemOfferDetails(
            minPurchaseAmount: 250.0,
            freeItems: [
              FreeItemOption(
                productId: 'free_1',
                productName: 'Gift',
                productImage: 'https://example.com/gift.jpg',
                quantity: 1,
              ),
            ],
          ),
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['type'], 'free_item');
        expect(json['details']['min_purchase_amount'], 250.0);
        expect(json['details']['free_items'], isA<List>());
      });
    });

    test('should handle round-trip serialization for all offer types', () {
      // Test each offer type
      final offerTypes = [
        (
          'bundle',
          OfferType.bundle,
          const BundleOfferDetails(
            items: [],
            bundlePrice: 100.0,
            originalTotalPrice: 150.0,
          )
        ),
        (
          'bogo',
          OfferType.bogo,
          const BOGOOfferDetails(
            buyProductId: 'p1',
            buyQuantity: 1,
            getProductId: 'p2',
            getQuantity: 1,
            buyProductName: 'Buy',
            getProductName: 'Get',
            buyProductImage: 'buy.jpg',
            getProductImage: 'get.jpg',
          )
        ),
        (
          'discount',
          OfferType.discount,
          const DiscountOfferDetails(
            productId: 'p1',
            discountValue: 20.0,
            isPercentage: true,
          )
        ),
        (
          'min_purchase',
          OfferType.minPurchase,
          const MinPurchaseOfferDetails(
            minPurchaseAmount: 100.0,
            discountValue: 10.0,
            isPercentage: false,
          )
        ),
        (
          'free_item',
          OfferType.freeItem,
          const FreeItemOfferDetails(
            minPurchaseAmount: 200.0,
            freeItems: [],
          )
        ),
      ];

      for (final (typeStr, type, details) in offerTypes) {
        // Arrange
        final original = OfferModel(
          id: 'test_id',
          merchandiserId: 'merch_1',
          title: const {'en': 'Test'},
          description: const {'en': 'Test Desc'},
          imageUrl: 'https://example.com/image.jpg',
          type: type,
          startDate: DateTime.parse('2024-01-01T00:00:00.000Z'),
          endDate: DateTime.parse('2024-12-31T23:59:59.999Z'),
          isActive: true,
          sortOrder: 1,
          details: details,
        );

        // Act
        final json = original.toJson();
        final deserialized = OfferModel.fromJson(json);

        // Assert
        expect(deserialized.id, original.id);
        expect(deserialized.type, original.type);
        expect(deserialized.isActive, original.isActive);
      }
    });
  });
}
