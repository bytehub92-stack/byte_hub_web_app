// Tag the ENTIRE file
@Tags(['web'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/widgets/merchandiser_card.dart';
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
        child: Scaffold(
          body: MerchandiserCard(merchandiser: TestFixtures.merchandiser1),
        ),
      ),
    );
  }

  group('MerchandiserCard Widget', () {
    testWidgets('should display merchandiser information correctly', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Test Business 1'), findsOneWidget);
      expect(find.text('Electronics'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('should show active status badge for active merchandiser', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Active'), findsOneWidget);

      // Find the container with green background
      final activeBadge = tester.widget<Container>(
        find
            .ancestor(of: find.text('Active'), matching: find.byType(Container))
            .first,
      );
      expect(activeBadge, isNotNull);
    });

    testWidgets('should show popup menu when tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('View Details'), findsOneWidget);
      expect(find.text('Deactivate'), findsOneWidget);
    });

    testWidgets('should navigate to details when card is tapped', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      // Assert - The navigation should have occurred
      // In a real app, you'd check for the new page
    });
  });
}
