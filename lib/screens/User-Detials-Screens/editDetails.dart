import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grounded/theme/app_colors.dart';
import 'package:grounded/theme/app_text_styles.dart';
import 'package:grounded/providers/theme_provider.dart';
import 'package:grounded/utils/emoji_assets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

// ============= EDIT PROFILE SCREEN =============
class EditProfileScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? userProfile;

  const EditProfileScreen({Key? key, this.userProfile}) : super(key: key);

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.userProfile?['full_name'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.userProfile?['email'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.userProfile?['phone'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final themeMode = ref.read(themeProvider);
      final textPrimary = _getTextPrimaryColor(themeMode);

      // Show options dialog
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: _getCardColor(themeMode),
          title: Text(
            'Choose Image Source',
            style: AppTextStyles.bodyLarge(
              context,
            ).copyWith(color: textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: AppColors.primaryGreen,
                ),
                title: Text(
                  'Gallery',
                  style: AppTextStyles.bodyMedium(
                    context,
                  ).copyWith(color: textPrimary),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primaryGreen),
                title: Text(
                  'Camera',
                  style: AppTextStyles.bodyMedium(
                    context,
                  ).copyWith(color: textPrimary),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      // Check and request permissions
      bool hasPermission = await _checkAndRequestPermission(source);
      if (!hasPermission) {
        // Don't show snackbar here anymore - the permission method handles it
        return;
      }

      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      print('❌ Error picking image: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
      }
    }
  }

  Future<bool> _checkAndRequestPermission(ImageSource source) async {
    Permission permission;

    if (source == ImageSource.camera) {
      // For camera, we need camera permission
      permission = Permission.camera;
    } else {
      // For gallery, we need photos permission (or storage on Android)
      if (Platform.isIOS) {
        permission = Permission.photos;
      } else {
        // For Android, use storage or photos permission
        // Note: On Android 13+, use photos instead of storage for gallery access
        if (await Permission.storage.isGranted) {
          return true;
        }
        permission = Permission.photos;
      }
    }

    // Check current status
    var status = await permission.status;

    // If already granted, return true
    if (status.isGranted) {
      return true;
    }

    // If permanently denied, show settings option
    if (status.isPermanentlyDenied) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: _getCardColor(ref.read(themeProvider)),
            title: Text(
              'Permission Required',
              style: AppTextStyles.bodyLarge(
                context,
              ).copyWith(color: _getTextPrimaryColor(ref.read(themeProvider))),
            ),
            content: Text(
              'This permission is permanently denied. Please enable it in app settings.',
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(color: _getTextPrimaryColor(ref.read(themeProvider))),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: Text('Settings'),
              ),
            ],
          ),
        );
      }
      return false;
    }

    // Request the permission
    status = await permission.request();

    return status.isGranted;
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Save to database
    await Future.delayed(Duration(milliseconds: 800));

    setState(() => _isLoading = false);

    Navigator.pop(context, {
      'full_name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'profile_image': _profileImage,
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final backgroundColor = _getBackgroundColor(themeMode);
    final cardColor = _getCardColor(themeMode);
    final textPrimary = _getTextPrimaryColor(themeMode);
    final textSecondary = _getTextSecondaryColor(themeMode);
    final borderColor = _getBorderColor(themeMode);

    final fullName = _nameController.text.isNotEmpty
        ? _nameController.text
        : widget.userProfile?['full_name'] ?? 'Grounded User';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: AppTextStyles.headlineSmall(
            context,
          ).copyWith(color: textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.primaryGreen,
                      ),
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryGreen.withOpacity(0.2),
                          AppColors.primaryGreen.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: _profileImage != null
                        ? ClipOval(
                            child: Image.file(
                              _profileImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              fullName.isNotEmpty
                                  ? fullName[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Full Name
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            // Email
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'your.email@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              enabled: false, // Usually email shouldn't be editable
            ),
            const SizedBox(height: 16),

            // Phone
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '+1 (555) 123-4567',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Delete Account Warning
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'To change your email, please contact support',
                      style: AppTextStyles.bodySmall(
                        context,
                      ).copyWith(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    final themeMode = ref.watch(themeProvider);
    final cardColor = _getCardColor(themeMode);
    final textSecondary = _getTextSecondaryColor(themeMode);
    final borderColor = _getBorderColor(themeMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium(context).copyWith(
            fontWeight: FontWeight.w600,
            color: _getTextPrimaryColor(themeMode),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          style: AppTextStyles.bodyMedium(
            context,
          ).copyWith(color: _getTextPrimaryColor(themeMode)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: textSecondary),
            prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
            filled: true,
            fillColor: enabled ? cardColor : borderColor.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }

  Color _getBackgroundColor(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.dark:
        return const Color(0xFF1A1A1A);
      case AppThemeMode.amoled:
        return const Color(0xFF000000);
      default:
        return AppColors.background;
    }
  }

  Color _getCardColor(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.dark:
        return const Color(0xFF2D2D2D);
      case AppThemeMode.amoled:
        return const Color(0xFF0D0D0D);
      default:
        return AppColors.card;
    }
  }

  Color _getTextPrimaryColor(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return const Color(0xFFFFFFFF);
      default:
        return AppColors.textPrimary;
    }
  }

  Color _getTextSecondaryColor(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return const Color(0xFFB0B0B0);
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getBorderColor(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.dark:
        return const Color(0xFF404040);
      case AppThemeMode.amoled:
        return const Color(0xFF1A1A1A);
      default:
        return AppColors.border;
    }
  }
}
