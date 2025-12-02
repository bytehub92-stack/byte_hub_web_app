// test/helpers/test_helpers.dart

import 'package:admin_panel/core/error/exceptions.dart';
import 'package:admin_panel/core/error/failures.dart';
import 'package:admin_panel/core/network/network_info.dart';
import 'package:admin_panel/core/usecases/usecase.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/data/datasources/admin_remote_datasource.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/data/datasources/admin_stats_remote_datasource.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/data/models/admin_stats_model.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/data/models/merchandiser_model.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/entities/admin_stats.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/entities/create_merchandiser_request.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/entities/merchandiser.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/repositories/admin_stats_repository.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/repositories/merchandiser_repository.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/usecases/create_merchandiser.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/usecases/get_admin_stats.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/usecases/get_merchandisers.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/domain/usecases/toggle_merchandiser_status.dart';
import 'package:dartz/dartz.dart';

// ============================================================================
// FAKE DATA SOURCES
// ============================================================================

class FakeMerchandiserRemoteDataSource implements MerchandiserRemoteDataSource {
  bool shouldThrowError = false;

  final List<MerchandiserModel> _fakeMerchandisers = [
    MerchandiserModel(
      id: '1',
      profileId: 'profile-1',
      businessName: {'en': 'Business 1', 'ar': 'نشاط 1'},
      businessType: {'en': 'Electronics', 'ar': 'إلكترونيات'},
      description: {'en': 'Description 1', 'ar': 'وصف 1'},
      isActive: true,
      subscriptionPlan: 'premium',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
      contactName: 'John Doe',
      email: 'john@example.com',
      phoneNumber: '+1234567890',
      totalCustomers: 50,
      totalCategories: 5,
      totalProducts: 100,
      totalOrders: 200,
      totalRevenue: 10000.0,
    ),
    MerchandiserModel(
      id: '2',
      profileId: 'profile-2',
      businessName: {'en': 'Business 2', 'ar': 'نشاط 2'},
      businessType: {'en': 'Fashion', 'ar': 'أزياء'},
      description: {'en': 'Description 2', 'ar': 'وصف 2'},
      isActive: false,
      subscriptionPlan: 'basic',
      createdAt: DateTime(2024, 1, 3),
      updatedAt: DateTime(2024, 1, 4),
      contactName: 'Jane Smith',
      email: 'jane@example.com',
      phoneNumber: '+0987654321',
      totalCustomers: 30,
      totalCategories: 3,
      totalProducts: 50,
      totalOrders: 100,
      totalRevenue: 5000.0,
    ),
  ];

  @override
  Future<List<MerchandiserModel>> getMerchandisers() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldThrowError) {
      throw ServerException(message: 'Server error');
    }
    return _fakeMerchandisers;
  }

  @override
  Future<MerchandiserModel> getMerchandiserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldThrowError) {
      throw ServerException(message: 'Server error');
    }
    try {
      return _fakeMerchandisers.firstWhere((m) => m.id == id);
    } catch (e) {
      throw ServerException(message: 'Merchandiser not found');
    }
  }

  @override
  Future<String> createMerchandiser(CreateMerchandiserRequest request) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldThrowError) {
      throw ServerException(message: 'Failed to create merchandiser');
    }
    return 'TempPass123!';
  }

  @override
  Future<void> updateMerchandiserStatus(String id, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldThrowError) {
      throw ServerException(message: 'Failed to update status');
    }
    // Update the fake data
    final index = _fakeMerchandisers.indexWhere((m) => m.id == id);
    if (index != -1) {
      final updated = MerchandiserModel(
        id: _fakeMerchandisers[index].id,
        profileId: _fakeMerchandisers[index].profileId,
        businessName: _fakeMerchandisers[index].businessName,
        businessType: _fakeMerchandisers[index].businessType,
        description: _fakeMerchandisers[index].description,
        isActive: isActive,
        subscriptionPlan: _fakeMerchandisers[index].subscriptionPlan,
        createdAt: _fakeMerchandisers[index].createdAt,
        updatedAt: DateTime.now(),
        contactName: _fakeMerchandisers[index].contactName,
        email: _fakeMerchandisers[index].email,
        phoneNumber: _fakeMerchandisers[index].phoneNumber,
        totalCustomers: _fakeMerchandisers[index].totalCustomers,
        totalCategories: _fakeMerchandisers[index].totalCategories,
        totalProducts: _fakeMerchandisers[index].totalProducts,
        totalOrders: _fakeMerchandisers[index].totalOrders,
        totalRevenue: _fakeMerchandisers[index].totalRevenue,
      );
      _fakeMerchandisers[index] = updated;
    }
  }
}

class FakeAdminStatsRemoteDataSource implements AdminStatsRemoteDataSource {
  bool shouldThrowError = false;

  @override
  Future<AdminStatsModel> getAdminStats() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldThrowError) {
      throw ServerException(message: 'Stats error');
    }
    return const AdminStatsModel(
      totalMerchandisers: 50,
      totalCustomers: 1000,
      totalCategories: 20,
      totalProducts: 500,
      activeMerchandisers: 45,
      inactiveCustomers: 100,
    );
  }
}

// ============================================================================
// FAKE REPOSITORIES
// ============================================================================

class FakeMerchandiserRepository implements MerchandiserRepository {
  bool shouldReturnError = false;

  final List<Merchandiser> _fakeMerchandisers = [
    Merchandiser(
      id: '1',
      profileId: 'profile-1',
      businessName: {'en': 'Business 1', 'ar': 'نشاط 1'},
      businessType: {'en': 'Electronics', 'ar': 'إلكترونيات'},
      description: {'en': 'Description 1', 'ar': 'وصف 1'},
      isActive: true,
      subscriptionPlan: 'premium',
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      updatedAt: DateTime.parse('2024-01-02T00:00:00Z'),
      contactName: 'John Doe',
      email: 'john@example.com',
      phoneNumber: '+1234567890',
      totalCustomers: 50,
      totalCategories: 5,
      totalProducts: 100,
      totalOrders: 200,
      totalRevenue: 10000.0,
    ),
    Merchandiser(
      id: '2',
      profileId: 'profile-2',
      businessName: {'en': 'Business 2', 'ar': 'نشاط 2'},
      businessType: {'en': 'Fashion', 'ar': 'أزياء'},
      isActive: false,
      subscriptionPlan: 'basic',
      createdAt: DateTime.parse('2024-01-03T00:00:00Z'),
      updatedAt: DateTime.parse('2024-01-04T00:00:00Z'),
    ),
  ];

  @override
  Future<Either<Failure, List<Merchandiser>>> getMerchandisers() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldReturnError) {
      return Left(ServerFailure(message: 'Failed to load'));
    }
    return Right(_fakeMerchandisers);
  }

  @override
  Future<Either<Failure, Merchandiser>> getMerchandiserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldReturnError) {
      return Left(ServerFailure(message: 'Failed to load'));
    }
    try {
      final merchandiser = _fakeMerchandisers.firstWhere((m) => m.id == id);
      return Right(merchandiser);
    } catch (e) {
      return Left(ServerFailure(message: 'Not found'));
    }
  }

  @override
  Future<Either<Failure, String>> createMerchandiser(
    CreateMerchandiserRequest request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldReturnError) {
      return Left(ServerFailure(message: 'Failed to create'));
    }
    return const Right('TempPass123!');
  }

  @override
  Future<Either<Failure, Unit>> updateMerchandiserStatus(
    String id,
    bool isActive,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldReturnError) {
      return Left(ServerFailure(message: 'Failed to update'));
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteMerchandiser(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldReturnError) {
      return Left(ServerFailure(message: 'Failed to delete'));
    }
    return const Right(unit);
  }
}

class FakeAdminStatsRepository implements AdminStatsRepository {
  bool shouldReturnError = false;

  @override
  Future<Either<Failure, AdminStats>> getAdminStats() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldReturnError) {
      return Left(ServerFailure(message: 'Failed to load stats'));
    }
    return const Right(
      AdminStats(
        totalMerchandisers: 50,
        totalCustomers: 1000,
        totalCategories: 20,
        totalProducts: 500,
        activeMerchandisers: 45,
      ),
    );
  }
}

// ============================================================================
// FAKE USE CASES
// ============================================================================

class FakeGetMerchandisers extends GetMerchandisers {
  bool shouldReturnError = false;
  late final FakeMerchandiserRepository _fakeRepository;

  FakeGetMerchandisers() : super(FakeMerchandiserRepository()) {
    _fakeRepository = repository as FakeMerchandiserRepository;
  }

  @override
  Future<Either<Failure, List<Merchandiser>>> call(NoParams params) async {
    _fakeRepository.shouldReturnError = shouldReturnError;
    return super.call(params);
  }
}

class FakeCreateMerchandiser extends CreateMerchandiser {
  bool shouldReturnError = false;
  late final FakeMerchandiserRepository _fakeRepository;

  FakeCreateMerchandiser() : super(FakeMerchandiserRepository()) {
    _fakeRepository = repository as FakeMerchandiserRepository;
  }

  @override
  Future<Either<Failure, String>> call(CreateMerchandiserRequest params) async {
    _fakeRepository.shouldReturnError = shouldReturnError;
    return super.call(params);
  }
}

class FakeToggleMerchandiserStatus extends ToggleMerchandiserStatus {
  bool shouldReturnError = false;
  late final FakeMerchandiserRepository _fakeRepository;

  FakeToggleMerchandiserStatus() : super(FakeMerchandiserRepository()) {
    _fakeRepository = repository as FakeMerchandiserRepository;
  }

  @override
  Future<Either<Failure, Unit>> call(
    ToggleMerchandiserStatusParams params,
  ) async {
    _fakeRepository.shouldReturnError = shouldReturnError;
    return super.call(params);
  }
}

class FakeGetAdminStats extends GetAdminStats {
  bool shouldReturnError = false;
  late final FakeAdminStatsRepository _fakeRepository;

  FakeGetAdminStats() : super(FakeAdminStatsRepository()) {
    _fakeRepository = repository as FakeAdminStatsRepository;
  }

  @override
  Future<Either<Failure, AdminStats>> call() async {
    _fakeRepository.shouldReturnError = shouldReturnError;
    return super.call();
  }
}

// ============================================================================
// FAKE NETWORK INFO
// ============================================================================

class FakeNetworkInfo implements NetworkInfo {
  bool _isConnected;

  FakeNetworkInfo({bool isConnected = true}) : _isConnected = isConnected;

  void setConnection(bool value) => _isConnected = value;

  @override
  Future<bool> get isConnected async => _isConnected;
}

// ============================================================================
// TEST FIXTURES
// ============================================================================

class TestFixtures {
  static Merchandiser get merchandiser1 => Merchandiser(
    id: '1',
    profileId: 'profile-1',
    businessName: {'en': 'Test Business 1', 'ar': 'نشاط تجاري 1'},
    businessType: {'en': 'Electronics', 'ar': 'إلكترونيات'},
    description: {'en': 'Test description', 'ar': 'وصف الاختبار'},
    isActive: true,
    subscriptionPlan: 'premium',
    createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
    updatedAt: DateTime.parse('2024-01-02T00:00:00Z'),
    contactName: 'John Doe',
    email: 'john@example.com',
    phoneNumber: '+1234567890',
    totalCustomers: 100,
    totalCategories: 10,
    totalProducts: 500,
    totalOrders: 1000,
    totalRevenue: 50000.0,
  );

  static Merchandiser get merchandiser2 => Merchandiser(
    id: '2',
    profileId: 'profile-2',
    businessName: {'en': 'Test Business 2', 'ar': 'نشاط تجاري 2'},
    businessType: {'en': 'Fashion', 'ar': 'أزياء'},
    isActive: false,
    subscriptionPlan: 'basic',
    createdAt: DateTime.parse('2024-01-03T00:00:00Z'),
    updatedAt: DateTime.parse('2024-01-04T00:00:00Z'),
  );

  static AdminStats get adminStats => const AdminStats(
    totalMerchandisers: 50,
    totalCustomers: 1000,
    totalCategories: 20,
    totalProducts: 500,
    activeMerchandisers: 45,
    inactiveCustomers: 100,
  );

  static CreateMerchandiserRequest get createRequest =>
      CreateMerchandiserRequest(
        businessName: 'New Business',
        businessNameArabic: 'نشاط جديد',
        businessType: 'Electronics',
        businessTypeArabic: 'إلكترونيات',
        description: 'Test description',
        descriptionArabic: 'وصف الاختبار',
        fullName: 'John Doe',
        email: 'john@example.com',
        phoneNumber: '+1234567890',
      );

  static Map<String, dynamic> get merchandiserJson => {
    'id': '1',
    'profile_id': 'profile-1',
    'business_name': {'en': 'Test Business', 'ar': 'نشاط تجاري'},
    'business_type': {'en': 'Electronics', 'ar': 'إلكترونيات'},
    'description': {'en': 'Test description', 'ar': 'وصف الاختبار'},
    'is_active': true,
    'subscription_plan': 'premium',
    'created_at': '2024-01-01T00:00:00.000Z',
    'updated_at': '2024-01-02T00:00:00.000Z',
    'contact_name': 'John Doe',
    'email': 'john@example.com',
    'phone_number': '+1234567890',
    'total_customers': 100,
    'total_categories': 10,
    'total_products': 500,
    'total_orders': 1000,
    'total_revenue': 50000.0,
  };

  static Map<String, dynamic> get adminStatsJson => {
    'total_merchandisers': 50,
    'total_customers': 1000,
    'total_categories': 20,
    'total_products': 500,
    'active_merchandisers': 45,
    'inactive_customers': 100,
  };
}
