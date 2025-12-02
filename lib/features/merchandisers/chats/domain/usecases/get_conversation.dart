// lib/features/shared/domain/usecases/message/get_conversation.dart

import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/message.dart';
import '../repositories/message_repository.dart';

class GetConversation {
  final MessageRepository repository;

  GetConversation(this.repository);

  Future<Either<Failure, List<Message>>> call(String userId1, String userId2) {
    return repository.getConversation(userId1, userId2);
  }
}
