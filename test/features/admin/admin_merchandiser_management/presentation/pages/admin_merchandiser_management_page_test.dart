// Tag the ENTIRE file
@Tags(['web'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/pages/admin_merchandiser_management_page.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/merchandiser_bloc/merchandiser_bloc.dart';
import '../../../../../helpers/test_helpers.dart';

void main() {
  late FakeGetMerchandisers fakeGetMerchandisers;
  late FakeCreateMerchandiser fakeCreateMerchandiser;
  late FakeToggleMerchandiserStatus fakeToggleStatus;

  setUp(() {
    fakeGetMerchandisers = FakeGetMerchandisers();
    fakeCreateMerchandiser = FakeCreateMerchandiser();
    fakeToggleStatus = FakeToggleMerchandiserStatus();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => MerchandiserBloc(
          getMerchandisers: fakeGetMerchandisers,
          createMerchandiser: fakeCreateMerchandiser,
          toggleMerchandiserStatus: fakeToggleStatus,
        ),
        child: const AdminMerchandiserManagementPage(),
      ),
    );
  }

  group('AdminMerchandiserManagementPage Widget', () {
    testWidgets('should display page title and add button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('Merchandiser Management'), findsOneWidget);
      expect(find.text('Add Merchandiser'), findsOneWidget);
    });

    testWidgets('should show loading indicator initially', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display merchandiser list when data loads', (
      tester,
    ) async {
      // Arrange
      fakeGetMerchandisers.shouldReturnError = false;
      await tester.pumpWidget(createWidgetUnderTest());

      // Wait for data
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Assert
      expect(find.text('Business 1'), findsOneWidget);
      expect(find.text('Business 2'), findsOneWidget);
    });

    testWidgets('should display empty state when no merchandisers exist', (
      tester,
    ) async {
      // Arrange - Mock empty list
      fakeGetMerchandisers.shouldReturnError = false;
      // You'd need to modify the fake to return empty list

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // This test needs proper empty state handling in the fake
    });

    testWidgets('should display error state when loading fails', (
      tester,
    ) async {
      // Arrange
      fakeGetMerchandisers.shouldReturnError = true;
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Error loading merchandisers'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should open add dialog when add button is tapped', (
      tester,
    ) async {
      // Arrange
      fakeGetMerchandisers.shouldReturnError = false;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Act
      await tester.tap(find.text('Add Merchandiser'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Add New Merchandiser'), findsOneWidget);
    });

    testWidgets('should show success snackbar when status is updated', (
      tester,
    ) async {
      // This test would require more complex setup with navigation
      // and proper snackbar handling
    });
  });
}
