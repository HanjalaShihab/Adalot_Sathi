import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../data/providers/repository_providers.dart';

class ProfileState {
  final bool isSubmitting;
  final String? error;
  final String? successMessage;

  const ProfileState({this.isSubmitting = false, this.error, this.successMessage});

  ProfileState copyWith({bool? isSubmitting, String? error, String? successMessage}) {
    return ProfileState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      successMessage: successMessage,
    );
  }
}

class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? password,
    String? barCouncilNumber,
    String? chamberName,
    String? address,
    String? district,
    String? profilePhoto,
    int? yearsOfExperience,
    List<String>? practiceAreas,
    String? preferredCourt,
    String? appLanguage,
    Map<String, dynamic>? notificationSettings,
    Map<String, dynamic>? reminderSettings,
    bool? darkMode,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null, successMessage: null);
    try {
      await ref.read(authRepositoryProvider).updateProfile(
            name: name,
            email: email,
            phone: phone,
            password: password,
            barCouncilNumber: barCouncilNumber,
            chamberName: chamberName,
            address: address,
            district: district,
            profilePhoto: profilePhoto,
            yearsOfExperience: yearsOfExperience,
            practiceAreas: practiceAreas,
            preferredCourt: preferredCourt,
            appLanguage: appLanguage,
            notificationSettings: notificationSettings,
            reminderSettings: reminderSettings,
            darkMode: darkMode,
          );
      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Profile updated successfully.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e is AppException ? e.message : 'Failed to update profile.',
      );
      return false;
    }
  }

  void clearMessages() => state = state.copyWith(error: null, successMessage: null);
}

final profileControllerProvider = NotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
);


