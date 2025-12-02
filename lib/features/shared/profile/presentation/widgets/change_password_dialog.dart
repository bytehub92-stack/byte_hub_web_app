// lib/features/profile/presentation/widgets/change_password_dialog.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is PasswordChangeSuccess) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final isChanging = state is PasswordChanging;

        return AlertDialog(
          title: Text(
            'Change Password',
            style: AppTextStyles.getH4(context),
          ).tr(),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your current password and choose a new password',
                    style: AppTextStyles.getBodySmall(context),
                  ).tr(),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Current Password
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrentPassword,
                    enabled: !isChanging,
                    decoration: InputDecoration(
                      labelText: 'Current Password'.tr(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrentPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // New Password
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    enabled: !isChanging,
                    decoration: InputDecoration(
                      labelText: 'New Password'.tr(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password'.tr();
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters'.tr();
                      }
                      if (value == _currentPasswordController.text) {
                        return 'New password must be different from current password'
                            .tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    enabled: !isChanging,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password'.tr(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password'.tr();
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.smallPadding),

                  // Password requirements
                  Container(
                    padding: const EdgeInsets.all(AppConstants.smallPadding),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password Requirements:',
                          style: AppTextStyles.getBodySmall(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ).tr(),
                        const SizedBox(height: 4),
                        _buildRequirement('At least 8 characters'),
                        _buildRequirement('Different from current password'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isChanging ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel').tr(),
            ),
            ElevatedButton(
              onPressed: isChanging ? null : _changePassword,
              child: isChanging
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Change Password').tr(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.info,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.getBodySmall(
              context,
            ).copyWith(color: AppColors.info),
          ).tr(),
        ],
      ),
    );
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        ChangePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        ),
      );
    }
  }
}
