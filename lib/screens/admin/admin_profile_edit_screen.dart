import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class AdminProfileEditScreen extends StatefulWidget {
  const AdminProfileEditScreen({super.key});

  @override
  State<AdminProfileEditScreen> createState() => _AdminProfileEditScreenState();
}

class _AdminProfileEditScreenState extends State<AdminProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _nameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';

        // Load additional data from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          _phoneController.text = data['phone'] ?? '';
        }
      }
    } catch (e) {
      _showSnackBar('Error loading profile data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileImage(),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildNameField(),
                    const SizedBox(height: AppTheme.paddingMedium),
                    _buildEmailField(),
                    const SizedBox(height: AppTheme.paddingMedium),
                    _buildPhoneField(),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: AppTheme.primaryGreen,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 60,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          TextButton.icon(
            onPressed: () {
              // TODO: Implement image picker
              _showSnackBar('Image picker coming soon');
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Change Photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.lightGray,
            hintText: 'Enter your full name',
            hintStyle: AppTheme.caption.copyWith(color: AppTheme.gray),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide:
                  const BorderSide(color: AppTheme.primaryGreen, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
              vertical: AppTheme.paddingMedium,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        TextFormField(
          controller: _emailController,
          enabled: false, // Email cannot be changed
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.gray.withValues(alpha: 0.1),
            hintText: 'Enter your email',
            hintStyle: AppTheme.caption.copyWith(color: AppTheme.gray),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide:
                  const BorderSide(color: AppTheme.primaryGreen, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
              vertical: AppTheme.paddingMedium,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        Text(
          'Email cannot be changed for security reasons',
          style: AppTheme.caption.copyWith(color: AppTheme.gray),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppTheme.paddingSmall),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.lightGray,
            hintText: 'Enter your phone number',
            hintStyle: AppTheme.caption.copyWith(color: AppTheme.gray),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide:
                  const BorderSide(color: AppTheme.primaryGreen, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingMedium,
              vertical: AppTheme.paddingMedium,
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              // Basic phone validation
              if (value.length < 10) {
                return 'Please enter a valid phone number';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(_nameController.text);

        // Update additional data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'displayName': _nameController.text,
          'phone': _phoneController.text,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        _showSnackBar('Profile updated successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Error updating profile: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
