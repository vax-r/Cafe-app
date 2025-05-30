import 'dart:math';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class CafeDistance {
  final String cafeId;
  final double distanceMeters;
  final int walkingTimeMinutes;
  final String distanceText;
  final String walkingTimeText;

  CafeDistance({
    required this.cafeId,
    required this.distanceMeters,
    required this.walkingTimeMinutes,
    required this.distanceText,
    required this.walkingTimeText,
  });
}

enum SortMode {
  distance,
  rating,
  waitTime,
}

class DistanceService {
  static const double _walkingSpeedKmH = 5.0; // Average walking speed: 5 km/h
  static const double _walkingSpeedMs = _walkingSpeedKmH * 1000 / 60; // meters per minute

  /// Calculate distance between two points using Haversine formula
  static double calculateDistance(LatLng from, LatLng to) {
    const double earthRadius = 6371000; // Earth radius in meters
    
    final double lat1Rad = from.latitude * (pi / 180);
    final double lat2Rad = to.latitude * (pi / 180);
    final double deltaLatRad = (to.latitude - from.latitude) * (pi / 180);
    final double deltaLngRad = (to.longitude - from.longitude) * (pi / 180);

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Calculate walking time based on distance
  static int calculateWalkingTime(double distanceMeters) {
    // Add 20% extra time for realistic walking (traffic lights, turns, etc.)
    final double baseTimeMinutes = distanceMeters / _walkingSpeedMs;
    final double adjustedTime = baseTimeMinutes * 1.2;
    
    return max(1, adjustedTime.round()); // Minimum 1 minute
  }

  /// Format distance for display
  static String formatDistance(double distanceMeters) {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()}m';
    } else if (distanceMeters < 10000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)}km';
    } else {
      return '${(distanceMeters / 1000).round()}km';
    }
  }

  /// Format walking time for display
  static String formatWalkingTime(int minutes) {
    if (minutes < 60) {
      return '${minutes}min walk';
    } else {
      final int hours = minutes ~/ 60;
      final int remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h walk';
      } else {
        return '${hours}h ${remainingMinutes}min walk';
      }
    }
  }

  /// Create CafeDistance object with all calculations
  static CafeDistance calculateCafeDistance(String cafeId, LatLng userLocation, LatLng cafeLocation) {
    final double distance = calculateDistance(userLocation, cafeLocation);
    final int walkingTime = calculateWalkingTime(distance);
    
    return CafeDistance(
      cafeId: cafeId,
      distanceMeters: distance,
      walkingTimeMinutes: walkingTime,
      distanceText: formatDistance(distance),
      walkingTimeText: formatWalkingTime(walkingTime),
    );
  }

  /// Get distance category for visual indicators
  static DistanceCategory getDistanceCategory(double distanceMeters) {
    if (distanceMeters <= 200) {
      return DistanceCategory.veryClose;
    } else if (distanceMeters <= 500) {
      return DistanceCategory.close;
    } else if (distanceMeters <= 1000) {
      return DistanceCategory.walkable;
    } else if (distanceMeters <= 2000) {
      return DistanceCategory.nearish;
    } else {
      return DistanceCategory.far;
    }
  }

  /// Get color for distance category
  static Color getDistanceColor(DistanceCategory category) {
    switch (category) {
      case DistanceCategory.veryClose:
        return Colors.green.shade600;
      case DistanceCategory.close:
        return Colors.lightGreen.shade600;
      case DistanceCategory.walkable:
        return Colors.orange.shade600;
      case DistanceCategory.nearish:
        return Colors.deepOrange.shade600;
      case DistanceCategory.far:
        return Colors.red.shade600;
    }
  }

  /// Get icon for distance category
  static IconData getDistanceIcon(DistanceCategory category) {
    switch (category) {
      case DistanceCategory.veryClose:
        return Icons.directions_walk;
      case DistanceCategory.close:
        return Icons.directions_walk;
      case DistanceCategory.walkable:
        return Icons.directions_walk;
      case DistanceCategory.nearish:
        return Icons.directions_bike;
      case DistanceCategory.far:
        return Icons.directions_car;
    }
  }

  /// Sort mode descriptions
  static String getSortModeDescription(SortMode mode) {
    switch (mode) {
      case SortMode.distance:
        return 'Nearest First';
      case SortMode.rating:
        return 'Highest Rated';
      case SortMode.waitTime:
        return 'Shortest Wait';
    }
  }

  /// Sort mode icons
  static IconData getSortModeIcon(SortMode mode) {
    switch (mode) {
      case SortMode.distance:
        return Icons.near_me;
      case SortMode.rating:
        return Icons.star;
      case SortMode.waitTime:
        return Icons.access_time;
    }
  }
}

enum DistanceCategory {
  veryClose,  // 0-200m
  close,      // 200-500m
  walkable,   // 500m-1km
  nearish,    // 1-2km
  far,        // 2km+
}