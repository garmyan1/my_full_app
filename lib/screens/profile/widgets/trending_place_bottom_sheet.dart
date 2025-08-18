import 'package:flutter/material.dart';
import '../nearby_map_screen.dart';

class TrendingPlaceBottomSheet extends StatelessWidget {
  final TrendingPlace place;

  const TrendingPlaceBottomSheet({
    Key? key,
    required this.place,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Place icon
          CircleAvatar(
            radius: 40,
            backgroundColor: _getTrendingColor(place.type),
            child: Icon(
              _getTrendingIcon(place.type),
              size: 40,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Place name
          Text(
            place.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          // User count and location
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: _getTrendingColor(place.type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${place.userCount} people • ${place.country}',
              style: TextStyle(
                color: _getTrendingColor(place.type),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                icon: Icons.directions,
                label: 'Directions',
                onTap: () {
                  // TODO: Implement directions
                  Navigator.pop(context);
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.bookmark_border,
                label: 'Save',
                onTap: () {
                  // TODO: Implement save
                  Navigator.pop(context);
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.share,
                label: 'Share',
                onTap: () {
                  // TODO: Implement share
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Color _getTrendingColor(TrendingType type) {
    switch (type) {
      case TrendingType.shopping:
        return Colors.purple;
      case TrendingType.landmark:
        return Colors.orange;
      case TrendingType.beach:
        return Colors.cyan;
      case TrendingType.restaurant:
        return Colors.red;
      case TrendingType.nightlife:
        return Colors.pink;
    }
  }

  IconData _getTrendingIcon(TrendingType type) {
    switch (type) {
      case TrendingType.shopping:
        return Icons.shopping_bag;
      case TrendingType.landmark:
        return Icons.location_city;
      case TrendingType.beach:
        return Icons.beach_access;
      case TrendingType.restaurant:
        return Icons.restaurant;
      case TrendingType.nightlife:
        return Icons.nightlife;
    }
  }
}
