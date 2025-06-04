import 'package:flutter/material.dart';

class UserReview {
  final String id;
  final String cafeId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime dateTime;
  final List<String> tags;
  final bool isVerified;
  final int helpfulCount;
  final ReviewStatus status;

  UserReview({
    required this.id,
    required this.cafeId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.dateTime,
    this.tags = const [],
    this.isVerified = false,
    this.helpfulCount = 0,
    this.status = ReviewStatus.approved,
  });

  UserReview copyWith({
    String? id,
    String? cafeId,
    String? userName,
    double? rating,
    String? comment,
    DateTime? dateTime,
    List<String>? tags,
    bool? isVerified,
    int? helpfulCount,
    ReviewStatus? status,
  }) {
    return UserReview(
      id: id ?? this.id,
      cafeId: cafeId ?? this.cafeId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      dateTime: dateTime ?? this.dateTime,
      tags: tags ?? this.tags,
      isVerified: isVerified ?? this.isVerified,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cafeId': cafeId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'dateTime': dateTime.toIso8601String(),
      'tags': tags,
      'isVerified': isVerified,
      'helpfulCount': helpfulCount,
      'status': status.toString(),
    };
  }

  factory UserReview.fromJson(Map<String, dynamic> json) {
    return UserReview(
      id: json['id'],
      cafeId: json['cafeId'],
      userName: json['userName'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      dateTime: DateTime.parse(json['dateTime']),
      tags: List<String>.from(json['tags'] ?? []),
      isVerified: json['isVerified'] ?? false,
      helpfulCount: json['helpfulCount'] ?? 0,
      status: ReviewStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ReviewStatus.approved,
      ),
    );
  }
}

enum ReviewStatus {
  pending,
  approved,
  rejected,
  flagged,
}

class ReviewSubmission {
  final String cafeId;
  final String cafeName;
  final double rating;
  final String comment;
  final List<String> selectedTags;
  final bool allowAnonymous;

  ReviewSubmission({
    required this.cafeId,
    required this.cafeName,
    required this.rating,
    required this.comment,
    this.selectedTags = const [],
    this.allowAnonymous = false,
  });

  bool get isValid {
    return rating >= 1 && rating <= 5 && comment.trim().isNotEmpty;
  }
}

class UserProfile {
  final String userName;
  final String displayName;
  final DateTime joinDate;
  final int totalReviews;
  final double averageRating;
  final List<String> badges;
  final bool isVerified;

  UserProfile({
    required this.userName,
    required this.displayName,
    required this.joinDate,
    this.totalReviews = 0,
    this.averageRating = 0.0,
    this.badges = const [],
    this.isVerified = false,
  });

  UserProfile copyWith({
    String? userName,
    String? displayName,
    DateTime? joinDate,
    int? totalReviews,
    double? averageRating,
    List<String>? badges,
    bool? isVerified,
  }) {
    return UserProfile(
      userName: userName ?? this.userName,
      displayName: displayName ?? this.displayName,
      joinDate: joinDate ?? this.joinDate,
      totalReviews: totalReviews ?? this.totalReviews,
      averageRating: averageRating ?? this.averageRating,
      badges: badges ?? this.badges,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class ReviewTags {
  static const List<String> availableTags = [
    'Great Coffee',
    'Cozy Atmosphere',
    'Good WiFi',
    'Quiet',
    'Busy',
    'Expensive',
    'Good Value',
    'Friendly Staff',
    'Quick Service',
    'Slow Service',
    'Clean',
    'Good Food',
    'Pet Friendly',
    'Study Friendly',
    'Date Spot',
    'Family Friendly',
    'Outdoor Seating',
    'Live Music',
    'Artsy',
    'Business Friendly',
  ];

  static Map<String, IconData> tagIcons = {
    'Great Coffee': Icons.coffee,
    'Cozy Atmosphere': Icons.home,
    'Good WiFi': Icons.wifi,
    'Quiet': Icons.volume_off,
    'Busy': Icons.people,
    'Expensive': Icons.attach_money,
    'Good Value': Icons.thumb_up,
    'Friendly Staff': Icons.sentiment_very_satisfied,
    'Quick Service': Icons.speed,
    'Slow Service': Icons.hourglass_empty,
    'Clean': Icons.cleaning_services,
    'Good Food': Icons.restaurant,
    'Pet Friendly': Icons.pets,
    'Study Friendly': Icons.school,
    'Date Spot': Icons.favorite,
    'Family Friendly': Icons.family_restroom,
    'Outdoor Seating': Icons.deck,
    'Live Music': Icons.music_note,
    'Artsy': Icons.palette,
    'Business Friendly': Icons.business_center,
  };

  static Color getTagColor(String tag) {
    final positiveColor = Colors.green.shade100;
    final negativeColor = Colors.red.shade100;
    final neutralColor = Colors.blue.shade100;

    const positiveTags = [
      'Great Coffee', 'Cozy Atmosphere', 'Good WiFi', 'Quiet',
      'Good Value', 'Friendly Staff', 'Quick Service', 'Clean',
      'Good Food', 'Pet Friendly', 'Study Friendly'
    ];

    const negativeTags = ['Expensive', 'Slow Service', 'Busy'];

    if (positiveTags.contains(tag)) return positiveColor;
    if (negativeTags.contains(tag)) return negativeColor;
    return neutralColor;
  }
}