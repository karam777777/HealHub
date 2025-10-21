import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  RatingModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return RatingModel(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  RatingModel copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    String? patientName,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return RatingModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class DoctorRatingStats {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution; // 1-5 stars count
  final List<RatingModel> recentRatings;

  DoctorRatingStats({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
    required this.recentRatings,
  });

  factory DoctorRatingStats.empty() {
    return DoctorRatingStats(
      averageRating: 0.0,
      totalRatings: 0,
      ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      recentRatings: [],
    );
  }

  factory DoctorRatingStats.fromRatings(List<RatingModel> ratings) {
    if (ratings.isEmpty) {
      return DoctorRatingStats.empty();
    }

    double totalRating = 0;
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var rating in ratings) {
      totalRating += rating.rating;
      int starCount = rating.rating.round();
      distribution[starCount] = (distribution[starCount] ?? 0) + 1;
    }

    double averageRating = totalRating / ratings.length;

    // Get recent ratings (last 10)
    List<RatingModel> recentRatings = List.from(ratings);
    recentRatings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (recentRatings.length > 10) {
      recentRatings = recentRatings.take(10).toList();
    }

    return DoctorRatingStats(
      averageRating: averageRating,
      totalRatings: ratings.length,
      ratingDistribution: distribution,
      recentRatings: recentRatings,
    );
  }

  String get ratingText {
    if (totalRatings == 0) return 'لا توجد تقييمات';
    return '${averageRating.toStringAsFixed(1)} (${totalRatings} تقييم)';
  }

  String get ratingDescription {
    if (averageRating >= 4.5) return 'ممتاز';
    if (averageRating >= 4.0) return 'جيد جداً';
    if (averageRating >= 3.5) return 'جيد';
    if (averageRating >= 3.0) return 'مقبول';
    if (averageRating >= 2.0) return 'ضعيف';
    return 'ضعيف جداً';
  }
}

