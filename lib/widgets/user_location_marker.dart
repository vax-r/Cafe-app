import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../services/location_service.dart';

class UserLocationMarker {
  static List<Marker> buildUserMarker(UserLocation? userLocation) {
    if (userLocation == null) return [];

    return [
      // Accuracy circle (background)
      Marker(
        point: userLocation.position,
        child: Container(
          width: _calculateAccuracyRadius(userLocation.accuracy),
          height: _calculateAccuracyRadius(userLocation.accuracy),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
      ),
      // User position marker (foreground)
      Marker(
        point: userLocation.position,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.my_location,
            color: Colors.white,
            size: 12,
          ),
        ),
      ),
    ];
  }

  static double _calculateAccuracyRadius(double accuracy) {
    // Convert accuracy in meters to visual radius
    // This is an approximation for display purposes
    if (accuracy <= 5) return 30;
    if (accuracy <= 10) return 50;
    if (accuracy <= 20) return 70;
    if (accuracy <= 50) return 100;
    return 150;
  }

  static Widget buildLocationStatusIndicator(LocationStatus status, {VoidCallback? onTap}) {
    Color color;
    IconData icon;
    String tooltip;

    switch (status) {
      case LocationStatus.loading:
        color = Colors.orange;
        icon = Icons.location_searching;
        tooltip = 'Searching for location...';
        break;
      case LocationStatus.found:
        color = Colors.green;
        icon = Icons.location_on;
        tooltip = 'Location found';
        break;
      case LocationStatus.denied:
        color = Colors.red;
        icon = Icons.location_disabled;
        tooltip = 'Location permission denied';
        break;
      case LocationStatus.disabled:
        color = Colors.red;
        icon = Icons.location_off;
        tooltip = 'Location services disabled';
        break;
      case LocationStatus.error:
        color = Colors.red;
        icon = Icons.error_outline;
        tooltip = 'Location error';
        break;
      default:
        color = Colors.grey;
        icon = Icons.location_searching;
        tooltip = 'Unknown location status';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  static Widget buildLocationAccuracyInfo(UserLocation userLocation) {
    String accuracyText;
    Color accuracyColor;

    if (userLocation.accuracy <= 5) {
      accuracyText = 'High accuracy (${userLocation.accuracy.round()}m)';
      accuracyColor = Colors.green;
    } else if (userLocation.accuracy <= 20) {
      accuracyText = 'Good accuracy (${userLocation.accuracy.round()}m)';
      accuracyColor = Colors.orange;
    } else {
      accuracyText = 'Low accuracy (${userLocation.accuracy.round()}m)';
      accuracyColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accuracyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accuracyColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.gps_fixed,
            size: 16,
            color: accuracyColor,
          ),
          const SizedBox(width: 4),
          Text(
            accuracyText,
            style: TextStyle(
              fontSize: 12,
              color: accuracyColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}