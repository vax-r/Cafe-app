import 'package:flutter/material.dart';
import '../services/distance_service.dart';

class CafeSortWidget extends StatelessWidget {
  final SortMode currentMode;
  final Function(SortMode) onSortChanged;
  final bool hasUserLocation;

  const CafeSortWidget({
    super.key,
    required this.currentMode,
    required this.onSortChanged,
    required this.hasUserLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sort,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            'Sort by:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          _buildSortButton(SortMode.distance, enabled: hasUserLocation),
          const SizedBox(width: 8),
          _buildSortButton(SortMode.rating, enabled: true),
          const SizedBox(width: 8),
          _buildSortButton(SortMode.waitTime, enabled: true),
        ],
      ),
    );
  }

  Widget _buildSortButton(SortMode mode, {required bool enabled}) {
    final bool isSelected = currentMode == mode;
    final Color backgroundColor = isSelected
        ? Colors.brown
        : enabled
            ? Colors.grey.shade100
            : Colors.grey.shade200;
    final Color textColor = isSelected
        ? Colors.white
        : enabled
            ? Colors.grey.shade700
            : Colors.grey.shade400;

    return GestureDetector(
      onTap: enabled ? () => onSortChanged(mode) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.brown : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              DistanceService.getSortModeIcon(mode),
              size: 14,
              color: textColor,
            ),
            const SizedBox(width: 4),
            Text(
              _getShortDescription(mode),
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getShortDescription(SortMode mode) {
    switch (mode) {
      case SortMode.distance:
        return 'Distance';
      case SortMode.rating:
        return 'Rating';
      case SortMode.waitTime:
        return 'Wait Time';
    }
  }
}

class CafeStatsBar extends StatelessWidget {
  final int totalCafes;
  final String? nearestDistance;
  final double? averageRating;

  const CafeStatsBar({
    super.key,
    required this.totalCafes,
    this.nearestDistance,
    this.averageRating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildStat(
            icon: Icons.coffee,
            label: 'Cafes',
            value: totalCafes.toString(),
            color: Colors.brown,
          ),
          if (nearestDistance != null) ...[
            const SizedBox(width: 16),
            _buildStat(
              icon: Icons.near_me,
              label: 'Nearest',
              value: nearestDistance!,
              color: Colors.green,
            ),
          ],
          if (averageRating != null) ...[
            const SizedBox(width: 16),
            _buildStat(
              icon: Icons.star,
              label: 'Avg Rating',
              value: averageRating!.toStringAsFixed(1),
              color: Colors.orange,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}