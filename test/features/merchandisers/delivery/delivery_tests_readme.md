# Delivery Feature Tests

Comprehensive test suite for the delivery feature covering all aspects from models to integration tests.

## Test Structure

```
test/features/delivery/
├── README.md (this file)
├── helpers/
│   └── test_helpers.dart           # Test constants, builders, and factory
├── fakes/
│   └── fake_delivery_remote_datasource.dart  # Fake implementation (no mocks)
├── data/
│   ├── models/
│   │   ├── driver_model_test.dart
│   │   └── order_assignment_model_test.dart
│   └── repositories/
│       └── delivery_repository_impl_test.dart
├── presentation/
│   └── bloc/
│       └── delivery_bloc_test.dart
└── integration/
    └── delivery_integration_test.dart
```

## Prerequisites

Add these dependencies to your `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.0
  mocktail: ^1.0.0  # Only if you need it for other features
  dartz: ^0.10.1    # Should already be in dependencies
```

## Running Tests

### Run all delivery tests
```bash
flutter test test/features/delivery/
```

### Run specific test files

```bash
# Model tests
flutter test test/features/delivery/data/models/driver_model_test.dart
flutter test test/features/delivery/data/models/order_assignment_model_test.dart

# Repository tests
flutter test test/features/delivery/data/repositories/delivery_repository_impl_test.dart

# BLoC tests
flutter test test/features/delivery/presentation/bloc/delivery_bloc_test.dart

# Integration tests
flutter test test/features/delivery/integration/delivery_integration_test.dart
```

### Run tests with coverage

```bash
flutter test --coverage test/features/delivery/
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # On Mac
# or
xdg-open coverage/html/index.html  # On Linux
```

## Test Coverage

### ✅ Model Tests (`driver_model_test.dart`)
- JSON parsing with complete and partial data
- Nested profile data handling
- Missing field defaults
- Type conversions (amount parsing)
- Address formatting
- Entity helpers (vehicleInfo, statusLabel)
- Serialization (toJson)

### ✅ Model Tests (`order_assignment_model_test.dart`)
- JSON parsing for assignments
- Nested order and driver data
- Amount type conversions (double, int, string, null)
- Address formatting from shipping_address
- Entity helpers (isActive, isCompleted, isFailed, deliveryStatusLabel)
- Delivery status handling

### ✅ Repository Tests (`delivery_repository_impl_test.dart`)

**Business Logic Validations:**
- ✅ Cannot assign order to inactive driver (`is_active: false`)
- ✅ Cannot assign order to unavailable driver (`is_available: false`)
- ✅ Cannot assign order with status != "preparing"
- ✅ Cannot assign already assigned order
- ✅ Can assign multiple orders to same driver
- ✅ Cannot unassign delivered order
- ✅ Driver active orders count updates correctly

**CRUD Operations:**
- Get all drivers for merchandiser
- Get driver by ID
- Assign order to driver
- Get assignments with filters
- Unassign order
- Get delivery statistics
- Get merchandiser code

**Error Handling:**
- Server exceptions
- Not found errors
- Validation errors

### ✅ BLoC Tests (`delivery_bloc_test.dart`)

**Events Tested:**
- LoadDrivers
- LoadDriverById
- AssignOrderToDriver (with all validation scenarios)
- LoadOrderAssignments (with filters)
- UnassignOrder
- LoadDeliveryStatistics
- LoadMerchandiserCode

**State Transitions:**
- DeliveryInitial → DeliveryLoading → Success/Error states
- All success states (DriversLoaded, OrderAssigned, etc.)
- Error states with proper messages

**Business Logic in BLoC:**
- Multiple assignment validation
- Status transition verification
- Filter combinations
- Statistics calculation

### ✅ Integration Tests (`delivery_integration_test.dart`)

**Complete Workflows:**
1. **Full Order Lifecycle:**
   - Get available drivers
   - Assign order
   - Verify status changes
   - Load assignments

2. **Reassignment Workflow:**
   - Assign to driver 1
   - Unassign
   - Assign to driver 2
   - Verify counts updated

3. **Multiple Orders to Single Driver:**
   - Assign 3 orders to one driver
   - Verify all assignments
   - Unassign one
   - Verify count decreases

4. **Statistics Tracking:**
   - Check initial stats
   - Make assignments
   - Check updated stats
   - Unassign
   - Verify stats updated

5. **Error Recovery:**
   - Handle errors
   - Retry operations
   - Validation error recovery

6. **Complex Filtering:**
   - Filter by driver
   - Filter by active status
   - Combine filters
   - Verify results

## Key Business Rules Tested

### Order Status Flow
```
Merchandiser → Customer:
pending → confirmed → preparing → on_the_way → delivered

Merchandiser → Driver (delivery_status):
assigned → picked_up → on_the_way → delivered/failed
```

### Assignment Rules
- ✅ Order must be in "preparing" status
- ✅ Driver must be active (`is_active: true`)
- ✅ Driver must be available (`is_available: true`)
- ✅ Order can only be assigned once at a time
- ✅ Multiple orders can be assigned to same driver
- ✅ Delivered orders cannot be unassigned

### Status Updates
- ✅ Assignment changes order status to "on_the_way"
- ✅ Unassignment changes order status back to "preparing"
- ✅ Driver active orders count updates on assign/unassign

## Test Data Builders

The test helpers provide fluent builders for creating test data:

```dart
// Create a driver
final driver = TestDriverBuilder()
    .withId('driver-1')
    .withFullName('John Doe')
    .withIsActive(true)
    .withIsAvailable(false)
    .withActiveOrders(2)
    .build();

// Create an assignment
final assignment = TestOrderAssignmentBuilder()
    .withOrderId('order-1')
    .withDriverId('driver-1')
    .withDeliveryStatus('picked_up')
    .withNotes('Handle with care')
    .build();
```

## Fake Data Source

The `FakeDeliveryRemoteDataSource` provides a complete in-memory implementation:

```dart
final fakeDataSource = FakeDeliveryRemoteDataSource();

// Setup test data
fakeDataSource.setupDrivers([driver1, driver2]);
fakeDataSource.setupAssignments([assignment1]);
fakeDataSource.setupOrderStatus('order-1', 'preparing');

// Verify operations
expect(fakeDataSource.isOrderAssigned('order-1'), true);
expect(fakeDataSource.getDriverActiveOrdersCount('driver-1'), 2);
```

## Common Test Patterns

### Testing Assignment Success
```dart
test('should successfully assign order', () async {
  // Setup
  fakeDataSource.setupDrivers([activeDriver]);
  fakeDataSource.setupOrderStatus(orderId, 'preparing');
  
  // Act
  final result = await repository.assignOrderToDriver(/*...*/);
  
  // Assert
  expect(result.isRight(), true);
  expect(fakeDataSource.getOrderStatus(orderId), 'on_the_way');
});
```

### Testing Validation Errors
```dart
test('should fail when driver is inactive', () async {
  // Setup
  final inactiveDriver = TestDriverBuilder()
      .withIsActive(false)
      .buildModel();
  fakeDataSource.setupDrivers([inactiveDriver]);
  
  // Act
  final result = await repository.assignOrderToDriver(/*...*/);
  
  // Assert
  expect(result.isLeft(), true);
  result.fold(
    (failure) => expect(failure.message, contains('inactive')),
    (_) => fail('Should have failed'),
  );
});
```

### Testing BLoC State Transitions
```dart
blocTest<DeliveryBloc, DeliveryState>(
  'emits [Loading, Loaded] when successful',
  build: () {
    fakeDataSource.setupDrivers([driver]);
    return bloc;
  },
  act: (bloc) => bloc.add(LoadDrivers(merchandiserId)),
  expect: () => [
    DeliveryLoading(),
    DriversLoaded([driver]),
  ],
);
```

## Troubleshooting

### Tests failing with "Driver not found"
Make sure you're setting up the fake data source before the act phase:
```dart
fakeDataSource.setupDrivers([driver]);
```

### Tests failing with order status validation
Ensure order status is set to "preparing":
```dart
fakeDataSource.setupOrderStatus(orderId, 'preparing');
```

### BLoC tests timing out
Add appropriate delays between events:
```dart
await Future.delayed(const Duration(milliseconds: 100));
```

### Coverage not complete
Run with coverage flag and check the HTML report:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## CI/CD Integration

Add to your CI pipeline (GitHub Actions example):

```yaml
- name: Run Delivery Tests
  run: flutter test test/features/delivery/ --coverage
  
- name: Upload Coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
```

## Next Steps

After all tests pass:
1. ✅ Integrate with your CI/CD pipeline
2. ✅ Set up code coverage requirements (aim for >90%)
3. ✅ Add tests to pre-commit hooks
4. ✅ Document any additional business rules
5. ✅ Add performance tests if needed

## Questions?

If tests fail or you find edge cases not covered:
1. Check the fake data source setup
2. Verify business rule assumptions
3. Add new test cases for discovered scenarios
4. Update this README with findings
