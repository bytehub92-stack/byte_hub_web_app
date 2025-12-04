// lib/features/shared/data/datasources/message_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../shared/shared_feature/data/models/message_model.dart';

abstract class MessageRemoteDataSource {
  Future<List<MessageModel>> getConversation(String userId1, String userId2);
  Future<MessageModel> sendMessage(String receiverId, String message);
  Future<void> markAsRead(String messageId);
  Future<int> getUnreadCount();
  Stream<List<MessageModel>> watchMessages(String currentUserId);
}

class MessageRemoteDataSourceImpl implements MessageRemoteDataSource {
  final SupabaseClient supabaseClient;

  const MessageRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<MessageModel>> getConversation(
    String userId1,
    String userId2,
  ) async {
    try {
      final response = await supabaseClient
          .from('messages')
          .select()
          .or('sender_id.eq.$userId1,sender_id.eq.$userId2')
          .or('receiver_id.eq.$userId1,receiver_id.eq.$userId2')
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to fetch messages: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<MessageModel> sendMessage(String receiverId, String message) async {
    try {
      final currentUserId = supabaseClient.auth.currentUser?.id;
      if (currentUserId == null) {
        throw ServerException(message: 'User not authenticated');
      }

      final response = await supabaseClient
          .from('messages')
          .insert({
            'sender_id': currentUserId,
            'receiver_id': receiverId,
            'message': message,
          })
          .select()
          .single();

      return MessageModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to send message: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> markAsRead(String messageId) async {
    try {
      await supabaseClient
          .from('messages')
          .update({'is_read': true})
          .eq('id', messageId);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to mark as read: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final currentUserId = supabaseClient.auth.currentUser?.id;
      if (currentUserId == null) return 0;

      final response = await supabaseClient
          .from('messages')
          .select('id')
          .eq('receiver_id', currentUserId)
          .eq('is_read', false)
          .count(CountOption.exact);

      return response.count;
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get unread count: ${e.message}',
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Stream<List<MessageModel>> watchMessages(String currentUserId) {
    return supabaseClient
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', currentUserId)
        .order('created_at')
        .map(
          (data) => data.map((json) => MessageModel.fromJson(json)).toList(),
        );
  }
}
