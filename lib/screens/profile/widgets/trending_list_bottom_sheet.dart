import 'package:flutter/material.dart';
import '../nearby_map_screen.dart';
import 'trending_place_bottom_sheet.dart';

class TrendingListBottomSheet extends StatelessWidget {
  final List<TrendingPlace> places;

  const TrendingListBottomSheet({
    Key? key,
    required this.places,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Trending Places',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          // Places list
          Expanded(
            child: ListView.builder(
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getTrendingColor(place.type),
                    child: Icon(
                      _getTrendingIcon(place.type),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(place.name),
                  subtitle: Text('${place.userCount} people here'),
                  trailing: Text(
                    place.country,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          TrendingPlaceBottomSheet(place: place),
                    );
                  },
                );
              },
            ),
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
