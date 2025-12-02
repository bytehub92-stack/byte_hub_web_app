import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/data/models/admin_stats_model.dart';

void main() {
  group('AdminStatsModel', () {
    final tStatsJson = {
      'total_merchandisers': 50,
      'total_customers': 1000,
      'total_categories': 20,
      'total_products': 500,
      'active_merchandisers': 45,
      'inactive_customers': 100,
    };

    test('should parse complete JSON correctly', () {
      final model = AdminStatsModel.fromJson(tStatsJson);

      expect(model.totalMerchandisers, 50);
      expect(model.totalCustomers, 1000);
      expect(model.totalCategories, 20);
      expect(model.totalProducts, 500);
      expect(model.activeMerchandisers, 45);
      expect(model.inactiveCustomers, 100);
    });

    test('should handle null values with defaults', () {
      final minimalJson = <String, dynamic>{};
      final model = AdminStatsModel.fromJson(minimalJson);

      expect(model.totalMerchandisers, 0);
      expect(model.totalCustomers, 0);
      expect(model.totalCategories, 0);
      expect(model.totalProducts, 0);
      expect(model.activeMerchandisers, 0);
      expect(model.inactiveCustomers, 0);
    });

    test('should handle partial JSON', () {
      final partialJson = {'total_merchandisers': 50, 'total_customers': 1000};

      final model = AdminStatsModel.fromJson(partialJson);

      expect(model.totalMerchandisers, 50);
      expect(model.totalCustomers, 1000);
      expect(model.totalCategories, 0);
      expect(model.totalProducts, 0);
    });
  });
}
