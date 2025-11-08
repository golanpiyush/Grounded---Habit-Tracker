// enum NotificationType { like, comment, reply, save, mention }

// class CommunityNotification {
//   final String id;
//   final String userId;
//   final String actorId;
//   final String actorName;
//   final String actorInitial;
//   final NotificationType type;
//   final String postId;
//   final String? commentId;
//   final String message;
//   final DateTime createdAt;
//   final bool isRead;

//   CommunityNotification({
//     required this.id,
//     required this.userId,
//     required this.actorId,
//     required this.actorName,
//     required this.actorInitial,
//     required this.type,
//     required this.postId,
//     this.commentId,
//     required this.message,
//     required this.createdAt,
//     this.isRead = false,
//   });

//   CommunityNotification copyWith({
//     String? id,
//     String? userId,
//     String? actorId,
//     String? actorName,
//     String? actorInitial,
//     NotificationType? type,
//     String? postId,
//     String? commentId,
//     String? message,
//     DateTime? createdAt,
//     bool? isRead,
//   }) {
//     return CommunityNotification(
//       id: id ?? this.id,
//       userId: userId ?? this.userId,
//       actorId: actorId ?? this.actorId,
//       actorName: actorName ?? this.actorName,
//       actorInitial: actorInitial ?? this.actorInitial,
//       type: type ?? this.type,
//       postId: postId ?? this.postId,
//       commentId: commentId ?? this.commentId,
//       message: message ?? this.message,
//       createdAt: createdAt ?? this.createdAt,
//       isRead: isRead ?? this.isRead,
//     );
//   }
// }
