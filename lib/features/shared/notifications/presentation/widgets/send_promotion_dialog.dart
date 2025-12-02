// lib/features/notifications/presentation/widgets/send_promotion_dialog.dart
import 'package:admin_panel/features/shared/orders/data/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';

class SendPromotionDialog extends StatefulWidget {
  final String merchandiserId;

  const SendPromotionDialog({super.key, required this.merchandiserId});

  @override
  State<SendPromotionDialog> createState() => _SendPromotionDialogState();
}

class _SendPromotionDialogState extends State<SendPromotionDialog> {
  final _titleEnController = TextEditingController();
  final _titleArController = TextEditingController();
  final _bodyEnController = TextEditingController();
  final _bodyArController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleArController.dispose();
    _bodyEnController.dispose();
    _bodyArController.dispose();
    super.dispose();
  }

  Future<void> _sendPromotion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final orderService = OrderService(Supabase.instance.client);

      await orderService.sendBulkNotificationToCustomers(
        merchandiserId: widget.merchandiserId,
        title: {
          'en': _titleEnController.text.trim(),
          'ar': _titleArController.text.trim(),
        },
        body: {
          'en': _bodyEnController.text.trim(),
          'ar': _bodyArController.text.trim(),
        },
        type: 'promo',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Promotion sent successfully to all customers'),
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
          const Icon(Icons.campaign, color: AppColors.primary),
          const SizedBox(width: 12),
          Text('Send Promotion', style: AppTextStyles.getH4(context)),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send a promotional notification to all your customers',
                style: AppTextStyles.getBodySmall(
                  context,
                ).copyWith(color: AppColors.grey600),
              ),
              const SizedBox(height: 24),

              // English Title
              TextFormField(
                controller: _titleEnController,
                decoration: const InputDecoration(
                  labelText: 'Title (English) *',
                  hintText: 'e.g., Special Offer!',
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
                  hintText: 'مثال: عرض خاص!',
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
                  hintText: 'Enter your promotional message...',
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 3,
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
                  hintText: 'أدخل رسالتك الترويجية...',
                  prefixIcon: Icon(Icons.message),
                ),
                textDirection: TextDirection.rtl,
                maxLines: 3,
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
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isSending ? null : _sendPromotion,
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
          label: Text(_isSending ? 'Sending...' : 'Send to All Customers'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
        ),
      ],
    );
  }
}
