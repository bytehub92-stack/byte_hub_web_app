// lib/features/profile/presentation/pages/merchandiser_profile_page.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/change_password_dialog.dart';

class MerchandiserProfilePage extends StatefulWidget {
  const MerchandiserProfilePage({super.key});

  @override
  State<MerchandiserProfilePage> createState() =>
      _MerchandiserProfilePageState();
}

class _MerchandiserProfilePageState extends State<MerchandiserProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _businessNameEnController;
  late TextEditingController _businessNameArController;
  late TextEditingController _businessTypeEnController;
  late TextEditingController _businessTypeArController;
  late TextEditingController _descriptionEnController;
  late TextEditingController _descriptionArController;
  late TextEditingController _addressEnController;
  late TextEditingController _addressArController;
  late TextEditingController _cityEnController;
  late TextEditingController _cityArController;
  late TextEditingController _stateEnController;
  late TextEditingController _stateArController;
  late TextEditingController _countryEnController;
  late TextEditingController _countryArController;
  late TextEditingController _postalCodeController;
  late TextEditingController _taxIdController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _websiteController = TextEditingController();
    _businessNameEnController = TextEditingController();
    _businessNameArController = TextEditingController();
    _businessTypeEnController = TextEditingController();
    _businessTypeArController = TextEditingController();
    _descriptionEnController = TextEditingController();
    _descriptionArController = TextEditingController();
    _addressEnController = TextEditingController();
    _addressArController = TextEditingController();
    _cityEnController = TextEditingController();
    _cityArController = TextEditingController();
    _stateEnController = TextEditingController();
    _stateArController = TextEditingController();
    _countryEnController = TextEditingController();
    _countryArController = TextEditingController();
    _postalCodeController = TextEditingController();
    _taxIdController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _businessNameEnController.dispose();
    _businessNameArController.dispose();
    _businessTypeEnController.dispose();
    _businessTypeArController.dispose();
    _descriptionEnController.dispose();
    _descriptionArController.dispose();
    _addressEnController.dispose();
    _addressArController.dispose();
    _cityEnController.dispose();
    _cityArController.dispose();
    _stateEnController.dispose();
    _stateArController.dispose();
    _countryEnController.dispose();
    _countryArController.dispose();
    _postalCodeController.dispose();
    _taxIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile').tr(),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'Change Password'.tr(),
            onPressed: _showChangePasswordDialog,
          ),
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileUpdating) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'Save Profile'.tr(),
                onPressed: _saveProfile,
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message).tr(),
                backgroundColor: AppColors.success,
              ),
            );
          }
          if (state is PasswordChangeSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password changed successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded ||
              state is ProfileUpdating ||
              state is ProfileUpdateSuccess ||
              state is LogoUploading) {
            final profile = state is ProfileLoaded
                ? state.profile
                : state is ProfileUpdating
                ? state.currentProfile
                : state is LogoUploading
                ? state.currentProfile
                : (state as ProfileUpdateSuccess).profile;

            _populateControllers(profile);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(profile, state is LogoUploading),
                    const SizedBox(height: AppConstants.largePadding),
                    _buildSectionTitle('Personal Information'),
                    const SizedBox(height: AppConstants.defaultPadding),
                    _buildPersonalInfoSection(profile),
                    const SizedBox(height: AppConstants.largePadding),
                    _buildSectionTitle('Business Information'),
                    const SizedBox(height: AppConstants.defaultPadding),
                    _buildBusinessInfoSection(),
                    const SizedBox(height: AppConstants.largePadding),
                    _buildSectionTitle('Address Information'),
                    const SizedBox(height: AppConstants.defaultPadding),
                    _buildAddressSection(),
                    const SizedBox(height: AppConstants.largePadding),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Failed to load profile'));
        },
      ),
    );
  }

  Widget _buildProfileHeader(profile, bool isUploading) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight, width: 2),
                ),
                child: isUploading
                    ? const Center(child: CircularProgressIndicator())
                    : profile.logoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          profile.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.store,
                              size: 48,
                              color: AppColors.grey500,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.store,
                        size: 48,
                        color: AppColors.grey500,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 20),
                    color: Colors.white,
                    onPressed: isUploading ? null : _pickAndUploadLogo,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(profile.fullName, style: AppTextStyles.getH3(context)),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: AppTextStyles.getBodyMedium(
              context,
            ).copyWith(color: AppColors.grey500),
          ),
          if (profile.merchandiserCode != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Code: ${profile.merchandiserCode}',
                style: AppTextStyles.getBodySmall(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title.tr(), style: AppTextStyles.getH4(context));
  }

  Widget _buildPersonalInfoSection(profile) {
    return Column(
      children: [
        // Email (Read-only)
        TextFormField(
          initialValue: profile.email,
          decoration: InputDecoration(
            labelText: 'Email'.tr(),
            enabled: false,
            suffixIcon: const Icon(Icons.lock, size: 20),
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        // Full Name
        TextFormField(
          controller: _fullNameController,
          decoration: InputDecoration(labelText: 'Full Name'.tr()),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        // Phone Number
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number'.tr(),
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        // Website
        TextFormField(
          controller: _websiteController,
          decoration: InputDecoration(
            labelText: 'Website'.tr(),
            prefixIcon: const Icon(Icons.language),
          ),
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildBusinessInfoSection() {
    return Column(
      children: [
        // Business Name (EN)
        TextFormField(
          controller: _businessNameEnController,
          decoration: InputDecoration(
            labelText: 'Business Name (English)'.tr(),
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        // Business Name (AR)
        TextFormField(
          controller: _businessNameArController,
          decoration: InputDecoration(labelText: 'Business Name (Arabic)'.tr()),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        // Business Type (EN)
        TextFormField(
          controller: _businessTypeEnController,
          decoration: InputDecoration(
            labelText: 'Business Type (English)'.tr(),
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        // Business Type (AR)
        TextFormField(
          controller: _businessTypeArController,
          decoration: InputDecoration(labelText: 'Business Type (Arabic)'.tr()),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        // Description (EN)
        TextFormField(
          controller: _descriptionEnController,
          decoration: InputDecoration(labelText: 'Description (English)'.tr()),
          maxLines: 3,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        // Description (AR)
        TextFormField(
          controller: _descriptionArController,
          decoration: InputDecoration(labelText: 'Description (Arabic)'.tr()),
          maxLines: 3,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        // Tax ID
        TextFormField(
          controller: _taxIdController,
          decoration: InputDecoration(labelText: 'Tax ID'.tr()),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      children: [
        // Address (EN)
        TextFormField(
          controller: _addressEnController,
          decoration: InputDecoration(labelText: 'Address (English)'.tr()),
          maxLines: 2,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        // Address (AR)
        TextFormField(
          controller: _addressArController,
          decoration: InputDecoration(labelText: 'Address (Arabic)'.tr()),
          maxLines: 2,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityEnController,
                decoration: InputDecoration(labelText: 'City (English)'.tr()),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: TextFormField(
                controller: _cityArController,
                decoration: InputDecoration(labelText: 'City (Arabic)'.tr()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _stateEnController,
                decoration: InputDecoration(labelText: 'State (English)'.tr()),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: TextFormField(
                controller: _stateArController,
                decoration: InputDecoration(labelText: 'State (Arabic)'.tr()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _countryEnController,
                decoration: InputDecoration(
                  labelText: 'Country (English)'.tr(),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: TextFormField(
                controller: _countryArController,
                decoration: InputDecoration(labelText: 'Country (Arabic)'.tr()),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        TextFormField(
          controller: _postalCodeController,
          decoration: InputDecoration(labelText: 'Postal Code'.tr()),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  void _populateControllers(profile) {
    _fullNameController.text = profile.fullName;
    _phoneController.text = profile.phoneNumber ?? '';
    _websiteController.text = profile.website ?? '';
    _businessNameEnController.text = profile.businessName?['en'] ?? '';
    _businessNameArController.text = profile.businessName?['ar'] ?? '';
    _businessTypeEnController.text = profile.businessType?['en'] ?? '';
    _businessTypeArController.text = profile.businessType?['ar'] ?? '';
    _descriptionEnController.text = profile.description?['en'] ?? '';
    _descriptionArController.text = profile.description?['ar'] ?? '';
    _addressEnController.text = profile.address?['en'] ?? '';
    _addressArController.text = profile.address?['ar'] ?? '';
    _cityEnController.text = profile.city?['en'] ?? 'Cairo';
    _cityArController.text = profile.city?['ar'] ?? 'القاهرة';
    _stateEnController.text = profile.state?['en'] ?? '';
    _stateArController.text = profile.state?['ar'] ?? '';
    _countryEnController.text = profile.country?['en'] ?? 'Egypt';
    _countryArController.text = profile.country?['ar'] ?? 'مصر';
    _postalCodeController.text = profile.postalCode ?? '';
    _taxIdController.text = profile.taxId ?? '';
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        UpdateProfile(
          fullName: _fullNameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          website: _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
          businessName: {
            'en': _businessNameEnController.text.trim(),
            'ar': _businessNameArController.text.trim(),
          },
          businessType: {
            'en': _businessTypeEnController.text.trim(),
            'ar': _businessTypeArController.text.trim(),
          },
          description: {
            'en': _descriptionEnController.text.trim(),
            'ar': _descriptionArController.text.trim(),
          },
          address: {
            'en': _addressEnController.text.trim(),
            'ar': _addressArController.text.trim(),
          },
          city: {
            'en': _cityEnController.text.trim(),
            'ar': _cityArController.text.trim(),
          },
          state: {
            'en': _stateEnController.text.trim(),
            'ar': _stateArController.text.trim(),
          },
          country: {
            'en': _countryEnController.text.trim(),
            'ar': _countryArController.text.trim(),
          },
          postalCode: _postalCodeController.text.trim().isEmpty
              ? null
              : _postalCodeController.text.trim(),
          taxId: _taxIdController.text.trim().isEmpty
              ? null
              : _taxIdController.text.trim(),
        ),
      );
    }
  }

  Future<void> _pickAndUploadLogo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final imageBytes = result.files.first.bytes;
        if (imageBytes != null) {
          context.read<ProfileBloc>().add(UploadLogo(imageBytes));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: const ChangePasswordDialog(),
      ),
    );
  }
}
