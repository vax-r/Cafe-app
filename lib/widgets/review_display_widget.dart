import 'package:flutter/material.dart';
import '../models/user_review.dart';
import '../services/review_service.dart';

class ReviewDisplayWidget extends StatelessWidget {
  final List<UserReview> reviews;
  final ReviewStats stats;
  final Function(UserReview) onEditReview;
  final VoidCallback onRefresh;

  const ReviewDisplayWidget({
    super.key,
    required this.reviews,
    required this.stats,
    required this.onEditReview,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewStats(),
        const SizedBox(height: 16),
        _buildReviewsList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Reviews Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your experience!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stats.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  _buildStarRating(stats.averageRating),
                  const SizedBox(height: 4),
                  Text(
                    '${stats.totalReviews} review${stats.totalReviews != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildRatingDistribution(),
              ),
            ],
          ),
          if (stats.topTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Popular Tags',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: stats.topTags.map((tag) => Chip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      ReviewTags.tagIcons[tag] ?? Icons.tag,
                      size: 14,
                      color: Colors.brown,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tag,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                backgroundColor: ReviewTags.getTagColor(tag),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingDistribution() {
    final maxCount = stats.ratingDistribution.isNotEmpty 
        ? stats.ratingDistribution.reduce((a, b) => a > b ? a : b)
        : 1;

    return Column(
      children: List.generate(5, (index) {
        final starCount = 5 - index;
        final count = stats.ratingDistribution.length > (starCount - 1) 
            ? stats.ratingDistribution[starCount - 1] 
            : 0;
        final percentage = maxCount > 0 ? count / maxCount : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text(
                '$starCount',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 12, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 20,
                child: Text(
                  '$count',
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReviewsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        ...reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildReviewCard(UserReview review) {
    final reviewService = ReviewService.instance;
    final isOwnReview = reviewService.isLoggedIn && 
        review.userName == reviewService.currentUserProfile?.displayName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info and rating
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.brown.shade100,
                child: Text(
                  review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: Colors.brown.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (review.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: Colors.blue.shade600,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _buildStarRating(review.rating),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.dateTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isOwnReview)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEditReview(review);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Comment
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          
          // Tags
          if (review.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: review.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ReviewTags.getTagColor(tag),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      ReviewTags.tagIcons[tag] ?? Icons.tag,
                      size: 12,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tag,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
          
          // Footer with helpful count
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => _markHelpful(review),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Helpful (${review.helpfulCount})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return Icon(
          starValue <= rating
              ? Icons.star
              : starValue - 0.5 <= rating
                  ? Icons.star_half
                  : Icons.star_border,
          color: Colors.orange,
          size: 16,
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _markHelpful(UserReview review) async {
    await ReviewService.instance.markReviewHelpful(review.id);
    onRefresh();
  }
}