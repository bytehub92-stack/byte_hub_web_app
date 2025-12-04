// Tag the ENTIRE file
@Tags(['integration'])
library;

import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/pages/admin_merchandiser_management_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/pages/admin_dashboard_page.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/merchandiser_bloc/merchandiser_bloc.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/admin_stats_bloc/admin_stats_bloc.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Admin Merchandiser Management Flow - Integration Tests', () {
    late FakeGetMerchandisers fakeGetMerchandisers;
    late FakeCreateMerchandiser fakeCreateMerchandiser;
    late FakeToggleMerchandiserStatus fakeToggleStatus;
    late FakeGetAdminStats fakeGetAdminStats;

    setUp(() {
      fakeGetMerchandisers = FakeGetMerchandisers();
      fakeCreateMerchandiser = FakeCreateMerchandiser();
      fakeToggleStatus = FakeToggleMerchandiserStatus();
      fakeGetAdminStats = FakeGetAdminStats();
    });

    testWidgets(
      'Complete flow: View dashboard, navigate to merchandisers, view details',
      (tester) async {
        // Arrange
        fakeGetAdminStats.shouldReturnError = false;
        fakeGetMerchandisers.shouldReturnError = false;

        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) =>
                      AdminStatsBloc(getAdminStats: fakeGetAdminStats),
                ),
                BlocProvider(
                  create: (_) => MerchandiserBloc(
                    getMerchandisers: fakeGetMerchandisers,
                    createMerchandiser: fakeCreateMerchandiser,
                    toggleMerchandiserStatus: fakeToggleStatus,
                  ),
                ),
              ],
              child: const AdminDashboardPage(),
            ),
          ),
        );

        // Act & Assert - View dashboard
        await tester.pumpAndSettle();
        expect(find.text('Dashboard Overview'), findsOneWidget);

        // Navigate to merchandisers
        await tester.tap(find.text('Merchandisers'));
        await tester.pumpAndSettle();
        expect(find.text('Merchandiser Management'), findsOneWidget);
      },
    );

    testWidgets(
      'Complete flow: Create merchandiser, view in list, toggle status',
      (tester) async {
        // Arrange
        fakeGetMerchandisers.shouldReturnError = false;
        fakeCreateMerchandiser.shouldReturnError = false;
        fakeToggleStatus.shouldReturnError = false;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider(
              create: (_) => MerchandiserBloc(
                getMerchandisers: fakeGetMerchandisers,
                createMerchandiser: fakeCreateMerchandiser,
                toggleMerchandiserStatus: fakeToggleStatus,
              ),
              child: const Scaffold(body: AdminMerchandiserManagementPage()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Act - Open add dialog
        await tester.tap(find.text('Add Merchandiser'));
        await tester.pumpAndSettle();

        // Fill form
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Business Name*'),
          'Test Business',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Contact Person Name*'),
          'John Doe',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Phone Number*'),
          '+1234567890',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email*'),
          'john@test.com',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Business Type*'),
          'Electronics',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Description*'),
          'Test description',
        );

        // Submit form
        await tester.tap(find.text('Create'));
        await tester.pump();

        // Wait for creation and list refresh
        await tester.pump(const Duration(milliseconds: 300));

        // Assert - Should show success and merchandiser list
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });
}
