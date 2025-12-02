import 'package:equatable/equatable.dart';
import '../../../domain/entities/create_merchandiser_request.dart';

abstract class MerchandiserEvent extends Equatable {
  const MerchandiserEvent();

  @override
  List<Object> get props => [];
}

class LoadMerchandisers extends MerchandiserEvent {}

class CreateMerchandiserEvent extends MerchandiserEvent {
  final CreateMerchandiserRequest request;

  const CreateMerchandiserEvent({required this.request});

  @override
  List<Object> get props => [request];
}

class ToggleMerchandiserStatusEvent extends MerchandiserEvent {
  final String merchandiserId;
  final bool newStatus;

  const ToggleMerchandiserStatusEvent({
    required this.merchandiserId,
    required this.newStatus,
  });

  @override
  List<Object> get props => [merchandiserId, newStatus];
}

class RefreshMerchandisers extends MerchandiserEvent {}
