// test/features/chat/helpers/test_helpers.dart

// ==================== Test Constants ====================
import 'package:admin_panel/features/merchandisers/chats/data/models/chat_preview_model.dart';
import 'package:admin_panel/features/merchandisers/chats/data/models/message_model.dart';
import 'package:admin_panel/features/merchandisers/chats/domain/entities/chat_preview.dart';
import 'package:admin_panel/features/merchandisers/chats/domain/entities/message.dart';

class ChatTestConstants {
  static const String merchandiserId = 'test-merchandiser-id-123';
  static const String merchandiserProfileId = 'merchandiser-profile-id-123';
  static const String customerProfileId1 = 'customer-profile-id-1';
  static const String customerProfileId2 = 'customer-profile-id-2';
  static const String customerProfileId3 = 'customer-profile-id-3';
  static const String messageId1 = 'message-id-1';
  static const String messageId2 = 'message-id-2';
  static const String messageId3 = 'message-id-3';
  static const String customerName1 = 'John Customer';
  static const String customerName2 = 'Jane Customer';
  static const String customerName3 = 'Bob Customer';
  static const String testImageUrl = 'https://example.com/image.jpg';
}

// ==================== Test Data Builders ====================
class TestMessageBuilder {
  String id = ChatTestConstants.messageId1;
  String senderId = ChatTestConstants.customerProfileId1;
  String receiverId = ChatTestConstants.merchandiserProfileId;
  String message = 'Hello, this is a test message';
  String? imageUrl;
  bool isRead = false;
  DateTime createdAt = DateTime(2024, 1, 1, 10, 0);
  DateTime updatedAt = DateTime(2024, 1, 1, 10, 0);

  TestMessageBuilder();

  TestMessageBuilder withId(String id) {
    this.id = id;
    return this;
  }

  TestMessageBuilder withSenderId(String senderId) {
    this.senderId = senderId;
    return this;
  }

  TestMessageBuilder withReceiverId(String receiverId) {
    this.receiverId = receiverId;
    return this;
  }

  TestMessageBuilder withMessage(String message) {
    this.message = message;
    return this;
  }

  TestMessageBuilder withImageUrl(String? imageUrl) {
    this.imageUrl = imageUrl;
    return this;
  }

  TestMessageBuilder withIsRead(bool isRead) {
    this.isRead = isRead;
    return this;
  }

  TestMessageBuilder withCreatedAt(DateTime createdAt) {
    this.createdAt = createdAt;
    this.updatedAt = createdAt;
    return this;
  }

  Message build() {
    return Message(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      imageUrl: imageUrl,
      isRead: isRead,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  MessageModel buildModel() {
    return MessageModel(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      imageUrl: imageUrl,
      isRead: isRead,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'image_url': imageUrl,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class TestChatPreviewBuilder {
  String customerProfileId = ChatTestConstants.customerProfileId1;
  String customerName = ChatTestConstants.customerName1;
  String? customerAvatar;
  String lastMessage = 'Last message text';
  DateTime lastMessageTime = DateTime(2024, 1, 1, 10, 0);
  int unreadCount = 0;
  bool isCustomerOnline = false;

  TestChatPreviewBuilder();

  TestChatPreviewBuilder withCustomerProfileId(String id) {
    this.customerProfileId = id;
    return this;
  }

  TestChatPreviewBuilder withCustomerName(String name) {
    this.customerName = name;
    return this;
  }

  TestChatPreviewBuilder withCustomerAvatar(String? avatar) {
    this.customerAvatar = avatar;
    return this;
  }

  TestChatPreviewBuilder withLastMessage(String message) {
    this.lastMessage = message;
    return this;
  }

  TestChatPreviewBuilder withLastMessageTime(DateTime time) {
    this.lastMessageTime = time;
    return this;
  }

  TestChatPreviewBuilder withUnreadCount(int count) {
    this.unreadCount = count;
    return this;
  }

  TestChatPreviewBuilder withIsOnline(bool isOnline) {
    this.isCustomerOnline = isOnline;
    return this;
  }

  ChatPreview build() {
    return ChatPreview(
      customerProfileId: customerProfileId,
      customerName: customerName,
      customerAvatar: customerAvatar,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
      isCustomerOnline: isCustomerOnline,
    );
  }

  ChatPreviewModel buildModel() {
    return ChatPreviewModel(
      customerProfileId: customerProfileId,
      customerName: customerName,
      customerAvatar: customerAvatar,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
      isCustomerOnline: isCustomerOnline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_profile_id': customerProfileId,
      'customer_name': customerName,
      'customer_avatar': customerAvatar,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime.toIso8601String(),
      'unread_count': unreadCount,
      'is_online': isCustomerOnline,
    };
  }
}

// ==================== Test Data Factory ====================
class ChatTestDataFactory {
  static Message createMessage({
    String? id,
    String? senderId,
    String? receiverId,
    String? message,
    String? imageUrl,
    bool isRead = false,
    DateTime? createdAt,
  }) {
    return TestMessageBuilder()
        .withId(id ?? ChatTestConstants.messageId1)
        .withSenderId(senderId ?? ChatTestConstants.customerProfileId1)
        .withReceiverId(receiverId ?? ChatTestConstants.merchandiserProfileId)
        .withMessage(message ?? 'Test message')
        .withImageUrl(imageUrl)
        .withIsRead(isRead)
        .withCreatedAt(createdAt ?? DateTime(2024, 1, 1, 10, 0))
        .build();
  }

  static MessageModel createMessageModel({
    String? id,
    String? senderId,
    String? receiverId,
    String? message,
    String? imageUrl,
    bool isRead = false,
    DateTime? createdAt,
  }) {
    return TestMessageBuilder()
        .withId(id ?? ChatTestConstants.messageId1)
        .withSenderId(senderId ?? ChatTestConstants.customerProfileId1)
        .withReceiverId(receiverId ?? ChatTestConstants.merchandiserProfileId)
        .withMessage(message ?? 'Test message')
        .withImageUrl(imageUrl)
        .withIsRead(isRead)
        .withCreatedAt(createdAt ?? DateTime(2024, 1, 1, 10, 0))
        .buildModel();
  }

  static List<MessageModel> createConversation() {
    return [
      TestMessageBuilder()
          .withId('msg-1')
          .withSenderId(ChatTestConstants.customerProfileId1)
          .withReceiverId(ChatTestConstants.merchandiserProfileId)
          .withMessage('Hello!')
          .withCreatedAt(DateTime(2024, 1, 1, 10, 0))
          .withIsRead(true)
          .buildModel(),
      TestMessageBuilder()
          .withId('msg-2')
          .withSenderId(ChatTestConstants.merchandiserProfileId)
          .withReceiverId(ChatTestConstants.customerProfileId1)
          .withMessage('Hi, how can I help?')
          .withCreatedAt(DateTime(2024, 1, 1, 10, 1))
          .withIsRead(true)
          .buildModel(),
      TestMessageBuilder()
          .withId('msg-3')
          .withSenderId(ChatTestConstants.customerProfileId1)
          .withReceiverId(ChatTestConstants.merchandiserProfileId)
          .withMessage('I have a question about my order')
          .withCreatedAt(DateTime(2024, 1, 1, 10, 2))
          .withIsRead(false)
          .buildModel(),
    ];
  }

  static ChatPreview createChatPreview({
    String? customerProfileId,
    String? customerName,
    String? lastMessage,
    int unreadCount = 0,
    bool isOnline = false,
  }) {
    return TestChatPreviewBuilder()
        .withCustomerProfileId(
            customerProfileId ?? ChatTestConstants.customerProfileId1)
        .withCustomerName(customerName ?? ChatTestConstants.customerName1)
        .withLastMessage(lastMessage ?? 'Last message')
        .withUnreadCount(unreadCount)
        .withIsOnline(isOnline)
        .build();
  }

  static List<ChatPreviewModel> createChatPreviewList() {
    return [
      TestChatPreviewBuilder()
          .withCustomerProfileId(ChatTestConstants.customerProfileId1)
          .withCustomerName(ChatTestConstants.customerName1)
          .withLastMessage('Hey, I need help with my order')
          .withLastMessageTime(DateTime(2024, 1, 1, 10, 0))
          .withUnreadCount(3)
          .withIsOnline(true)
          .buildModel(),
      TestChatPreviewBuilder()
          .withCustomerProfileId(ChatTestConstants.customerProfileId2)
          .withCustomerName(ChatTestConstants.customerName2)
          .withLastMessage('Thank you for your help!')
          .withLastMessageTime(DateTime(2024, 1, 1, 9, 0))
          .withUnreadCount(0)
          .withIsOnline(false)
          .buildModel(),
      TestChatPreviewBuilder()
          .withCustomerProfileId(ChatTestConstants.customerProfileId3)
          .withCustomerName(ChatTestConstants.customerName3)
          .withLastMessage('When will my order arrive?')
          .withLastMessageTime(DateTime(2024, 1, 1, 8, 0))
          .withUnreadCount(1)
          .withIsOnline(true)
          .buildModel(),
    ];
  }
}
