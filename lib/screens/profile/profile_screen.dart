import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings_screen.dart';
import '../finance/balance_screen.dart';
import '../communication/messenger_screen.dart';
import '../lifestyle/live_screen.dart';
import '../lifestyle/lifestyle_screen.dart';
import '../lifestyle/groups_screen.dart';
import '../general/notifications_screen.dart';
import '../payment/payment_screen.dart';
import '../menu/menu_bottom/tiktok_studio/tiktok_studio_screen.dart';
import '../menu/menu_bottom/my_project/my_project_screen.dart';
import '../menu/menu_bottom/my_qr_code/my_qr_code_screen.dart';
import '../../data/services/theme_service.dart';
import 'nearby_map_screen.dart';

/// A widget for displaying a section header within the drop-up menu.
class DropUpSectionHeader extends StatelessWidget {
  final String title;

  const DropUpSectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Made background color theme-aware
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]
          : const Color(0xFFFAFAFA),
      child: Padding(
        // Updated padding to provide symmetric vertical padding, centering the text
        // within the background while maintaining horizontal padding.
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 6, // Changed font size to 6 as requested (smaller)
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget for displaying a single item in the drop-up menu.
class DropUpMenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final VoidCallback onTap;

  const DropUpMenuItemWidget({
    super.key,
    required this.icon,
    required this.label,
    this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      minVerticalPadding: 0.0,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      leading: Icon(icon,
          size: 20, color: Theme.of(context).iconTheme.color ?? Colors.black87),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (description != null) ...<Widget>[
            const SizedBox(height: 2.0),
            Text(
              description!,
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
      subtitle: null,
      trailing: const Icon(
        Icons.chevron_right,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
      hoverColor: Colors.transparent, // Disable hover effect
    );
  }
}

class ShopCategoryData extends ChangeNotifier {
  final List<Map<String, dynamic>> categories = <Map<String, dynamic>>[
    {'name': 'All', 'icon': Icons.dashboard_outlined},
    {'name': 'Electronics', 'icon': Icons.electrical_services_outlined},
    {'name': 'Clothing', 'icon': Icons.checkroom_outlined},
    {'name': 'Books', 'icon': Icons.book_outlined},
    {'name': 'Home Decor', 'icon': Icons.home_outlined},
    {'name': 'Sports', 'icon': Icons.sports_soccer_outlined},
    {'name': 'Beauty', 'icon': Icons.spa_outlined},
  ];

  ShopCategoryData();
}

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool isFollowing = false;

  Map<String, dynamic>? userData;
  bool isLoading = true;

  /// Defines the structure and content of the drop-up menu.
  /// Each map represents either a 'section' header or an 'item'.
  static const List<Map<String, dynamic>> _menuData = <Map<String, dynamic>>[
    {
      'type': 'item',
      'icon': Icons.star_outline,
      'label': 'TikTok Studio',
      'description':
          'Access advanced tools for content creation and analytics.',
    },
    {
      'type': 'item',
      'icon': Icons.folder_open,
      'label': 'My Project',
      'description': 'Manage your ongoing creative projects and drafts.',
    },
    {
      'type': 'item',
      'icon': Icons.account_balance_wallet_outlined,
      'label': 'Balance',
      'description': 'Manage your earnings, rewards, and virtual gifts.',
    },
    {
      'type': 'item',
      'icon': Icons.qr_code_2_outlined,
      'label': 'My QR code',
      'description': 'Share your profile with others by scanning a QR code.',
    },
    {
      'type': 'item',
      'icon': Icons.palette_outlined,
      'label': 'Preferences',
      'description': 'Customize your app appearance and theme preferences.',
    },
    {
      'type': 'item',
      'icon': Icons.settings_outlined,
      'label': 'Settings and privacy',
      'description':
          'Control your account, app settings, and privacy preferences.',
    },
  ];

  void _showDropUpMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor ??
          (Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.white),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 10), // Top padding
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.blue[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Removed the SizedBox(height: 10) here as requested
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      _menuData.map<Widget>((Map<String, dynamic> itemData) {
                    if (itemData['type'] == 'section') {
                      return DropUpSectionHeader(
                          title: itemData['title']! as String);
                    } else if (itemData['type'] == 'item') {
                      final DropUpMenuItemWidget itemWidget =
                          DropUpMenuItemWidget(
                        icon: itemData['icon']! as IconData,
                        label: itemData['label']! as String,
                        description: itemData['description'] as String?,
                        onTap: () {
                          Navigator.pop(context); // Close the bottom sheet

                          // Handle navigation based on the item
                          if (itemData['label'] == 'Preferences') {
                            _showPreferencesDialog(context);
                          } else if (itemData['label'] ==
                              'Settings and privacy') {
                            _showSettingsAndPrivacyMenu(context);
                          } else if (itemData['label'] == 'Balance') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BalanceScreen(),
                              ),
                            );
                          } else if (itemData['label'] == 'TikTok Studio') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TikTokStudioScreen(),
                              ),
                            );
                          } else if (itemData['label'] == 'My Project') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyProjectScreen(),
                              ),
                            );
                          } else if (itemData['label'] == 'My QR code') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyQRCodeScreen(),
                              ),
                            );
                          }
                          // You can add more navigation cases here for other menu items
                        },
                      );

                      // Directly return the itemWidget without a wrapping box
                      return itemWidget;
                    }
                    return const SizedBox
                        .shrink(); // Fallback for unknown types
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10), // Bottom padding
          ],
        );
      },
    );
  }

  void _showPreferencesDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor ??
          (Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.white),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Preferences',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Customize your app appearance and settings',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 20),

              // Theme Mode Selection
              FutureBuilder<ThemeService>(
                future: ThemeService.getInstance(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return ListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: const Text('Theme Mode'),
                      subtitle: const Text('Loading...'),
                      trailing: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  final themeService = snapshot.data!;
                  return AnimatedBuilder(
                    animation: themeService,
                    builder: (context, child) {
                      String currentTheme = 'System Default';
                      IconData currentIcon = Icons.auto_mode;
                      switch (themeService.themeMode) {
                        case ThemeMode.light:
                          currentTheme = 'Light Mode';
                          currentIcon = Icons.light_mode;
                          break;
                        case ThemeMode.dark:
                          currentTheme = 'Dark Mode';
                          currentIcon = Icons.dark_mode;
                          break;
                        case ThemeMode.system:
                          currentTheme = 'System Default';
                          currentIcon = Icons.auto_mode;
                          break;
                      }

                      return Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: Icon(
                            currentIcon,
                            color: Colors.blue,
                          ),
                          title: const Text(
                            'Theme Mode',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            currentTheme,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _showThemeSelectionDialog(context, themeService);
                          },
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Other preferences placeholders
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.language,
                        color: Colors.blue,
                      ),
                      title: const Text(
                        'Language',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'English',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Language settings coming soon!'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.blue,
                      ),
                      title: const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Manage notification preferences',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Notification preferences coming soon!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Footer
              Center(
                child: Text(
                  'Powered by CGC',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsAndPrivacyMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor ??
          (Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.white),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 10), // Top padding
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.blue[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            
            // Settings and Privacy Options
            ListTile(
              leading: const Icon(
                Icons.account_circle_outlined,
                color: Colors.blue,
                size: 24,
              ),
              title: const Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Manage your account information',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            
            ListTile(
              leading: const Icon(
                Icons.security_outlined,
                color: Colors.blue,
                size: 24,
              ),
              title: const Text(
                'Privacy & Security',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Control your privacy settings',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy settings coming soon!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            
            const Divider(height: 1),
            
            // Logout Option
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
                size: 24,
              ),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              subtitle: const Text(
                'Sign out of your account',
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  setState(() {}); // Rebuild to show unauthenticated state
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Successfully signed out!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20), // Bottom padding
          ],
        );
      },
    );
  }

  void _showThemeSelectionDialog(
      BuildContext context, ThemeService themeService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Select Theme Mode',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeDialogOption(
                context: context,
                title: 'Light Mode',
                subtitle: 'Use light theme',
                icon: Icons.light_mode,
                themeMode: ThemeMode.light,
                themeService: themeService,
                isSelected: themeService.isLightMode,
              ),
              const SizedBox(height: 8),
              _buildThemeDialogOption(
                context: context,
                title: 'Dark Mode',
                subtitle: 'Use dark theme',
                icon: Icons.dark_mode,
                themeMode: ThemeMode.dark,
                themeService: themeService,
                isSelected: themeService.isDarkMode,
              ),
              const SizedBox(height: 8),
              _buildThemeDialogOption(
                context: context,
                title: 'System Default',
                subtitle: 'Follow system theme setting',
                icon: Icons.auto_mode,
                themeMode: ThemeMode.system,
                themeService: themeService,
                isSelected: themeService.isSystemMode,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeDialogOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode themeMode,
    required ThemeService themeService,
    required bool isSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.blue : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check_circle,
                color: Colors.blue,
              )
            : null,
        onTap: () {
          themeService.setThemeMode(themeMode);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchUserData();
    checkIfFollowing();
  }

  Future<void> checkIfFollowing() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final targetUid = widget.userId ?? currentUid;
    if (currentUid != null && targetUid != null && currentUid != targetUid) {
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .get();
      final following =
          currentUserDoc.data()?['following'] as List<dynamic>? ?? [];
      setState(() {
        isFollowing = following.contains(targetUid);
      });
    }
  }

  Future<void> handleFollowUnfollow() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final targetUid = widget.userId ?? currentUid;
    if (currentUid == null || targetUid == null || currentUid == targetUid)
      return;

    final currentUserRef =
        FirebaseFirestore.instance.collection('users').doc(currentUid);
    final targetUserRef =
        FirebaseFirestore.instance.collection('users').doc(targetUid);

    if (!isFollowing) {
      // Follow: add targetUid to current user's 'following', add currentUid to target user's 'followers'
      await currentUserRef.update({
        'following': FieldValue.arrayUnion([targetUid]),
      });
      await targetUserRef.update({
        'followers': FieldValue.arrayUnion([currentUid]),
      });
    } else {
      // Unfollow: remove targetUid from current user's 'following', remove currentUid from target user's 'followers'
      await currentUserRef.update({
        'following': FieldValue.arrayRemove([targetUid]),
      });
      await targetUserRef.update({
        'followers': FieldValue.arrayRemove([currentUid]),
      });
    }
    setState(() {
      isFollowing = !isFollowing;
    });
  }

  Future<void> fetchUserData() async {
    final uid = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
          isLoading = false;
        });
      }
    }
  }

  void _showEditBioDialog(BuildContext context) {
    // Only allow editing if viewing own profile
    if (widget.userId != null &&
        widget.userId != FirebaseAuth.instance.currentUser?.uid) {
      return;
    }

    final TextEditingController bioController = TextEditingController(
      text: userData?['bio'] ?? '',
    );

    const int maxBioLength = 140;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Edit Bio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: bioController,
                    maxLines: 4,
                    maxLength: maxBioLength,
                    decoration: InputDecoration(
                      hintText: 'Write something about yourself...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      counterText: '${bioController.text.length}/$maxBioLength',
                    ),
                    onChanged: (text) {
                      setState(() {}); // Update character count
                    },
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tip: Keep it short and engaging!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              actions: [
                // Adaptive button layout based on text length
                bioController.text.length <= 50
                    ? Column(
                        children: [
                          // When text is short, stack buttons vertically like bases
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  bioController.text.length <= maxBioLength
                                      ? () async {
                                          await _updateBio(
                                              bioController.text.trim());
                                          Navigator.of(context).pop();
                                        }
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Save',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: BorderSide(color: Colors.grey[400]!),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // When text is longer, use horizontal layout
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: bioController.text.length <= maxBioLength
                                ? () async {
                                    await _updateBio(bioController.text.trim());
                                    Navigator.of(context).pop();
                                  }
                                : null,
                            child: const Text('Save'),
                          ),
                        ],
                      ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateBio(String newBio) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'bio': newBio});

        setState(() {
          userData = {...userData ?? {}, 'bio': newBio};
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bio updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update bio. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return _buildUnauthenticatedProfile();
    }

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return _buildAuthenticatedProfile();
  }

  Widget _buildUnauthenticatedProfile() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile icon placeholder
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[600]
                        : Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  'Join the Community',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Sign in or create an account to access your profile and all features',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _showLoginRegisterModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB700FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign In / Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Continue as guest
                TextButton(
                  onPressed: () {
                    // Just close the modal or navigate back
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Continue Browsing',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLoginRegisterModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[600]
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Text(
                'Join the Community',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Sign in or create an account to access all features',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 30),
              
              // Login/Register Form
              Expanded(
                child: _LoginRegisterForm(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuthenticatedProfile() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side icons
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LiveScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.live_tv,
                            color: Theme.of(context).iconTheme.color ??
                                Colors.black,
                            size: 23),
                        const SizedBox(height: 2),
                        Text(
                          'Live',
                          style: TextStyle(
                            fontSize: 8,
                            color:
                                Theme.of(context).textTheme.bodySmall?.color ??
                                    Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LifestyleScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.spa,
                            color: Theme.of(context).iconTheme.color ??
                                Colors.black,
                            size: 23),
                        const SizedBox(height: 2),
                        Text(
                          'Lifestyle',
                          style: TextStyle(
                            fontSize: 8,
                            color:
                                Theme.of(context).textTheme.bodySmall?.color ??
                                    Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GroupsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.groups,
                            color: Theme.of(context).iconTheme.color ??
                                Colors.black,
                            size: 23),
                        const SizedBox(height: 2),
                        Text(
                          'Groups',
                          style: TextStyle(
                            fontSize: 8,
                            color:
                                Theme.of(context).textTheme.bodySmall?.color ??
                                    Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Right side - Payment, Chat, and Settings buttons
            Row(
              children: [
                // Payment button
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.payment,
                    color: Theme.of(context).iconTheme.color ?? Colors.black,
                    size: 24,
                  ),
                  tooltip: 'Payment',
                ),
                // Chat button
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MessengerScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.chat,
                    color: Theme.of(context).iconTheme.color ?? Colors.black,
                    size: 24,
                  ),
                  tooltip: 'Chat',
                ),
                // Settings button
                IconButton(
                  onPressed: () {
                    _showDropUpMenu(context);
                  },
                  icon: Icon(
                    Icons.settings,
                    color: Theme.of(context).iconTheme.color ?? Colors.black,
                    size: 24,
                  ),
                  tooltip: 'Settings',
                ),
              ],
            ),
          ],
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Profile Image
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Name with verification badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          ((userData?['firstName'] ?? '') +
                                      (userData?['lastName'] != null &&
                                              userData?['lastName'] != ''
                                          ? ' ' + userData!['lastName']
                                          : ''))
                                  .trim()
                                  .isNotEmpty
                              ? ((userData?['firstName'] ?? '') +
                                      (userData?['lastName'] != null &&
                                              userData?['lastName'] != ''
                                          ? ' ' + userData!['lastName']
                                          : ''))
                                  .trim()
                              : 'No Name',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(1),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: <Color>[
                                Colors.purple,
                                Colors.pink,
                                Colors.orange,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: <Color>[
                                    Colors.purple,
                                    Colors.pink,
                                    Colors.orange,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: const Icon(
                                Icons.verified,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Username
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '@${userData?['username'] ?? 'user'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.7) ??
                                Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if ((widget.userId ??
                                FirebaseAuth.instance.currentUser?.uid) !=
                            FirebaseAuth.instance.currentUser?.uid) ...[
                          ElevatedButton(
                            onPressed: handleFollowUnfollow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isFollowing ? Colors.white : Colors.blue,
                              foregroundColor:
                                  isFollowing ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                                side: isFollowing
                                    ? BorderSide(color: Colors.grey[300]!)
                                    : BorderSide.none,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (!isFollowing) ...<Widget>[
                                  const Icon(Icons.add, size: 18),
                                  const SizedBox(width: 4),
                                ],
                                Text(isFollowing ? 'Following' : 'Follow'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: const Text('Message'),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _SmallStatItem(
                          value: (userData?['following'] is List)
                              ? (userData!['following'] as List)
                                  .length
                                  .toString()
                              : '0',
                          label: 'Following',
                        ),
                        _SmallStatItem(
                          value: (userData?['followers'] is List)
                              ? (userData!['followers'] as List)
                                  .length
                                  .toString()
                              : '0',
                          label: 'Followers',
                        ),
                        const _SmallStatItem(value: '1.2K', label: 'Likes'),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Location and link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NearbyMapScreen(
                                  userId: widget.userId,
                                  currentLocation: userData?['location'] !=
                                              null &&
                                          userData?['country'] != null
                                      ? '${userData!['location']}, ${userData!['country']}'
                                      : userData?['location'] ??
                                          userData!['country'],
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                userData?['location'] ??
                                    userData?['country'] ??
                                    'No Location',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.link, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        const Text(
                          'kartikkhorwal.com',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    // Bio
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GestureDetector(
                          onTap: () => _showEditBioDialog(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.transparent,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              userData?['bio']?.isNotEmpty == true
                                  ? userData!['bio']
                                  : (widget.userId ==
                                          FirebaseAuth.instance.currentUser?.uid
                                      ? 'Tap to add bio'
                                      : 'No bio available'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: userData?['bio']?.isNotEmpty == true
                                    ? (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[300]
                                        : Colors.grey[800])
                                    : Colors.grey[500],
                                fontStyle: userData?['bio']?.isNotEmpty == true
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                Container(
                  alignment: Alignment.center,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                    tabs: const <Widget>[
                      Tab(icon: Icon(Icons.person_outline), text: 'Profile'),
                      Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
                      Tab(icon: Icon(Icons.video_library), text: 'Reels'),
                      Tab(icon: Icon(Icons.shopping_bag), text: 'Shop'),
                    ],
                    indicatorColor: Colors.blue,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(fontSize: 12),
                    unselectedLabelStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            const ProfileTabContent(),
            const PostsGridContent(),
            const ReelsTabContent(),
            ChangeNotifierProvider<ShopCategoryData>(
              create: (BuildContext context) => ShopCategoryData(),
              builder: (BuildContext context, Widget? child) =>
                  const ShopTabContent(),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Classes - These should be at the end of the file, outside the main class

class _SmallStatItem extends StatelessWidget {
  const _SmallStatItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._widget);

  final Widget _widget;

  @override
  double get minExtent => 72.0;

  @override
  double get maxExtent => 72.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.white,
      child: _widget,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class ProfileTabContent extends StatelessWidget {
  const ProfileTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Profile Content',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class PostsGridContent extends StatelessWidget {
  const PostsGridContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Posts Content',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ReelsTabContent extends StatelessWidget {
  const ReelsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Reels Content',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ShopTabContent extends StatefulWidget {
  const ShopTabContent({super.key});

  @override
  State<ShopTabContent> createState() => _ShopTabContentState();
}

class _ShopTabContentState extends State<ShopTabContent>
    with TickerProviderStateMixin {
  late TabController _shopTabController;
  late List<Map<String, dynamic>> _categories;

  @override
  void initState() {
    super.initState();
    _categories = context.read<ShopCategoryData>().categories;
    _shopTabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _shopTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Modern styled category selection Tab Bar
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : const Color.fromARGB(26, 158, 158, 158),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: TabBar(
              controller: _shopTabController,
              isScrollable: true,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Theme.of(context)
                    .primaryColor
                    .withAlpha((255 * 0.1).toInt()),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey[600],
              dividerColor: Colors.transparent,
              tabs: _categories.map<Widget>((Map<String, dynamic> category) {
                return Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        category['icon'] as IconData,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category['name'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Content based on selected category
        Expanded(
          child: TabBarView(
            controller: _shopTabController,
            children: _categories
                .map<Widget>(
                    (Map<String, dynamic> categoryData) => CategoryViewContent(
                          category: categoryData,
                        ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class CategoryViewContent extends StatelessWidget {
  const CategoryViewContent({
    required this.category,
    super.key,
  });

  final Map<String, dynamic> category;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Showing items for: ${category['name']}',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Login/Register Form Widget
class _LoginRegisterForm extends StatefulWidget {
  @override
  State<_LoginRegisterForm> createState() => _LoginRegisterFormState();
}

class _LoginRegisterFormState extends State<_LoginRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await _login();
      } else {
        await _register();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _login() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully logged in!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _register() async {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    
    if (credential.user != null && _nameController.text.isNotEmpty) {
      await credential.user!.updateDisplayName(_nameController.text.trim());
    }
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully registered!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Name field (only for register)
            if (!_isLogin) ...[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (!_isLogin && (value == null || value.isEmpty)) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
            
            // Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB700FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isLogin ? 'Sign In' : 'Sign Up',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Toggle between login and register
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                  _formKey.currentState?.reset();
                });
              },
              child: Text(
                _isLogin
                    ? 'Don\'t have an account? Sign Up'
                    : 'Already have an account? Sign In',
                style: TextStyle(
                  color: const Color(0xFFB700FF),
                  fontSize: 14,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Forgot password
            if (_isLogin)
              TextButton(
                onPressed: () async {
                  if (_emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter your email first'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: _emailController.text.trim(),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password reset email sent!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
