// screens/Community/notifications_screen.dart
import 'package:Grounded/services/mock_community_data.dart';
import 'package:Grounded/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Grounded/providers/theme_provider.dart';
import 'package:Grounded/theme/app_colors.dart';
import 'package:Grounded/theme/app_text_styles.dart';
import 'package:Grounded/utils/emoji_assets.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<CommunityNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = MockCommunityData.getMockNotifications();
    });
  }

  void _markAsRead(String notificationId) {
    HapticFeedback.lightImpact();
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    HapticFeedback.lightImpact();
    setState(() {
      _notifications = _notifications
          .map((notification) => notification.copyWith(isRead: true))
          .toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('All notifications marked as read'),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.chat_bubble;
      case NotificationType.reply:
        return Icons.reply;
      case NotificationType.save:
        return Icons.bookmark;
      case NotificationType.mention:
        return Icons.alternate_email;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return AppColors.accentOrange;
      case NotificationType.comment:
      case NotificationType.reply:
        return AppColors.primaryGreen;
      case NotificationType.save:
        return const Color(0xFF4A90E2);
      case NotificationType.mention:
        return const Color(0xFF9B59B6);
    }
  }

  String _getNotificationEmoji(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return '❤️';
      case NotificationType.comment:
        return '💬';
      case NotificationType.reply:
        return '↩️';
      case NotificationType.save:
        return '🔖';
      case NotificationType.mention:
        return '📢';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final unreadCount = _notifications.where((n) => !n.isRead).length;

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
              Icons.arrow_back,
              color: AppColorsTheme.getTextPrimary(currentTheme),
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: AppTextStyles.headlineSmall(context).copyWith(
                color: AppColorsTheme.getTextPrimary(currentTheme),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount new',
                style: AppTextStyles.caption(context).copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: _markAllAsRead,
                icon: Icon(
                  Icons.done_all,
                  size: 18,
                  color: AppColors.primaryGreen,
                ),
                label: Text(
                  'Mark all',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
      body: _notifications.isEmpty
          ? _buildEmptyState(currentTheme)
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: AppColorsTheme.getBorder(currentTheme),
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                return _buildNotificationItem(
                  _notifications[index],
                  currentTheme,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(AppThemeMode currentTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none,
                size: 64,
                color: AppColors.primaryGreen.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No notifications yet',
              style: AppTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.w600,
                color: AppColorsTheme.getTextPrimary(currentTheme),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'When someone interacts with your posts,\nyou\'ll see it here',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColorsTheme.getTextSecondary(currentTheme),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    CommunityNotification notification,
    AppThemeMode currentTheme,
  ) {
    final notificationColor = _getNotificationColor(notification.type);

    return InkWell(
      onTap: () {
        _markAsRead(notification.id);
        // TODO: Navigate to post or comment
        HapticFeedback.lightImpact();
      },
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : AppColors.primaryGreen.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar with Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
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
                      color: notification.isRead
                          ? AppColorsTheme.getBorder(currentTheme)
                          : AppColors.primaryGreen.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      notification.actorInitial,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: notificationColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColorsTheme.getCard(currentTheme),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: notificationColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _getNotificationIcon(notification.type),
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Notification Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: AppColorsTheme.getTextPrimary(currentTheme),
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: notification.actorName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: ' ${notification.message}',
                          style: TextStyle(
                            color: AppColorsTheme.getTextSecondary(
                              currentTheme,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: notificationColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getNotificationEmoji(notification.type),
                              style: const TextStyle(fontSize: 10),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              notification.type.toString().split('.').last,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: notificationColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColorsTheme.getTextSecondary(currentTheme),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeago.format(notification.createdAt),
                        style: AppTextStyles.caption(context).copyWith(
                          color: AppColorsTheme.getTextSecondary(currentTheme),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Unread Indicator
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (!notification.isRead)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
