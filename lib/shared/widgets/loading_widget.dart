import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool showMessage;

  const LoadingWidget({super.key, this.message, this.showMessage = true});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          if (showMessage) ...[
            const SizedBox(height: 16),
            Text(
              message ?? 'loading',
              style: AppTextStyles.getBodyMedium(context),
            ),
          ],
        ],
      ),
    );
  }
}
