import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';

class CustomErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const CustomErrorWidget({super.key, this.message, this.onRetry, this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon ?? Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message ?? 'somethingWentWrong',
              style: AppTextStyles.getH4(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: Text('tryAgain')),
            ],
          ],
        ),
      ),
    );
  }
}
