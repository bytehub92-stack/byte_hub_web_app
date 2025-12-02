// test/features/chat/integration/chat_integration_test.dart

import 'dart:typed_data';
import 'package:admin_panel/features/merchandisers/chats/presentation/bloc/chat_bloc.dart';
import 'package:admin_panel/features/merchandisers/chats/presentation/bloc/chat_event.dart';
import 'package:admin_panel/features/merchandisers/chats/presentation/bloc/chat_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_chat_remote_datasource.dart';
import '../helpers/test_helpers.dart';

void main() {
  late ChatBloc bloc;
  late FakeChatRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeChatRemoteDataSource();
    bloc = ChatBloc(
      dataSource: fakeDataSource,
      merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
    );
  });

  tearDown(() {
    bloc.close();
    fakeDataSource.reset();
  });

  group('Complete Chat Workflow', () {
    test(
        'should handle full chat session: load previews → open chat → send messages',
        () async {
      // Setup
      final previews = ChatTestDataFactory.createChatPreviewList();
      final messages = ChatTestDataFactory.createConversation();
      fakeDataSource.setupPreviews(previews);
      fakeDataSource.setupMessages(messages);
      fakeDataSource.setupMerchandiserProfile(
        ChatTestConstants.merchandiserId,
        ChatTestConstants.merchandiserProfileId,
      );

      // 1. Load chat previews
      bloc.add(LoadChatPreviews(
        merchandiserId: ChatTestConstants.merchandiserId,
      ));
      await Future.delayed(Duration(milliseconds: 100));

      expect(bloc.state, isA<ChatPreviewsLoaded>());
      final previewsState = bloc.state as ChatPreviewsLoaded;
      expect(previewsState.previews.length, 3);
      expect(previewsState.previews.first.unreadCount, 3);

      // 2. Open specific chat
      bloc.add(LoadChatMessages(
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ));
      await Future.delayed(Duration(milliseconds: 100));

      expect(bloc.state, isA<ChatMessagesLoaded>());
      final messagesState = bloc.state as ChatMessagesLoaded;
      expect(messagesState.messages.length, 3);
      expect(messagesState.customerProfileId,
          ChatTestConstants.customerProfileId1);

      // 3. Send text message
      bloc.add(SendMessage(
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Hello customer!',
      ));
      await Future.delayed(Duration(milliseconds: 100));

      expect(bloc.state, isA<ChatMessagesLoaded>());
      final afterSendState = bloc.state as ChatMessagesLoaded;
      expect(afterSendState.messages.length, 4);
      expect(afterSendState.messages.last.message, 'Hello customer!');

      // 4. Verify message persisted in data source
      final allMessages = await fakeDataSource.getMessages(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId1,
      );
      expect(allMessages.length, 4);
    });

    test('should handle multiple conversations simultaneously', () async {
      // Setup
      fakeDataSource.setupPreviews(ChatTestDataFactory.createChatPreviewList());
      fakeDataSource.setupMessages([]);
      fakeDataSource.setupMerchandiserProfile(
        ChatTestConstants.merchandiserId,
        ChatTestConstants.merchandiserProfileId,
      );

      // 1. Load previews
      bloc.add(LoadChatPreviews(
        merchandiserId: ChatTestConstants.merchandiserId,
      ));
      await Future.delayed(Duration(milliseconds: 100));
      expect(bloc.state, isA<ChatPreviewsLoaded>());

      // 2. Open first chat
      bloc.add(LoadChatMessages(
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ));
      await Future.delayed(Duration(milliseconds: 100));

      // 3. Send message to customer 1
      bloc.add(SendMessage(
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Message for customer 1',
      ));
      await Future.delayed(Duration(milliseconds: 100));

      // 4. Switch to customer 2
      bloc.add(LoadChatMessages(
        customerProfileId: ChatTestConstants.customerProfileId2,
        customerName: ChatTestConstants.customerName2,
      ));
      await Future.delayed(Duration(milliseconds: 100));

      expect(bloc.state, isA<ChatMessagesLoaded>());
      final customer2State = bloc.state as ChatMessagesLoaded;
      expect(customer2State.customerProfileId,
          ChatTestConstants.customerProfileId2);
      expect(customer2State.messages.isEmpty, true);

      // 5. Send message to customer 2
      bloc.add(SendMessage(
        receiverId: ChatTestConstants.customerProfileId2,
        message: 'Message for customer 2',
      ));
      await Future.delayed(Duration(milliseconds: 100));

      // 6. Verify both conversations exist
      final customer1Messages = await fakeDataSource.getMessages(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId1,
      );
      final customer2Messages = await fakeDataSource.getMessages(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId2,
      );

      expect(customer1Messages.length, 1);
      expect(customer2Messages.length, 1);
    });

    test('should handle image sending workflow', () async {
      // Setup
      fakeDataSource.setupMessages([]);
      fakeDataSource.setupMerchandiserProfile(
        ChatTestConstants.merchandiserId,
        ChatTestConstants.merchandiserProfileId,
      );

      // 1. Open chat
      bloc.add(LoadChatMessages(
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ));
      await Future.delayed(Duration(milliseconds: 100));

      // 2. Send image
      final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      bloc.add(SendImageMessage(
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Product image',
        fileBytes: imageBytes,
        fileName: 'product.jpg',
      ));
      await Future.delayed(Duration(milliseconds: 100));

      // 3. Verify sending state
      expect(bloc.state, isA<ChatMessagesLoaded>());
      final state = bloc.state as ChatMessagesLoaded;
      expect(state.isSendingImage, false);
      expect(state.messages.length, 1);
      expect(state.messages.first.hasImage, true);

      // 4. Verify image uploaded
      expect(fakeDataSource.hasUploadedImage('product.jpg'), true);
    });
  });

  group('Unread Messages Workflow', () {
    test('should mark messages as read when opening chat', () async {
      // Setup with unread messages
      final unreadMessages = [
        ChatTestDataFactory.createMessageModel(
          id: 'msg-1',
          senderId: ChatTestConstants.customerProfileId1,
          receiverId: ChatTestConstants.merchandiserProfileId,
          isRead: false,
        ),
        ChatTestDataFactory.createMessageModel(
          id: 'msg-2',
          senderId: ChatTestConstants.customerProfileId1,
          receiverId: ChatTestConstants.merchandiserProfileId,
          isRead: false,
        ),
        ChatTestDataFactory.createMessageModel(
          id: 'msg-3',
          senderId: ChatTestConstants.customerProfileId1,
          receiverId: ChatTestConstants.merchandiserProfileId,
          isRead: false,
        ),
      ];
      fakeDataSource.setupMessages(unreadMessages);

      // 1. Check initial unread count
      final initialUnreadCount = await fakeDataSource.getUnreadCount(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId1,
      );
      expect(initialUnreadCount, 3);

      // 2. Open chat (should trigger mark as read)
      bloc.add(LoadChatMessages(
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ));
      await Future.delayed(Duration(milliseconds: 200));

      // 3. Verify messages marked as read
      final finalUnreadCount = await fakeDataSource.getUnreadCount(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId1,
      );
      expect(finalUnreadCount, 0);
    });

    test('should track unread count per customer', () async {
      // Setup messages from multiple customers
      final messages = [
        // Customer 1 - 2 unread
        ChatTestDataFactory.createMessageModel(
          id: 'msg-1',
          senderId: ChatTestConstants.customerProfileId1,
          receiverId: ChatTestConstants.merchandiserProfileId,
          isRead: false,
        ),
        ChatTestDataFactory.createMessageModel(
          id: 'msg-2',
          senderId: ChatTestConstants.customerProfileId1,
          receiverId: ChatTestConstants.merchandiserProfileId,
          isRead: false,
        ),
        // Customer 2 - 1 unread
        ChatTestDataFactory.createMessageModel(
          id: 'msg-3',
          senderId: ChatTestConstants.customerProfileId2,
          receiverId: ChatTestConstants.merchandiserProfileId,
          isRead: false,
        ),
      ];
      fakeDataSource.setupMessages(messages);

      // Check unread counts
      final customer1Unread = await fakeDataSource.getUnreadCount(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId1,
      );
      final customer2Unread = await fakeDataSource.getUnreadCount(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId2,
      );

      expect(customer1Unread, 2);
      expect(customer2Unread, 1);

      // Mark customer 1 as read
      await fakeDataSource.markAllAsRead(
        senderId: ChatTestConstants.customerProfileId1,
        receiverId: ChatTestConstants.merchandiserProfileId,
      );

      // Verify only customer 1 messages marked
      final customer1AfterRead = await fakeDataSource.getUnreadCount(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId1,
      );
      final customer2AfterRead = await fakeDataSource.getUnreadCount(
        merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
        customerProfileId: ChatTestConstants.customerProfileId2,
      );

      expect(customer1AfterRead, 0);
      expect(customer2AfterRead, 1); // Still unread
    });
  });

  group('Real-time Message Updates', () {
    test('should add received message to active chat', () async {
      // Setup active chat
      fakeDataSource.setupMessages([]);
      bloc.add(LoadChatMessages(
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ));
      await Future.delayed(Duration(milliseconds: 100));

      expect(bloc.state, isA<ChatMessagesLoaded>());
      final initialState = bloc.state as ChatMessagesLoaded;
      expect(initialState.messages.length, 0);

      // Simulate receiving message
      final receivedMessage = ChatTestDataFactory.createMessageModel(
        id: 'received-msg',
        senderId: ChatTestConstants.customerProfileId1,
        receiverId: ChatTestConstants.merchandiserProfileId,
        message: 'Message from customer',
      );

      bloc.add(ChatRoomMessageReceived(message: receivedMessage));
      await Future.delayed(Duration(milliseconds: 100));

      // Verify message added
      final updatedState = bloc.state as ChatMessagesLoaded;
      expect(updatedState.messages.length, 1);
      expect(updatedState.messages.first.message, 'Message from customer');
    });

    test('should not duplicate messages', () async {
      // Setup chat with existing messages
      final existingMessages = ChatTestDataFactory.createConversation();
      fakeDataSource.setupMessages(existingMessages);

      bloc.add(LoadChatMessages(
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ));
      await Future.delayed(Duration(milliseconds: 100));

      final initialState = bloc.state as ChatMessagesLoaded;
      final initialCount = initialState.messages.length;

      // Try to add duplicate message
      bloc.add(ChatRoomMessageReceived(
        message: existingMessages.first,
      ));
      await Future.delayed(Duration(milliseconds: 100));

      // Verify no duplicate
      final finalState = bloc.state as ChatMessagesLoaded;
      expect(finalState.messages.length, initialCount);
    });
  });

  group('Error Recovery', () {
    test('should recover from failed message send', () async {
      // Setup
      fakeDataSource.setupMessages([]);
      bloc.add(LoadChatMessages(
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ));
      await Future.delayed(Duration(milliseconds: 100));

      // 1. Try to send message (will fail)
      fakeDataSource.throwException('Network error');
      bloc.add(SendMessage(
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'This will fail',
      ));
      await Future.delayed(Duration(milliseconds: 100));

      expect(bloc.state, isA<ChatError>());

      // 2. Fix error and reload
      fakeDataSource.reset();
      fakeDataSource.setupMessages([]);
      bloc.add(LoadChatMessages(
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ));
      await Future.delayed(Duration(milliseconds: 100));

      expect(bloc.state, isA<ChatMessagesLoaded>());

      // 3. Successfully send message
      bloc.add(SendMessage(
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'This should work',
      ));
      await Future.delayed(Duration(milliseconds: 100));

      final finalState = bloc.state as ChatMessagesLoaded;
      expect(finalState.messages.length, 1);
    });

    test('should recover from failed image upload', () async {
      // Setup
      fakeDataSource.setupMessages([]);
      bloc.add(LoadChatMessages(
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ));
      await Future.delayed(Duration(milliseconds: 100));

      // 1. Try to send image (will fail)
      fakeDataSource.throwException('Upload failed');
      final imageBytes = Uint8List.fromList([1, 2, 3]);
      bloc.add(SendImageMessage(
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Failed image',
        fileBytes: imageBytes,
        fileName: 'fail.jpg',
      ));
      await Future.delayed(Duration(milliseconds: 100));

      final failedState = bloc.state as ChatMessagesLoaded;
      expect(failedState.isSendingImage, false);

      // 2. Fix and retry
      fakeDataSource.reset();
      fakeDataSource.setupMessages([]);
      bloc.add(LoadChatMessages(
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ));
      await Future.delayed(Duration(milliseconds: 100));

      bloc.add(SendImageMessage(
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Success image',
        fileBytes: imageBytes,
        fileName: 'success.jpg',
      ));
      await Future.delayed(Duration(milliseconds: 100));

      final successState = bloc.state as ChatMessagesLoaded;
      expect(successState.messages.length, 1);
      expect(successState.messages.first.hasImage, true);
    });
  });

  group('Notification System', () {
    test('should send notification when message is sent', () async {
      // Setup
      fakeDataSource.setupMessages([]);
      fakeDataSource.setupCustomerName(
        ChatTestConstants.merchandiserProfileId,
        'Test Merchant',
      );

      bloc.add(LoadChatMessages(
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ));
      await Future.delayed(Duration(milliseconds: 100));

      // Send message
      bloc.add(SendMessage(
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Test notification',
      ));
      await Future.delayed(Duration(milliseconds: 100));

      // Verify notification sent
      expect(
        fakeDataSource.wasNotificationSent(
          ChatTestConstants.customerProfileId1,
          ChatTestConstants.merchandiserProfileId,
        ),
        true,
      );
    });

    test('should send notification for image messages', () async {
      // Setup
      fakeDataSource.setupMessages([]);
      fakeDataSource.setupCustomerName(
        ChatTestConstants.merchandiserProfileId,
        'Test Merchant',
      );

      bloc.add(LoadChatMessages(
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ));
      await Future.delayed(Duration(milliseconds: 100));

      // Send image
      final imageBytes = Uint8List.fromList([1, 2, 3]);
      bloc.add(SendImageMessage(
        receiverId: ChatTestConstants.customerProfileId1,
        message: 'Image notification',
        fileBytes: imageBytes,
        fileName: 'notify.jpg',
      ));
      await Future.delayed(Duration(milliseconds: 100));

      // Verify notification sent
      expect(fakeDataSource.sentNotifications.isNotEmpty, true);
    });
  });
}
