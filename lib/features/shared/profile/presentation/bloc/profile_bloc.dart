// lib/features/profile/presentation/bloc/profile_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/auth_service.dart';
import '../../data/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;
  final AuthService _authService;

  ProfileBloc({
    required ProfileRepository repository,
    required AuthService authService,
  }) : _repository = repository,
       _authService = authService,
       super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadLogo>(_onUploadLogo);
    on<ChangePassword>(_onChangePassword);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());

      final profileId = _authService.currentUserId;
      if (profileId == null) {
        emit(const ProfileError('User not authenticated'));
        return;
      }

      final profile = await _repository.getMerchandiserProfile(profileId);

      if (profile == null) {
        emit(const ProfileError('Profile not found'));
        return;
      }

      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is! ProfileLoaded) return;

      final currentProfile = (state as ProfileLoaded).profile;
      emit(ProfileUpdating(currentProfile));

      final profileId = _authService.currentUserId;
      if (profileId == null) {
        emit(const ProfileError('User not authenticated'));
        return;
      }

      await _repository.updateMerchandiserProfile(
        merchandiserId: currentProfile.id,
        profileId: profileId,
        phoneNumber: event.phoneNumber,
        fullName: event.fullName,
        website: event.website,
        businessName: event.businessName,
        businessType: event.businessType,
        description: event.description,
        address: event.address,
        city: event.city,
        state: event.state,
        country: event.country,
        postalCode: event.postalCode,
        taxId: event.taxId,
      );

      // Reload profile to get updated data
      add(const LoadProfile());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUploadLogo(
    UploadLogo event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is! ProfileLoaded) return;

      final currentProfile = (state as ProfileLoaded).profile;
      emit(LogoUploading(currentProfile));

      final profileId = _authService.currentUserId;
      if (profileId == null) {
        emit(const ProfileError('User not authenticated'));
        return;
      }

      final logoUrl = await _repository.uploadLogo(
        currentProfile.id,
        event.imageBytes,
      );

      await _repository.updateMerchandiserProfile(
        merchandiserId: currentProfile.id,
        profileId: profileId,
        logoUrl: logoUrl,
      );

      add(const LoadProfile());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(PasswordChanging());

      await _repository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );

      emit(const PasswordChangeSuccess());

      // Return to loaded state
      add(const LoadProfile());
    } catch (e) {
      emit(ProfileError(e.toString()));
      // Return to loaded state even on error
      add(const LoadProfile());
    }
  }
}
