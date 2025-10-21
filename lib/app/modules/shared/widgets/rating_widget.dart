import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:untitled/app/data/models/rating_model.dart';
import '../controllers/rating_controller.dart';

class RatingWidget extends GetView<RatingController> {
  final String doctorId;
  final String doctorName;
  final bool showAddRating;

  const RatingWidget({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    this.showAddRating = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Load ratings when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadDoctorRatings(doctorId);
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                ),
              );
            }

            final stats = controller.doctorStats.value;
            if (stats == null || stats.totalRatings == 0) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                _buildRatingStats(stats),
                const SizedBox(height: 20),
                _buildRatingsList(stats.recentRatings),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.star,
            color: Color(0xFF667eea),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'التقييمات والآراء',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        if (showAddRating && controller.isPatient)
          ElevatedButton.icon(
            onPressed: () => controller.showRatingDialog(doctorId, doctorName),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('إضافة تقييم'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_outline,
              size: 32,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد تقييمات بعد',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'كن أول من يقيم هذا الطبيب',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          if (showAddRating && controller.isPatient) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.showRatingDialog(doctorId, doctorName),
              icon: const Icon(Icons.star, size: 16),
              label: const Text('إضافة تقييم'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingStats(DoctorRatingStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Average rating
          Column(
            children: [
              Text(
                stats.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < stats.averageRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.white,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                stats.ratingDescription,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 24),
          
          // Rating distribution
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.totalRatings} تقييم',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(5, (index) {
                  final starCount = 5 - index;
                  final count = stats.ratingDistribution[starCount] ?? 0;
                  final percentage = stats.totalRatings > 0 
                      ? (count / stats.totalRatings) * 100 
                      : 0.0;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          '$starCount',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentage / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsList(List<RatingModel> ratings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'آخر التقييمات',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        ...ratings.map((rating) => _buildRatingItem(rating)).toList(),
      ],
    );
  }

  Widget _buildRatingItem(RatingModel rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Patient avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF667eea),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Patient info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.patientName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      timeago.format(rating.createdAt, locale: 'ar'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Rating stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.rating.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          
          if (rating.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              rating.comment,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

