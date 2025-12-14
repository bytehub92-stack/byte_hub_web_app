// lib/features/notifications/presentation/widgets/admin_send_notification_dialog.dart
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum NotificationTarget { allUsers, merchandisersOnly, customersOnly }

class AdminSendNotificationDialog extends StatefulWidget {
  const AdminSendNotificationDialog({super.key});

  @override
  State<AdminSendNotificationDialog> createState() =>
      _AdminSendNotificationDialogState();
}

class _AdminSendNotificationDialogState
    extends State<AdminSendNotificationDialog> {
  final _titleEnController = TextEditingController();
  final _titleArController = TextEditingController();
  final _bodyEnController = TextEditingController();
  final _bodyArController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;
  NotificationTarget _selectedTarget = NotificationTarget.allUsers;

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleArController.dispose();
    _bodyEnController.dispose();
    _bodyArController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final supabase = Supabase.instance.client;

      // Get target user IDs based on selection
      List<String> userIds = [];

      switch (_selectedTarget) {
        case NotificationTarget.allUsers:
          // Get all active users
          final response = await supabase
              .from('profiles')
              .select('id')
              .eq('is_active', true);
          userIds = (response as List).map((e) => e['id'] as String).toList();
          break;

        case NotificationTarget.merchandisersOnly:
          // Get all merchandiser profile IDs
          final response = await supabase
              .from('profiles')
              .select('id')
              .eq('user_type', 'merchandiser')
              .eq('is_active', true);
          userIds = (response as List).map((e) => e['id'] as String).toList();
          break;

        case NotificationTarget.customersOnly:
          // Get all customer profile IDs
          final response = await supabase
              .from('profiles')
              .select('id')
              .eq('user_type', 'customer')
              .eq('is_active', true);
          userIds = (response as List).map((e) => e['id'] as String).toList();
          break;
      }

      if (userIds.isEmpty) {
        throw Exception('No users found for the selected target');
      }

      // Create notifications for all users
      final notifications = userIds.map((userId) {
        return {
          'user_id': userId,
          'title': {
            'en': _titleEnController.text.trim(),
            'ar': _titleArController.text.trim(),
          },
          'body': {
            'en': _bodyEnController.text.trim(),
            'ar': _bodyArController.text.trim(),
          },
          'type': 'admin_announcement',
          'is_read': false,
        };
      }).toList();

      // Insert in batches of 1000 to avoid payload size limits
      const batchSize = 1000;
      for (var i = 0; i < notifications.length; i += batchSize) {
        final end = (i + batchSize < notifications.length)
            ? i + batchSize
            : notifications.length;
        final batch = notifications.sublist(i, end);
        await supabase.from('notifications').insert(batch);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notification sent successfully to ${userIds.length} users',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.notifications_active, color: AppColors.primary),
          const SizedBox(width: 12),
          Text('Send Global Notification', style: AppTextStyles.getH4(context)),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send a notification to users in the system',
                  style: AppTextStyles.getBodySmall(
                    context,
                  ).copyWith(color: AppColors.grey600),
                ),
                const SizedBox(height: 24),

                // Target Selection
                Text(
                  'Send To:',
                  style: AppTextStyles.getBodyMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _buildTargetOption(
                  NotificationTarget.allUsers,
                  'All Users',
                  'Send to all active users (customers and merchandisers)',
                  Icons.people,
                ),
                _buildTargetOption(
                  NotificationTarget.merchandisersOnly,
                  'Merchandisers Only',
                  'Send only to merchandisers',
                  Icons.store,
                ),
                _buildTargetOption(
                  NotificationTarget.customersOnly,
                  'Customers Only',
                  'Send only to customers',
                  Icons.person,
                ),

                const SizedBox(height: 24),

                // English Title
                TextFormField(
                  controller: _titleEnController,
                  decoration: const InputDecoration(
                    labelText: 'Title (English) *',
                    hintText: 'e.g., System Maintenance Notice',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'English title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Arabic Title
                TextFormField(
                  controller: _titleArController,
                  decoration: const InputDecoration(
                    labelText: 'Title (Arabic) *',
                    hintText: 'مثال: إشعار صيانة النظام',
                    prefixIcon: Icon(Icons.title),
                  ),
                  textDirection: TextDirection.rtl,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Arabic title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // English Body
                TextFormField(
                  controller: _bodyEnController,
                  decoration: const InputDecoration(
                    labelText: 'Message (English) *',
                    hintText: 'Enter your message...',
                    prefixIcon: Icon(Icons.message),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'English message is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Arabic Body
                TextFormField(
                  controller: _bodyArController,
                  decoration: const InputDecoration(
                    labelText: 'Message (Arabic) *',
                    hintText: 'أدخل رسالتك...',
                    prefixIcon: Icon(Icons.message),
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Arabic message is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isSending ? null : _sendNotification,
          icon: _isSending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Icon(Icons.send),
          label: Text(_isSending ? 'Sending...' : 'Send Notification'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildTargetOption(
    NotificationTarget target,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = _selectedTarget == target;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedTarget = target),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.grey600,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.getBodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTextStyles.getBodySmall(
                        context,
                      ).copyWith(color: AppColors.grey600),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.success),
            ],
          ),
        ),
      ),
    );
  }
}

// Usage in AdminDashboardPage:
// FloatingActionButton(
//   onPressed: () {
//     showDialog(
//       context: context,
//       builder: (context) => const AdminSendNotificationDialog(),
//     );
//   },
//   child: const Icon(Icons.notifications_active),
// );
