import 'package:admin_panel/features/shared/offers/data/models/offer_model.dart';
import 'package:admin_panel/features/shared/offers/domain/entities/offer.dart';

/// Helper class to generate test data for offers
class OfferTestData {
  // Sample Bundle Offer
  static OfferModel bundleOffer({
    String id = 'bundle_1',
    String merchandiserId = 'merch_1',
    bool isActive = true,
    int sortOrder = 1,
  }) {
    return OfferModel(
      id: id,
      merchandiserId: merchandiserId,
      title: const {
        'en': 'Summer Bundle Deal',
        'ar': 'صفقة حزمة الصيف',
      },
      description: const {
        'en': 'Get 3 items for the price of 2',
        'ar': 'احصل على 3 منتجات بسعر 2',
      },
      imageUrl: 'https://example.com/bundle.jpg',
      type: OfferType.bundle,
      startDate: DateTime(2024, 6, 1),
      endDate: DateTime(2024, 8, 31),
      isActive: isActive,
      sortOrder: sortOrder,
      details: const BundleOfferDetails(
        items: [
          BundleItem(
            productId: 'prod_1',
            quantity: 1,
            productName: 'Product A',
            productImage: 'https://example.com/prod_a.jpg',
            productPrice: 50.0,
          ),
          BundleItem(
            productId: 'prod_2',
            quantity: 1,
            productName: 'Product B',
            productImage: 'https://example.com/prod_b.jpg',
            productPrice: 60.0,
          ),
          BundleItem(
            productId: 'prod_3',
            quantity: 1,
            productName: 'Product C',
            productImage: 'https://example.com/prod_c.jpg',
            productPrice: 40.0,
          ),
        ],
        bundlePrice: 120.0,
        originalTotalPrice: 150.0,
      ),
    );
  }

  // Sample BOGO Offer
  static OfferModel bogoOffer({
    String id = 'bogo_1',
    String merchandiserId = 'merch_1',
    bool isActive = true,
    int sortOrder = 1,
  }) {
    return OfferModel(
      id: id,
      merchandiserId: merchandiserId,
      title: const {
        'en': 'Buy 2 Get 1 Free',
        'ar': 'اشتري 2 واحصل على 1 مجانا',
      },
      description: const {
        'en': 'Buy 2 beverages and get 1 free',
        'ar': 'اشتر 2 من المشروبات واحصل على 1 مجانا',
      },
      imageUrl: 'https://example.com/bogo.jpg',
      type: OfferType.bogo,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 12, 31),
      isActive: isActive,
      sortOrder: sortOrder,
      details: const BOGOOfferDetails(
        buyProductId: 'prod_drink_1',
        buyQuantity: 2,
        getProductId: 'prod_drink_2',
        getQuantity: 1,
        buyProductName: 'Cola',
        getProductName: 'Juice',
        buyProductImage: 'https://example.com/cola.jpg',
        getProductImage: 'https://example.com/juice.jpg',
      ),
    );
  }

  // Sample Product Discount Offer
  static OfferModel productDiscountOffer({
    String id = 'discount_1',
    String merchandiserId = 'merch_1',
    bool isActive = true,
    int sortOrder = 1,
  }) {
    return OfferModel(
      id: id,
      merchandiserId: merchandiserId,
      title: const {
        'en': '20% Off Electronics',
        'ar': 'خصم 20٪ على الإلكترونيات',
      },
      description: const {
        'en': 'Save 20% on all electronic items',
        'ar': 'وفر 20٪ على جميع الأجهزة الإلكترونية',
      },
      imageUrl: 'https://example.com/electronics.jpg',
      type: OfferType.discount,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 3, 31),
      isActive: isActive,
      sortOrder: sortOrder,
      details: const DiscountOfferDetails(
        productId: 'prod_phone',
        categoryId: null,
        subCategoryId: null,
        discountValue: 20.0,
        isPercentage: true,
        maxDiscountAmount: 100.0,
        minPurchaseAmount: null,
      ),
    );
  }

  // Sample Category Discount Offer
  static OfferModel categoryDiscountOffer({
    String id = 'discount_cat_1',
    String merchandiserId = 'merch_1',
    bool isActive = true,
    int sortOrder = 1,
  }) {
    return OfferModel(
      id: id,
      merchandiserId: merchandiserId,
      title: const {
        'en': '15% Off Groceries',
        'ar': 'خصم 15٪ على البقالة',
      },
      description: const {
        'en': 'Get 15% discount on all grocery items',
        'ar': 'احصل على خصم 15٪ على جميع منتجات البقالة',
      },
      imageUrl: 'https://example.com/groceries.jpg',
      type: OfferType.discount,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 12, 31),
      isActive: isActive,
      sortOrder: sortOrder,
      details: const DiscountOfferDetails(
        productId: null,
        categoryId: 'cat_groceries',
        subCategoryId: null,
        discountValue: 15.0,
        isPercentage: true,
        maxDiscountAmount: 50.0,
        minPurchaseAmount: 100.0,
      ),
    );
  }

  // Sample Min Purchase Offer
  static OfferModel minPurchaseOffer({
    String id = 'minpurchase_1',
    String merchandiserId = 'merch_1',
    bool isActive = true,
    int sortOrder = 1,
  }) {
    return OfferModel(
      id: id,
      merchandiserId: merchandiserId,
      title: const {
        'en': 'Spend 100 Save 10',
        'ar': 'أنفق 100 واحفظ 10',
      },
      description: const {
        'en': 'Spend 100 EGP or more and get 10 EGP off',
        'ar': 'أنفق 100 جنيه أو أكثر واحصل على خصم 10 جنيه',
      },
      imageUrl: 'https://example.com/minpurchase.jpg',
      type: OfferType.minPurchase,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 12, 31),
      isActive: isActive,
      sortOrder: sortOrder,
      details: const MinPurchaseOfferDetails(
        minPurchaseAmount: 100.0,
        discountValue: 10.0,
        isPercentage: false,
        freeShipping: false,
      ),
    );
  }

  // Sample Free Shipping Offer
  static OfferModel freeShippingOffer({
    String id = 'freeship_1',
    String merchandiserId = 'merch_1',
    bool isActive = true,
    int sortOrder = 1,
  }) {
    return OfferModel(
      id: id,
      merchandiserId: merchandiserId,
      title: const {
        'en': 'Free Shipping on Orders Over 200',
        'ar': 'شحن مجاني للطلبات التي تزيد عن 200',
      },
      description: const {
        'en': 'Get free shipping when you spend 200 EGP or more',
        'ar': 'احصل على شحن مجاني عند إنفاق 200 جنيه أو أكثر',
      },
      imageUrl: 'https://example.com/freeship.jpg',
      type: OfferType.minPurchase,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 12, 31),
      isActive: isActive,
      sortOrder: sortOrder,
      details: const MinPurchaseOfferDetails(
        minPurchaseAmount: 200.0,
        discountValue: null,
        isPercentage: null,
        freeShipping: true,
      ),
    );
  }

  // Sample Free Item Offer
  static OfferModel freeItemOffer({
    String id = 'freeitem_1',
    String merchandiserId = 'merch_1',
    bool isActive = true,
    int sortOrder = 1,
  }) {
    return OfferModel(
      id: id,
      merchandiserId: merchandiserId,
      title: const {
        'en': 'Free Gift with Purchase',
        'ar': 'هدية مجانية مع الشراء',
      },
      description: const {
        'en': 'Spend 150 EGP and choose a free gift',
        'ar': 'أنفق 150 جنيه واختر هدية مجانية',
      },
      imageUrl: 'https://example.com/freegift.jpg',
      type: OfferType.freeItem,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 12, 31),
      isActive: isActive,
      sortOrder: sortOrder,
      details: const FreeItemOfferDetails(
        minPurchaseAmount: 150.0,
        freeItems: [
          FreeItemOption(
            productId: 'free_1',
            productName: 'Tote Bag',
            productImage: 'https://example.com/bag.jpg',
            quantity: 1,
          ),
          FreeItemOption(
            productId: 'free_2',
            productName: 'Water Bottle',
            productImage: 'https://example.com/bottle.jpg',
            quantity: 1,
          ),
          FreeItemOption(
            productId: 'free_3',
            productName: 'Keychain',
            productImage: 'https://example.com/keychain.jpg',
            quantity: 2,
          ),
        ],
      ),
    );
  }

  // Get a list of all sample offers
  static List<OfferModel> allSampleOffers({String merchandiserId = 'merch_1'}) {
    return [
      bundleOffer(merchandiserId: merchandiserId, sortOrder: 1),
      bogoOffer(merchandiserId: merchandiserId, sortOrder: 2),
      productDiscountOffer(merchandiserId: merchandiserId, sortOrder: 3),
      categoryDiscountOffer(merchandiserId: merchandiserId, sortOrder: 4),
      minPurchaseOffer(merchandiserId: merchandiserId, sortOrder: 5),
      freeShippingOffer(merchandiserId: merchandiserId, sortOrder: 6),
      freeItemOffer(merchandiserId: merchandiserId, sortOrder: 7),
    ];
  }

  // Get active offers only
  static List<OfferModel> activeOffers({String merchandiserId = 'merch_1'}) {
    return allSampleOffers(merchandiserId: merchandiserId)
        .where((offer) => offer.isActive)
        .toList();
  }

  // Get inactive offers
  static List<OfferModel> inactiveOffers({String merchandiserId = 'merch_1'}) {
    return [
      bundleOffer(
        id: 'inactive_1',
        merchandiserId: merchandiserId,
        isActive: false,
        sortOrder: 10,
      ),
      bogoOffer(
        id: 'inactive_2',
        merchandiserId: merchandiserId,
        isActive: false,
        sortOrder: 11,
      ),
    ];
  }

  // Get expired offers
  static List<OfferModel> expiredOffers({String merchandiserId = 'merch_1'}) {
    return [
      OfferModel(
        id: 'expired_1',
        merchandiserId: merchandiserId,
        title: const {'en': 'Expired Deal', 'ar': 'صفقة منتهية'},
        description: const {'en': 'This offer has expired'},
        imageUrl: 'https://example.com/expired.jpg',
        type: OfferType.discount,
        startDate: DateTime(2023, 1, 1),
        endDate: DateTime(2023, 12, 31),
        isActive: false,
        sortOrder: 20,
        details: const DiscountOfferDetails(
          productId: 'prod_old',
          discountValue: 30.0,
          isPercentage: true,
        ),
      ),
    ];
  }

  // Get future offers (not started yet)
  static List<OfferModel> futureOffers({String merchandiserId = 'merch_1'}) {
    final futureDate = DateTime.now().add(const Duration(days: 30));
    return [
      OfferModel(
        id: 'future_1',
        merchandiserId: merchandiserId,
        title: const {'en': 'Upcoming Sale', 'ar': 'تخفيضات قادمة'},
        description: const {'en': 'Coming soon'},
        imageUrl: 'https://example.com/future.jpg',
        type: OfferType.discount,
        startDate: futureDate,
        endDate: futureDate.add(const Duration(days: 60)),
        isActive: true,
        sortOrder: 25,
        details: const DiscountOfferDetails(
          categoryId: 'cat_all',
          discountValue: 25.0,
          isPercentage: true,
        ),
      ),
    ];
  }
}
