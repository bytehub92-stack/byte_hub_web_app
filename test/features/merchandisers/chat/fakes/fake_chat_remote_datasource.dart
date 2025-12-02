// test/features/chat/fakes/fake_chat_remote_datasource.dart

import 'dart:typed_data';

import 'package:admin_panel/features/merchandisers/chats/data/datasources/chat_remote_datasource.dart';
import 'package:admin_panel/features/merchandisers/chats/data/models/chat_preview_model.dart';
import 'package:admin_panel/features/merchandisers/chats/data/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../helpers/test_helpers.dart';

class FakeChatRemoteDataSource implements ChatRemoteDataSource {
  final List<MessageModel> _messages = [];
  final List<ChatPreviewModel> _previews = [];
  final Map<String, String> _merchandiserProfiles = {};
  final Map<String, String> _customerNames = {};

  bool shouldThrowException = false;
  String? exceptionMessage;

  // Track sent notifications
  final List<Map<String, dynamic>> sentNotifications = [];

  // Track image uploads
  final Map<String, Uint8List> uploadedImages = {};

  // Setup methods
  void setupMessages(List<MessageModel> messages) {
    _messages.clear();
    _messages.addAll(messages);
  }

  void setupPreviews(List<ChatPreviewModel> previews) {
    _previews.clear();
    _previews.addAll(previews);
  }

  void setupMerchandiserProfile(String merchandiserId, String profileId) {
    _merchandiserProfiles[merchandiserId] = profileId;
  }

  void setupCustomerName(String profileId, String name) {
    _customerNames[profileId] = name;
  }

  void reset() {
    _messages.clear();
    _previews.clear();
    _merchandiserProfiles.clear();
    _customerNames.clear();
    sentNotifications.clear();
    uploadedImages.clear();
    shouldThrowException = false;
    exceptionMessage = null;
  }

  void throwException(String message) {
    shouldThrowException = true;
    exceptionMessage = message;
  }

  void _checkException() {
    if (shouldThrowException) {
      throw Exception(exceptionMessage ?? 'Test exception');
    }
  }

  @override
  Future<List<ChatPreviewModel>> getChatPreviews({
    required String merchandiserId,
  }) async {
    _checkException();

    // Simulate getting merchandiser profile_id
    final profileId = _merchandiserProfiles[merchandiserId];
    if (profileId == null) {
      throw Exception('Merchandiser not found');
    }

    // Return previews for this merchandiser
    return List.from(_previews);
  }

  @override
  Future<List<MessageModel>> getMessages({
    required String merchandiserProfileId,
    required String customerProfileId,
  }) async {
    _checkException();

    // Filter messages between merchandiser and customer
    return _messages.where((message) {
      final isMerchantToCustomer = message.senderId == merchandiserProfileId &&
          message.receiverId == customerProfileId;
      final isCustomerToMerchant = message.senderId == customerProfileId &&
          message.receiverId == merchandiserProfileId;

      return isMerchantToCustomer || isCustomerToMerchant;
    }).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<MessageModel> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    _checkException();

    final newMessage = TestMessageBuilder()
        .withId('msg-${DateTime.now().millisecondsSinceEpoch}')
        .withSenderId(senderId)
        .withReceiverId(receiverId)
        .withMessage(message)
        .withIsRead(false)
        .withCreatedAt(DateTime.now())
        .buildModel();

    _messages.add(newMessage);

    // Simulate notification
    await _sendNotification(
      receiverId: receiverId,
      senderId: senderId,
      message: message,
    );

    return newMessage;
  }

  @override
  Future<MessageModel> sendImageMessage({
    required String senderId,
    required String receiverId,
    required String message,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    _checkException();

    // Simulate image upload
    final filePath =
        'chat_images/$senderId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    uploadedImages[filePath] = fileBytes;

    // Simulate getting public URL
    final imageUrl = 'https://fake-storage.com/$filePath';

    final newMessage = TestMessageBuilder()
        .withId('msg-${DateTime.now().millisecondsSinceEpoch}')
        .withSenderId(senderId)
        .withReceiverId(receiverId)
        .withMessage(message)
        .withImageUrl(imageUrl)
        .withIsRead(false)
        .withCreatedAt(DateTime.now())
        .buildModel();

    _messages.add(newMessage);

    // Simulate notification
    await _sendNotification(
      receiverId: receiverId,
      senderId: senderId,
      message: '📷 Image',
    );

    return newMessage;
  }

  @override
  Future<void> markAllAsRead({
    required String senderId,
    required String receiverId,
  }) async {
    _checkException();

    // Mark messages as read
    for (var i = 0; i < _messages.length; i++) {
      final msg = _messages[i];
      if (msg.senderId == senderId &&
          msg.receiverId == receiverId &&
          !msg.isRead) {
        _messages[i] = msg.copyWith(isRead: true);
      }
    }
  }

  @override
  Future<int> getUnreadCount({
    required String merchandiserProfileId,
    required String customerProfileId,
  }) async {
    _checkException();

    return _messages
        .where((msg) =>
            msg.senderId == customerProfileId &&
            msg.receiverId == merchandiserProfileId &&
            !msg.isRead)
        .length;
  }

  @override
  RealtimeChannel subscribeToNewMessages({
    required String merchandiserProfileId,
    required Function(MessageModel) onMessageReceived,
  }) {
    // Return a fake channel - in real tests, you'd simulate message reception
    return FakeRealtimeChannel();
  }

  @override
  RealtimeChannel subscribeToChatRoom({
    required String merchandiserProfileId,
    required String customerProfileId,
    required Function(MessageModel) onMessageReceived,
  }) {
    // Return a fake channel - in real tests, you'd simulate message reception
    return FakeRealtimeChannel();
  }

  // Helper method to simulate notification
  Future<void> _sendNotification({
    required String receiverId,
    required String senderId,
    required String message,
  }) async {
    final senderName = _customerNames[senderId] ?? 'Someone';
    final messagePreview =
        message.length > 50 ? '${message.substring(0, 50)}...' : message;

    final notification = {
      'user_id': receiverId,
      'title': {
        'en': 'New Message from $senderName',
        'ar': 'رسالة جديدة من $senderName',
      },
      'body': {'en': messagePreview, 'ar': messagePreview},
      'type': 'chat',
      'reference_id': senderId,
      'is_read': false,
    };

    sentNotifications.add(notification);
  }

  // Helper methods for testing
  List<MessageModel> getMessagesBetween(String profileId1, String profileId2) {
    return _messages.where((msg) {
      return (msg.senderId == profileId1 && msg.receiverId == profileId2) ||
          (msg.senderId == profileId2 && msg.receiverId == profileId1);
    }).toList();
  }

  bool hasUploadedImage(String fileName) {
    return uploadedImages.keys.any((path) => path.contains(fileName));
  }

  int getUnreadCountForCustomer(
      String customerProfileId, String merchandiserProfileId) {
    return _messages
        .where((msg) =>
            msg.senderId == customerProfileId &&
            msg.receiverId == merchandiserProfileId &&
            !msg.isRead)
        .length;
  }

  bool wasNotificationSent(String receiverId, String senderId) {
    return sentNotifications.any(
      (notif) =>
          notif['user_id'] == receiverId && notif['reference_id'] == senderId,
    );
  }
}

// Fake RealtimeChannel for testing
class FakeRealtimeChannel extends RealtimeChannel {
  FakeRealtimeChannel()
      : super(
          'fake-channel',
          RealtimeClient(
            'fake-url',
            params: {},
          ),
        );
}
