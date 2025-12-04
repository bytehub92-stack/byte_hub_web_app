// lib/features/shared/domain/usecases/message/get_unread_count.dart

import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../repositories/message_repository.dart';

class GetUnreadMessageCount {
  final MessageRepository repository;

  GetUnreadMessageCount(this.repository);

  Future<Either<Failure, int>> call() {
    return repository.getUnreadCount();
  }
}
