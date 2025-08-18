import 'package:flutter/material.dart';
import '../nearby_map_screen.dart';

class UserProfileBottomSheet extends StatelessWidget {
  final MapUser user;

  const UserProfileBottomSheet({
    Key? key,
    required this.user,
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

          // User avatar and status
          CircleAvatar(
            radius: 40,
            child: Text(
              user.avatar,
              style: const TextStyle(fontSize: 32),
            ),
          ),

          const SizedBox(height: 16),

          // User name
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Online status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: user.isOnline ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.isOnline ? 'Online' : 'Last seen ${user.lastSeen}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Location info
          if (user.location != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 8),
                Text(user.location!),
              ],
            ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                icon: Icons.message,
                label: 'Message',
                onTap: () {
                  // TODO: Implement messaging
                  Navigator.pop(context);
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.video_call,
                label: 'Video Call',
                onTap: () {
                  // TODO: Implement video call
                  Navigator.pop(context);
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.person_add,
                label: 'Add Friend',
                onTap: () {
                  // TODO: Implement add friend
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
}
