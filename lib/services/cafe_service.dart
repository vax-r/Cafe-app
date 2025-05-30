import 'dart:math';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import '../models/cafe_info.dart';

class CafeService {
  final Dio _dio = Dio();

  Future<List<CafeInfo>> searchCafes(LatLng center) async {
    try {
      // Enhanced Overpass API query to get more cafe details
      final query = '''
[out:json][timeout:25];
(
  node["amenity"="cafe"](around:50000,${center.latitude},${center.longitude});
  way["amenity"="cafe"](around:50000,${center.latitude},${center.longitude});
  relation["amenity"="cafe"](around:50000,${center.latitude},${center.longitude});
);
out geom;
''';

      final response = await _dio.post(
        'https://overpass-api.de/api/interpreter',
        data: query,
        options: Options(
          headers: {'Content-Type': 'text/plain'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<CafeInfo> cafes = [];

        for (var element in data['elements']) {
          if (element['type'] == 'node' && element['lat'] != null && element['lon'] != null) {
            final tags = element['tags'] ?? {};
            final name = tags['name'] ?? 'Unknown Cafe';
            
            if (name == 'Unknown Cafe' || name.isEmpty) continue;

            // Enhanced cafe information
            final cafeInfo = await _enrichCafeData(
              name: name,
              tags: tags,
              location: LatLng(element['lat'].toDouble(), element['lon'].toDouble()),
            );

            cafes.add(cafeInfo);
          }
        }

        return cafes.take(30).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error searching cafes: ${e.toString()}');
    }
  }

  Future<CafeInfo> _enrichCafeData({
    required String name,
    required Map<String, dynamic> tags,
    required LatLng location,
  }) async {
    // Generate realistic data based on cafe name and location
    final random = Random(name.hashCode);
    
    // Generate rating (3.0 to 5.0)
    final rating = 3.0 + (random.nextDouble() * 2.0);
    final reviewCount = 10 + random.nextInt(200);
    
    // Generate sample photos URLs (using placeholder images)
    final photos = <String>[];
    final photoCount = random.nextInt(4) + 1;
    for (int i = 0; i < photoCount; i++) {
      photos.add('https://picsum.photos/400/300?random=${name.hashCode + i}');
    }
    
    // Generate amenities
    final allAmenities = ['WiFi', 'Outdoor Seating', 'Pet Friendly', 'Takeaway', 'Vegetarian Options', 'Study Space', 'Live Music'];
    final amenities = <String>[];
    for (int i = 0; i < 3; i++) {
      if (random.nextBool()) {
        amenities.add(allAmenities[random.nextInt(allAmenities.length)]);
      }
    }
    
    // Generate sample reviews
    final sampleReviews = [
      'Great coffee and cozy atmosphere!',
      'Perfect place for studying and working.',
      'Delicious pastries and friendly staff.',
      'Love the outdoor seating area.',
      'Best latte in the neighborhood!',
      'Quiet spot with excellent WiFi.',
    ];
    
    final reviews = <CafeReview>[];
    final reviewsToGenerate = random.nextInt(3) + 1;
    for (int i = 0; i < reviewsToGenerate; i++) {
      reviews.add(CafeReview(
        author: 'User${random.nextInt(1000)}',
        rating: 3.0 + (random.nextDouble() * 2.0),
        comment: sampleReviews[random.nextInt(sampleReviews.length)],
        date: DateTime.now().subtract(Duration(days: random.nextInt(90))),
      ));
    }

    return CafeInfo(
      name: name,
      address: _buildAddress(tags),
      location: location,
      phone: tags['phone'],
      website: tags['website'],
      rating: rating,
      reviewCount: reviewCount,
      photos: photos,
      description: _generateDescription(name),
      openingHours: tags['opening_hours'] ?? '8:00 AM - 8:00 PM',
      amenities: amenities.toSet().toList(),
      reviews: reviews,
      priceRange: _generatePriceRange(random),
    );
  }

  String _generateDescription(String name) {
    final descriptions = [
      'A cozy neighborhood cafe perfect for coffee lovers and remote workers.',
      'Traditional Taiwanese cafe serving excellent coffee and local pastries.',
      'Modern coffee shop with specialty brews and comfortable seating.',
      'Family-owned cafe known for its warm atmosphere and fresh roasted beans.',
      'Trendy spot popular with locals and students, offering great WiFi and study space.',
    ];
    return descriptions[name.hashCode % descriptions.length];
  }

  String _generatePriceRange(Random random) {
    final ranges = ['💰', '💰💰', '💰💰💰'];
    return ranges[random.nextInt(ranges.length)];
  }

  String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];
    
    if (tags['addr:street'] != null) parts.add(tags['addr:street']);
    if (tags['addr:city'] != null) parts.add(tags['addr:city']);
    if (tags['addr:state'] != null) parts.add(tags['addr:state']);
    
    if (parts.isEmpty) {
      return 'Address not available';
    }
    
    return parts.join(', ');
  }
}