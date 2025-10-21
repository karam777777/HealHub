import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community_post_model.dart';
import '../models/comment_model.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new community post
  Future<void> addCommunityPost(CommunityPostModel post) async {
    final docRef = _firestore.collection('community_posts').doc();
    final newPost = post.copyWith(postId: docRef.id);
    await docRef.set(newPost.toMap());
  }

  // Get community posts for followed doctors only (for patients)
  Stream<List<CommunityPostModel>> getFollowedDoctorsPosts(List<String> followedDoctorUids) {
    if (followedDoctorUids.isEmpty) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('community_posts')
        .where('doctorUid', whereIn: followedDoctorUids)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommunityPostModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Get all community posts (for patients)
  Stream<List<CommunityPostModel>> getAllCommunityPosts() {
    return _firestore.collection('community_posts').orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => CommunityPostModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Get community posts by doctor UID (for doctors)
  Stream<List<CommunityPostModel>> getDoctorCommunityPosts(String doctorUid) {
    return _firestore
        .collection('community_posts')
        .where('doctorUid', isEqualTo: doctorUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommunityPostModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Add a like to a post
  Future<void> addLike(String postId, String userId) async {
    await _firestore.collection("community_posts").doc(postId).update({
      "likes": FieldValue.arrayUnion([userId]),
    });
  }

  // Remove a like from a post
  Future<void> removeLike(String postId, String userId) async {
    await _firestore.collection("community_posts").doc(postId).update({
      "likes": FieldValue.arrayRemove([userId]),
    });
  }

  // Add a comment to a post
  Future<void> addComment(CommentModel comment) async {
    final docRef = _firestore.collection('community_posts').doc(comment.postId).collection('comments').doc();
    final newComment = comment.copyWith(commentId: docRef.id);
    await docRef.set(newComment.toMap());
    // Increment commentsCount in the post document
    await _firestore.collection('community_posts').doc(comment.postId).update({
      'commentsCount': FieldValue.increment(1),
    });
  }

  // Get comments for a post
  Stream<List<CommentModel>> getCommentsForPost(String postId) {
    return _firestore
        .collection('community_posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Delete a community post
  Future<void> deleteCommunityPost(String postId) async {
    await _firestore.collection('community_posts').doc(postId).delete();
  }
}


