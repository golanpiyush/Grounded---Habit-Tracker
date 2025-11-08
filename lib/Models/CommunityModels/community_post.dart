import 'package:Grounded/models/CommunityModels/postcomments.dart';

class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String userInitial;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final int savesCount;
  final bool isLiked;
  final bool isSaved;
  final List<String> tags;
  final List<PostComment> comments; // Add this field

  CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userInitial,
    required this.content,
    this.imageUrls = const [],
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.savesCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.tags = const [],
    this.comments = const [], // Initialize with empty list
  });

  CommunityPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userInitial,
    String? content,
    List<String>? imageUrls,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    int? savesCount,
    bool? isLiked,
    bool? isSaved,
    List<String>? tags,
    List<PostComment>? comments, // Add comments to copyWith
  }) {
    return CommunityPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userInitial: userInitial ?? this.userInitial,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      savesCount: savesCount ?? this.savesCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      tags: tags ?? this.tags,
      comments: comments ?? this.comments, // Include comments
    );
  }
}
