import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cafe_info.dart';
import '../models/wait_time_info.dart';
import '../models/user_review.dart';
import '../services/wait_time_predictor.dart';
import '../services/distance_service.dart';
import '../services/review_service.dart';
import '../widgets/review_display_widget.dart';
import '../widgets/review_submission_widget.dart';

class CafeInfoCard extends StatefulWidget {
  final CafeInfo cafe;
  final VoidCallback onClose;

  const CafeInfoCard({
    super.key,
    required this.cafe,
    required this.onClose,
  });

  @override
  State<CafeInfoCard> createState() => _CafeInfoCardState();
}

class _CafeInfoCardState extends State<CafeInfoCard> {
  final ReviewService _reviewService = ReviewService.instance;
  List<UserReview> _userReviews = [];
  ReviewStats? _reviewStats;
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      final reviews = await _reviewService.getCafeReviews(widget.cafe.id);
      final stats = _reviewService.getCafeReviewStats(widget.cafe.id);
      
      setState(() {
        _userReviews = reviews;
        _reviewStats = stats;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current wait time prediction
    final waitInfo = WaitTimePredictor.predictWaitTime(
      cafeName: widget.cafe.name,
      currentTime: DateTime.now(),
    );

    return Card(
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: _buildHeader(),
            ),
            
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wait Time Prediction Section
                    _buildWaitTimeSection(waitInfo),

                    // Distance Information Section
                    if (widget.cafe.distance != null) ...[
                      const SizedBox(height: 12),
                      _buildDistanceSection(widget.cafe.distance!),
                    ],
                    
                    // Rating and reviews
                    if (widget.cafe.rating != null) ...[
                      const SizedBox(height: 12),
                      _buildRatingSection(),
                    ],

                    // Photos
                    if (widget.cafe.photos.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildPhotoSection(context),
                    ],

                    // Description
                    if (widget.cafe.description != null) ...[
                      const SizedBox(height: 12),
                      Text(widget.cafe.description!, style: const TextStyle(fontSize: 14)),
                    ],

                    // Address and contact info
                    const SizedBox(height: 12),
                    _buildContactInfo(),

                    // Amenities
                    if (widget.cafe.amenities.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildAmenities(),
                    ],

                    // User Reviews Section
                    const SizedBox(height: 20),
                    _buildUserReviewsSection(),

                    // Coordinates
                    const SizedBox(height: 8),
                    _buildCoordinates(),
                  ],
                ),
              ),
            ),
            
            // Review action button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: _buildReviewActionButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.cafe.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (widget.cafe.priceRange != null)
                Text(
                  widget.cafe.priceRange!,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: widget.onClose,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildWaitTimeSection(WaitTimeInfo waitInfo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: waitInfo.busyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: waitInfo.busyColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: waitInfo.busyColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Estimated Wait Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: waitInfo.busyColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${waitInfo.minRange}-${waitInfo.maxRange} minutes',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: waitInfo.busyColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  waitInfo.busyLevel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildWaitInfoItem(Icons.people, 'Queue: ${waitInfo.currentQueue} people'),
              const SizedBox(width: 16),
              _buildWaitInfoItem(Icons.person, 'Staff: ${waitInfo.staffCount}'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Based on current time, queue length, and historical patterns',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildDistanceSection(CafeDistance distance) {
    final category = DistanceService.getDistanceCategory(distance.distanceMeters);
    final color = DistanceService.getDistanceColor(category);
    final icon = DistanceService.getDistanceIcon(category);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.near_me, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                'Distance & Travel Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                distance.distanceText,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      distance.walkingTimeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Walking time estimated at 5 km/h average speed',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Row(
      children: [
        _buildStarRating(widget.cafe.rating!),
        const SizedBox(width: 8),
        Text(
          '${widget.cafe.rating!.toStringAsFixed(1)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (widget.cafe.reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '(${widget.cafe.reviewCount} reviews)',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        double starValue = index + 1;
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

  Widget _buildPhotoSection(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.cafe.photos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => _showPhotoDialog(context, widget.cafe.photos[index]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: widget.cafe.photos[index],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      children: [
        _buildInfoRow(Icons.location_on, widget.cafe.address),
        if (widget.cafe.phone != null)
          _buildInfoRow(Icons.phone, widget.cafe.phone!, 
            isClickable: true, onTap: () => _launchPhone(widget.cafe.phone!)),
        if (widget.cafe.website != null)
          _buildInfoRow(Icons.web, widget.cafe.website!, 
            isClickable: true, onTap: () => _launchWebsite(widget.cafe.website!)),
        if (widget.cafe.openingHours != null)
          _buildInfoRow(Icons.access_time, widget.cafe.openingHours!),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isClickable = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 16, color: isClickable ? Colors.blue : Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isClickable ? Colors.blue : Colors.grey,
                  decoration: isClickable ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenities() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: widget.cafe.amenities.map((amenity) {
        return Chip(
          label: Text(amenity, style: const TextStyle(fontSize: 12)),
          backgroundColor: Colors.brown.shade100,
        );
      }).toList(),
    );
  }

  Widget _buildUserReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Community Reviews',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (_reviewService.isLoggedIn)
              TextButton.icon(
                onPressed: _showReviewSubmission,
                icon: const Icon(Icons.add, size: 16),
                label: Text(_hasUserReview ? 'Edit Review' : 'Write Review'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.brown,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (_isLoadingReviews)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_reviewStats != null)
          ReviewDisplayWidget(
            reviews: _userReviews,
            stats: _reviewStats!,
            onEditReview: _editReview,
            onRefresh: _loadReviews,
          ),
      ],
    );
  }

  Widget _buildReviewActionButton() {
    if (!_reviewService.isLoggedIn) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _showLoginPrompt,
          icon: const Icon(Icons.login),
          label: const Text('Login to Write Review'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showReviewSubmission,
        icon: Icon(_hasUserReview ? Icons.edit : Icons.add),
        label: Text(_hasUserReview ? 'Edit Your Review' : 'Write a Review'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  bool get _hasUserReview {
    return _reviewService.hasUserReviewedCafe(widget.cafe.id);
  }

  void _showReviewSubmission() {
    final existingReview = _reviewService.getUserReviewForCafe(widget.cafe.id);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReviewSubmissionWidget(
          cafeId: widget.cafe.id,
          cafeName: widget.cafe.name,
          existingReview: existingReview,
          onReviewSubmitted: _loadReviews,
        ),
      ),
    );
  }

  void _editReview(UserReview review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReviewSubmissionWidget(
          cafeId: widget.cafe.id,
          cafeName: widget.cafe.name,
          existingReview: review,
          onReviewSubmitted: _loadReviews,
        ),
      ),
    );
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to write reviews and share your experience with the community.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showQuickLogin();
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showQuickLogin() {
    final userNameController = TextEditingController();
    final displayNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter a username to get started. No password required for this demo!',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: userNameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Choose a username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name (Optional)',
                hintText: 'How others will see you',
                border: OutlineInputBorder(),
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
                  setState(() {}); // Refresh UI
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

  Widget _buildCoordinates() {
    return Text(
      'Coordinates: ${widget.cafe.location.latitude.toStringAsFixed(4)}, ${widget.cafe.location.longitude.toStringAsFixed(4)}',
      style: const TextStyle(fontSize: 10, color: Colors.grey),
    );
  }

  void _showPhotoDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  void _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _launchWebsite(String website) async {
    final uri = Uri.parse(website);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}