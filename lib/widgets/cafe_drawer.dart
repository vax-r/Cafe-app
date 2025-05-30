import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cafe_info.dart';
import '../services/wait_time_predictor.dart';

class CafeDrawer extends StatelessWidget {
  final List<CafeInfo> cafes;
  final Function(CafeInfo) onCafeSelected;

  const CafeDrawer({
    super.key,
    required this.cafes,
    required this.onCafeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.brown,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.coffee, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Taiwan Cafes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                Text(
                  'Tap a cafe to view details',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: cafes.isEmpty
                ? const Center(
                    child: Text('No cafes found.\nTry searching in a different area.'),
                  )
                : ListView.builder(
                    itemCount: cafes.length,
                    itemBuilder: (context, index) {
                      final cafe = cafes[index];
                      final waitInfo = WaitTimePredictor.predictWaitTime(
                        cafeName: cafe.name,
                        currentTime: DateTime.now(),
                      );
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRatingColor(cafe.rating),
                          child: const Icon(Icons.coffee, color: Colors.white),
                        ),
                        title: Text(cafe.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cafe.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                if (cafe.rating != null) ...[
                                  _buildStarRating(cafe.rating!),
                                  const SizedBox(width: 4),
                                  Text('${cafe.rating!.toStringAsFixed(1)} • '),
                                ],
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: waitInfo.busyColor,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${waitInfo.estimatedMinutes}min wait',
                                  style: TextStyle(
                                    color: waitInfo.busyColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: cafe.photos.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: CachedNetworkImage(
                                  imageUrl: cafe.photos.first,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.image, size: 20),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.broken_image, size: 20),
                                  ),
                                ),
                              )
                            : null,
                        onTap: () {
                          onCafeSelected(cafe);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double? rating) {
    if (rating == null) return Colors.brown;
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.5) return Colors.orange;
    if (rating >= 3.0) return Colors.deepOrange;
    return Colors.red;
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
}