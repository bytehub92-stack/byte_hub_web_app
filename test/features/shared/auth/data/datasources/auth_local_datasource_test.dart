import 'package:admin_panel/core/error/exceptions.dart';
import 'package:admin_panel/features/shared/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../fixtures/auth_fixtures.dart';
import '../../../../../helpers/mocks.dart';

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = AuthLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getCachedUser', () {
    test('should return UserModel when cache is present', () async {
      // Arrange
      final jsonString =
          '{"id":"admin-123","email":"admin@bytehub.com","full_name":"Admin User","user_type":"admin","token":"valid-admin-token"}';
      when(() => mockSharedPreferences.getString(any())).thenReturn(jsonString);

      // Act
      final result = await dataSource.getCachedUser();

      // Assert
      expect(result, isNotNull);
      expect(result!.email, 'admin@bytehub.com');
    });

    test('should return null when cache is empty', () async {
      // Arrange
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);

      // Act
      final result = await dataSource.getCachedUser();

      // Assert
      expect(result, isNull);
    });

    test('should throw ServerException when JSON is invalid', () async {
      // Arrange
      when(
        () => mockSharedPreferences.getString(any()),
      ).thenReturn('invalid json');

      // Act & Assert
      expect(() => dataSource.getCachedUser(), throwsA(isA<ServerException>()));
    });
  });

  group('cacheUser', () {
    test('should call SharedPreferences to cache user', () async {
      // Arrange
      when(
        () => mockSharedPreferences.setString(any(), any()),
      ).thenAnswer((_) async => true);

      // Act
      await dataSource.cacheUser(AuthFixtures.adminUser);

      // Assert
      verify(() => mockSharedPreferences.setString(any(), any())).called(1);
    });

    test('should throw ServerException when caching fails', () async {
      // Arrange
      when(
        () => mockSharedPreferences.setString(any(), any()),
      ).thenThrow(Exception('Storage error'));

      // Act & Assert
      expect(
        () => dataSource.cacheUser(AuthFixtures.adminUser),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('clearCache', () {
    test('should call SharedPreferences to remove user', () async {
      // Arrange
      when(
        () => mockSharedPreferences.remove(any()),
      ).thenAnswer((_) async => true);

      // Act
      await dataSource.clearCache();

      // Assert
      verify(() => mockSharedPreferences.remove(any())).called(1);
    });
  });
}
