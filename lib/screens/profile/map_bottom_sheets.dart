import 'package:flutter/material.dart';
import 'nearby_map_screen.dart';

class UserProfileBottomSheet extends StatelessWidget {
  final MapUser user;

  const UserProfileBottomSheet({Key? key, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // User avatar and info
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: user.hasStory
                  ? const LinearGradient(
                      colors: [Colors.purple, Colors.pink, Colors.orange],
                    )
                  : null,
              border: !user.hasStory
                  ? Border.all(color: Colors.grey[300]!, width: 2)
                  : null,
            ),
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  user.avatar,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            user.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: user.isOnline ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                user.isOnline ? 'Online now' : 'Last seen ${user.lastSeen}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Location information
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.red[600],
                ),
                const SizedBox(width: 8),
                Text(
                  user.location ?? 'Location unavailable',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                Icons.message,
                'Message',
                Colors.blue,
                () =>
                    _showMessage(context, 'Opening chat with ${user.name}...'),
              ),
              if (user.hasStory)
                _buildActionButton(
                  Icons.play_circle_fill,
                  'View Story',
                  Colors.purple,
                  () =>
                      _showMessage(context, 'Opening ${user.name}\'s story...'),
                ),
              _buildActionButton(
                Icons.person_add,
                'Add Friend',
                Colors.green,
                () => _showMessage(
                    context, 'Friend request sent to ${user.name}!'),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class TrendingPlaceBottomSheet extends StatelessWidget {
  final TrendingPlace place;

  const TrendingPlaceBottomSheet({Key? key, required this.place})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Place icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getTrendingColor(place.type),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTrendingIcon(place.type),
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            place.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getTrendingColor(place.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '${place.userCount} people here now',
              style: TextStyle(
                fontSize: 14,
                color: _getTrendingColor(place.type),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Country information
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.public,
                  size: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  place.country,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                Icons.directions,
                'Directions',
                Colors.blue,
                () => _showMessage(
                    context, 'Opening directions to ${place.name}...'),
              ),
              _buildActionButton(
                Icons.info_outline,
                'Details',
                Colors.orange,
                () => _showMessage(
                    context, 'Loading details for ${place.name}...'),
              ),
              _buildActionButton(
                Icons.share,
                'Share',
                Colors.green,
                () => _showMessage(context, 'Sharing ${place.name}...'),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
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

  void _showMessage(BuildContext context, String message) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class FriendsListBottomSheet extends StatelessWidget {
  final List<MapUser> users;

  const FriendsListBottomSheet({Key? key, required this.users})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Friends Nearby',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: user.hasStory
                          ? const LinearGradient(
                              colors: [
                                Colors.purple,
                                Colors.pink,
                                Colors.orange
                              ],
                            )
                          : null,
                      border: !user.hasStory
                          ? Border.all(color: Colors.grey[300]!, width: 2)
                          : null,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          user.avatar,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: user.isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.isOnline ? 'Online now' : user.lastSeen,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.chat_bubble,
                    color: Colors.blue[600],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Opening chat with ${user.name}...')),
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
}

class TrendingListBottomSheet extends StatelessWidget {
  final List<TrendingPlace> places;

  const TrendingListBottomSheet({Key? key, required this.places})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Trending Places',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getTrendingColor(place.type),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getTrendingIcon(place.type),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    place.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    '${place.userCount} people here',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  trailing: Icon(
                    Icons.directions,
                    color: Colors.blue[600],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Getting directions to ${place.name}...')),
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

class SearchBottomSheet extends StatefulWidget {
  const SearchBottomSheet({Key? key}) : super(key: key);

  @override
  _SearchBottomSheetState createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<String> searchResults = [];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search friends or places...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[700] : Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  // Mock search results
                  searchResults = [
                    'Dubai Mall',
                    'Burj Khalifa',
                    'Sarah Johnson',
                    'Mike Chen',
                    'Marina Beach',
                  ]
                      .where((item) =>
                          item.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // Search results
          Expanded(
            child: searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search for friends or places',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final result = searchResults[index];
                      final isPlace = !result.contains(' ');

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPlace ? Colors.blue : Colors.green,
                          child: Icon(
                            isPlace ? Icons.location_on : Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          result,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          isPlace ? 'Popular place' : 'Friend',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Selected: $result')),
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
}

class MapSettingsBottomSheet extends StatelessWidget {
  const MapSettingsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Map Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 20),

          _buildSettingTile(
            Icons.visibility,
            'Ghost Mode',
            'Hide your location from others',
            false,
            (value) {},
            isDark,
          ),

          _buildSettingTile(
            Icons.notifications,
            'Location Notifications',
            'Get notified when friends are nearby',
            true,
            (value) {},
            isDark,
          ),

          _buildSettingTile(
            Icons.public,
            'Share Location',
            'Let friends see your location',
            true,
            (value) {},
            isDark,
          ),

          const SizedBox(height: 20),

          ListTile(
            leading: Icon(
              Icons.color_lens,
              color: isDark ? Colors.white : Colors.black87,
            ),
            title: Text(
              'Map Style',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              'Standard',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Map style options coming soon!')),
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }
}
