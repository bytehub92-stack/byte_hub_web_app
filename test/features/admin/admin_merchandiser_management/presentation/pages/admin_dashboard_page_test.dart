// Tag the ENTIRE file
@Tags(['web'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/pages/admin_dashboard_page.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/bloc/admin_stats_bloc/admin_stats_bloc.dart';
import '../../../../../helpers/test_helpers.dart';

void main() {
  late FakeGetAdminStats fakeGetAdminStats;

  setUp(() {
    fakeGetAdminStats = FakeGetAdminStats();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AdminStatsBloc>(
        create: (_) => AdminStatsBloc(getAdminStats: fakeGetAdminStats),
        child: const AdminDashboardPage(),
      ),
    );
  }

  group('AdminDashboardPage Widget', () {
    testWidgets('should display navigation destinations', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Merchandisers'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should switch between pages when navigation is tapped', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act - Tap on Merchandisers
      await tester.tap(find.text('Merchandisers'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Merchandiser Management'), findsOneWidget);
    });

    testWidgets('should display dashboard overview by default', (tester) async {
      // Arrange
      fakeGetAdminStats.shouldReturnError = false;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Dashboard Overview'), findsOneWidget);
    });
  });

  group('DashboardOverview Widget', () {
    testWidgets('should display loading indicator initially', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display stat cards when data loads successfully', (
      tester,
    ) async {
      // Arrange
      fakeGetAdminStats.shouldReturnError = false;
      await tester.pumpWidget(createWidgetUnderTest());

      // Wait for loading
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Assert
      expect(find.text('Total Merchandisers'), findsOneWidget);
      expect(find.text('Total Customers'), findsOneWidget);
      expect(find.text('Total Categories'), findsOneWidget);
      expect(find.text('Total Products'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('1000'), findsOneWidget);
    });

    testWidgets('should display error message when loading fails', (
      tester,
    ) async {
      // Arrange
      fakeGetAdminStats.shouldReturnError = true;
      await tester.pumpWidget(createWidgetUnderTest());

      // Wait for error
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should reload data when refresh button is tapped', (
      tester,
    ) async {
      // Arrange
      fakeGetAdminStats.shouldReturnError = false;
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Act
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Assert - Should show loading again
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
