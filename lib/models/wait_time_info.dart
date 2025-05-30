import 'package:flutter/material.dart';

class WaitTimeInfo {
  final int estimatedMinutes;
  final int minRange;
  final int maxRange;
  final String busyLevel;
  final Color busyColor;
  final int currentQueue;
  final int staffCount;

  WaitTimeInfo({
    required this.estimatedMinutes,
    required this.minRange,
    required this.maxRange,
    required this.busyLevel,
    required this.busyColor,
    required this.currentQueue,
    required this.staffCount,
  });
}