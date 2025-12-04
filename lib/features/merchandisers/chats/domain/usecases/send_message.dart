import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/message.dart';
import '../repositories/message_repository.dart';

class SendMessage {
  final MessageRepository repository;

  SendMessage(this.repository);

  Future<Either<Failure, Message>> call(String receiverId, String message) {
    return repository.sendMessage(receiverId, message);
  }
}
