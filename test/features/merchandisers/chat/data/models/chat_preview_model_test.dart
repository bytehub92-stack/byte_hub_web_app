// test/features/chat/data/models/chat_preview_model_test.dart

import 'package:admin_panel/features/merchandisers/chats/data/models/chat_preview_model.dart';
import 'package:admin_panel/features/merchandisers/chats/domain/entities/chat_preview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('ChatPreviewModel', () {
    late TestChatPreviewBuilder previewBuilder;

    setUp(() {
      previewBuilder = TestChatPreviewBuilder();
    });

    group('fromJson', () {
      test('should parse complete JSON correctly', () {
        // Arrange
        final json = previewBuilder.toJson();

        // Act
        final result = ChatPreviewModel.fromJson(json);

        // Assert
        expect(result.customerProfileId, ChatTestConstants.customerProfileId1);
        expect(result.customerName, ChatTestConstants.customerName1);
        expect(result.lastMessage, 'Last message text');
        expect(result.lastMessageTime, DateTime(2024, 1, 1, 10, 0));
        expect(result.unreadCount, 0);
        expect(result.isCustomerOnline, false);
      });

      test('should handle missing optional fields', () {
        // Arrange
        final json = {
          'customer_profile_id': 'profile-1',
          'last_message_time': '2024-01-01T10:00:00.000Z',
        };

        // Act
        final result = ChatPreviewModel.fromJson(json);

        // Assert
        expect(result.customerProfileId, 'profile-1');
        expect(result.customerName, 'Unknown Customer'); // Default
        expect(result.customerAvatar, null);
        expect(result.lastMessage, 'No messages yet'); // Default
        expect(result.unreadCount, 0); // Default
        expect(result.isCustomerOnline, false); // Default
      });

      test('should parse customer with avatar', () {
        // Arrange
        final json = previewBuilder
            .withCustomerAvatar('https://example.com/avatar.jpg')
            .toJson();

        // Act
        final result = ChatPreviewModel.fromJson(json);

        // Assert
        expect(result.customerAvatar, 'https://example.com/avatar.jpg');
      });

      test('should parse unread count correctly', () {
        // Arrange
        final json = previewBuilder.withUnreadCount(5).toJson();

        // Act
        final result = ChatPreviewModel.fromJson(json);

        // Assert
        expect(result.unreadCount, 5);
      });

      test('should parse online status correctly', () {
        // Arrange
        final onlineJson = previewBuilder.withIsOnline(true).toJson();
        final offlineJson = previewBuilder.withIsOnline(false).toJson();

        // Act
        final onlineResult = ChatPreviewModel.fromJson(onlineJson);
        final offlineResult = ChatPreviewModel.fromJson(offlineJson);

        // Assert
        expect(onlineResult.isCustomerOnline, true);
        expect(offlineResult.isCustomerOnline, false);
      });

      test('should handle null last_message_time with default', () {
        // Arrange
        final beforeParse = DateTime.now();
        final json = {
          'customer_profile_id': 'profile-1',
          'customer_name': 'Test Customer',
        };

        // Act
        final result = ChatPreviewModel.fromJson(json);
        final afterParse = DateTime.now();

        // Assert
        expect(
          result.lastMessageTime.isAfter(beforeParse) ||
              result.lastMessageTime.isAtSameMomentAs(beforeParse),
          true,
        );
        expect(
          result.lastMessageTime.isBefore(afterParse) ||
              result.lastMessageTime.isAtSameMomentAs(afterParse),
          true,
        );
      });

      test('should handle numeric unread count as num type', () {
        // Arrange
        final json = {
          'customer_profile_id': 'profile-1',
          'customer_name': 'Test',
          'last_message': 'Hello',
          'last_message_time': '2024-01-01T10:00:00.000Z',
          'unread_count': 3.0, // Double value
          'is_online': false,
        };

        // Act
        final result = ChatPreviewModel.fromJson(json);

        // Assert
        expect(result.unreadCount, 3);
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        // Arrange
        final model = previewBuilder.buildModel();

        // Act
        final json = model.toJson();

        // Assert
        expect(
            json['customer_profile_id'], ChatTestConstants.customerProfileId1);
        expect(json['customer_name'], ChatTestConstants.customerName1);
        expect(json['last_message'], 'Last message text');
        expect(json['last_message_time'], isA<String>());
        expect(json['unread_count'], 0);
        expect(json['is_online'], false);
      });

      test('should include avatar when present', () {
        // Arrange
        final model = previewBuilder
            .withCustomerAvatar('https://example.com/avatar.jpg')
            .buildModel();

        // Act
        final json = model.toJson();

        // Assert
        expect(json['customer_avatar'], 'https://example.com/avatar.jpg');
      });
    });

    group('Entity Conversion', () {
      test('should extend ChatPreview entity', () {
        // Arrange
        final model = previewBuilder.buildModel();

        // Assert
        expect(model, isA<ChatPreview>());
      });

      test('should have same properties as entity', () {
        // Arrange
        final model = previewBuilder.buildModel();
        final entity = previewBuilder.build();

        // Assert
        expect(model.customerProfileId, entity.customerProfileId);
        expect(model.customerName, entity.customerName);
        expect(model.lastMessage, entity.lastMessage);
        expect(model.unreadCount, entity.unreadCount);
        expect(model.isCustomerOnline, entity.isCustomerOnline);
      });
    });

    group('timeAgo getter', () {
      test('should return "Just now" for recent messages', () {
        // Arrange
        final preview = previewBuilder
            .withLastMessageTime(DateTime.now().subtract(Duration(seconds: 30)))
            .build();

        // Act
        final timeAgo = preview.timeAgo;

        // Assert
        expect(timeAgo, 'Just now');
      });

      test('should return minutes for messages within an hour', () {
        // Arrange
        final preview = previewBuilder
            .withLastMessageTime(DateTime.now().subtract(Duration(minutes: 15)))
            .build();

        // Act
        final timeAgo = preview.timeAgo;

        // Assert
        expect(timeAgo, '15m ago');
      });

      test('should return hours for messages within a day', () {
        // Arrange
        final preview = previewBuilder
            .withLastMessageTime(DateTime.now().subtract(Duration(hours: 5)))
            .build();

        // Act
        final timeAgo = preview.timeAgo;

        // Assert
        expect(timeAgo, '5h ago');
      });

      test('should return days for messages within a week', () {
        // Arrange
        final preview = previewBuilder
            .withLastMessageTime(DateTime.now().subtract(Duration(days: 3)))
            .build();

        // Act
        final timeAgo = preview.timeAgo;

        // Assert
        expect(timeAgo, '3d ago');
      });

      test('should return date for messages older than a week', () {
        // Arrange
        final oldDate = DateTime(2024, 1, 15);
        final preview = previewBuilder.withLastMessageTime(oldDate).build();

        // Act
        final timeAgo = preview.timeAgo;

        // Assert
        expect(timeAgo, '15/1/2024');
      });
    });

    group('Preview Sorting', () {
      test('should sort previews by last message time', () {
        // Arrange
        final preview1 = previewBuilder
            .withCustomerProfileId('customer-1')
            .withLastMessageTime(DateTime(2024, 1, 1, 8, 0))
            .buildModel();

        final preview2 = previewBuilder
            .withCustomerProfileId('customer-2')
            .withLastMessageTime(DateTime(2024, 1, 1, 10, 0))
            .buildModel();

        final preview3 = previewBuilder
            .withCustomerProfileId('customer-3')
            .withLastMessageTime(DateTime(2024, 1, 1, 9, 0))
            .buildModel();

        // Act
        final previews = [preview1, preview2, preview3];
        previews.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

        // Assert - Most recent first
        expect(previews[0].customerProfileId, 'customer-2');
        expect(previews[1].customerProfileId, 'customer-3');
        expect(previews[2].customerProfileId, 'customer-1');
      });
    });

    group('Unread Count Display', () {
      test('should differentiate between read and unread conversations', () {
        // Arrange
        final readPreview = previewBuilder.withUnreadCount(0).buildModel();

        final unreadPreview = previewBuilder.withUnreadCount(5).buildModel();

        // Assert
        expect(readPreview.unreadCount, 0);
        expect(unreadPreview.unreadCount, 5);
        expect(unreadPreview.unreadCount > 0, true);
      });
    });
  });
}
