// test/features/chat/data/models/message_model_test.dart

import 'package:admin_panel/features/merchandisers/chats/data/models/message_model.dart';
import 'package:admin_panel/features/merchandisers/chats/domain/entities/message.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('MessageModel', () {
    late TestMessageBuilder messageBuilder;

    setUp(() {
      messageBuilder = TestMessageBuilder();
    });

    group('fromJson', () {
      test('should parse complete JSON correctly', () {
        // Arrange
        final json = messageBuilder.toJson();

        // Act
        final result = MessageModel.fromJson(json);

        // Assert
        expect(result.id, ChatTestConstants.messageId1);
        expect(result.senderId, ChatTestConstants.customerProfileId1);
        expect(result.receiverId, ChatTestConstants.merchandiserProfileId);
        expect(result.message, 'Hello, this is a test message');
        expect(result.imageUrl, null);
        expect(result.isRead, false);
        expect(result.createdAt, DateTime(2024, 1, 1, 10, 0));
      });

      test('should parse message with image URL', () {
        // Arrange
        final json = messageBuilder
            .withImageUrl(ChatTestConstants.testImageUrl)
            .toJson();

        // Act
        final result = MessageModel.fromJson(json);

        // Assert
        expect(result.imageUrl, ChatTestConstants.testImageUrl);
        expect(result.hasImage, true);
      });

      test('should handle missing optional fields', () {
        // Arrange
        final json = {
          'id': 'msg-1',
          'sender_id': 'sender-1',
          'receiver_id': 'receiver-1',
          'created_at': '2024-01-01T10:00:00.000Z',
        };

        // Act
        final result = MessageModel.fromJson(json);

        // Assert
        expect(result.id, 'msg-1');
        expect(result.senderId, 'sender-1');
        expect(result.receiverId, 'receiver-1');
        expect(result.message, ''); // Default empty string
        expect(result.imageUrl, null);
        expect(result.isRead, false); // Default false
      });

      test('should default to current time if created_at is null', () {
        // Arrange
        final beforeParse = DateTime.now();
        final json = {
          'id': 'msg-1',
          'sender_id': 'sender-1',
          'receiver_id': 'receiver-1',
          'message': 'Test',
        };

        // Act
        final result = MessageModel.fromJson(json);
        final afterParse = DateTime.now();

        // Assert
        expect(
          result.createdAt.isAfter(beforeParse) ||
              result.createdAt.isAtSameMomentAs(beforeParse),
          true,
        );
        expect(
          result.createdAt.isBefore(afterParse) ||
              result.createdAt.isAtSameMomentAs(afterParse),
          true,
        );
      });

      test('should handle read and unread messages', () {
        // Read message
        final readJson = messageBuilder.withIsRead(true).toJson();
        final readMessage = MessageModel.fromJson(readJson);
        expect(readMessage.isRead, true);

        // Unread message
        final unreadJson = messageBuilder.withIsRead(false).toJson();
        final unreadMessage = MessageModel.fromJson(unreadJson);
        expect(unreadMessage.isRead, false);
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        // Arrange
        final model = messageBuilder.buildModel();

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], ChatTestConstants.messageId1);
        expect(json['sender_id'], ChatTestConstants.customerProfileId1);
        expect(json['receiver_id'], ChatTestConstants.merchandiserProfileId);
        expect(json['message'], 'Hello, this is a test message');
        expect(json['image_url'], null);
        expect(json['is_read'], false);
        expect(json['created_at'], isA<String>());
      });

      test('should include image URL when present', () {
        // Arrange
        final model = messageBuilder
            .withImageUrl(ChatTestConstants.testImageUrl)
            .buildModel();

        // Act
        final json = model.toJson();

        // Assert
        expect(json['image_url'], ChatTestConstants.testImageUrl);
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        // Arrange
        final original = messageBuilder.buildModel();

        // Act
        final copied = original.copyWith(
          message: 'Updated message',
          isRead: true,
        );

        // Assert
        expect(copied.id, original.id);
        expect(copied.senderId, original.senderId);
        expect(copied.receiverId, original.receiverId);
        expect(copied.message, 'Updated message');
        expect(copied.isRead, true);
        expect(copied.createdAt, original.createdAt);
      });

      test('should keep original values when not specified', () {
        // Arrange
        final original = messageBuilder
            .withImageUrl(ChatTestConstants.testImageUrl)
            .withIsRead(true)
            .buildModel();

        // Act
        final copied = original.copyWith(message: 'New message');

        // Assert
        expect(copied.message, 'New message');
        expect(copied.imageUrl, original.imageUrl);
        expect(copied.isRead, original.isRead);
        expect(copied.senderId, original.senderId);
      });
    });

    group('Entity Conversion', () {
      test('should extend Message entity', () {
        // Arrange
        final model = messageBuilder.buildModel();

        // Assert
        expect(model, isA<Message>());
      });

      test('should have same properties as entity', () {
        // Arrange
        final model = messageBuilder.buildModel();
        final entity = messageBuilder.build();

        // Assert
        expect(model.id, entity.id);
        expect(model.senderId, entity.senderId);
        expect(model.receiverId, entity.receiverId);
        expect(model.message, entity.message);
        expect(model.isRead, entity.isRead);
        expect(model.createdAt, entity.createdAt);
      });
    });

    group('hasImage getter', () {
      test('should return true when image URL exists', () {
        // Arrange
        final model = messageBuilder
            .withImageUrl(ChatTestConstants.testImageUrl)
            .buildModel();

        // Assert
        expect(model.hasImage, true);
      });

      test('should return false when image URL is null', () {
        // Arrange
        final model = messageBuilder.withImageUrl(null).buildModel();

        // Assert
        expect(model.hasImage, false);
      });
    });

    group('Message Ordering', () {
      test('should compare messages by creation time', () {
        // Arrange
        final message1 = messageBuilder
            .withId('msg-1')
            .withCreatedAt(DateTime(2024, 1, 1, 10, 0))
            .buildModel();

        final message2 = messageBuilder
            .withId('msg-2')
            .withCreatedAt(DateTime(2024, 1, 1, 10, 5))
            .buildModel();

        final message3 = messageBuilder
            .withId('msg-3')
            .withCreatedAt(DateTime(2024, 1, 1, 10, 3))
            .buildModel();

        // Act
        final messages = [message2, message1, message3];
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        // Assert
        expect(messages[0].id, 'msg-1');
        expect(messages[1].id, 'msg-3');
        expect(messages[2].id, 'msg-2');
      });
    });
  });
}
