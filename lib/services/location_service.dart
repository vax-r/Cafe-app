import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocationStatus {
  unknown,
  loading,
  found,
  denied,
  disabled,
  error,
}

class UserLocation {
  final LatLng position;
  final double accuracy;
  final DateTime timestamp;

  UserLocation({
    required this.position,
    required this.accuracy,
    required this.timestamp,
  });
}

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  UserLocation? _lastKnownLocation;
  LocationStatus _status = LocationStatus.unknown;

  UserLocation? get lastKnownLocation => _lastKnownLocation;
  LocationStatus get status => _status;

  /// Check if location services are enabled and permissions are granted
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _status = LocationStatus.disabled;
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _status = LocationStatus.denied;
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _status = LocationStatus.denied;
      return false;
    }

    return true;
  }

  /// Get the current location of the user
  Future<UserLocation?> getCurrentLocation() async {
    try {
      _status = LocationStatus.loading;

      // Check permissions first
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      final userLocation = UserLocation(
        position: LatLng(position.latitude, position.longitude),
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
      );

      _lastKnownLocation = userLocation;
      _status = LocationStatus.found;
      
      return userLocation;
    } catch (e) {
      _status = LocationStatus.error;
      return null;
    }
  }

  /// Get cached location if available and recent (within 5 minutes)
  UserLocation? getCachedLocation() {
    if (_lastKnownLocation == null) return null;
    
    final now = DateTime.now();
    final age = now.difference(_lastKnownLocation!.timestamp);
    
    // Return cached location if it's less than 5 minutes old
    if (age.inMinutes < 5) {
      return _lastKnownLocation;
    }
    
    return null;
  }

  /// Start listening to location changes (for real-time tracking)
  Stream<UserLocation> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).map((position) {
      final userLocation = UserLocation(
        position: LatLng(position.latitude, position.longitude),
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
      );
      
      _lastKnownLocation = userLocation;
      _status = LocationStatus.found;
      
      return userLocation;
    });
  }

  /// Calculate distance between two points in meters
  double calculateDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// Get location status message for UI
  String getStatusMessage() {
    switch (_status) {
      case LocationStatus.unknown:
        return 'Location status unknown';
      case LocationStatus.loading:
        return 'Getting your location...';
      case LocationStatus.found:
        return 'Location found';
      case LocationStatus.denied:
        return 'Location permission denied';
      case LocationStatus.disabled:
        return 'Location services disabled';
      case LocationStatus.error:
        return 'Error getting location';
    }
  }

  /// Open app settings for location permissions
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings for app permissions
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}