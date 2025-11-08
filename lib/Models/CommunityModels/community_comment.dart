class CommunityComment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String userInitial;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final int repliesCount;
  final bool isLiked;
  final String? parentCommentId;

  CommunityComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userInitial,
    required this.content,
    required this.createdAt,
    this.likesCount = 0,
    this.repliesCount = 0,
    this.isLiked = false,
    this.parentCommentId,
  });

  CommunityComment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? userInitial,
    String? content,
    DateTime? createdAt,
    int? likesCount,
    int? repliesCount,
    bool? isLiked,
    String? parentCommentId,
  }) {
    return CommunityComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userInitial: userInitial ?? this.userInitial,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      isLiked: isLiked ?? this.isLiked,
      parentCommentId: parentCommentId ?? this.parentCommentId,
    );
  }
}
