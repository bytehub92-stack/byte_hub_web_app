// lib/features/profile/presentation/bloc/profile_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/merchandiser_profile_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final MerchandiserProfileModel profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

class ProfileUpdating extends ProfileState {
  final MerchandiserProfileModel currentProfile;

  const ProfileUpdating(this.currentProfile);

  @override
  List<Object> get props => [currentProfile];
}

class ProfileUpdateSuccess extends ProfileState {
  final MerchandiserProfileModel profile;
  final String message;

  const ProfileUpdateSuccess(
    this.profile, {
    this.message = 'Profile updated successfully',
  });

  @override
  List<Object> get props => [profile, message];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

class LogoUploading extends ProfileState {
  final MerchandiserProfileModel currentProfile;

  const LogoUploading(this.currentProfile);

  @override
  List<Object> get props => [currentProfile];
}

class PasswordChanging extends ProfileState {}

class PasswordChangeSuccess extends ProfileState {
  const PasswordChangeSuccess();
}
