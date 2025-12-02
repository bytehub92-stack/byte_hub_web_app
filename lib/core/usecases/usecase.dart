import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

abstract class UseCase<CustomType, Params> {
  Future<Either<Failure, CustomType>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
