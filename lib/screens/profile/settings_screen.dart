import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/profile_data.dart';
import '../finance/manage_subscription_screen.dart';
import '../finance/buy_subscription_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileData>(
      create: (BuildContext context) => ProfileData(
        name: 'Ahmad Karim',
        username: '@Ahmadkarim23',
        phoneNumber: '+964 785 312 3668',
        profileImageUrl:
            'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
        isPremium: false,
      ),
      child: const TikTokStyleSettingsPage(),
    );
  }
}

class TikTokStyleSettingsPage extends StatelessWidget {
  const TikTokStyleSettingsPage({super.key});

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Sign Out',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[600],
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home',
                    (Route<dynamic> route) => false,
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<SettingsSectionData> _settingsSections(BuildContext context) =>
      <SettingsSectionData>[
        SettingsSectionData(
          title: "Account",
          children: <SettingTileData>[
            SettingTileData(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              description: 'Change your name and username',
              trailingIcon: Icons.chevron_right,
            ),
            SettingTileData(
              icon: Icons.lock_open_outlined,
              title: 'Privacy Controls',
              description: 'Manage your account privacy',
              trailingIcon: Icons.chevron_right,
            ),
            SettingTileData(
              icon: Icons.phone_android_outlined,
              title: 'Phone Number',
              description: 'Update your contact number',
              trailingIcon: Icons.chevron_right,
            ),
            SettingTileData(
              icon: Icons.vpn_key_outlined,
              title: 'Two-Step Verification',
              description: 'Add an extra layer of security',
              trailingIcon: Icons.chevron_right,
            ),
          ],
        ),
        SettingsSectionData(
          title: "Preferences",
          children: <SettingTileData>[
            SettingTileData(
              icon: Icons.notifications_none_outlined,
              title: 'Notifications',
              description: 'Customize alerts and sounds',
              trailingIcon: Icons.chevron_right,
            ),
            SettingTileData(
              icon: Icons.lock_outline,
              title: 'Privacy & Security',
              description: 'Control your privacy settings',
              trailingIcon: Icons.chevron_right,
            ),
            SettingTileData(
              icon: Icons.storage_outlined,
              title: 'Data & Storage',
              description: 'Manage media and cache',
              trailingIcon: Icons.chevron_right,
            ),
            SettingTileData(
              icon: Icons.language_outlined,
              title: 'Language',
              description: 'Change app language',
              trailingIcon: Icons.chevron_right,
            ),
          ],
        ),
        SettingsSectionData(
          title: "Support",
          children: <SettingTileData>[
            SettingTileData(
              icon: Icons.help_outline,
              title: 'Help Center',
              description: 'Get help and support',
              trailingIcon: Icons.chevron_right,
            ),
            SettingTileData(
              icon: Icons.feedback_outlined,
              title: 'Report a Problem',
              description: 'Report bugs or issues',
              trailingIcon: Icons.chevron_right,
            ),
            SettingTileData(
              icon: Icons.info_outline,
              title: 'About',
              description: 'App version and information',
              trailingIcon: Icons.chevron_right,
            ),
          ],
        ),
        SettingsSectionData(
          title: "Account Actions",
          children: <SettingTileData>[
            SettingTileData(
              icon: Icons.delete_outline,
              title: 'Delete Account',
              description: 'Permanently remove your account',
              trailingIcon: Icons.chevron_right,
              isDestructive: true,
            ),
            SettingTileData(
              icon: Icons.logout,
              title: 'Sign Out',
              description: 'Sign out from this account',
              trailingIcon: Icons.chevron_right,
              isDestructive: true,
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final ProfileData profileData = Provider.of<ProfileData>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: <Widget>[
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFE2C55),
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(profileData.profileImageUrl),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        profileData.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profileData.username,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFE2C55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Settings Sections
          ..._settingsSections(context).map((section) => _buildSettingsSection(
                context,
                section,
                isDark,
              )),

          const SizedBox(height: 40),

          // App Version
          Center(
            child: Text(
              'TikTok Clone v1.0.0',
              style: TextStyle(
                color: isDark ? Colors.grey[600] : Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    SettingsSectionData section,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            section.title.toUpperCase(),
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: section.children.map((tile) {
              final isLast = section.children.last == tile;
              return Column(
                children: [
                  _buildSettingTile(context, tile, isDark),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    SettingTileData tile,
    bool isDark,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tile.isDestructive
              ? Colors.red.withOpacity(0.1)
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          tile.icon,
          color: tile.isDestructive
              ? Colors.red
              : (isDark ? Colors.white : Colors.black87),
          size: 20,
        ),
      ),
      title: Text(
        tile.title,
        style: TextStyle(
          color: tile.isDestructive
              ? Colors.red
              : (isDark ? Colors.white : Colors.black87),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: tile.description != null
          ? Text(
              tile.description!,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
            )
          : null,
      trailing: tile.trailing != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFE2C55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tile.trailing!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : tile.trailingIcon != null
              ? Icon(
                  tile.trailingIcon,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  size: 20,
                )
              : null,
      onTap: tile.onTap,
    );
  }
}

// Data Models
class SettingsSectionData {
  final String title;
  final List<SettingTileData> children;

  SettingsSectionData({
    required this.title,
    required this.children,
  });
}

class SettingTileData {
  final IconData icon;
  final String title;
  final String? description;
  final IconData? trailingIcon;
  final String? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  SettingTileData({
    required this.icon,
    required this.title,
    this.description,
    this.trailingIcon,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });
}

class ProfileSubscriptionData {
  final String title;
  final String status;
  final List<String> benefits;
  final String actionText;
  final IconData actionIcon;
  final String expiryDate;
  final String price;
  final String signatureText;

  ProfileSubscriptionData({
    required this.title,
    required this.status,
    required this.benefits,
    required this.actionText,
    required this.actionIcon,
    required this.expiryDate,
    required this.price,
    required this.signatureText,
  });
}
