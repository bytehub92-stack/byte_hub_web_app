import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/data/models/merchandiser_model.dart';

void main() {
  group('MerchandiserModel', () {
    final tMerchandiserJson = {
      'id': '123',
      'profile_id': 'profile-123',
      'business_name': {'en': 'Test Business', 'ar': 'نشاط تجاري'},
      'business_type': {'en': 'Electronics', 'ar': 'إلكترونيات'},
      'description': {'en': 'Test description', 'ar': 'وصف الاختبار'},
      'logo_url': 'https://example.com/logo.png',
      'website': 'https://example.com',
      'address': {'en': '123 Street', 'ar': '١٢٣ شارع'},
      'city': {'en': 'Cairo', 'ar': 'القاهرة'},
      'state': {'en': 'Cairo', 'ar': 'القاهرة'},
      'country': {'en': 'Egypt', 'ar': 'مصر'},
      'postal_code': '12345',
      'tax_id': 'TAX123',
      'is_active': true,
      'subscription_plan': 'premium',
      'subscription_expires_at': '2024-12-31T23:59:59.000Z',
      'settings': {'theme': 'dark'},
      'created_at': '2024-01-01T00:00:00.000Z',
      'updated_at': '2024-01-02T00:00:00.000Z',
      'contact_name': 'John Doe',
      'email': 'john@example.com',
      'phone_number': '+1234567890',
      'last_login': '2024-01-03T00:00:00.000Z',
      'total_customers': 100,
      'total_categories': 10,
      'total_products': 500,
      'total_orders': 1000,
      'total_revenue': 50000.50,
    };

    test('should be a subclass of Merchandiser entity', () {
      final model = MerchandiserModel.fromJson(tMerchandiserJson);
      expect(model, isA<MerchandiserModel>());
    });

    test('should parse complete JSON correctly', () {
      final model = MerchandiserModel.fromJson(tMerchandiserJson);

      expect(model.id, '123');
      expect(model.profileId, 'profile-123');
      expect(model.businessName['en'], 'Test Business');
      expect(model.businessName['ar'], 'نشاط تجاري');
      expect(model.businessType!['en'], 'Electronics');
      expect(model.email, 'john@example.com');
      expect(model.isActive, true);
      expect(model.totalCustomers, 100);
      expect(model.totalRevenue, 50000.50);
    });

    test('should handle null optional fields', () {
      final minimalJson = {
        'id': '123',
        'profile_id': 'profile-123',
        'business_name': {'en': 'Test Business'},
        'is_active': true,
        'subscription_plan': 'basic',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T00:00:00.000Z',
      };

      final model = MerchandiserModel.fromJson(minimalJson);

      expect(model.id, '123');
      expect(model.businessType, null);
      expect(model.description, null);
      expect(model.logoUrl, null);
      expect(model.contactName, null);
      expect(model.totalCustomers, 0);
      expect(model.totalRevenue, 0.0);
    });

    test('should parse string business_name to Map', () {
      final jsonWithStringName = {
        'id': '123',
        'profile_id': 'profile-123',
        'business_name': 'Simple Name',
        'is_active': true,
        'subscription_plan': 'basic',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T00:00:00.000Z',
      };

      final model = MerchandiserModel.fromJson(jsonWithStringName);
      expect(model.businessName['en'], 'Simple Name');
    });

    test('should handle different numeric types for revenue', () {
      final jsonWithIntRevenue = {...tMerchandiserJson, 'total_revenue': 50000};
      final model1 = MerchandiserModel.fromJson(jsonWithIntRevenue);
      expect(model1.totalRevenue, 50000.0);

      final jsonWithStringRevenue = {
        ...tMerchandiserJson,
        'total_revenue': '50000.50',
      };
      final model2 = MerchandiserModel.fromJson(jsonWithStringRevenue);
      expect(model2.totalRevenue, 50000.50);
    });
  });
}
