import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorLocation;
  final double? doctorRating;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final PostType type;
  final List<String> likes;
  final int likesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  PostModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorLocation,
    this.doctorRating,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    required this.type,
    required this.likes,
    required this.likesCount,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return PostModel(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      doctorSpecialty: data['doctorSpecialty'] ?? '',
      doctorLocation: data['doctorLocation'] ?? '',
      doctorRating: data['doctorRating']?.toDouble(),
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      videoUrl: data['videoUrl'],
      type: PostType.values.firstWhere(
        (e) => e.toString() == 'PostType.${data['type']}',
        orElse: () => PostType.general,
      ),
      likes: List<String>.from(data['likes'] ?? []),
      likesCount: data['likesCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'doctorLocation': doctorLocation,
      'doctorRating': doctorRating,
      'content': content,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'type': type.toString().split('.').last,
      'likes': likes,
      'likesCount': likesCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  PostModel copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialty,
    String? doctorLocation,
    double? doctorRating,
    String? content,
    String? imageUrl,
    String? videoUrl,
    PostType? type,
    List<String>? likes,
    int? likesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return PostModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      doctorLocation: doctorLocation ?? this.doctorLocation,
      doctorRating: doctorRating ?? this.doctorRating,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      type: type ?? this.type,
      likes: likes ?? this.likes,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

enum PostType {
  general,        // منشور عام
  medical,        // معلومات طبية
  promotion,      // عروض وحسومات
  announcement,   // إعلانات
  educational,    // تعليمي
}

extension PostTypeExtension on PostType {
  String get displayName {
    switch (this) {
      case PostType.general:
        return 'عام';
      case PostType.medical:
        return 'طبي';
      case PostType.promotion:
        return 'عرض';
      case PostType.announcement:
        return 'إعلان';
      case PostType.educational:
        return 'تعليمي';
    }
  }

  String get icon {
    switch (this) {
      case PostType.general:
        return '📝';
      case PostType.medical:
        return '🏥';
      case PostType.promotion:
        return '🎯';
      case PostType.announcement:
        return '📢';
      case PostType.educational:
        return '📚';
    }
  }
}

