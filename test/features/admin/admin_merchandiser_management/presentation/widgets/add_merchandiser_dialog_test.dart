import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_panel/features/admin/admin_merchandiser_management/presentation/widgets/add_merchandiser_dialog.dart';
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
        child: const Scaffold(body: AddMerchandiserDialog()),
      ),
    );
  }

  group('AddMerchandiserDialog Widget', () {
    testWidgets('should display all required form fields', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Add New Merchandiser'), findsOneWidget);
      expect(find.text('Business Name*'), findsOneWidget);
      expect(find.text('Contact Person Name*'), findsOneWidget);
      expect(find.text('Phone Number*'), findsOneWidget);
      expect(find.text('Email*'), findsOneWidget);
      expect(find.text('Business Type*'), findsOneWidget);
      expect(find.text('Description*'), findsOneWidget);
    });

    testWidgets('should show validation error when form is incomplete', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - Try to submit without filling fields
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('This field is required'), findsWidgets);
    });

    testWidgets('should validate email format', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email*'),
        'invalid-email',
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should submit form when all fields are valid', (tester) async {
      // Arrange
      fakeCreateMerchandiser.shouldReturnError = false;
      await tester.pumpWidget(createWidgetUnderTest());

      // Act - Fill all required fields
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
        'john@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Business Type*'),
        'Electronics',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description*'),
        'Test description',
      );

      await tester.tap(find.text('Create'));
      await tester.pump();

      // Assert - Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should close dialog when cancel is pressed', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => BlocProvider(
                    create: (_) => MerchandiserBloc(
                      getMerchandisers: fakeGetMerchandisers,
                      createMerchandiser: fakeCreateMerchandiser,
                      toggleMerchandiserStatus: fakeToggleStatus,
                    ),
                    child: const AddMerchandiserDialog(),
                  ),
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AddMerchandiserDialog), findsNothing);
    });
  });
}
