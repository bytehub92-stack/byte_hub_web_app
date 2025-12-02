// lib/features/admin/content_management/presentation/widgets/content_editor_dialog.dart
import 'package:admin_panel/core/constants/app_constants.dart';
import 'package:admin_panel/core/theme/colors.dart';
import 'package:admin_panel/core/theme/text_styles.dart';
import 'package:admin_panel/features/shared/app_settings/domain/entities/app_setting.dart';
import 'package:admin_panel/features/shared/app_settings/presentation/bloc/app_settings_bloc.dart';
import 'package:admin_panel/features/shared/app_settings/presentation/bloc/app_settings_event.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContentEditorDialog extends StatefulWidget {
  final String settingKey;
  final AppSetting? existingSetting;

  const ContentEditorDialog({
    super.key,
    required this.settingKey,
    this.existingSetting,
  });

  @override
  State<ContentEditorDialog> createState() => _ContentEditorDialogState();
}

class _ContentEditorDialogState extends State<ContentEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _enController;
  late TextEditingController _arController;
  late TextEditingController _enDescController;
  late TextEditingController _arDescController;

  @override
  void initState() {
    super.initState();
    final enContent =
        widget.existingSetting?.settingValue['en'] as String? ?? '';
    final arContent =
        widget.existingSetting?.settingValue['ar'] as String? ?? '';
    final enDesc = widget.existingSetting?.description?['en'] ?? '';
    final arDesc = widget.existingSetting?.description?['ar'] ?? '';

    _enController = TextEditingController(text: enContent);
    _arController = TextEditingController(text: arContent);
    _enDescController = TextEditingController(text: enDesc);
    _arDescController = TextEditingController(text: arDesc);
  }

  @override
  void dispose() {
    _enController.dispose();
    _arController.dispose();
    _enDescController.dispose();
    _arDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.existingSetting != null;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        isUpdate ? Icons.edit : Icons.add,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isUpdate ? 'Edit Content' : 'Add Content',
                          style: AppTextStyles.getH3(context),
                        ).tr(),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppSettingKeys.getDisplayName(widget.settingKey),
                    style: AppTextStyles.getBodyMedium(
                      context,
                    ).copyWith(color: AppColors.grey500),
                  ).tr(),
                  const Divider(height: 32),

                  // English Content
                  Text(
                    'English Content',
                    style: AppTextStyles.getH4(context),
                  ).tr(),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _enController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: 'Enter content in English...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultRadius,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'English content is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // English Description
                  Text(
                    'English Description (Optional)',
                    style: AppTextStyles.getBodyLarge(context),
                  ).tr(),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _enDescController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Brief description in English...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultRadius,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.largePadding),

                  // Arabic Content
                  Text(
                    'Arabic Content',
                    style: AppTextStyles.getH4(context),
                  ).tr(),
                  const SizedBox(height: 8),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      controller: _arController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        hintText: 'أدخل المحتوى بالعربية...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.defaultRadius,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Arabic content is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Arabic Description
                  Text(
                    'Arabic Description (Optional)',
                    style: AppTextStyles.getBodyLarge(context),
                  ).tr(),
                  const SizedBox(height: 8),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      controller: _arDescController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'وصف مختصر بالعربية...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.defaultRadius,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.largePadding),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel').tr(),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _saveContent,
                        icon: const Icon(Icons.save),
                        label: Text(isUpdate ? 'Update' : 'Create').tr(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveContent() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final settingValue = {
      'en': _enController.text.trim(),
      'ar': _arController.text.trim(),
    };

    final description = {
      'en': _enDescController.text.trim(),
      'ar': _arDescController.text.trim(),
    };

    final isUpdate = widget.existingSetting != null;

    if (isUpdate) {
      context.read<AppSettingsBloc>().add(
        UpdateAppSettingEvent(
          settingKey: widget.settingKey,
          settingValue: settingValue,
          description: description,
          merchandiserId: null, // Global setting
        ),
      );
    } else {
      context.read<AppSettingsBloc>().add(
        CreateAppSettingEvent(
          settingKey: widget.settingKey,
          settingValue: settingValue,
          description: description,
          merchandiserId: null, // Global setting
        ),
      );
    }

    Navigator.of(context).pop();
  }
}
