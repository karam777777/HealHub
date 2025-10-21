import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String postId;
  final String userId;
  final String userName;
  final String commentText;
  final DateTime createdAt;

  CommentModel({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.commentText,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentId: map["commentId"] ?? "",
      postId: map["postId"] ?? "",
      userId: map["userId"] ?? "",
      userName: map["userName"] ?? "",
      commentText: map["commentText"] ?? "",
      createdAt: (map["createdAt"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "commentId": commentId,
      "postId": postId,
      "userId": userId,
      "userName": userName,
      "commentText": commentText,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  CommentModel copyWith({
    String? commentId,
    String? postId,
    String? userId,
    String? userName,
    String? commentText,
    DateTime? createdAt,
  }) {
    return CommentModel(
      commentId: commentId ?? this.commentId,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      commentText: commentText ?? this.commentText,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


