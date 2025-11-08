// models/CommunityModels/community_post.dart
// REMOVE this line:
// import 'package:Grounded/services/mock_community_data.dart';

// Add the PostComment model definition directly in this file or import it from its own file
class PostComment {
  final String id;
  final String userId;
  final String userName;
  final String userInitial;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;
  final List<PostComment> replies;

  PostComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userInitial,
    required this.content,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
    this.replies = const [],
  });

  PostComment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userInitial,
    String? content,
    DateTime? createdAt,
    int? likesCount,
    bool? isLiked,
    List<PostComment>? replies,
  }) {
    return PostComment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userInitial: userInitial ?? this.userInitial,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      replies: replies ?? this.replies,
    );
  }
}
