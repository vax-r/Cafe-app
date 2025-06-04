import 'package:flutter/material.dart';
import '../models/user_review.dart';
import '../services/review_service.dart';

class ReviewSubmissionWidget extends StatefulWidget {
  final String cafeId;
  final String cafeName;
  final VoidCallback onReviewSubmitted;
  final UserReview? existingReview;

  const ReviewSubmissionWidget({
    super.key,
    required this.cafeId,
    required this.cafeName,
    required this.onReviewSubmitted,
    this.existingReview,
  });

  @override
  State<ReviewSubmissionWidget> createState() => _ReviewSubmissionWidgetState();
}

class _ReviewSubmissionWidgetState extends State<ReviewSubmissionWidget> {
  final ReviewService _reviewService = ReviewService.instance;
  final TextEditingController _commentController = TextEditingController();
  
  double _rating = 5.0;
  List<String> _selectedTags = [];
  bool _isSubmitting = false;
  bool _allowAnonymous = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _commentController.text = widget.existingReview!.comment;
      _selectedTags = List.from(widget.existingReview!.tags);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReview != null;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? 'Edit Review' : 'Write a Review',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Cafe name
          Text(
            widget.cafeName,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Rating section
          Text(
            'Your Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          _buildRatingSection(),
          
          const SizedBox(height: 20),
          
          // Comment section
          Text(
            'Your Review',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          _buildCommentSection(),
          
          const SizedBox(height: 20),
          
          // Tags section
          Text(
            'Tags (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          _buildTagsSection(),
          
          const SizedBox(height: 20),
          
          // Options
          _buildOptionsSection(),
          
          const SizedBox(height: 20),
          
          // Submit button
          _buildSubmitButton(isEditing),
          
          // Delete button for editing
          if (isEditing) ...[
            const SizedBox(height: 10),
            _buildDeleteButton(),
          ],
          
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = (index + 1).toDouble();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 32,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _getRatingText(_rating),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _commentController,
        maxLines: 4,
        maxLength: 500,
        decoration: InputDecoration(
          hintText: 'Share your experience at ${widget.cafeName}...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          counterStyle: TextStyle(color: Colors.grey.shade500),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ReviewTags.availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    ReviewTags.tagIcons[tag] ?? Icons.tag,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(tag),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              backgroundColor: ReviewTags.getTagColor(tag),
              selectedColor: Colors.brown,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Row(
      children: [
        Checkbox(
          value: _allowAnonymous,
          onChanged: (value) {
            setState(() {
              _allowAnonymous = value ?? false;
            });
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Post anonymously',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isEditing) {
    final isValid = _rating > 0 && _commentController.text.trim().isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid && !_isSubmitting ? _submitReview : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                isEditing ? 'Update Review' : 'Submit Review',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isSubmitting ? null : _deleteReview,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Delete Review',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    switch (rating.round()) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Rate this cafe';
    }
  }

  Future<void> _submitReview() async {
    if (!_reviewService.isLoggedIn) {
      _showLoginDialog();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      bool success;
      
      if (widget.existingReview != null) {
        // Update existing review
        success = await _reviewService.updateReview(
          widget.existingReview!.id,
          _commentController.text,
          _rating,
          _selectedTags,
        );
      } else {
        // Submit new review
        final submission = ReviewSubmission(
          cafeId: widget.cafeId,
          cafeName: widget.cafeName,
          rating: _rating,
          comment: _commentController.text,
          selectedTags: _selectedTags,
          allowAnonymous: _allowAnonymous,
        );
        success = await _reviewService.submitReview(submission);
      }

      if (success && mounted) {
        widget.onReviewSubmitted();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingReview != null 
                  ? 'Review updated successfully!' 
                  : 'Review submitted successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit review. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _deleteReview() async {
    if (widget.existingReview == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await _reviewService.deleteReview(widget.existingReview!.id);
      
      if (success && mounted) {
        widget.onReviewSubmitted();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete review. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please log in to submit a review.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showUserLoginDialog();
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showUserLoginDialog() {
    final userNameController = TextEditingController();
    final displayNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userNameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Enter a username',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name (Optional)',
                hintText: 'How others will see you',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final username = userNameController.text.trim();
              if (username.isNotEmpty) {
                final success = await _reviewService.loginUser(
                  username,
                  displayNameController.text.trim(),
                );
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Welcome, ${_reviewService.currentUserProfile?.displayName}!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}