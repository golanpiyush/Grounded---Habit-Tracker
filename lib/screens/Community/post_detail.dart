// screens/Community/post_detail_screen.dart
import 'package:Grounded/models/CommunityModels/postcomments.dart';
import 'package:Grounded/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Grounded/models/CommunityModels/community_post.dart';
import 'package:Grounded/providers/theme_provider.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:Grounded/theme/app_text_styles.dart';
import 'package:Grounded/services/mock_community_data.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailScreen extends ConsumerStatefulWidget {
  final CommunityPost post;
  final Function(String) onLike;
  final Function(String) onSave;

  const PostDetailScreen({
    Key? key,
    required this.post,
    required this.onLike,
    required this.onSave,
  }) : super(key: key);

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  late CommunityPost _post;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    // Load full post data with comments
    _loadPostDetails();
  }

  void _loadPostDetails() {
    final fullPost = MockCommunityData.getPostWithComments(_post.id);
    if (fullPost != null) {
      setState(() {
        _post = fullPost;
      });
    }
  }

  void _onLikePost() {
    HapticFeedback.lightImpact();
    widget.onLike(_post.id);
    setState(() {
      _post = _post.copyWith(
        isLiked: !_post.isLiked,
        likesCount: _post.isLiked ? _post.likesCount - 1 : _post.likesCount + 1,
      );
    });
  }

  void _onSavePost() {
    HapticFeedback.lightImpact();
    widget.onSave(_post.id);
    setState(() {
      _post = _post.copyWith(
        isSaved: !_post.isSaved,
        savesCount: _post.isSaved ? _post.savesCount - 1 : _post.savesCount + 1,
      );
    });
  }

  void _submitComment() async {
    if (_commentController.text.trim().isEmpty || _isSubmittingComment) return;

    setState(() {
      _isSubmittingComment = true;
    });

    HapticFeedback.lightImpact();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    final newComment = PostComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      userName: 'You',
      userInitial: 'Y',
      content: _commentController.text.trim(),
      createdAt: DateTime.now(),
      likesCount: 0,
      isLiked: false,
      replies: [],
    );

    setState(() {
      _post = _post.copyWith(
        comments: [..._post.comments, newComment],
        commentsCount: _post.commentsCount + 1,
      );
      _commentController.clear();
    });

    // Scroll to the new comment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    setState(() {
      _isSubmittingComment = false;
    });
  }

  void _onLikeComment(String commentId) {
    HapticFeedback.lightImpact();
    setState(() {
      final commentIndex = _post.comments.indexWhere((c) => c.id == commentId);
      if (commentIndex != -1) {
        final comment = _post.comments[commentIndex];
        _post.comments[commentIndex] = comment.copyWith(
          isLiked: !comment.isLiked,
          likesCount: comment.isLiked
              ? comment.likesCount - 1
              : comment.likesCount + 1,
        );
      }
    });
  }

  void _onReplyToComment(String commentId) {
    // Focus on comment field and add mention
    final comment = _post.comments.firstWhere((c) => c.id == commentId);
    _commentController.text = '@${comment.userName} ';
    _commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _commentController.text.length),
    );
    FocusScope.of(context).requestFocus(FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
      // Scroll to comment field
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
            Expanded(child: _buildContent(currentTheme)),
            _buildCommentInput(currentTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppThemeMode currentTheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColorsTheme.getCard(currentTheme),
        border: Border(
          bottom: BorderSide(
            color: AppColorsTheme.getBorder(currentTheme),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColorsTheme.getBackground(currentTheme),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColorsTheme.getBorder(currentTheme),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 18,
                color: AppColorsTheme.getTextPrimary(currentTheme),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Post',
            style: AppTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.w700,
              color: AppColorsTheme.getTextPrimary(currentTheme),
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: AppColorsTheme.getBackground(currentTheme),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
            ),
            child: IconButton(
              icon: Icon(
                Icons.share_outlined,
                size: 20,
                color: AppColorsTheme.getTextPrimary(currentTheme),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                // Share functionality would go here
              },
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppThemeMode currentTheme) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(child: _buildPostCard(currentTheme)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColorsTheme.getTextPrimary(currentTheme),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _post.commentsCount.toString(),
                    style: AppTextStyles.caption(context).copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_post.comments.isEmpty)
          SliverToBoxAdapter(child: _buildEmptyComments(currentTheme))
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return _buildCommentCard(_post.comments[index], currentTheme);
            }, childCount: _post.comments.length),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildPostCard(AppThemeMode currentTheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsTheme.getCard(currentTheme),
        border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
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
                      _post.userInitial,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
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
                        _post.userName,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColorsTheme.getTextPrimary(currentTheme),
                        ),
                      ),
                      Text(
                        timeago.format(_post.createdAt, locale: 'en_short'),
                        style: AppTextStyles.caption(context).copyWith(
                          color: AppColorsTheme.getTextSecondary(currentTheme),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              _post.content,
              style: AppTextStyles.bodyLarge(context).copyWith(
                color: AppColorsTheme.getTextPrimary(currentTheme),
                height: 1.6,
              ),
            ),
          ),

          // Tags
          if (_post.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _post.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      '#$tag',
                      style: AppTextStyles.caption(context).copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildStatItem(
                  _post.likesCount.toString(),
                  'likes',
                  currentTheme,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  _post.commentsCount.toString(),
                  'comments',
                  currentTheme,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  _post.savesCount.toString(),
                  'saves',
                  currentTheme,
                ),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColorsTheme.getBorder(currentTheme),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _buildActionButton(
                  icon: _post.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: 'Like',
                  color: _post.isLiked ? AppColors.accentOrange : null,
                  onTap: _onLikePost,
                  currentTheme: currentTheme,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Comment',
                  onTap: () {
                    // Focus on comment field
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });
                  },
                  currentTheme: currentTheme,
                ),
                const Spacer(),
                _buildActionButton(
                  icon: _post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  label: 'Save',
                  color: _post.isSaved ? AppColors.primaryGreen : null,
                  onTap: _onSavePost,
                  currentTheme: currentTheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, AppThemeMode currentTheme) {
    return Row(
      children: [
        Text(
          count,
          style: AppTextStyles.bodyMedium(context).copyWith(
            fontWeight: FontWeight.w700,
            color: AppColorsTheme.getTextPrimary(currentTheme),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption(
            context,
          ).copyWith(color: AppColorsTheme.getTextSecondary(currentTheme)),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
    required AppThemeMode currentTheme,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color != null ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // ← Add this to prevent overflow
            children: [
              Icon(
                icon,
                size: 18,
                color: color ?? AppColorsTheme.getTextSecondary(currentTheme),
              ),
              const SizedBox(width: 6),
              Flexible(
                // ← Wrap text in Flexible to allow shrinking
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        color ?? AppColorsTheme.getTextSecondary(currentTheme),
                  ),
                  overflow: TextOverflow.ellipsis, // ← Handle text overflow
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentCard(PostComment comment, AppThemeMode currentTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColorsTheme.getCard(currentTheme),
        border: Border.all(color: AppColorsTheme.getBorder(currentTheme)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
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
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      comment.userInitial,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userName,
                        style: AppTextStyles.bodySmall(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColorsTheme.getTextPrimary(currentTheme),
                        ),
                      ),
                      Text(
                        timeago.format(comment.createdAt, locale: 'en_short'),
                        style: AppTextStyles.caption(context).copyWith(
                          color: AppColorsTheme.getTextSecondary(currentTheme),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _onLikeComment(comment.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Icon(
                          comment.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 14,
                          color: comment.isLiked
                              ? AppColors.accentOrange
                              : AppColorsTheme.getTextSecondary(currentTheme),
                        ),
                        if (comment.likesCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            comment.likesCount.toString(),
                            style: AppTextStyles.caption(context).copyWith(
                              color: comment.isLiked
                                  ? AppColors.accentOrange
                                  : AppColorsTheme.getTextSecondary(
                                      currentTheme,
                                    ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Comment Content
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(
              comment.content,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColorsTheme.getTextPrimary(currentTheme),
                height: 1.4,
              ),
            ),
          ),

          // Reply Button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: GestureDetector(
              onTap: () => _onReplyToComment(comment.id),
              child: Text(
                'Reply',
                style: AppTextStyles.caption(context).copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Replies
          if (comment.replies.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColorsTheme.getBackground(currentTheme),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColorsTheme.getBorder(currentTheme),
                ),
              ),
              child: Column(
                children: comment.replies.map((reply) {
                  return _buildReplyCard(reply, currentTheme);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReplyCard(PostComment reply, AppThemeMode currentTheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGreen.withOpacity(0.2),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                reply.userInitial,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reply.userName,
                  style: AppTextStyles.caption(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColorsTheme.getTextPrimary(currentTheme),
                  ),
                ),
                Text(
                  reply.content,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColorsTheme.getTextPrimary(currentTheme),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(reply.createdAt, locale: 'en_short'),
                  style: AppTextStyles.caption(context).copyWith(
                    color: AppColorsTheme.getTextSecondary(currentTheme),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyComments(AppThemeMode currentTheme) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: AppColorsTheme.getTextSecondary(
              currentTheme,
            ).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No comments yet',
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColorsTheme.getTextSecondary(currentTheme),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your thoughts',
            style: AppTextStyles.caption(
              context,
            ).copyWith(color: AppColorsTheme.getTextSecondary(currentTheme)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(AppThemeMode currentTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsTheme.getCard(currentTheme),
        border: Border(
          top: BorderSide(
            color: AppColorsTheme.getBorder(currentTheme),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColorsTheme.getBackground(currentTheme),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColorsTheme.getBorder(currentTheme),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                          color: AppColorsTheme.getTextSecondary(currentTheme),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: AppColorsTheme.getTextPrimary(currentTheme),
                      ),
                    ),
                  ),
                  if (_commentController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      onPressed: _submitComment,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
