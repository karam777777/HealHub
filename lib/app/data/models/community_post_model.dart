import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/app/data/models/post_type.dart';

class CommunityPostModel {
  final String postId;
  final String doctorUid;
  final String doctorName;
  final String? doctorSpecialty;
  final String? doctorLocation;
  final double doctorAverageRating;
  final int doctorTotalRatings;
  final PostType postType; // Use PostType enum
  final String? mediaUrl; // Can be null if postType is 'text'
  final String content; // For text posts or captions for media posts
  final List<String> likes;
  final int commentsCount;
  final DateTime createdAt;

  CommunityPostModel({
    required this.postId,
    required this.doctorUid,
    required this.doctorName,
    this.doctorSpecialty,
    this.doctorLocation,
    this.doctorAverageRating = 0.0,
    this.doctorTotalRatings = 0,
    required this.postType,
    this.mediaUrl,
    required this.content,
    this.likes = const [],
    this.commentsCount = 0,
    required this.createdAt,
  });

  factory CommunityPostModel.fromMap(Map<String, dynamic> map) {
    return CommunityPostModel(
      postId: map['postId'] ?? '',
      doctorUid: map['doctorUid'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorSpecialty: map['doctorSpecialty'],
      doctorLocation: map['doctorLocation'],
      doctorAverageRating: (map['doctorAverageRating'] ?? 0.0).toDouble(),
      doctorTotalRatings: (map['doctorTotalRatings'] ?? 0).toInt(),
      postType: PostType.values.firstWhere(
        (e) => e.toString() == 'PostType.' + (map['postType'] ?? 'text'),
        orElse: () => PostType.text,
      ),
      mediaUrl: map['mediaUrl'],
      content: map['content'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      commentsCount: (map['commentsCount'] ?? 0).toInt(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'doctorUid': doctorUid,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'doctorLocation': doctorLocation,
      'doctorAverageRating': doctorAverageRating,
      'doctorTotalRatings': doctorTotalRatings,
      'postType': postType.name, // Store enum name as string
      'mediaUrl': mediaUrl,
      'content': content,
      'likes': likes,
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CommunityPostModel copyWith({
    String? postId,
    String? doctorUid,
    String? doctorName,
    String? doctorSpecialty,
    String? doctorLocation,
    double? doctorAverageRating,
    int? doctorTotalRatings,
    PostType? postType,
    String? mediaUrl,
    String? content,
    List<String>? likes,
    int? commentsCount,
    DateTime? createdAt,
  }) {
    return CommunityPostModel(
      postId: postId ?? this.postId,
      doctorUid: doctorUid ?? this.doctorUid,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      doctorLocation: doctorLocation ?? this.doctorLocation,
      doctorAverageRating: doctorAverageRating ?? this.doctorAverageRating,
      doctorTotalRatings: doctorTotalRatings ?? this.doctorTotalRatings,
      postType: postType ?? this.postType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


