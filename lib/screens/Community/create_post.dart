// screens/Community/create_post_screen.dart
import 'package:Grounded/models/CommunityModels/community_post.dart';
import 'package:Grounded/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Grounded/providers/theme_provider.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:Grounded/theme/app_text_styles.dart';
import 'package:Grounded/utils/emoji_assets.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final List<String> _selectedTags = [];
  final List<String> _availableTags = [
    'milestone',
    'awareness',
    'support',
    'mindset',
    'journaling',
    'self-care',
    'honesty',
    'community',
    'tips',
    'mindfulness',
    'progress',
    'gratitude',
  ];

  bool _isPosting = false;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(() {
      setState(() {
        _characterCount = _contentController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        if (_selectedTags.length < 3) {
          _selectedTags.add(tag);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You can only select up to 3 tags'),
              backgroundColor: AppColors.accentOrange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    });
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text('Please write something to share'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isPosting = true);
    HapticFeedback.mediumImpact();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1500));

    final newPost = CommunityPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      userName: 'You',
      userInitial: 'Y',
      content: _contentController.text.trim(),
      createdAt: DateTime.now(),
      tags: _selectedTags,
    );

    if (mounted) {
      Navigator.pop(context, newPost);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final canPost = _contentController.text.trim().isNotEmpty && !_isPosting;

    return Scaffold(
      backgroundColor: AppColorsTheme.getBackground(currentTheme),
      appBar: AppBar(
        backgroundColor: AppColorsTheme.getCard(currentTheme),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColorsTheme.getBackground(currentTheme),
              border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.close,
              color: AppColorsTheme.getTextPrimary(currentTheme),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Post',
          style: AppTextStyles.headlineSmall(context).copyWith(
            color: AppColorsTheme.getTextPrimary(currentTheme),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: canPost ? _createPost : null,
              style: TextButton.styleFrom(
                backgroundColor: canPost
                    ? AppColors.primaryGreen
                    : AppColors.primaryGreen.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: _isPosting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColorsTheme.getBorder(currentTheme),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(currentTheme),
            const SizedBox(height: 20),
            _buildContentInput(currentTheme),
            const SizedBox(height: 8),
            _buildCharacterCount(currentTheme),
            const SizedBox(height: 28),
            _buildTagsSection(currentTheme),
            const SizedBox(height: 28),
            _buildImageUploadSection(currentTheme),
            const SizedBox(height: 28),
            _buildGuidelinesCard(currentTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppThemeMode currentTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsTheme.getCard(currentTheme),
        border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryGreen.withOpacity(0.3),
                  AppColors.primaryGreen.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                'Y',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You',
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColorsTheme.getTextPrimary(currentTheme),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.public,
                      size: 14,
                      color: AppColorsTheme.getTextSecondary(currentTheme),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Sharing with Community',
                      style: AppTextStyles.caption(context).copyWith(
                        color: AppColorsTheme.getTextSecondary(currentTheme),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentInput(AppThemeMode currentTheme) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsTheme.getCard(currentTheme),
        border: Border.all(
          color: _contentController.text.isNotEmpty
              ? AppColors.primaryGreen.withOpacity(0.3)
              : AppColorsTheme.getBorder(currentTheme),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _contentController,
        maxLines: null,
        minLines: 10,
        decoration: InputDecoration(
          hintText:
              'Share your thoughts, experiences, or tips with the community...',
          hintStyle: TextStyle(
            color: AppColorsTheme.getTextSecondary(currentTheme),
            height: 1.5,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        style: TextStyle(
          color: AppColorsTheme.getTextPrimary(currentTheme),
          fontSize: 15,
          height: 1.6,
        ),
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  Widget _buildCharacterCount(AppThemeMode currentTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$_characterCount characters',
            style: AppTextStyles.caption(
              context,
            ).copyWith(color: AppColorsTheme.getTextSecondary(currentTheme)),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(AppThemeMode currentTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_offer_outlined,
                  size: 18,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                // ← Add Expanded here to prevent overflow
                child: Text(
                  'Add Tags',
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColorsTheme.getTextPrimary(currentTheme),
                  ),
                ),
              ),
              const SizedBox(width: 10), // ← Add some spacing
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _selectedTags.length == 3
                      ? AppColors.primaryGreen.withOpacity(0.1)
                      : AppColorsTheme.getCard(currentTheme),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedTags.length == 3
                        ? AppColors.primaryGreen
                        : AppColorsTheme.getBorder(currentTheme),
                  ),
                ),
                child: Text(
                  '${_selectedTags.length}/3',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _selectedTags.length == 3
                        ? AppColors.primaryGreen
                        : AppColorsTheme.getTextSecondary(currentTheme),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return InkWell(
              onTap: () => _toggleTag(tag),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryGreen,
                            AppColors.primaryGreen.withOpacity(0.8),
                          ],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : AppColorsTheme.getCard(currentTheme),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColorsTheme.getBorder(currentTheme),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    Text(
                      '#$tag',
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColorsTheme.getTextPrimary(currentTheme),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection(AppThemeMode currentTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.image_outlined,
                  size: 18,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                // ← Add Expanded here
                child: Text(
                  'Add Image',
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColorsTheme.getTextPrimary(currentTheme),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColorsTheme.getCard(currentTheme),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColorsTheme.getBorder(currentTheme),
                  ),
                ),
                child: Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColorsTheme.getTextSecondary(currentTheme),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('Image upload coming soon!'),
                  ],
                ),
                backgroundColor: AppColors.accentOrange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColorsTheme.getCard(currentTheme),
              border: Border.all(
                color: AppColorsTheme.getBorder(currentTheme),
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 32,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to add image',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColorsTheme.getTextSecondary(currentTheme),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Max 5MB',
                    style: AppTextStyles.caption(context).copyWith(
                      color: AppColorsTheme.getTextSecondary(currentTheme),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuidelinesCard(AppThemeMode currentTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.05),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: AppColors.primaryGreen),
              const SizedBox(width: 10),
              Text(
                'Community Guidelines',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuidelineItem('• Be respectful and supportive', currentTheme),
          _buildGuidelineItem(
            '• Share honestly without judgment',
            currentTheme,
          ),
          _buildGuidelineItem(
            '• Focus on harm reduction, not shame',
            currentTheme,
          ),
          _buildGuidelineItem(
            '• No medical advice or triggering content',
            currentTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text, AppThemeMode currentTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppTextStyles.bodySmall(context).copyWith(
          color: AppColorsTheme.getTextSecondary(currentTheme),
          height: 1.4,
        ),
      ),
    );
  }
}
