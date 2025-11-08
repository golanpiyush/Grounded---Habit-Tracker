// screens/Community/community_screen.dart
import 'package:Grounded/models/CommunityModels/community_post.dart';
import 'package:Grounded/screens/Community/post_detail.dart';
import 'package:Grounded/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Grounded/providers/theme_provider.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:Grounded/theme/app_text_styles.dart';
import 'package:Grounded/utils/emoji_assets.dart';
import 'package:Grounded/services/mock_community_data.dart';
import 'package:Grounded/screens/Community/create_post.dart';
import 'package:Grounded/screens/Community/notifications_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CommunityPost> _posts = [];
  List<CommunityPost> _savedPosts = [];
  int _unreadNotifications = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPosts() {
    setState(() {
      _posts = MockCommunityData.getMockPosts();
      _savedPosts = _posts.where((post) => post.isSaved).toList();
    });
  }

  void _onLikePost(String postId) {
    HapticFeedback.lightImpact();
    setState(() {
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _posts[index];
        _posts[index] = post.copyWith(
          isLiked: !post.isLiked,
          likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
        );
      }
    });
  }

  void _onSavePost(String postId) {
    HapticFeedback.lightImpact();
    setState(() {
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _posts[index];
        _posts[index] = post.copyWith(
          isSaved: !post.isSaved,
          savesCount: post.isSaved ? post.savesCount - 1 : post.savesCount + 1,
        );
        _savedPosts = _posts.where((p) => p.isSaved).toList();
      }
    });
  }

  void _onCommentPost(String postId) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PostDetailScreen(
              post: _posts.firstWhere((p) => p.id == postId),
              onLike: _onLikePost,
              onSave: _onSavePost,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _createPost() async {
    HapticFeedback.lightImpact();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );

    if (result != null && result is CommunityPost) {
      setState(() {
        _posts.insert(0, result);
      });
    }
  }

  void _openNotifications() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    ).then((_) {
      setState(() {
        _unreadNotifications = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: AppColorsTheme.getBackground(currentTheme),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(currentTheme),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFeedTab(currentTheme),
                  _buildSavedTab(currentTheme),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPost,
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildHeader(AppThemeMode currentTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Community',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColorsTheme.getTextPrimary(currentTheme),
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none,
                      color: AppColorsTheme.getTextPrimary(currentTheme),
                      size: 26,
                    ),
                    onPressed: _openNotifications,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  if (_unreadNotifications > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accentOrange,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$_unreadNotifications',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildTab('Feed', 0, currentTheme),
              const SizedBox(width: 12),
              _buildTab('Saved', 1, currentTheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, AppThemeMode currentTheme) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _tabController.animateTo(index);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : AppColorsTheme.getCard(currentTheme),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : AppColorsTheme.getTextSecondary(currentTheme),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedTab(AppThemeMode currentTheme) {
    if (_posts.isEmpty) {
      return _buildEmptyState(
        'No posts yet',
        'Be the first to share',
        currentTheme,
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        _loadPosts();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPostCard(_posts[index], currentTheme),
          );
        },
      ),
    );
  }

  Widget _buildSavedTab(AppThemeMode currentTheme) {
    if (_savedPosts.isEmpty) {
      return _buildEmptyState(
        'No saved posts',
        'Bookmark posts to see them here',
        currentTheme,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _savedPosts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildPostCard(_savedPosts[index], currentTheme),
        );
      },
    );
  }

  Widget _buildPostCard(CommunityPost post, AppThemeMode currentTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColorsTheme.getCard(currentTheme),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    post.userInitial,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColorsTheme.getTextPrimary(currentTheme),
                      ),
                    ),
                    Text(
                      timeago.format(post.createdAt, locale: 'en_short'),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColorsTheme.getTextSecondary(currentTheme),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_horiz,
                  color: AppColorsTheme.getTextSecondary(currentTheme),
                  size: 20,
                ),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Content
          Text(
            post.content,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColorsTheme.getTextPrimary(currentTheme),
            ),
          ),

          // Tags
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: post.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              _buildActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: post.likesCount.toString(),
                isActive: post.isLiked,
                onTap: () => _onLikePost(post.id),
                currentTheme: currentTheme,
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: post.commentsCount.toString(),
                isActive: false,
                onTap: () => _onCommentPost(post.id),
                currentTheme: currentTheme,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  size: 22,
                  color: post.isSaved
                      ? AppColors.primaryGreen
                      : AppColorsTheme.getTextSecondary(currentTheme),
                ),
                onPressed: () => _onSavePost(post.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required AppThemeMode currentTheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: isActive
                ? AppColors.accentOrange
                : AppColorsTheme.getTextSecondary(currentTheme),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? AppColors.accentOrange
                  : AppColorsTheme.getTextSecondary(currentTheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String title,
    String subtitle,
    AppThemeMode currentTheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(EmojiAssets.seedling, width: 48, height: 48),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColorsTheme.getTextPrimary(currentTheme),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 15,
                color: AppColorsTheme.getTextSecondary(currentTheme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
