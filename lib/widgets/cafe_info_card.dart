import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cafe_info.dart';
import '../models/wait_time_info.dart';
import '../services/wait_time_predictor.dart';

class CafeInfoCard extends StatelessWidget {
  final CafeInfo cafe;
  final VoidCallback onClose;

  const CafeInfoCard({
    super.key,
    required this.cafe,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Get current wait time prediction
    final waitInfo = WaitTimePredictor.predictWaitTime(
      cafeName: cafe.name,
      currentTime: DateTime.now(),
    );

    return Card(
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 450),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildWaitTimeSection(waitInfo),
                if (cafe.rating != null) ...[
                  const SizedBox(height: 12),
                  _buildRatingSection(),
                ],
                if (cafe.photos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildPhotoSection(context),
                ],
                if (cafe.description != null) ...[
                  const SizedBox(height: 12),
                  Text(cafe.description!, style: const TextStyle(fontSize: 14)),
                ],
                const SizedBox(height: 12),
                _buildContactInfo(),
                if (cafe.amenities.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildAmenities(),
                ],
                if (cafe.reviews.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildReviewsSection(),
                ],
                const SizedBox(height: 8),
                _buildCoordinates(),
              ],
            ),
          ),
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
                cafe.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (cafe.priceRange != null)
                Text(
                  cafe.priceRange!,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: onClose,
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

  Widget _buildRatingSection() {
    return Row(
      children: [
        _buildStarRating(cafe.rating!),
        const SizedBox(width: 8),
        Text(
          '${cafe.rating!.toStringAsFixed(1)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        if (cafe.reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '(${cafe.reviewCount} reviews)',
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
        itemCount: cafe.photos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => _showPhotoDialog(context, cafe.photos[index]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: cafe.photos[index],
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
        _buildInfoRow(Icons.location_on, cafe.address),
        if (cafe.phone != null)
          _buildInfoRow(Icons.phone, cafe.phone!, 
            isClickable: true, onTap: () => _launchPhone(cafe.phone!)),
        if (cafe.website != null)
          _buildInfoRow(Icons.web, cafe.website!, 
            isClickable: true, onTap: () => _launchWebsite(cafe.website!)),
        if (cafe.openingHours != null)
          _buildInfoRow(Icons.access_time, cafe.openingHours!),
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
      children: cafe.amenities.map((amenity) {
        return Chip(
          label: Text(amenity, style: const TextStyle(fontSize: 12)),
          backgroundColor: Colors.brown.shade100,
        );
      }).toList(),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Reviews',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...cafe.reviews.take(2).map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildReviewCard(CafeReview review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(review.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                _buildStarRating(review.rating),
              ],
            ),
            const SizedBox(height: 4),
            Text(review.comment, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              _formatDate(review.date),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinates() {
    return Text(
      'Coordinates: ${cafe.location.latitude.toStringAsFixed(4)}, ${cafe.location.longitude.toStringAsFixed(4)}',
      style: const TextStyle(fontSize: 10, color: Colors.grey),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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