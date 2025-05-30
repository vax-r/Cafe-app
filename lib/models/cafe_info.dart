import 'package:latlong2/latlong.dart';
import '../services/distance_service.dart';

class CafeInfo {
  final String name;
  final String address;
  final LatLng location;
  final String? phone;
  final String? website;
  final double? rating;
  final int? reviewCount;
  final List<String> photos;
  final String? description;
  final String? openingHours;
  final List<String> amenities;
  final List<CafeReview> reviews;
  final String? priceRange;
  
  // Distance-related properties
  CafeDistance? distance;

  CafeInfo({
    required this.name,
    required this.address,
    required this.location,
    this.phone,
    this.website,
    this.rating,
    this.reviewCount,
    this.photos = const [],
    this.description,
    this.openingHours,
    this.amenities = const [],
    this.reviews = const [],
    this.priceRange,
    this.distance,
  });

  /// Create a copy with updated distance information
  CafeInfo copyWithDistance(CafeDistance? newDistance) {
    return CafeInfo(
      name: name,
      address: address,
      location: location,
      phone: phone,
      website: website,
      rating: rating,
      reviewCount: reviewCount,
      photos: photos,
      description: description,
      openingHours: openingHours,
      amenities: amenities,
      reviews: reviews,
      priceRange: priceRange,
      distance: newDistance,
    );
  }

  /// Get unique identifier for this cafe
  String get id => '${name}_${location.latitude}_${location.longitude}';
}

class CafeReview {
  final String author;
  final double rating;
  final String comment;
  final DateTime date;

  CafeReview({
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
  });
}