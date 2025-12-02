// lib/features/shared/domain/repositories/message_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/message.dart';

abstract class MessageRepository {
  Future<Either<Failure, List<Message>>> getConversation(
    String userId1,
    String userId2,
  );
  Future<Either<Failure, Message>> sendMessage(
    String receiverId,
    String message,
  );
  Future<Either<Failure, void>> markAsRead(String messageId);
  Future<Either<Failure, int>> getUnreadCount();
  Stream<List<Message>> watchMessages(String currentUserId);
}
