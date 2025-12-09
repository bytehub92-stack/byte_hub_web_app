// test/features/shared/data/datasources/fake_customer_remote_datasource.dart

import 'package:admin_panel/core/error/exceptions.dart';
import 'package:admin_panel/features/shared/shared_feature/data/datasources/customer_remote_datasource.dart';

import 'package:admin_panel/features/shared/shared_feature/data/models/customer_model.dart';

class FakeCustomerRemoteDataSource implements CustomerRemoteDataSource {
  final Map<String, CustomerModel> _customers = {};
  bool shouldThrowError = false;
  String? errorMessage;

  void seedData() {
    final customer1 = CustomerModel(
      id: 'cust-1',
      email: 'john.doe@example.com',
      phoneNumber: '+201234567890',
      fullName: 'John Doe',
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      lastLogin: DateTime(2024, 1, 15),
      avatarUrl: 'https://example.com/avatar1.jpg',
      preferredLanguage: 'en',
      merchandiserId: 'merch-1',
      totalOrders: 5,
      totalSpent: 1500.50,
      lastOrderDate: DateTime(2024, 1, 10),
    );

    final customer2 = CustomerModel(
      id: 'cust-2',
      email: 'jane.smith@example.com',
      phoneNumber: '+201234567891',
      fullName: 'Jane Smith',
      isActive: true,
      createdAt: DateTime(2024, 1, 2),
      lastLogin: DateTime(2024, 1, 14),
      avatarUrl: 'https://example.com/avatar2.jpg',
      preferredLanguage: 'ar',
      merchandiserId: 'merch-1',
      totalOrders: 10,
      totalSpent: 3200.75,
      lastOrderDate: DateTime(2024, 1, 12),
    );

    final customer3 = CustomerModel(
      id: 'cust-3',
      email: 'ahmed.ali@example.com',
      phoneNumber: '+201234567892',
      fullName: 'Ahmed Ali',
      isActive: false,
      createdAt: DateTime(2024, 1, 3),
      lastLogin: DateTime(2024, 1, 5),
      avatarUrl: null,
      preferredLanguage: 'ar',
      merchandiserId: 'merch-1',
      totalOrders: 2,
      totalSpent: 500.0,
      lastOrderDate: DateTime(2024, 1, 4),
    );

    final customer4 = CustomerModel(
      id: 'cust-4',
      email: 'sara.mohamed@example.com',
      phoneNumber: '+201234567893',
      fullName: 'Sara Mohamed',
      isActive: true,
      createdAt: DateTime(2024, 1, 4),
      lastLogin: null,
      avatarUrl: 'https://example.com/avatar4.jpg',
      preferredLanguage: 'en',
      merchandiserId: 'merch-2',
      totalOrders: 0,
      totalSpent: 0.0,
      lastOrderDate: null,
    );

    _customers[customer1.id] = customer1;
    _customers[customer2.id] = customer2;
    _customers[customer3.id] = customer3;
    _customers[customer4.id] = customer4;
  }

  void clear() {
    _customers.clear();
    shouldThrowError = false;
    errorMessage = null;
  }

  void throwError(String message) {
    shouldThrowError = true;
    errorMessage = message;
  }

  @override
  Future<List<CustomerModel>> getCustomersByMerchandiser(
    String merchandiserId,
  ) async {
    if (shouldThrowError) {
      throw ServerException(
        message: errorMessage ?? 'Failed to fetch customers',
      );
    }

    await Future.delayed(const Duration(milliseconds: 10));

    final results =
        _customers.values
            .where((customer) => customer.merchandiserId == merchandiserId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return results;
  }

  @override
  Future<CustomerModel> getCustomerById(String customerId) async {
    if (shouldThrowError) {
      throw ServerException(
        message: errorMessage ?? 'Failed to fetch customer',
      );
    }

    await Future.delayed(const Duration(milliseconds: 10));

    final customer = _customers[customerId];
    if (customer == null) {
      throw ServerException(message: 'Customer not found');
    }

    return customer;
  }

  @override
  Future<void> toggleCustomerStatus(String customerId, bool isActive) async {
    if (shouldThrowError) {
      throw ServerException(message: errorMessage ?? 'Failed to update status');
    }

    await Future.delayed(const Duration(milliseconds: 10));

    final existing = _customers[customerId];
    if (existing == null) {
      throw ServerException(message: 'Customer not found');
    }

    final updated = CustomerModel(
      id: existing.id,
      email: existing.email,
      phoneNumber: existing.phoneNumber,
      fullName: existing.fullName,
      isActive: isActive,
      createdAt: existing.createdAt,
      lastLogin: existing.lastLogin,
      avatarUrl: existing.avatarUrl,
      preferredLanguage: existing.preferredLanguage,
      merchandiserId: existing.merchandiserId,
      totalOrders: existing.totalOrders,
      totalSpent: existing.totalSpent,
      lastOrderDate: existing.lastOrderDate,
    );

    _customers[customerId] = updated;
  }

  // Helper methods for testing
  int getCustomerCount() => _customers.length;

  bool customerExists(String customerId) => _customers.containsKey(customerId);

  List<CustomerModel> getAllCustomers() => _customers.values.toList();

  int getActiveCustomerCount() =>
      _customers.values.where((c) => c.isActive).length;

  int getCustomerCountByMerchandiser(String merchandiserId) =>
      _customers.values.where((c) => c.merchandiserId == merchandiserId).length;
}
