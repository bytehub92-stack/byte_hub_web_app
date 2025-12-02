// lib/features/chat/data/datasources/chat_remote_datasource.dart
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';
import '../models/chat_preview_model.dart';

class ChatRemoteDataSource {
  final SupabaseClient _supabase;

  ChatRemoteDataSource(this._supabase);

  /// Get all chat previews for a merchandiser
  Future<List<ChatPreviewModel>> getChatPreviews({
    required String merchandiserId,
  }) async {
    try {
      // Get merchandiser's profile_id
      final merchandiserData = await _supabase
          .from('merchandisers')
          .select('profile_id')
          .eq('id', merchandiserId)
          .single();

      final profileId = merchandiserData['profile_id'] as String;

      // Call the database function
      final response = await _supabase.rpc(
        'get_merchandiser_chat_previews',
        params: {'merchandiser_profile_id': profileId},
      );

      return (response as List)
          .map((json) => ChatPreviewModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load chat previews: $e');
    }
  }

  Future<List<MessageModel>> getMessages({
    required String merchandiserProfileId, // ✅ This is profile_id
    required String customerProfileId, // ✅ This is profile_id
  }) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .or(
            'and(sender_id.eq.$merchandiserProfileId,receiver_id.eq.$customerProfileId),and(sender_id.eq.$customerProfileId,receiver_id.eq.$merchandiserProfileId)',
          )
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  // ✅ CORRECT: This should use profile_id
  Future<MessageModel> sendMessage({
    required String senderId, // ✅ Should be profile_id
    required String receiverId, // ✅ Should be profile_id (customer)
    required String message,
  }) async {
    try {
      final response = await _supabase
          .from('messages')
          .insert({
            'sender_id': senderId, // ✅ profile_id
            'receiver_id': receiverId, // ✅ profile_id
            'message': message,
            'is_read': false,
          })
          .select()
          .single();

      await _sendChatNotification(
        receiverId: receiverId,
        senderId: senderId,
        message: message,
      );

      return MessageModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // ✅ CORRECT: This should use profile_id for storage path
  Future<MessageModel> sendImageMessage({
    required String senderId, // ✅ Should be profile_id
    required String receiverId, // ✅ Should be profile_id
    required String message,
    required Uint8List fileBytes, // ✅ Changed from html.File
    required String fileName, // ✅ Added fileName parameter
  }) async {
    try {
      // Upload to Supabase Storage
      final filePath =
          'chat_images/$senderId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // ✅ Upload bytes directly (works on all platforms!)
      await _supabase.storage.from('chat-images').uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(
              contentType: 'image/*',
              upsert: false,
            ),
          );

      final imageUrl =
          _supabase.storage.from('chat-images').getPublicUrl(filePath);

      // Insert message with image
      final response = await _supabase
          .from('messages')
          .insert({
            'sender_id': senderId, // ✅ profile_id
            'receiver_id': receiverId, // ✅ profile_id
            'message': message,
            'image_url': imageUrl,
            'is_read': false,
          })
          .select()
          .single();

      await _sendChatNotification(
        receiverId: receiverId,
        senderId: senderId,
        message: '📷 Image',
      );

      return MessageModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to send image message: $e');
    }
  }

  /// Mark messages as read
  Future<void> markAllAsRead({
    required String senderId,
    required String receiverId,
  }) async {
    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('sender_id', senderId)
          .eq('receiver_id', receiverId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  /// Get unread message count for specific customer
  Future<int> getUnreadCount({
    required String merchandiserProfileId,
    required String customerProfileId,
  }) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('id')
          .eq('sender_id', customerProfileId)
          .eq('receiver_id', merchandiserProfileId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  /// Subscribe to new messages for merchandiser
  RealtimeChannel subscribeToNewMessages({
    required String merchandiserProfileId,
    required Function(MessageModel) onMessageReceived,
  }) {
    return _supabase
        .channel('merchandiser_messages:$merchandiserProfileId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: merchandiserProfileId,
          ),
          callback: (payload) {
            final message = MessageModel.fromJson(payload.newRecord);
            onMessageReceived(message);
          },
        )
        .subscribe();
  }

  /// Subscribe to specific chat room
  RealtimeChannel subscribeToChatRoom({
    required String merchandiserProfileId,
    required String customerProfileId,
    required Function(MessageModel) onMessageReceived,
  }) {
    return _supabase
        .channel('chat:$merchandiserProfileId:$customerProfileId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: merchandiserProfileId,
          ),
          callback: (payload) {
            final message = MessageModel.fromJson(payload.newRecord);
            if (message.senderId == customerProfileId) {
              onMessageReceived(message);
            }
          },
        )
        .subscribe();
  }

  /// Private: Send chat notification
  Future<void> _sendChatNotification({
    required String receiverId,
    required String senderId,
    required String message,
  }) async {
    try {
      // Get sender name
      final senderData = await _supabase
          .from('profiles')
          .select('full_name')
          .eq('id', senderId)
          .maybeSingle();

      final senderName = senderData?['full_name'] as String? ?? 'Someone';

      // Prepare message preview
      final messagePreview =
          message.length > 50 ? '${message.substring(0, 50)}...' : message;

      // Create notification
      final notificationData = {
        'user_id': receiverId,
        'title': {
          'en': 'New Message from $senderName',
          'ar': 'رسالة جديدة من $senderName',
        },
        'body': {'en': messagePreview, 'ar': messagePreview},
        'type': 'chat',
        'reference_id':
            senderId, // This is the sender's profile_id for navigation
        'is_read': false,
      };

      await _supabase.from('notifications').insert(notificationData);
    } catch (e, stackTrace) {
      print('❌ Error sending chat notification: $e');
      print('   Stack trace: $stackTrace');
      // Print more details for debugging
      print('   Receiver: $receiverId, Sender: $senderId');
    }
  }
}
