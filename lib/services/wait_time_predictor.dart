import 'dart:math';
import 'package:flutter/material.dart';
import '../models/wait_time_info.dart';

class WaitTimePredictor {
  static const double baseServiceTimeMinutes = 3.0;
  
  static WaitTimeInfo predictWaitTime({
    required String cafeName,
    required DateTime currentTime,
    int? customQueue,
  }) {
    // Generate consistent queue based on cafe name and current time
    final random = Random(cafeName.hashCode + currentTime.hour);
    
    // Determine queue length based on time patterns
    final queue = customQueue ?? _generateRealisticQueue(currentTime, random);
    
    // Get time multipliers
    final hourMultiplier = _getHourMultiplier(currentTime.hour);
    final dayMultiplier = _getDayMultiplier(currentTime.weekday);
    
    // Staff count varies by time and cafe size
    final staffCount = _getStaffCount(currentTime, random);
    
    // Calculate base wait time
    final baseWaitTime = queue * baseServiceTimeMinutes;
    
    // Apply multipliers
    final adjustedWaitTime = baseWaitTime * hourMultiplier * dayMultiplier;
    
    // Staff efficiency factor
    final staffEfficiency = staffCount / 2.0; // 2 is optimal staff count
    final finalWaitTime = (adjustedWaitTime / staffEfficiency).clamp(0.5, 45.0);
    
    // Create range (±25% of estimate)
    final estimatedMinutes = finalWaitTime.round();
    final minRange = (finalWaitTime * 0.75).round();
    final maxRange = (finalWaitTime * 1.25).round();
    
    // Determine busy level
    final busyInfo = _getBusyLevel(finalWaitTime, queue);
    
    return WaitTimeInfo(
      estimatedMinutes: estimatedMinutes,
      minRange: minRange,
      maxRange: maxRange,
      busyLevel: busyInfo['level'],
      busyColor: busyInfo['color'],
      currentQueue: queue,
      staffCount: staffCount,
    );
  }
  
  static int _generateRealisticQueue(DateTime time, Random random) {
    final hour = time.hour;
    
    // Base queue by time of day
    int baseQueue;
    if (hour >= 7 && hour <= 9) { // Morning rush
      baseQueue = 8 + random.nextInt(7); // 8-14 people
    } else if (hour >= 12 && hour <= 14) { // Lunch time
      baseQueue = 5 + random.nextInt(6); // 5-10 people
    } else if (hour >= 15 && hour <= 17) { // Afternoon
      baseQueue = 2 + random.nextInt(4); // 2-5 people
    } else if (hour >= 18 && hour <= 20) { // Evening
      baseQueue = 4 + random.nextInt(5); // 4-8 people
    } else { // Off hours
      baseQueue = 0 + random.nextInt(3); // 0-2 people
    }
    
    // Weekend adjustment
    if (time.weekday >= 6) {
      baseQueue = (baseQueue * 1.3).round(); // 30% busier on weekends
    }
    
    return baseQueue;
  }
  
  static double _getHourMultiplier(int hour) {
    // Rush hour multipliers
    if (hour >= 7 && hour <= 9) return 2.2; // Morning rush
    if (hour >= 12 && hour <= 14) return 1.6; // Lunch rush
    if (hour >= 15 && hour <= 17) return 0.8; // Afternoon lull
    if (hour >= 18 && hour <= 20) return 1.4; // Evening peak
    if (hour >= 6 && hour <= 11) return 1.2; // Morning
    if (hour >= 21 && hour <= 22) return 1.1; // Late evening
    return 0.7; // Off hours
  }
  
  static double _getDayMultiplier(int weekday) {
    // Monday = 1, Sunday = 7
    if (weekday >= 1 && weekday <= 5) return 1.0; // Weekdays
    if (weekday == 6) return 1.3; // Saturday
    if (weekday == 7) return 1.2; // Sunday
    return 1.0;
  }
  
  static int _getStaffCount(DateTime time, Random random) {
    final hour = time.hour;
    
    // More staff during busy hours
    if (hour >= 7 && hour <= 10) return 3 + random.nextInt(2); // 3-4 staff
    if (hour >= 11 && hour <= 15) return 2 + random.nextInt(2); // 2-3 staff
    if (hour >= 16 && hour <= 20) return 2 + random.nextInt(2); // 2-3 staff
    return 1 + random.nextInt(2); // 1-2 staff off hours
  }
  
  static Map<String, dynamic> _getBusyLevel(double waitTime, int queue) {
    if (waitTime <= 3) {
      return {'level': 'Not Busy', 'color': Colors.green};
    } else if (waitTime <= 6) {
      return {'level': 'Moderately Busy', 'color': Colors.yellow.shade700};
    } else if (waitTime <= 10) {
      return {'level': 'Busy', 'color': Colors.orange};
    } else if (waitTime <= 15) {
      return {'level': 'Very Busy', 'color': Colors.red.shade600};
    } else {
      return {'level': 'Extremely Busy', 'color': Colors.red.shade800};
    }
  }
}