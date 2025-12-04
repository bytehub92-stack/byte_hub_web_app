// test/features/chat/data/datasources/chat_remote_datasource_test.dart

import 'dart:typed_data';
import 'package:admin_panel/features/merchandisers/chats/data/models/chat_preview_model.dart';
import 'package:admin_panel/features/merchandisers/chats/data/models/message_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_chat_remote_datasource.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late FakeChatRemoteDataSource dataSource;

  setUp(() {
    dataSource = FakeChatRemoteDataSource();
  });

  tearDown(() {
    dataSource.reset();
  });

  group('getChatPreviews', () {
    test('should return list of chat previews for merchandiser', () async {
      // Arrange
      final previews = ChatTestDataFactory.createChatPreviewList();
      dataSource.setupPreviews(previews);
      dataSource.setupMerchandiserProfile(
        ChatTestConstants.merchandiserId,
        ChatTestConstants.merchandiserProfileId,
      );

      // Act
      final result = await dataSource.getChatPreviews(
        merchandiserId: ChatTestConstants.merchandiserId,
      );

      // Assert
      expect(result, isA<List<ChatPreviewModel>>());
      expect(result.length, 3);
      expect(result[0].customerProfileId, ChatTestConstants.customerProfileId1);
      expect(result[1].customerProfileId, ChatTestConstants.customerProfileId2);
      expect(result[2].customerProfileId, ChatTestConstants.customerProfileId3);
    });

    test('should return empty list when no previews exist', () async {
      // Arrange
      dataSource.setupPreviews([]);
      dataSource.setupMerchandiserProfile(
        ChatTestConstants.merchandiserId,
        ChatTestConstants.merchandiserProfileId,
      );

      // Act
      final result = await dataSource.getChatPreviews(
        merchandiserId: ChatTestConstants.merchandiserId,
      );

      // Assert
      expect(result.isEmpty, true);
    });

    test('should throw exception when merchandiser not found', () async {
      // Arrange - Don't setup merchandiser profile

      // Act & Assert
      expect(
        () => dataSource.getChatPreviews(
          merchandiserId: 'non-existent-id',
        ),
        throwsException,
      );
    });

    test('should throw exception when error occurs', () async {
      // Arrange
      dataSource.throwException('Database connection failed');

      // Act & Assert
      expect(
        () => dataSource.getChatPreviews(
          merchandiserId: ChatTestConstants.merchandiserId,
        ),
        throwsException,
      );
    });
  });

  group('getMessages', () {
    setUp(() {
      final messages = ChatTestDataFactory.createConversation();
      dataSource.setupMessages(messages);
    });

    test('should return messages between merchandiser and customer', () async {
      // Act
      final result = await dataSource.getMessages(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId1,
      );

      // Assert
      expect(result, isA<List<MessageModel>>());
      expect(result.length, 3);
    });

    test('should sort messages by creation time ascending', () async {
      // Act
      final result = await dataSource.getMessages(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId1,
      );

      // Assert
      expect(result[0].message, 'Hello!');
      expect(result[1].message, 'Hi, how can I help?');
      expect(result[2].message, 'I have a question about my order');
    });

    test('should return empty list when no messages exist', () async {
      // Arrange
      dataSource.setupMessages([]);

      // Act
      final result = await dataSource.getMessages(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: 'non-existent-customer',
      );

      // Assert
      expect(result.isEmpty, true);
    });

    test('should only return messages for specific conversation', () async {
      // Arrange - Add messages from different customer
      final otherCustomerMessage = TestMessageBuilder()
          .withId('other-msg')
          .withSenderId(ChatTestConstants.customerProfileId2)
          .withReceiverId(ChatTestConstants.merchandiserProfileId)
          .withMessage('Message from another customer')
          .buildModel();
      dataSource.setupMessages([
        ...ChatTestDataFactory.createConversation(),
        otherCustomerMessage,
      ]);

      // Act
      final result = await dataSource.getMessages(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId1,
      );

      // Assert
      expect(result.length, 3);
      expect(
        result.every((msg) =>
            msg.senderId == ChatTestConstants.customerProfileId1 ||
            msg.receiverId == ChatTestConstants.customerProfileId1),
        true,
      );
    });
  });

  group('sendMessage', () {
    setUp(() {
      dataSource.setupCustomerName(
        ChatTestConstants.merchandiserProfileId,
        'Test Merchandiser',
      );
    });

    test('should send text message successfully', () async {
      // Act
      final result = await dataSource.sendMessage(
        senderId: ChatTestConstants.merchandiserProfileId,
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Hello customer!',
      );

      // Assert
      expect(result, isA<MessageModel>());
      expect(result.senderId, ChatTestConstants.merchandiserProfileId);
      expect(result.receiverId, ChatTestConstants.customerProfileId1);
      expect(result.message, 'Hello customer!');
      expect(result.isRead, false);
      expect(result.imageUrl, null);
    });

    test('should add sent message to messages list', () async {
      // Act
      await dataSource.sendMessage(
        senderId: ChatTestConstants.merchandiserProfileId,
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Test message',
      );

      // Verify
      final messages = await dataSource.getMessages(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId1,
      );

      expect(messages.length, 1);
      expect(messages.first.message, 'Test message');
    });

    test('should send notification when message is sent', () async {
      // Act
      await dataSource.sendMessage(
        senderId: ChatTestConstants.merchandiserProfileId,
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Test notification',
      );

      // Assert
      expect(
        dataSource.wasNotificationSent(
          ChatTestConstants.customerProfileId1,
          ChatTestConstants.merchandiserProfileId,
        ),
        true,
      );
    });

    test('should create message with current timestamp', () async {
      // Arrange
      final beforeSend = DateTime.now();

      // Act
      final result = await dataSource.sendMessage(
        senderId: ChatTestConstants.merchandiserProfileId,
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Timestamp test',
      );

      final afterSend = DateTime.now();

      // Assert
      expect(
        result.createdAt.isAfter(beforeSend) ||
            result.createdAt.isAtSameMomentAs(beforeSend),
        true,
      );
      expect(
        result.createdAt.isBefore(afterSend) ||
            result.createdAt.isAtSameMomentAs(afterSend),
        true,
      );
    });
  });

  group('sendImageMessage', () {
    setUp(() {
      dataSource.setupCustomerName(
        ChatTestConstants.merchandiserProfileId,
        'Test Merchandiser',
      );
    });

    test('should send image message successfully', () async {
      // Arrange
      final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      // Act
      final result = await dataSource.sendImageMessage(
        senderId: ChatTestConstants.merchandiserProfileId,
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Check out this image',
        fileBytes: imageBytes,
        fileName: 'test-image.jpg',
      );

      // Assert
      expect(result, isA<MessageModel>());
      expect(result.message, 'Check out this image');
      expect(result.imageUrl, isNotNull);
      expect(result.hasImage, true);
    });

    test('should upload image to storage', () async {
      // Arrange
      final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      // Act
      await dataSource.sendImageMessage(
        senderId: ChatTestConstants.merchandiserProfileId,
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Image test',
        fileBytes: imageBytes,
        fileName: 'test-upload.jpg',
      );

      // Assert
      expect(dataSource.hasUploadedImage('test-upload.jpg'), true);
    });

    test('should send notification with image indicator', () async {
      // Arrange
      final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      // Act
      await dataSource.sendImageMessage(
        senderId: ChatTestConstants.merchandiserProfileId,
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Image notification test',
        fileBytes: imageBytes,
        fileName: 'notification-test.jpg',
      );

      // Assert
      expect(
        dataSource.wasNotificationSent(
          ChatTestConstants.customerProfileId1,
          ChatTestConstants.merchandiserProfileId,
        ),
        true,
      );
    });

    test('should generate unique file path for each image', () async {
      // Arrange
      final imageBytes = Uint8List.fromList([1, 2, 3]);

      // Act
      final result1 = await dataSource.sendImageMessage(
        senderId: ChatTestConstants.merchandiserProfileId,
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Image 1',
        fileBytes: imageBytes,
        fileName: 'image1.jpg',
      );

      await Future.delayed(Duration(milliseconds: 10));

      final result2 = await dataSource.sendImageMessage(
        senderId: ChatTestConstants.merchandiserProfileId,
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Image 2',
        fileBytes: imageBytes,
        fileName: 'image2.jpg',
      );

      // Assert
      expect(result1.imageUrl, isNot(equals(result2.imageUrl)));
    });
  });

  group('markAllAsRead', () {
    setUp(() {
      final messages = [
        TestMessageBuilder()
            .withId('msg-1')
            .withSenderId(ChatTestConstants.customerProfileId1)
            .withReceiverId(ChatTestConstants.merchandiserProfileId)
            .withIsRead(false)
            .buildModel(),
        TestMessageBuilder()
            .withId('msg-2')
            .withSenderId(ChatTestConstants.customerProfileId1)
            .withReceiverId(ChatTestConstants.merchandiserProfileId)
            .withIsRead(false)
            .buildModel(),
        TestMessageBuilder()
            .withId('msg-3')
            .withSenderId(ChatTestConstants.merchandiserProfileId)
            .withReceiverId(ChatTestConstants.customerProfileId1)
            .withIsRead(false)
            .buildModel(),
      ];
      dataSource.setupMessages(messages);
    });

    test('should mark messages as read', () async {
      // Act
      await dataSource.markAllAsRead(
        senderId: ChatTestConstants.customerProfileId1,
        receiverId: ChatTestConstants.merchandiserProfileId,
      );

      // Verify
      final messages = await dataSource.getMessages(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId1,
      );

      final customerMessages = messages.where(
        (msg) => msg.senderId == ChatTestConstants.customerProfileId1,
      );

      expect(customerMessages.every((msg) => msg.isRead), true);
    });

    test('should only mark messages from specific sender', () async {
      // Act
      await dataSource.markAllAsRead(
        senderId: ChatTestConstants.customerProfileId1,
        receiverId: ChatTestConstants.merchandiserProfileId,
      );

      // Verify
      final messages = await dataSource.getMessages(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId1,
      );

      final merchantMessages = messages.where(
        (msg) => msg.senderId == ChatTestConstants.merchandiserProfileId,
      );

      // Merchant's own messages should not be affected
      expect(merchantMessages.any((msg) => !msg.isRead), true);
    });
  });

  group('getUnreadCount', () {
    setUp(() {
      final messages = [
        TestMessageBuilder()
            .withSenderId(ChatTestConstants.customerProfileId1)
            .withReceiverId(ChatTestConstants.merchandiserProfileId)
            .withIsRead(false)
            .buildModel(),
        TestMessageBuilder()
            .withSenderId(ChatTestConstants.customerProfileId1)
            .withReceiverId(ChatTestConstants.merchandiserProfileId)
            .withIsRead(false)
            .buildModel(),
        TestMessageBuilder()
            .withSenderId(ChatTestConstants.customerProfileId1)
            .withReceiverId(ChatTestConstants.merchandiserProfileId)
            .withIsRead(true)
            .buildModel(),
      ];
      dataSource.setupMessages(messages);
    });

    test('should return correct unread count', () async {
      // Act
      final count = await dataSource.getUnreadCount(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId1,
      );

      // Assert
      expect(count, 2);
    });

    test('should return 0 when all messages are read', () async {
      // Arrange
      await dataSource.markAllAsRead(
        senderId: ChatTestConstants.customerProfileId1,
        receiverId: ChatTestConstants.merchandiserProfileId,
      );

      // Act
      final count = await dataSource.getUnreadCount(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId1,
      );

      // Assert
      expect(count, 0);
    });

    test('should return 0 on error', () async {
      // Arrange
      dataSource.throwException('Database error');

      // Act
      final count = await dataSource.getUnreadCount(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId1,
      );

      // Assert
      expect(count, 0); // Should not throw, returns 0
    });
  });

  group('Notification Handling', () {
    test('should truncate long messages in notification', () async {
      // Arrange
      dataSource.setupCustomerName(
        ChatTestConstants.merchandiserProfileId,
        'Test User',
      );
      final longMessage = 'This is a very long message ' * 10;

      // Act
      await dataSource.sendMessage(
        senderId: ChatTestConstants.merchandiserProfileId,
        receiverId: ChatTestConstants.customerProfileId1,
        message: longMessage,
      );

      // Assert
      expect(dataSource.sentNotifications.isNotEmpty, true);
      final notification = dataSource.sentNotifications.first;
      final messagePreview = notification['body']['en'] as String;
      expect(messagePreview.length, lessThanOrEqualTo(53)); // 50 + "..."
    });

    test('should include sender name in notification', () async {
      // Arrange
      dataSource.setupCustomerName(
        ChatTestConstants.merchandiserProfileId,
        'John Merchant',
      );

      // Act
      await dataSource.sendMessage(
        senderId: ChatTestConstants.merchandiserProfileId,
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Test',
      );

      // Assert
      final notification = dataSource.sentNotifications.first;
      final title = notification['title']['en'] as String;
      expect(title, contains('John Merchant'));
    });
  });
}
