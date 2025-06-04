import 'dart:convert';
import 'dart:math';
import '../models/user_review.dart';

class ReviewService {
  static ReviewService? _instance;
  static ReviewService get instance => _instance ??= ReviewService._();
  ReviewService._();

  // In-memory storage for demo purposes
  // In a real app, this would connect to a backend database
  final Map<String, List<UserReview>> _cafeReviews = {};
  final Map<String, UserProfile> _userProfiles = {};
  String? _currentUser;

  // Current user management
  String? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  UserProfile? get currentUserProfile => 
      _currentUser != null ? _userProfiles[_currentUser] : null;

  Future<bool> loginUser(String userName, String displayName) async {
    // Simulate login process
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (userName.trim().isEmpty) return false;
    
    _currentUser = userName.toLowerCase().replaceAll(' ', '_');
    
    // Create profile if doesn't exist
    if (!_userProfiles.containsKey(_currentUser)) {
      _userProfiles[_currentUser!] = UserProfile(
        userName: _currentUser!,
        displayName: displayName.trim().isEmpty ? userName : displayName,
        joinDate: DateTime.now(),
      );
    }
    
    return true;
  }

  void logoutUser() {
    _currentUser = null;
  }

  // Review management
  Future<List<UserReview>> getCafeReviews(String cafeId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _cafeReviews[cafeId] ?? [];
  }

  Future<bool> submitReview(ReviewSubmission submission) async {
    if (!isLoggedIn) return false;
    if (!submission.isValid) return false;

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final review = UserReview(
      id: _generateReviewId(),
      cafeId: submission.cafeId,
      userName: currentUserProfile!.displayName,
      rating: submission.rating,
      comment: submission.comment.trim(),
      dateTime: DateTime.now(),
      tags: submission.selectedTags,
      isVerified: currentUserProfile!.isVerified,
    );

    // Add to cafe reviews
    if (!_cafeReviews.containsKey(submission.cafeId)) {
      _cafeReviews[submission.cafeId] = [];
    }
    _cafeReviews[submission.cafeId]!.add(review);

    // Update user profile
    _updateUserProfile(review);

    return true;
  }

  Future<bool> updateReview(String reviewId, String newComment, double newRating, List<String> newTags) async {
    if (!isLoggedIn) return false;

    await Future.delayed(const Duration(milliseconds: 500));

    for (var cafeReviews in _cafeReviews.values) {
      final reviewIndex = cafeReviews.indexWhere((r) => r.id == reviewId);
      if (reviewIndex != -1) {
        final oldReview = cafeReviews[reviewIndex];
        
        // Check if user owns this review
        if (oldReview.userName != currentUserProfile!.displayName) {
          return false;
        }

        cafeReviews[reviewIndex] = oldReview.copyWith(
          comment: newComment.trim(),
          rating: newRating,
          tags: newTags,
          dateTime: DateTime.now(), // Update timestamp
        );
        return true;
      }
    }
    return false;
  }

  Future<bool> deleteReview(String reviewId) async {
    if (!isLoggedIn) return false;

    await Future.delayed(const Duration(milliseconds: 300));

    for (var cafeReviews in _cafeReviews.values) {
      final reviewIndex = cafeReviews.indexWhere((r) => r.id == reviewId);
      if (reviewIndex != -1) {
        final review = cafeReviews[reviewIndex];
        
        // Check if user owns this review
        if (review.userName != currentUserProfile!.displayName) {
          return false;
        }

        cafeReviews.removeAt(reviewIndex);
        return true;
      }
    }
    return false;
  }

  Future<bool> markReviewHelpful(String reviewId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    for (var cafeReviews in _cafeReviews.values) {
      final reviewIndex = cafeReviews.indexWhere((r) => r.id == reviewId);
      if (reviewIndex != -1) {
        final oldReview = cafeReviews[reviewIndex];
        cafeReviews[reviewIndex] = oldReview.copyWith(
          helpfulCount: oldReview.helpfulCount + 1,
        );
        return true;
      }
    }
    return false;
  }

  // Review statistics
  ReviewStats getCafeReviewStats(String cafeId) {
    final reviews = _cafeReviews[cafeId] ?? [];
    
    if (reviews.isEmpty) {
      return ReviewStats(
        totalReviews: 0,
        averageRating: 0.0,
        ratingDistribution: [0, 0, 0, 0, 0],
        topTags: [],
      );
    }

    final totalRating = reviews.fold<double>(0, (sum, r) => sum + r.rating);
    final averageRating = totalRating / reviews.length;

    final ratingDistribution = List<int>.filled(5, 0);
    for (var review in reviews) {
      ratingDistribution[review.rating.round() - 1]++;
    }

    final tagCounts = <String, int>{};
    for (var review in reviews) {
      for (var tag in review.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final topTags = tagCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

    return ReviewStats(
      totalReviews: reviews.length,
      averageRating: averageRating,
      ratingDistribution: ratingDistribution,
      topTags: topTags.take(5).map((e) => e.key).toList(),
    );
  }

  UserReview? getUserReviewForCafe(String cafeId) {
    if (!isLoggedIn) return null;
    
    final reviews = _cafeReviews[cafeId] ?? [];
    return reviews.where((r) => r.userName == currentUserProfile!.displayName).firstOrNull;
  }

  bool hasUserReviewedCafe(String cafeId) {
    return getUserReviewForCafe(cafeId) != null;
  }

  List<UserReview> getUserReviews() {
    if (!isLoggedIn) return [];
    
    final userReviews = <UserReview>[];
    for (var cafeReviews in _cafeReviews.values) {
      userReviews.addAll(
        cafeReviews.where((r) => r.userName == currentUserProfile!.displayName),
      );
    }
    
    userReviews.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return userReviews;
  }

  // Helper methods
  String _generateReviewId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    return '${timestamp}_$random';
  }

  void _updateUserProfile(UserReview review) {
    if (_currentUser == null) return;
    
    final userReviews = getUserReviews();
    final totalReviews = userReviews.length;
    final averageRating = userReviews.isEmpty ? 0.0 : 
        userReviews.fold<double>(0, (sum, r) => sum + r.rating) / totalReviews;

    final badges = <String>[];
    if (totalReviews >= 5) badges.add('Regular Reviewer');
    if (totalReviews >= 20) badges.add('Coffee Expert');
    if (averageRating >= 4.0) badges.add('Positive Reviewer');

    _userProfiles[_currentUser!] = _userProfiles[_currentUser!]!.copyWith(
      totalReviews: totalReviews,
      averageRating: averageRating,
      badges: badges,
    );
  }

  // Demo data generation
  void generateSampleReviews() {
    final sampleUsers = [
      'coffee_lover', 'jane_doe', 'taipei_foodie', 'study_buddy', 'cafe_hopper'
    ];
    
    final sampleComments = [
      'Amazing coffee and great atmosphere!',
      'Perfect place for studying with excellent WiFi.',
      'Love the cozy interior and friendly staff.',
      'Great value for money, will definitely come back.',
      'The latte art here is incredible!',
      'Bit crowded during lunch hours but worth the wait.',
      'Clean space with comfortable seating.',
      'Their pastries are delicious, especially the croissants.',
    ];

    // Create sample user profiles
    for (var user in sampleUsers) {
      _userProfiles[user] = UserProfile(
        userName: user,
        displayName: user.replaceAll('_', ' ').split(' ').map((w) => 
            w[0].toUpperCase() + w.substring(1)).join(' '),
        joinDate: DateTime.now().subtract(Duration(days: Random().nextInt(365))),
        isVerified: Random().nextBool(),
      );
    }
  }
}

class ReviewStats {
  final int totalReviews;
  final double averageRating;
  final List<int> ratingDistribution; // [1-star count, 2-star count, ...]
  final List<String> topTags;

  ReviewStats({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
    required this.topTags,
  });
}

extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}