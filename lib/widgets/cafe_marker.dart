import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/cafe_info.dart';
import '../services/wait_time_predictor.dart';
import '../services/distance_service.dart';

class CafeMarkerBuilder {
  static List<Marker> buildMarkers(
    List<CafeInfo> cafes,
    Function(CafeInfo) onMarkerTap,
  ) {
    return cafes.map((cafe) {
      // Get current wait time prediction
      final waitInfo = WaitTimePredictor.predictWaitTime(
        cafeName: cafe.name,
        currentTime: DateTime.now(),
      );

      return Marker(
        point: cafe.location,
        child: GestureDetector(
          onTap: () => onMarkerTap(cafe),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _getRatingColor(cafe.rating),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.coffee,
                  color: Colors.white,
                  size: 18,
                ),
                if (cafe.rating != null)
                  Text(
                    cafe.rating!.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                // Distance indicator (if available)
                if (cafe.distance != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: DistanceService.getDistanceColor(
                        DistanceService.getDistanceCategory(cafe.distance!.distanceMeters),
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      cafe.distance!.distanceText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                // Wait time indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: waitInfo.busyColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${waitInfo.estimatedMinutes}m',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  static Color _getRatingColor(double? rating) {
    if (rating == null) return Colors.brown;
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.5) return Colors.orange;
    if (rating >= 3.0) return Colors.deepOrange;
    return Colors.red;
  }
}