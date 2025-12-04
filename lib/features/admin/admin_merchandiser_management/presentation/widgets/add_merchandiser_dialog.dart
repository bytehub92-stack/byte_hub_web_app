import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/create_merchandiser_request.dart';
import '../bloc/merchandiser_bloc/merchandiser_bloc.dart';
import '../bloc/merchandiser_bloc/merchandiser_event.dart';
import '../bloc/merchandiser_bloc/merchandiser_state.dart';

class AddMerchandiserDialog extends StatefulWidget {
  const AddMerchandiserDialog({super.key});

  @override
  State<AddMerchandiserDialog> createState() => _AddMerchandiserDialogState();
}

class _AddMerchandiserDialogState extends State<AddMerchandiserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessNameArabicController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _businessTypeArabicController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionArabicController = TextEditingController();

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessNameArabicController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _fullNameController.dispose();
    _businessTypeController.dispose();
    _businessTypeArabicController.dispose();
    _descriptionController.dispose();
    _descriptionArabicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MerchandiserBloc, MerchandiserState>(
      listener: (context, state) {
        if (state is MerchandiserError) {
          Navigator.pop(context);
        }
      },
      child: AlertDialog(
        title: const Text('Add New Merchandiser'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    controller: _businessNameController,
                    label: 'Business Name*',
                    hint: 'Enter business name',
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _businessNameArabicController,
                    label: 'Business Name (Arabic)',
                    hint: 'Enter Arabic business name',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Contact Person Name*',
                    hint: 'Enter contact person name',
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number*',
                    hint: 'Enter phone number',
                    keyboardType: TextInputType.phone,
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email*',
                    hint: 'Enter email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _businessTypeController,
                    label: 'Business Type*',
                    hint: 'e.g., Electronics, Fashion, Food',
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _businessTypeArabicController,
                    label: 'Business Type (Arabic)',
                    hint: 'Enter Arabic business type',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description*',
                    hint: 'Brief description of the business',
                    maxLines: 3,
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionArabicController,
                    label: 'Description (Arabic)',
                    hint: 'Brief description in Arabic',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          BlocBuilder<MerchandiserBloc, MerchandiserState>(
            builder: (context, state) {
              final isLoading = state is MerchandiserCreating;

              return ElevatedButton(
                onPressed: isLoading ? null : _createMerchandiser,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: validator,
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  void _createMerchandiser() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final request = CreateMerchandiserRequest(
      businessName: _businessNameController.text.trim(),
      businessNameArabic: _businessNameArabicController.text.trim().isEmpty
          ? null
          : _businessNameArabicController.text.trim(),
      businessType: _businessTypeController.text.trim(),
      businessTypeArabic: _businessTypeArabicController.text.trim().isEmpty
          ? null
          : _businessTypeArabicController.text.trim(),
      description: _descriptionController.text.trim(),
      descriptionArabic: _descriptionArabicController.text.trim().isEmpty
          ? null
          : _descriptionArabicController.text.trim(),
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    context.read<MerchandiserBloc>().add(
      CreateMerchandiserEvent(request: request),
    );
  }
}
