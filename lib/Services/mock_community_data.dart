// services/mock_community_data.dart
import 'package:Grounded/Services/mock_community_data.dart';
import 'package:Grounded/models/CommunityModels/community_post.dart';
import 'package:Grounded/models/CommunityModels/postcomments.dart';

class MockCommunityData {
  static List<CommunityPost> getMockPosts() {
    return [
      CommunityPost(
        id: 'post_1',
        userId: 'user_1',
        userName: 'Morgan',
        userInitial: 'M',
        content:
            'Today was challenging but I remembered to practice self-compassion. Progress isn\'t always linear, and that\'s okay. What helps you be kind to yourself on tough days?',
        imageUrls: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 24,
        commentsCount: 8,
        savesCount: 5,
        isLiked: true,
        isSaved: false,
        tags: ['selfcompassion', 'mindfulness', 'progress'],
      ),
      CommunityPost(
        id: 'post_2',
        userId: 'user_2',
        userName: 'Alex',
        userInitial: 'A',
        content:
            'Sharing a grounding technique that\'s been helpful: 5-4-3-2-1 method. Notice 5 things you can see, 4 things you can touch, 3 things you can hear, 2 things you can smell, 1 thing you can taste. It brings me back to the present moment.',
        imageUrls: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likesCount: 42,
        commentsCount: 12,
        savesCount: 18,
        isLiked: false,
        isSaved: true,
        tags: ['grounding', 'coping', 'present'],
      ),
      CommunityPost(
        id: 'post_3',
        userId: 'user_3',
        userName: 'Sam',
        userInitial: 'S',
        content:
            'Reminder: It\'s okay to not be okay. Your feelings are valid. You don\'t have to have everything figured out. Taking things one breath at a time is enough.',
        imageUrls: [],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likesCount: 67,
        commentsCount: 15,
        savesCount: 23,
        isLiked: true,
        isSaved: true,
        tags: ['validation', 'mentalhealth', 'support'],
      ),
      CommunityPost(
        id: 'post_4',
        userId: 'user_4',
        userName: 'Taylor',
        userInitial: 'T',
        content:
            'Does anyone else find nature walks helpful for managing anxiety? The combination of fresh air, movement, and natural surroundings has been a gentle way for me to process difficult emotions.',
        imageUrls: [],
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        likesCount: 31,
        commentsCount: 9,
        savesCount: 7,
        isLiked: false,
        isSaved: false,
        tags: ['anxiety', 'nature', 'movement'],
      ),
      CommunityPost(
        id: 'post_5',
        userId: 'user_5',
        userName: 'Abhishek',
        userInitial: 'A',
        content:
            'Celebrating small wins today: Got out of bed, drank water, took my meds. Some days these are big accomplishments. Remember to acknowledge your efforts, no matter how small they seem.',
        imageUrls: [],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        likesCount: 89,
        commentsCount: 22,
        savesCount: 34,
        isLiked: true,
        isSaved: false,
        tags: ['smallwins', 'selfcare', 'medication'],
      ),
      CommunityPost(
        id: 'post_6',
        userId: 'user_6',
        userName: 'Riley',
        userInitial: 'R',
        content:
            'For those struggling with sleep: Creating a gentle bedtime routine has helped me. No screens an hour before bed, herbal tea, and reading something uplifting. What sleep tips have worked for you?',
        imageUrls: [],
        createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
        likesCount: 38,
        commentsCount: 14,
        savesCount: 11,
        isLiked: false,
        isSaved: true,
        tags: ['sleep', 'routine', 'selfcare'],
      ),
      CommunityPost(
        id: 'post_7',
        userId: 'user_7',
        userName: 'Casey',
        userInitial: 'C',
        content:
            'Harm reduction reminder: Meeting yourself where you\'re at is an act of courage. Whether you\'re reducing use, taking a break, or just getting through the day - you\'re doing important work.',
        imageUrls: [],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        likesCount: 56,
        commentsCount: 18,
        savesCount: 27,
        isLiked: true,
        isSaved: true,
        tags: ['harmreduction', 'courage', 'support'],
      ),
      CommunityPost(
        id: 'post_8',
        userId: 'user_8',
        userName: 'Drew',
        userInitial: 'D',
        content:
            'Sharing a breathing technique: Box breathing - inhale 4 counts, hold 4 counts, exhale 4 counts, hold 4 counts. Repeat. It\'s been a discreet way to manage panic attacks in public.',
        imageUrls: [],
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        likesCount: 47,
        commentsCount: 11,
        savesCount: 19,
        isLiked: false,
        isSaved: false,
        tags: ['breathing', 'panic', 'coping'],
      ),
    ];
  }

  static List<CommunityPost> getMockSavedPosts() {
    return getMockPosts().where((post) => post.isSaved).toList();
  }

  static List<String> getPopularTags() {
    return [
      'selfcompassion',
      'grounding',
      'anxiety',
      'smallwins',
      'harmreduction',
      'mindfulness',
      'coping',
      'support',
      'mentalhealth',
      'selfcare',
      'breathing',
      'sleep',
      'progress',
      'validation',
    ];
  }

  static Map<String, String> getTagDescriptions() {
    return {
      'selfcompassion': 'Practicing kindness and understanding toward oneself',
      'grounding': 'Techniques to stay present and connected to the moment',
      'anxiety': 'Managing anxious thoughts and feelings',
      'smallwins': 'Celebrating everyday accomplishments',
      'harmreduction': 'Practical strategies to reduce negative consequences',
      'mindfulness': 'Staying present and aware without judgment',
      'coping': 'Healthy ways to manage difficult emotions and situations',
      'support': 'Community encouragement and understanding',
      'mentalhealth': 'Overall psychological well-being',
      'selfcare': 'Intentional practices to maintain health and well-being',
      'breathing': 'Techniques using breath to regulate nervous system',
      'sleep': 'Strategies for restful sleep and bedtime routines',
      'progress': 'Acknowledging growth and forward movement',
      'validation': 'Recognizing and accepting feelings as valid',
    };
  }

  static CommunityPost createMockPost({
    required String content,
    List<String> tags = const [],
    List<String> imageUrls = const [],
  }) {
    return CommunityPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      userName: 'You',
      userInitial: 'Y',
      content: content,
      imageUrls: imageUrls,
      createdAt: DateTime.now(),
      likesCount: 0,
      commentsCount: 0,
      savesCount: 0,
      isLiked: false,
      isSaved: false,
      tags: tags,
    );
  }

  static CommunityPost? getPostWithComments(String postId) {
    final post = getMockPosts().firstWhere((post) => post.id == postId);
    final comments = PostComments.getMockCommentsForPost(postId);
    return post.copyWith(
      comments:
          comments, // This is fine since comments is non-null List<PostComment>
      commentsCount: comments.length,
    );
  }

  // For notifications screen
  static List<CommunityNotification> getMockNotifications() {
    return [
      CommunityNotification(
        id: 'notif_1',
        type: NotificationType.like,
        actorId: 'user_2',
        actorName: 'Alex Chen',
        actorInitial: 'A',
        message: 'liked your post',
        postId: 'post_1',
        postPreview:
            'Today was challenging but I remembered to practice self-compassion...',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        isRead: false,
      ),
      CommunityNotification(
        id: 'notif_2',
        type: NotificationType.comment,
        actorId: 'user_4',
        actorName: 'Taylor Kim',
        actorInitial: 'T',
        message: 'commented on your post',
        postId: 'post_1',
        postPreview:
            'Today was challenging but I remembered to practice self-compassion...',
        commentPreview:
            'I needed to hear this today. Thank you for the reminder...',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      CommunityNotification(
        id: 'notif_3',
        type: NotificationType.like,
        actorId: 'user_5',
        actorName: 'Jordan Patel',
        actorInitial: 'J',
        message: 'liked your post',
        postId: 'post_3',
        postPreview:
            'Reminder: It\'s okay to not be okay. Your feelings are valid...',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      CommunityNotification(
        id: 'notif_4',
        type: NotificationType.comment,
        actorId: 'user_7',
        actorName: 'Casey Morgan',
        actorInitial: 'C',
        message: 'commented on your post',
        postId: 'post_3',
        postPreview:
            'Reminder: It\'s okay to not be okay. Your feelings are valid...',
        commentPreview:
            'Needed this today. The pressure to have everything together...',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      CommunityNotification(
        id: 'notif_5',
        type: NotificationType.comment,
        actorId: 'user_8',
        actorName: 'Drew Williams',
        actorInitial: 'D',
        message: 'started following you',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
      ),
      CommunityNotification(
        id: 'notif_6',
        type: NotificationType.like,
        actorId: 'user_6',
        actorName: 'Riley Zhang',
        actorInitial: 'R',
        message: 'liked your post',
        postId: 'post_5',
        postPreview:
            'Celebrating small wins today: Got out of bed, drank water...',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];
  }
}

// models/CommunityModels/community_notification.dart
enum NotificationType { like, comment, reply, save, mention }

class CommunityNotification {
  final String id;
  final NotificationType type;
  final String actorId;
  final String actorName;
  final String actorInitial;
  final String message;
  final String? postId;
  final String? postPreview;
  final String? commentPreview;
  final DateTime createdAt;
  final bool isRead;

  CommunityNotification({
    required this.id,
    required this.type,
    required this.actorId,
    required this.actorName,
    required this.actorInitial,
    required this.message,
    this.postId,
    this.postPreview,
    this.commentPreview,
    required this.createdAt,
    required this.isRead,
  });

  CommunityNotification copyWith({
    String? id,
    NotificationType? type,
    String? actorId,
    String? actorName,
    String? actorInitial,
    String? message,
    String? postId,
    String? postPreview,
    String? commentPreview,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return CommunityNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      actorInitial: actorInitial ?? this.actorInitial,
      message: message ?? this.message,
      postId: postId ?? this.postId,
      postPreview: postPreview ?? this.postPreview,
      commentPreview: commentPreview ?? this.commentPreview,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

// Extension method to get comments for posts
extension PostComments on MockCommunityData {
  static List<PostComment> getMockCommentsForPost(String postId) {
    switch (postId) {
      case 'post_1':
        return [
          PostComment(
            id: 'comment_1_1',
            userId: 'user_2',
            userName: 'Alex Chen',
            userInitial: 'A',
            content:
                'Thanks for sharing this. The reminder about self-compassion is so important. On tough days, I try to talk to myself like I would talk to a good friend.',
            createdAt: DateTime.now().subtract(
              const Duration(hours: 1, minutes: 45),
            ),
            likesCount: 3,
            isLiked: false,
            replies: [
              PostComment(
                id: 'reply_1_1',
                userId: 'user_3',
                userName: 'Sam Rivera',
                userInitial: 'S',
                content:
                    'That\'s such a beautiful practice. We often forget to be as kind to ourselves as we are to others.',
                createdAt: DateTime.now().subtract(const Duration(hours: 1)),
                likesCount: 1,
                isLiked: true,
                replies: [],
              ),
            ],
          ),
          PostComment(
            id: 'comment_1_2',
            userId: 'user_4',
            userName: 'Taylor Kim',
            userInitial: 'T',
            content:
                'I needed to hear this today. Thank you for the reminder that progress isn\'t linear.',
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
            likesCount: 2,
            isLiked: true,
            replies: [],
          ),
        ];

      case 'post_2':
        return [
          PostComment(
            id: 'comment_2_1',
            userId: 'user_5',
            userName: 'Jordan Patel',
            userInitial: 'J',
            content:
                'The 5-4-3-2-1 method has been really helpful for me too! It\'s especially useful in overwhelming situations.',
            createdAt: DateTime.now().subtract(
              const Duration(hours: 4, minutes: 30),
            ),
            likesCount: 5,
            isLiked: false,
            replies: [
              PostComment(
                id: 'reply_2_1',
                userId: 'user_2',
                userName: 'Alex Chen',
                userInitial: 'A',
                content:
                    'So glad it helps others too! It\'s become my go-to grounding technique.',
                createdAt: DateTime.now().subtract(const Duration(hours: 4)),
                likesCount: 2,
                isLiked: false,
                replies: [],
              ),
            ],
          ),
        ];

      default:
        return [
          PostComment(
            id: 'comment_default_1',
            userId: 'user_2',
            userName: 'Alex Chen',
            userInitial: 'A',
            content:
                'Thanks for sharing this thoughtful post. Your vulnerability helps others feel less alone.',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            likesCount: 2,
            isLiked: false,
            replies: [],
          ),
        ];
    }
  }
}
