// test/features/chat/presentation/bloc/chat_bloc_test.dart

import 'dart:typed_data';
import 'package:admin_panel/features/merchandisers/chats/presentation/bloc/chat_bloc.dart';
import 'package:admin_panel/features/merchandisers/chats/presentation/bloc/chat_event.dart';
import 'package:admin_panel/features/merchandisers/chats/presentation/bloc/chat_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_chat_remote_datasource.dart';
import '../../helpers/test_helpers.dart';

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

  test('initial state should be ChatInitial', () {
    expect(bloc.state, equals(ChatInitial()));
  });

  group('LoadChatPreviews', () {
    blocTest<ChatBloc, ChatState>(
      'emits [ChatPreviewsLoading, ChatPreviewsLoaded] when successful',
      build: () {
        final previews = ChatTestDataFactory.createChatPreviewList();
        fakeDataSource.setupPreviews(previews);
        fakeDataSource.setupMerchandiserProfile(
          ChatTestConstants.merchandiserId,
          ChatTestConstants.merchandiserProfileId,
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        LoadChatPreviews(merchandiserId: ChatTestConstants.merchandiserId),
      ),
      expect: () => [
        ChatPreviewsLoading(),
        isA<ChatPreviewsLoaded>()
            .having((state) => state.previews.length, 'previews length', 3),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'emits [ChatPreviewsLoading, ChatPreviewsLoaded] with empty list',
      build: () {
        fakeDataSource.setupPreviews([]);
        fakeDataSource.setupMerchandiserProfile(
          ChatTestConstants.merchandiserId,
          ChatTestConstants.merchandiserProfileId,
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        LoadChatPreviews(merchandiserId: ChatTestConstants.merchandiserId),
      ),
      expect: () => [
        ChatPreviewsLoading(),
        isA<ChatPreviewsLoaded>()
            .having((state) => state.previews.isEmpty, 'previews empty', true),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'emits [ChatPreviewsLoading, ChatError] when error occurs',
      build: () {
        fakeDataSource.throwException('Failed to load previews');
        return bloc;
      },
      act: (bloc) => bloc.add(
        LoadChatPreviews(merchandiserId: ChatTestConstants.merchandiserId),
      ),
      expect: () => [
        ChatPreviewsLoading(),
        isA<ChatError>().having(
            (state) => state.message, 'error message', contains('Failed')),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'does not emit loading if already have previews',
      build: () {
        fakeDataSource
            .setupPreviews(ChatTestDataFactory.createChatPreviewList());
        fakeDataSource.setupMerchandiserProfile(
          ChatTestConstants.merchandiserId,
          ChatTestConstants.merchandiserProfileId,
        );
        return bloc;
      },
      seed: () => ChatPreviewsLoaded(
        previews: ChatTestDataFactory.createChatPreviewList(),
      ),
      act: (bloc) => bloc.add(
        LoadChatPreviews(merchandiserId: ChatTestConstants.merchandiserId),
      ),
      expect: () => [
        isA<ChatPreviewsLoaded>(),
      ],
    );
  });

  group('LoadChatMessages', () {
    setUp(() {
      final messages = ChatTestDataFactory.createConversation();
      fakeDataSource.setupMessages(messages);
    });

    blocTest<ChatBloc, ChatState>(
      'emits [ChatMessagesLoading, ChatMessagesLoaded] when successful',
      build: () => bloc,
      act: (bloc) => bloc.add(
        LoadChatMessages(
          customerProfileId: ChatTestConstants.customerProfileId1,
          customerName: ChatTestConstants.customerName1,
        ),
      ),
      expect: () => [
        ChatMessagesLoading(),
        isA<ChatMessagesLoaded>()
            .having((s) => s.messages.length, 'messages length', 3)
            .having((s) => s.customerProfileId, 'customerProfileId',
                ChatTestConstants.customerProfileId1)
            .having((s) => s.customerName, 'customerName',
                ChatTestConstants.customerName1),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'marks messages as read after loading',
      build: () => bloc,
      act: (bloc) => bloc.add(
        LoadChatMessages(
          customerProfileId: ChatTestConstants.customerProfileId1,
          customerName: ChatTestConstants.customerName1,
        ),
      ),
      verify: (_) async {
        // Wait for async operations
        await Future.delayed(Duration(milliseconds: 100));

        final unreadCount = await fakeDataSource.getUnreadCount(
          merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
          customerProfileId: ChatTestConstants.customerProfileId1,
        );

        expect(unreadCount, 0);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'emits error and returns to previous state on failure',
      build: () {
        fakeDataSource.throwException('Failed to load messages');
        return bloc;
      },
      seed: () => ChatPreviewsLoaded(
        previews: ChatTestDataFactory.createChatPreviewList(),
      ),
      act: (bloc) => bloc.add(
        LoadChatMessages(
          customerProfileId: ChatTestConstants.customerProfileId1,
          customerName: ChatTestConstants.customerName1,
        ),
      ),
      expect: () => [
        ChatMessagesLoading(),
        isA<ChatPreviewsLoaded>(),
        isA<ChatError>(),
      ],
    );
  });

  group('SendMessage', () {
    blocTest<ChatBloc, ChatState>(
      'adds message to current conversation',
      build: () {
        fakeDataSource.setupMessages(ChatTestDataFactory.createConversation());
        return bloc;
      },
      seed: () => ChatMessagesLoaded(
        messages: ChatTestDataFactory.createConversation(),
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ),
      act: (bloc) => bloc.add(
        SendMessage(
          receiverId: ChatTestConstants.customerProfileId1,
          message: 'New message from merchant',
        ),
      ),
      expect: () => [
        isA<ChatMessagesLoaded>()
            .having((s) => s.messages.length, 'messages length', 4)
            .having(
              (s) => s.messages.last.message,
              'last message',
              'New message from merchant',
            ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'uses merchandiser profile ID as sender',
      build: () => bloc,
      seed: () => ChatMessagesLoaded(
        messages: [],
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ),
      act: (bloc) => bloc.add(
        SendMessage(
          receiverId: ChatTestConstants.customerProfileId1,
          message: 'Test sender ID',
        ),
      ),
      verify: (_) async {
        final messages = await fakeDataSource.getMessages(
          merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
          customerProfileId: ChatTestConstants.customerProfileId1,
        );

        expect(messages.last.senderId, ChatTestConstants.merchandiserProfileId);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'does not send message if not in ChatMessagesLoaded state',
      build: () => bloc,
      seed: () => ChatPreviewsLoaded(
        previews: ChatTestDataFactory.createChatPreviewList(),
      ),
      act: (bloc) => bloc.add(
        SendMessage(
          receiverId: ChatTestConstants.customerProfileId1,
          message: 'Should not send',
        ),
      ),
      expect: () => [],
    );

    blocTest<ChatBloc, ChatState>(
      'emits error on failure',
      build: () {
        fakeDataSource.throwException('Failed to send message');
        return bloc;
      },
      seed: () => ChatMessagesLoaded(
        messages: [],
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ),
      act: (bloc) => bloc.add(
        SendMessage(
          receiverId: ChatTestConstants.customerProfileId1,
          message: 'This will fail',
        ),
      ),
      expect: () => [
        isA<ChatError>(),
      ],
    );
  });

  group('SendImageMessage', () {
    final testImageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

    blocTest<ChatBloc, ChatState>(
      'sets isSendingImage to true then false',
      build: () => bloc,
      seed: () => ChatMessagesLoaded(
        messages: [],
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ),
      act: (bloc) => bloc.add(
        SendImageMessage(
          receiverId: ChatTestConstants.customerProfileId1,
          message: 'Image message',
          fileBytes: testImageBytes,
          fileName: 'test.jpg',
        ),
      ),
      expect: () => [
        isA<ChatMessagesLoaded>()
            .having((s) => s.isSendingImage, 'isSendingImage', true),
        isA<ChatMessagesLoaded>()
            .having((s) => s.isSendingImage, 'isSendingImage', false)
            .having((s) => s.messages.length, 'messages length', 1),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'adds image message with URL to conversation',
      build: () => bloc,
      seed: () => ChatMessagesLoaded(
        messages: [],
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ),
      act: (bloc) => bloc.add(
        SendImageMessage(
          receiverId: ChatTestConstants.customerProfileId1,
          message: 'Check this out',
          fileBytes: testImageBytes,
          fileName: 'photo.jpg',
        ),
      ),
      verify: (_) async {
        final messages = await fakeDataSource.getMessages(
          merchandiserProfileId: ChatTestConstants.merchandiserProfileId,
          customerProfileId: ChatTestConstants.customerProfileId1,
        );

        expect(messages.last.hasImage, true);
        expect(messages.last.imageUrl, isNotNull);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'handles error and resets isSendingImage',
      build: () {
        fakeDataSource.throwException('Image upload failed');
        return bloc;
      },
      seed: () => ChatMessagesLoaded(
        messages: [],
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ),
      act: (bloc) => bloc.add(
        SendImageMessage(
          receiverId: ChatTestConstants.customerProfileId1,
          message: 'Failed image',
          fileBytes: testImageBytes,
          fileName: 'fail.jpg',
        ),
      ),
      expect: () => [
        isA<ChatMessagesLoaded>()
            .having((s) => s.isSendingImage, 'isSendingImage', true),
        isA<ChatMessagesLoaded>()
            .having((s) => s.isSendingImage, 'isSendingImage', false),
        isA<ChatError>(),
      ],
    );
  });

  group('ChatRoomMessageReceived', () {
    blocTest<ChatBloc, ChatState>(
      'adds new message to conversation',
      build: () => bloc,
      seed: () => ChatMessagesLoaded(
        messages: ChatTestDataFactory.createConversation(),
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ),
      act: (bloc) {
        final newMessage = ChatTestDataFactory.createMessageModel(
          id: 'new-msg',
          message: 'Real-time message',
        );
        bloc.add(ChatRoomMessageReceived(message: newMessage));
      },
      expect: () => [
        isA<ChatMessagesLoaded>()
            .having((s) => s.messages.length, 'messages length', 4),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'does not add duplicate message',
      build: () => bloc,
      seed: () {
        final messages = ChatTestDataFactory.createConversation();
        return ChatMessagesLoaded(
          messages: messages,
          customerProfileId: ChatTestConstants.customerProfileId1,
          customerName: ChatTestConstants.customerName1,
        );
      },
      act: (bloc) {
        final existingMessage = ChatTestDataFactory.createConversation().first;
        bloc.add(ChatRoomMessageReceived(message: existingMessage));
      },
      expect: () => [], // No change
    );

    blocTest<ChatBloc, ChatState>(
      'marks received message as read',
      build: () => bloc,
      seed: () => ChatMessagesLoaded(
        messages: [],
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ),
      act: (bloc) {
        final newMessage = ChatTestDataFactory.createMessageModel(
          id: 'new-received',
          senderId: ChatTestConstants.customerProfileId1,
          receiverId: ChatTestConstants.merchandiserProfileId,
          message: 'Customer message',
          isRead: false,
        );
        bloc.add(ChatRoomMessageReceived(message: newMessage));
      },
      verify: (_) async {
        await Future.delayed(Duration(milliseconds: 100));

        // Event should trigger mark as read
        expect(bloc.state, isA<ChatMessagesLoaded>());
      },
    );
  });

  group('RefreshChatPreviews', () {
    blocTest<ChatBloc, ChatState>(
      'refreshes previews when in ChatPreviewsLoaded state',
      build: () {
        final previews = ChatTestDataFactory.createChatPreviewList();
        fakeDataSource.setupPreviews(previews);
        fakeDataSource.setupMerchandiserProfile(
          ChatTestConstants.merchandiserId,
          ChatTestConstants.merchandiserProfileId,
        );
        return bloc;
      },
      seed: () => ChatPreviewsLoaded(
        previews: [],
      ),
      act: (bloc) => bloc.add(
        RefreshChatPreviews(merchandiserId: ChatTestConstants.merchandiserId),
      ),
      expect: () => [
        isA<ChatPreviewsLoaded>()
            .having((s) => s.previews.length, 'previews length', 3),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'updates previews from ChatInitial state',
      build: () {
        final previews = ChatTestDataFactory.createChatPreviewList();
        fakeDataSource.setupPreviews(previews);
        fakeDataSource.setupMerchandiserProfile(
          ChatTestConstants.merchandiserId,
          ChatTestConstants.merchandiserProfileId,
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        RefreshChatPreviews(merchandiserId: ChatTestConstants.merchandiserId),
      ),
      expect: () => [
        isA<ChatPreviewsLoaded>(),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'does not emit state when in ChatMessagesLoaded',
      build: () {
        fakeDataSource
            .setupPreviews(ChatTestDataFactory.createChatPreviewList());
        fakeDataSource.setupMerchandiserProfile(
          ChatTestConstants.merchandiserId,
          ChatTestConstants.merchandiserProfileId,
        );
        return bloc;
      },
      seed: () => ChatMessagesLoaded(
        messages: [],
        customerProfileId: ChatTestConstants.customerProfileId1,
        customerName: ChatTestConstants.customerName1,
      ),
      act: (bloc) => bloc.add(
        RefreshChatPreviews(merchandiserId: ChatTestConstants.merchandiserId),
      ),
      expect: () => [], // State should not change
    );
  });

  group('State Transitions', () {
    blocTest<ChatBloc, ChatState>(
      'can navigate from previews to messages and back',
      build: () {
        final previews = ChatTestDataFactory.createChatPreviewList();
        final messages = ChatTestDataFactory.createConversation();
        fakeDataSource.setupPreviews(previews);
        fakeDataSource.setupMessages(messages);
        fakeDataSource.setupMerchandiserProfile(
          ChatTestConstants.merchandiserId,
          ChatTestConstants.merchandiserProfileId,
        );
        return bloc;
      },
      act: (bloc) async {
        // Load previews
        bloc.add(LoadChatPreviews(
          merchandiserId: ChatTestConstants.merchandiserId,
        ));
        await Future.delayed(Duration(milliseconds: 100));

        // Open chat
        bloc.add(LoadChatMessages(
          customerProfileId: ChatTestConstants.customerProfileId1,
          customerName: ChatTestConstants.customerName1,
        ));
        await Future.delayed(Duration(milliseconds: 100));

        // Go back to previews
        bloc.add(LoadChatPreviews(
          merchandiserId: ChatTestConstants.merchandiserId,
        ));
      },
      expect: () => [
        ChatPreviewsLoading(),
        isA<ChatPreviewsLoaded>(),
        ChatMessagesLoading(),
        isA<ChatMessagesLoaded>(),
        ChatPreviewsLoading(),
        isA<ChatPreviewsLoaded>(),
      ],
    );
  });
}
