import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/features/shared/shared_feature/presentation/widgets/stat_card.dart';
import 'package:admin_panel/core/theme/colors.dart';

void main() {
  group('StatCard Widget', () {
    testWidgets('should display title, value, and icon correctly', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: 'Total Users',
              value: '1,000',
              icon: Icons.people,
              color: AppColors.primary,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('1,000'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('should use specified color for icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: 'Total Products',
              value: '500',
              icon: Icons.inventory,
              color: AppColors.success,
            ),
          ),
        ),
      );

      // Assert
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.inventory));
      expect(iconWidget.color, AppColors.success);
    });
  });
}
