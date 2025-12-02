import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/theme/colors.dart';

class PasswordChangeGuard extends StatefulWidget {
  final Widget child;

  const PasswordChangeGuard({super.key, required this.child});

  @override
  State<PasswordChangeGuard> createState() => _PasswordChangeGuardState();
}

class _PasswordChangeGuardState extends State<PasswordChangeGuard> {
  bool _isChecking = true;
  bool _mustChangePassword = false;
  bool _showBanner = true;

  @override
  void initState() {
    super.initState();
    _checkPasswordChangeRequired();
  }

  Future<void> _checkPasswordChangeRequired() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('must_change_password, user_type')
            .eq('id', user.id)
            .single();

        setState(() {
          _mustChangePassword =
              response['must_change_password'] == true &&
              response['user_type'] == 'merchandiser';
          _isChecking = false;
        });

        // Show non-blocking notification after build completes
        if (_mustChangePassword && _showBanner) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showPasswordChangeNotification();
          });
        }
      } else {
        setState(() {
          _isChecking = false;
        });
      }
    } catch (e) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  void _showPasswordChangeNotification() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'You are using a temporary password. Please change it for security.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _showPasswordChangeDialog();
              },
              child: const Text(
                'Change Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showPasswordChangeDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing the dialog
      builder: (context) => PasswordChangeDialog(
        onPasswordChanged: () {
          setState(() {
            _mustChangePassword = false;
            _showBanner = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show banner at the top if password change is required
    return Column(
      children: [
        if (_mustChangePassword && _showBanner)
          MaterialBanner(
            content: Row(
              children: [
                const Icon(Icons.security, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Security Notice: You are using a temporary password. Please change it to secure your account.',
                    style: AppTextStyles.getBodySmall(context),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.warning.withValues(alpha: 0.1),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showBanner = false;
                  });
                },
                child: const Text('Dismiss'),
              ),
              ElevatedButton(
                onPressed: _showPasswordChangeDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                ),
                child: const Text('Change Password'),
              ),
            ],
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}

class PasswordChangeDialog extends StatefulWidget {
  final VoidCallback onPasswordChanged;

  const PasswordChangeDialog({super.key, required this.onPasswordChanged});

  @override
  State<PasswordChangeDialog> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<PasswordChangeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update password through Supabase Auth
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      // Update profile to mark password as changed
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('profiles')
            .update({'must_change_password': false})
            .eq('id', user.id);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onPasswordChanged();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password changed successfully! Your account is now secure.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error changing password: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.lock_reset, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('Change Your Password'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Create a strong password with at least 8 characters, including uppercase, lowercase, and numbers.',
                      style: AppTextStyles.getBodySmall(
                        context,
                      ).copyWith(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      hintText: 'Enter a strong new password',
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
                        return 'Please enter a new password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (!RegExp(
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
                      ).hasMatch(value)) {
                        return 'Password must contain uppercase, lowercase, and number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      hintText: 'Confirm your new password',
                      prefixIcon: const Icon(Icons.lock_outline),
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
                        return 'Please confirm your password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Later'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _changePassword,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Change Password'),
        ),
      ],
    );
  }
}
