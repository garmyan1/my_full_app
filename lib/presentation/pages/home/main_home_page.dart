import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../../screens/profile/profile_screen.dart';
import '../../../screens/ai/ai_chat_screen.dart';
import '../../../screens/tiktok_live/tiktok_live_screen.dart';

/// Data model for an action option in the add modal.
class _AddActionOption {
  final IconData icon;
  final String title;
  final String description;

  _AddActionOption({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Widget> _pages = [
    const _InstagramStyleHomeContent(),
    const AIChatScreen(),
    const SimpleNotificationsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    // Check if user is authenticated for restricted tabs
    if (_auth.currentUser == null && index != 0) {
      // Show TikTok-style login modal for unauthenticated users
      _showTikTokStyleLoginModal(context);
      return;
    }

    if (index == 2) {
      _showAddOptionsModal(context);
    } else {
      int pageIndex = index;
      if (index > 2) pageIndex = index - 1;
      setState(() {
        _selectedIndex = pageIndex;
      });
    }
  }

  void _showTikTokStyleLoginModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[600]
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // TikTok-style header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Login to Continue',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to access all features',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Login form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _TikTokLoginForm(),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showAddOptionsModal(BuildContext context) {
    // Check if user is authenticated
    if (_auth.currentUser == null) {
      _showTikTokStyleLoginModal(context);
      return;
    }

    final List<_AddActionOption> options = <_AddActionOption>[
      _AddActionOption(
        icon: Icons.folder_open,
        title: 'Add Project',
        description: 'Start a new creative project',
      ),
      _AddActionOption(
        icon: Icons.image,
        title: 'Add Image',
        description: 'Upload an image from your gallery',
      ),
      _AddActionOption(
        icon: Icons.videocam,
        title: 'Add Video',
        description: 'Record or upload a video clip',
      ),
      _AddActionOption(
        icon: Icons.group_add,
        title: 'Create Group',
        description: 'Start a new collaborative group',
      ),
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[600]
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Column(
                children: options.map<Widget>((_AddActionOption option) {
                  return _AddOptionTile(
                    option: option,
                    onTap: () {
                      Navigator.pop(bc);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${option.title} tapped!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        height: 75,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
              width: 0.5,
            ),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _TikTokNavItem(
              icon: Icons.home,
              label: 'Home',
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            _AINavItem(
              label: 'AI Chat',
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            _CenterAddButton(
              onTap: () => _onItemTapped(2),
            ),
            _TikTokNavItem(
              icon: Icons.live_tv,
              label: 'Live',
              selected: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TikTokLiveScreen(),
                  ),
                );
              },
            ),
            Stack(
              children: <Widget>[
                _TikTokNavItem(
                  icon: Icons.notifications,
                  label: 'Notifications',
                  selected: _selectedIndex == 2,
                  onTap: () => _onItemTapped(3),
                ),
                if (_auth.currentUser != null)
                  Positioned(
                    right: 10,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            _TikTokNavItem(
              icon: Icons.person,
              label: 'Profile',
              selected: _selectedIndex == 3,
              onTap: () => _onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _TikTokNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TikTokNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55,
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              color: selected
                  ? Colors.deepPurple
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              size: selected ? 24 : 22,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected
                      ? Colors.deepPurple
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AINavItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AINavItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55,
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: selected ? 24 : 22,
              height: selected ? 24 : 22,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: selected
                      ? [Colors.deepPurple, Colors.purple]
                      : (isDark
                          ? [Colors.grey.shade600, Colors.grey.shade700]
                          : [Colors.grey.shade600, Colors.grey.shade500]),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(selected ? 12 : 11),
              ),
              child: Center(
                child: Text(
                  'AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: selected ? 10 : 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected
                      ? Colors.deepPurple
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterAddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CenterAddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 28,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              left: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            Container(
              width: 34,
              height: 28,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.add,
                color: isDark ? Colors.white : Colors.black,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tile widget for displaying an add option in the bottom sheet.
class _AddOptionTile extends StatelessWidget {
  final _AddActionOption option;
  final VoidCallback onTap;

  const _AddOptionTile({
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade200,
            width: 0.8,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Icon(
              option.icon,
              size: 24,
              color: isDark ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    option.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey.shade400 : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _InstagramStyleHomeContent extends StatefulWidget {
  const _InstagramStyleHomeContent();

  @override
  State<_InstagramStyleHomeContent> createState() => _InstagramStyleHomeContentState();
}

class _InstagramStyleHomeContentState extends State<_InstagramStyleHomeContent> {
  // Add state variable to track which secondary tab is active
  int _activeSecondaryTab = 0; // 0 for World, 1 for Business, 2 for Cities
  // Add state variable to track which sub-tab is active within each category
  int _activeSubTab = 0; // 0 for first sub-tab, 1 for second, etc.

  // Format views count with K and M suffixes
  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    } else {
      return views.toString();
    }
  }

  // Build TikTok-style navigation item
  Widget _buildTikTokNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    final Color activeColor = isDark ? Colors.white : Colors.black;
    final Color inactiveColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : inactiveColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }

  // Build second tab bar based on selected top icon
  Widget _buildSecondTabBar(bool isDark) {
    if (_activeSecondaryTab == -1) {
      // Live tabs
      return DefaultTabController(
        length: 6,
        child: TabBar(
          tabs: const [
            Tab(text: 'Live Now'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Featured'),
            Tab(text: 'Gaming'),
            Tab(text: 'Music'),
            Tab(text: 'Sports'),
          ],
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          labelColor: isDark ? Colors.white : Colors.black,
          unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          indicator: const _TikTokUnderlineIndicator(),
          indicatorSize: TabBarIndicatorSize.label,
          overlayColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          onTap: (index) {
            setState(() {
              _activeSubTab = index;
            });
          },
        ),
      );
    } else if (_activeSecondaryTab == 0) {
      // World tabs
      return DefaultTabController(
        length: 6,
        child: TabBar(
          tabs: const [
            Tab(text: 'Trending'),
            Tab(text: 'Popular'),
            Tab(text: 'Latest'),
            Tab(text: 'Travel'),
            Tab(text: 'Food'),
            Tab(text: 'Art'),
          ],
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          labelColor: isDark ? Colors.white : Colors.black,
          unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          indicator: const _TikTokUnderlineIndicator(),
          indicatorSize: TabBarIndicatorSize.label,
          overlayColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          onTap: (index) {
            setState(() {
              _activeSubTab = index;
            });
          },
        ),
      );
    } else if (_activeSecondaryTab == 1) {
      // Business tabs
      return DefaultTabController(
        length: 6,
        child: TabBar(
          tabs: const [
            Tab(text: 'Startups'),
            Tab(text: 'Corporate'),
            Tab(text: 'Finance'),
            Tab(text: 'Marketing'),
            Tab(text: 'HR'),
            Tab(text: 'Consulting'),
          ],
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          labelColor: isDark ? Colors.white : Colors.black,
          unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          indicator: const _TikTokUnderlineIndicator(),
          indicatorSize: TabBarIndicatorSize.label,
          overlayColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          onTap: (index) {
            setState(() {
              _activeSubTab = index;
            });
          },
        ),
      );
    } else {
      // Cities tabs
      return DefaultTabController(
        length: 6,
        child: TabBar(
          tabs: const [
            Tab(text: 'Architecture'),
            Tab(text: 'Culture'),
            Tab(text: 'Nightlife'),
            Tab(text: 'Transport'),
            Tab(text: 'History'),
            Tab(text: 'Modern'),
          ],
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          labelColor: isDark ? Colors.white : Colors.black,
          unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          indicator: const _TikTokUnderlineIndicator(),
          indicatorSize: TabBarIndicatorSize.label,
          overlayColor: MaterialStateProperty.resolveWith((states) => Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          onTap: (index) {
            setState(() {
              _activeSubTab = index;
            });
          },
        ),
      );
    }
  }

  // Build image thumbnail for grid
  Widget _buildImageThumbnail(PostItem post) {
    return Stack(
      fit: StackFit.expand,
        children: [
        Image.asset(
          post.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildColoredThumbnail(post.username);
          },
        ),
        // Instagram-style post overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username
                Text(
                  post.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Likes and views
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 10,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      post.likes,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.visibility,
                      color: Colors.white,
                      size: 10,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      _formatViews(post.views),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Location indicator at top
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
                child: Row(
              mainAxisSize: MainAxisSize.min,
                  children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 10,
                ),
                const SizedBox(width: 2),
                Text(
                  post.location.split(',')[0], // Show only city name
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
        ),
        // Video indicator overlay for video posts
        if (post.isVideo)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  // Build colored thumbnail as fallback
  Widget _buildColoredThumbnail(String username) {
    // Generate a consistent color based on username
    final colors = [
      Colors.blue[400]!,
      Colors.green[400]!,
      Colors.orange[400]!,
      Colors.purple[400]!,
      Colors.red[400]!,
      Colors.teal[400]!,
      Colors.indigo[400]!,
      Colors.pink[400]!,
      Colors.amber[400]!,
      Colors.cyan[400]!,
    ];
    
    final colorIndex = username.hashCode % colors.length;
    final color = colors[colorIndex];
    
    return Container(
      color: color,
      child: Center(
        child: Icon(
          Icons.image,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

    // Build Instagram-style grid layout
  Widget _buildInstagramStyleGrid() {
    final List<PostItem> posts = _getPostsForCurrentTab();
    if (posts.isEmpty) return const SizedBox.shrink();
    
    List<Widget> gridRows = [];
    int currentIndex = 0;
    
    // ALWAYS show first grid row (2 small + 2 small + 1 big) for ALL pages
    if (posts.length >= 5) {
      gridRows.add(
        // First row: 2 small posts on left, 2 small posts in center, 1 big post on right
        Row(
          children: [
            // Left side: 2 small posts
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildGridPost(posts[currentIndex++], isSmall: true),
                  _buildGridPost(posts[currentIndex++], isSmall: true),
                ],
              ),
            ),
            
            // Center: 2 small posts
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildGridPost(posts[currentIndex++], isSmall: true),
                  _buildGridPost(posts[currentIndex++], isSmall: true),
                ],
              ),
            ),
            
            // Right side: 1 big post
            Expanded(
              flex: 2,
              child: _buildGridPost(posts[currentIndex++], isSmall: false),
            ),
          ],
        ),
      );
    }
    
    // ALWAYS show second grid row (3 large posts) for ALL pages
    if (posts.length >= 8) {
      gridRows.add(
        // Second row: 3 large posts
        Row(
          children: [
            Expanded(
              child: _buildGridPost(posts[currentIndex++], isSmall: false),
            ),
            Expanded(
              child: _buildGridPost(posts[currentIndex++], isSmall: false),
            ),
            Expanded(
              child: _buildGridPost(posts[currentIndex++], isSmall: false),
            ),
          ],
        ),
      );
    }
    
    // ALWAYS show third grid row (1 big + 2 small + 2 small) for ALL pages
    if (posts.length >= 13) {
      gridRows.add(
        // Third row: Large post on left, 2 small posts in center, 2 small posts on right
        Row(
          children: [
            // Left side: 1 big post
            Expanded(
              flex: 2,
              child: _buildGridPost(posts[currentIndex++], isSmall: false),
            ),
            
            // Center: 2 small posts
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildGridPost(posts[currentIndex++], isSmall: true),
                  _buildGridPost(posts[currentIndex++], isSmall: true),
                ],
              ),
            ),
            
            // Right side: 2 small posts
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildGridPost(posts[currentIndex++], isSmall: true),
                  _buildGridPost(posts[currentIndex++], isSmall: true),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    // Continue with more grid rows following the same pattern for ALL pages
    while (currentIndex + 4 < posts.length) {
      gridRows.add(
        // Additional rows: 2 small posts on left, 2 small posts in center, 1 big post on right
        Row(
          children: [
            // Left side: 2 small posts
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildGridPost(posts[currentIndex++], isSmall: true),
                  _buildGridPost(posts[currentIndex++], isSmall: true),
                ],
              ),
            ),
            
            // Center: 2 small posts
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildGridPost(posts[currentIndex++], isSmall: true),
                  _buildGridPost(posts[currentIndex++], isSmall: true),
                ],
              ),
            ),
            
            // Right side: 1 big post
            Expanded(
              flex: 2,
              child: _buildGridPost(posts[currentIndex++], isSmall: false),
            ),
          ],
        ),
      );
    }
    
    // Handle remaining posts (less than 5) in a standard grid for ALL pages
    if (currentIndex < posts.length) {
      List<PostItem> remainingPosts = posts.sublist(currentIndex);
      gridRows.add(_buildRemainingPosts(remainingPosts));
    }
    
    return Column(children: gridRows);
  }

  // Build individual grid post
  Widget _buildGridPost(PostItem post, {required bool isSmall}) {
    return GestureDetector(
      onTap: () => _showPostDetail(post),
      child: Container(
        height: isSmall ? 120 : 240,
        decoration: BoxDecoration(
          color: Colors.grey[300],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image or video
            post.isVideo && post.videoUrl != null
                ? _buildVideoThumbnail(post)
                : _buildImageThumbnail(post),
            
            // Video indicator for video posts
            if (post.isVideo)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Build remaining posts in standard grid
  Widget _buildRemainingPosts(List<PostItem> posts) {
    if (posts.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(top: 2),
             child: GridView.builder(
         shrinkWrap: true,
         physics: const NeverScrollableScrollPhysics(),
         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
           crossAxisCount: 3,
           crossAxisSpacing: 0,
           mainAxisSpacing: 0,
           childAspectRatio: 1,
         ),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return _buildGridPost(posts[index], isSmall: true);
        },
      ),
    );
  }

  // Get posts based on current tab - ensure ALL tabs have enough posts for complete grid structure
  List<PostItem> _getPostsForCurrentTab() {
    List<PostItem> posts;
    
    if (_activeSecondaryTab == -1) {
      // Live tab - use live posts with sub-categories
      posts = _getLivePosts();
      // Filter based on sub-tab if needed
      if (_activeSubTab == 0) {
        // Live Now - keep all live posts for now
      } else if (_activeSubTab == 1) {
        // Upcoming - keep all live posts for now
      } else if (_activeSubTab == 2) {
        // Featured - keep all live posts for now
      } else if (_activeSubTab == 3) {
        // Gaming - keep all live posts for now
      } else if (_activeSubTab == 4) {
        // Music - keep all live posts for now
      } else if (_activeSubTab == 5) {
        // Sports - keep all live posts for now
      }
    } else if (_activeSecondaryTab == 0) {
      // World tab - use sub-tabs for different world content
      if (_activeSubTab == 0) {
        posts = _trendingPosts; // Trending
      } else if (_activeSubTab == 1) {
        posts = [..._trendingPosts, ..._recentPosts]; // Popular
      } else if (_activeSubTab == 2) {
        posts = _recentPosts; // Latest
      } else if (_activeSubTab == 3) {
        posts = _getTravelPosts(); // Travel
      } else if (_activeSubTab == 4) {
        posts = _getFoodPosts(); // Food
      } else if (_activeSubTab == 5) {
        posts = _getArtPosts(); // Art
      } else {
        posts = _trendingPosts;
      }
    } else if (_activeSecondaryTab == 1) {
      // Business tab - use business posts with sub-categories
      posts = _getBusinessPosts();
      // Filter based on sub-tab if needed
      if (_activeSubTab == 0) {
        // Startups - keep all business posts for now
      } else if (_activeSubTab == 1) {
        // Corporate - keep all business posts for now
      } else if (_activeSubTab == 2) {
        // Finance - keep all business posts for now
      } else if (_activeSubTab == 3) {
        // Marketing - keep all business posts for now
      } else if (_activeSubTab == 4) {
        // HR - keep all business posts for now
      } else if (_activeSubTab == 5) {
        // Consulting - keep all business posts for now
      }
    } else if (_activeSecondaryTab == 2) {
      // Cities tab - use cities posts with sub-categories
      posts = _getCitiesPosts();
      // Filter based on sub-tab if needed
      if (_activeSubTab == 0) {
        // Architecture - keep all cities posts for now
      } else if (_activeSubTab == 1) {
        // Culture - keep all cities posts for now
      } else if (_activeSubTab == 2) {
        // Nightlife - keep all cities posts for now
      } else if (_activeSubTab == 3) {
        // Transport - keep all cities posts for now
      } else if (_activeSubTab == 4) {
        // History - keep all cities posts for now
      } else if (_activeSubTab == 5) {
        // Modern - keep all cities posts for now
      }
    } else if (_activeSecondaryTab == 3) {
      // Trending tab - trending posts
      posts = _trendingPosts;
    } else if (_activeSecondaryTab == 4) {
      // Popular tab - combined content
      posts = [..._trendingPosts, ..._recentPosts];
    } else if (_activeSecondaryTab == 5) {
      // Latest tab - recent posts
      posts = _recentPosts;
    } else if (_activeSecondaryTab == 6) {
      // Travel tab
      posts = _getTravelPosts();
    } else if (_activeSecondaryTab == 7) {
      // Food tab
      posts = _getFoodPosts();
    } else if (_activeSecondaryTab == 8) {
      // Art tab
      posts = _getArtPosts();
    } else if (_activeSecondaryTab == 9) {
      // Sports tab
      posts = _getSportsPosts();
    } else if (_activeSecondaryTab == 10) {
      // Music tab
      posts = _getMusicPosts();
    } else if (_activeSecondaryTab == 11) {
      // Tech tab
      posts = _getTechPosts();
    } else {
      // Default fallback
      posts = _recentPosts;
    }
    
    // Ensure minimum posts for complete grid structure on ALL pages
    if (posts.length < 13) {
      // If any tab has less than 13 posts, combine with other posts to ensure complete grid
      if (_activeSecondaryTab == -1) {
        // Live tab - combine with trending posts if needed
        posts = [...posts, ..._trendingPosts];
      } else if (_activeSecondaryTab == 0) {
        // World tab - combine with recent posts if needed
        posts = [...posts, ..._recentPosts];
      } else if (_activeSecondaryTab == 1) {
        // Business tab - combine with trending posts if needed
        posts = [...posts, ..._trendingPosts];
      } else if (_activeSecondaryTab == 2) {
        // Cities tab - combine with trending posts if needed
        posts = [...posts, ..._trendingPosts];
      } else if (_activeSecondaryTab == 3 || _activeSecondaryTab == 4) {
        // Trending/Explore tabs - combine with recent posts if needed
        posts = [...posts, ..._recentPosts];
      } else if (_activeSecondaryTab == 5) {
        // Latest tab - combine with trending posts if needed
        posts = [...posts, ..._trendingPosts];
      } else if (_activeSecondaryTab >= 6 && _activeSecondaryTab <= 11) {
        // New category tabs - combine with trending and recent posts if needed
        posts = [...posts, ..._trendingPosts, ..._recentPosts];
      }
    }
    
    return posts;
  }

  // Category-specific post methods
  List<PostItem> _getTravelPosts() {
    return [
      PostItem(
        username: 'travel_explorer',
        location: 'Santorini, Greece',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '3.1k',
        caption: 'White buildings against the blue sea 🏛️ #santorini #greece',
        timeAgo: '1 hour ago',
        views: 18700,
      ),
      PostItem(
        username: 'wanderlust_heart',
        location: 'Machu Picchu, Peru',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '4.2k',
        caption: 'Ancient ruins in the clouds 🏔️ #machupicchu #peru',
        timeAgo: '3 hours ago',
        views: 25600,
      ),
      PostItem(
        username: 'nomad_life',
        location: 'Kyoto, Japan',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '2.8k',
        caption: 'Cherry blossoms in full bloom 🌸 #kyoto #japan',
        timeAgo: '6 hours ago',
        views: 19800,
      ),
      PostItem(
        username: 'adventure_seeker',
        location: 'Queenstown, New Zealand',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '3.5k',
        caption: 'Bungee jumping over the Kawarau Gorge! 🪂 #adventure #nz',
        timeAgo: '1 day ago',
        views: 28900,
        isVideo: true,
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      ),
      PostItem(
        username: 'desert_rider',
        location: 'Riyadh, Saudi Arabia',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '1.2k',
        caption: 'Dunes and endless skies 🐪 #desert #travel',
        timeAgo: '2 days ago',
        views: 15600,
      ),
    ];
  }

  List<PostItem> _getFoodPosts() {
    return [
      PostItem(
        username: 'foodie_adventures',
        location: 'Tokyo, Japan',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '1.8k',
        caption: 'Best ramen in Shibuya! 🍜 #japan #food',
        timeAgo: '2 hours ago',
        views: 12850,
      ),
      PostItem(
        username: 'street_food',
        location: 'Bangkok, Thailand',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '2.0k',
        caption: 'Pad Thai on the go 🍤 #streetfood #thailand',
        timeAgo: '4 hours ago',
        views: 15800,
      ),
      PostItem(
        username: 'chef_creative',
        location: 'Paris, France',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '3.3k',
        caption: 'Homemade croissants 🥐 #paris #baking',
        timeAgo: '8 hours ago',
        views: 22400,
      ),
      PostItem(
        username: 'wine_connoisseur',
        location: 'Bordeaux, France',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '1.6k',
        caption: 'Wine tasting in the vineyards 🍷 #wine #france',
        timeAgo: '1 day ago',
        views: 13800,
      ),
      PostItem(
        username: 'coffee_daily',
        location: 'Rome, Italy',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '640',
        caption: 'Morning espresso, cobblestone streets ☕ #rome #cafe',
        timeAgo: '2 days ago',
        views: 5430,
      ),
    ];
  }

  List<PostItem> _getArtPosts() {
    return [
      PostItem(
        username: 'art_creator',
        location: 'New York, USA',
        imageUrl: 'assets/USA/amazon.png',
        likes: '3.2k',
        caption: 'Street art in Brooklyn 🎨 #art #nyc',
        timeAgo: '1 day ago',
        views: 25680,
      ),
      PostItem(
        username: 'artsy_me',
        location: 'Paris, France',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '1.4k',
        caption: 'Palette and pastels 🎨 #painting #paris',
        timeAgo: '3 hours ago',
        views: 11200,
      ),
      PostItem(
        username: 'creative_soul',
        location: 'Berlin, Germany',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '2.1k',
        caption: 'Graffiti art in Kreuzberg 🎭 #berlin #streetart',
        timeAgo: '6 hours ago',
        views: 15600,
      ),
      PostItem(
        username: 'design_daily',
        location: 'Berlin, Germany',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '420',
        caption: 'Minimal desks, maximal focus 💻 #workspace #design',
        timeAgo: '1 day ago',
        views: 3200,
      ),
      PostItem(
        username: 'fashion_ista',
        location: 'Milan, Italy',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '5.7k',
        caption: 'Fashion Week street style 👗 #milan #fashion',
        timeAgo: '2 days ago',
        views: 48700,
      ),
    ];
  }

  List<PostItem> _getSportsPosts() {
    return [
      PostItem(
        username: 'sports_fan',
        location: 'Barcelona, Spain',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '4.2k',
        caption: 'Camp Nou match day! ⚽ #barcelona #football',
        timeAgo: '1 day ago',
        views: 35600,
      ),
      PostItem(
        username: 'fit_life',
        location: 'Los Angeles, USA',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '860',
        caption: 'Sunrise run at the pier 🏃 #fitness #running',
        timeAgo: '2 hours ago',
        views: 7200,
      ),
      PostItem(
        username: 'yoga_master',
        location: 'Rishikesh, India',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '2.3k',
        caption: 'Sunrise yoga by the Ganges 🧘‍♀️ #yoga #india',
        timeAgo: '1 day ago',
        views: 19400,
      ),
      PostItem(
        username: 'skate_vibes',
        location: 'Barcelona, Spain',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '3.3k',
        caption: 'Ollies by the beach 🛹 #skateboarding #barcelona',
        timeAgo: '2 days ago',
        views: 26700,
        isVideo: true,
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      ),
      PostItem(
        username: 'mountain_go',
        location: 'Zermatt, Switzerland',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '2.1k',
        caption: 'Misty trails under the Matterhorn 🏔️ #hike #alps',
        timeAgo: '3 days ago',
        views: 18900,
      ),
    ];
  }

  List<PostItem> _getLivePosts() {
    return [
      PostItem(
        username: 'live_gamer',
        location: 'Twitch HQ, USA',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '15.2k',
        caption: 'LIVE: Epic gaming session 🎮 #gaming #live #twitch',
        timeAgo: 'LIVE NOW',
        views: 125000,
        isVideo: true,
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      ),
      PostItem(
        username: 'music_live',
        location: 'Coachella, USA',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '8.9k',
        caption: 'LIVE: Festival performance 🎵 #music #live #coachella',
        timeAgo: 'LIVE NOW',
        views: 89000,
        isVideo: true,
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      ),
      PostItem(
        username: 'sports_live',
        location: 'Stadium, UK',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '12.3k',
        caption: 'LIVE: Championship match ⚽ #sports #live #football',
        timeAgo: 'LIVE NOW',
        views: 156000,
        isVideo: true,
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      ),
      PostItem(
        username: 'cooking_live',
        location: 'Kitchen Studio, France',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '5.7k',
        caption: 'LIVE: Cooking masterclass 👨‍🍳 #cooking #live #french',
        timeAgo: 'LIVE NOW',
        views: 67000,
        isVideo: true,
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      ),
      PostItem(
        username: 'travel_live',
        location: 'Tokyo, Japan',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '7.1k',
        caption: 'LIVE: Exploring Shibuya 🌃 #travel #live #tokyo',
        timeAgo: 'LIVE NOW',
        views: 78000,
        isVideo: true,
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      ),
      PostItem(
        username: 'fitness_live',
        location: 'Gym Studio, USA',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '4.2k',
        caption: 'LIVE: HIIT workout session 💪 #fitness #live #workout',
        timeAgo: 'LIVE NOW',
        views: 52000,
        isVideo: true,
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      ),
      PostItem(
        username: 'art_live',
        location: 'Art Studio, Italy',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '3.8k',
        caption: 'LIVE: Painting session 🎨 #art #live #painting',
        timeAgo: 'LIVE NOW',
        views: 45000,
        isVideo: true,
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      ),
      PostItem(
        username: 'dance_live',
        location: 'Dance Studio, Brazil',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '6.5k',
        caption: 'LIVE: Samba dance class 💃 #dance #live #brazil',
        timeAgo: 'LIVE NOW',
        views: 72000,
        isVideo: true,
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      ),
      PostItem(
        username: 'news_live',
        location: 'News Studio, USA',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '9.1k',
        caption: 'LIVE: Breaking news coverage 📰 #news #live #breaking',
        timeAgo: 'LIVE NOW',
        views: 98000,
        isVideo: true,
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_1mb.mp4',
      ),
      PostItem(
        username: 'comedy_live',
        location: 'Comedy Club, UK',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '4.7k',
        caption: 'LIVE: Stand-up comedy night 😂 #comedy #live #standup',
        timeAgo: 'LIVE NOW',
        views: 56000,
        isVideo: true,
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      ),
      PostItem(
        username: 'education_live',
        location: 'University, Canada',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '2.9k',
        caption: 'LIVE: Online lecture 📚 #education #live #lecture',
        timeAgo: 'LIVE NOW',
        views: 34000,
        isVideo: true,
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      ),
      PostItem(
        username: 'fashion_live',
        location: 'Fashion Week, France',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '8.3k',
        caption: 'LIVE: Runway show 👗 #fashion #live #runway',
        timeAgo: 'LIVE NOW',
        views: 92000,
        isVideo: true,
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      ),
      PostItem(
        username: 'science_live',
        location: 'Lab, Germany',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '3.2k',
        caption: 'LIVE: Science experiment 🔬 #science #live #experiment',
        timeAgo: 'LIVE NOW',
        views: 38000,
        isVideo: true,
        videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      ),
    ];
  }

  List<PostItem> _getMusicPosts() {
    return [
      PostItem(
        username: 'music_lover',
        location: 'Nashville, USA',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '1.9k',
        caption: 'Country music and cowboy boots 🎸 #nashville #music',
        timeAgo: '1 day ago',
        views: 16500,
      ),
      PostItem(
        username: 'dj_vibes',
        location: 'Ibiza, Spain',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '3.8k',
        caption: 'Sunset DJ set at the beach 🎧 #ibiza #electronic',
        timeAgo: '4 hours ago',
        views: 28900,
      ),
      PostItem(
        username: 'classical_music',
        location: 'Vienna, Austria',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '1.2k',
        caption: 'Vienna Philharmonic performance 🎻 #classical #vienna',
        timeAgo: '1 day ago',
        views: 9800,
      ),
      PostItem(
        username: 'rock_star',
        location: 'London, UK',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '2.7k',
        caption: 'Rock concert at Wembley 🎤 #rock #london',
        timeAgo: '2 days ago',
        views: 20300,
      ),
      PostItem(
        username: 'jazz_nights',
        location: 'New Orleans, USA',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '1.5k',
        caption: 'Jazz in the French Quarter 🎷 #jazz #neworleans',
        timeAgo: '3 days ago',
        views: 12300,
      ),
    ];
  }

  List<PostItem> _getTechPosts() {
    return [
      PostItem(
        username: 'tech_notes',
        location: 'San Francisco, USA',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '3.8k',
        caption: 'Refactoring day, coffee mandatory ☕ #devlife #coding',
        timeAgo: '2 hours ago',
        views: 28900,
      ),
      PostItem(
        username: 'tech_geek',
        location: 'Silicon Valley, USA',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '3.1k',
        caption: 'Startup life and coffee ☕ #tech #startup',
        timeAgo: '1 day ago',
        views: 27800,
      ),
      PostItem(
        username: 'ai_researcher',
        location: 'Cambridge, UK',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '2.4k',
        caption: 'Working on the next breakthrough 🤖 #ai #research',
        timeAgo: '6 hours ago',
        views: 18700,
      ),
      PostItem(
        username: 'gaming_pro',
        location: 'Seoul, Korea',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '4.6k',
        caption: 'Esports tournament finals 🎮 #gaming #esports',
        timeAgo: '1 day ago',
        views: 34200,
      ),
      PostItem(
        username: 'cyber_security',
        location: 'Tel Aviv, Israel',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '1.8k',
        caption: 'Protecting digital frontiers 🔒 #cybersecurity #tech',
        timeAgo: '2 days ago',
        views: 15600,
      ),
    ];
  }

  List<PostItem> _getBusinessPosts() {
    return [
      PostItem(
        username: 'business_leader',
        location: 'New York, USA',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '4.2k',
        caption: 'Boardroom strategy session 📊 #business #strategy',
        timeAgo: '2 hours ago',
        views: 28900,
      ),
      PostItem(
        username: 'startup_founder',
        location: 'San Francisco, USA',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '3.8k',
        caption: 'Pitching to investors today 💼 #startup #pitch',
        timeAgo: '5 hours ago',
        views: 25600,
      ),
      PostItem(
        username: 'corporate_exec',
        location: 'London, UK',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '2.9k',
        caption: 'Global expansion meeting 🌍 #corporate #expansion',
        timeAgo: '1 day ago',
        views: 19800,
      ),
      PostItem(
        username: 'finance_pro',
        location: 'Singapore',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '3.1k',
        caption: 'Market analysis and trends 📈 #finance #markets',
        timeAgo: '2 days ago',
        views: 22400,
      ),
      PostItem(
        username: 'entrepreneur',
        location: 'Dubai, UAE',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '4.5k',
        caption: 'New venture launch 🚀 #entrepreneur #launch',
        timeAgo: '3 days ago',
        views: 31200,
      ),
      PostItem(
        username: 'consultant',
        location: 'Zurich, Switzerland',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '2.7k',
        caption: 'Client strategy workshop 💡 #consulting #strategy',
        timeAgo: '4 days ago',
        views: 18700,
      ),
      PostItem(
        username: 'tech_ceo',
        location: 'Seattle, USA',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '5.2k',
        caption: 'Product roadmap planning 🎯 #tech #product',
        timeAgo: '5 days ago',
        views: 35600,
      ),
      PostItem(
        username: 'investment_banker',
        location: 'Hong Kong',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '3.4k',
        caption: 'Deal closing celebration 🥂 #investment #deals',
        timeAgo: '1 week ago',
        views: 24300,
      ),
      PostItem(
        username: 'marketing_director',
        location: 'Amsterdam, Netherlands',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '2.8k',
        caption: 'Brand campaign launch 📢 #marketing #brand',
        timeAgo: '1 week ago',
        views: 19600,
      ),
      PostItem(
        username: 'hr_manager',
        location: 'Toronto, Canada',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '1.9k',
        caption: 'Team building workshop 👥 #hr #teamwork',
        timeAgo: '1 week ago',
        views: 13400,
      ),
    ];
  }

  List<PostItem> _getCitiesPosts() {
    return [
      PostItem(
        username: 'city_explorer',
        location: 'Tokyo, Japan',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '4.8k',
        caption: 'Shibuya crossing at night 🌃 #tokyo #citylife',
        timeAgo: '1 hour ago',
        views: 32400,
      ),
      PostItem(
        username: 'urban_photographer',
        location: 'Paris, France',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '3.9k',
        caption: 'Eiffel Tower sunset view 🌅 #paris #architecture',
        timeAgo: '3 hours ago',
        views: 26700,
      ),
      PostItem(
        username: 'street_artist',
        location: 'Berlin, Germany',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '2.6k',
        caption: 'Graffiti art in Kreuzberg 🎨 #berlin #streetart',
        timeAgo: '6 hours ago',
        views: 18900,
      ),
      PostItem(
        username: 'city_planner',
        location: 'Singapore',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '3.2k',
        caption: 'Modern urban development 🏗️ #singapore #urban',
        timeAgo: '1 day ago',
        views: 21800,
      ),
      PostItem(
        username: 'metro_rider',
        location: 'New York, USA',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '4.1k',
        caption: 'Subway rush hour vibes 🚇 #nyc #metro',
        timeAgo: '2 days ago',
        views: 28900,
      ),
      PostItem(
        username: 'rooftop_viewer',
        location: 'Bangkok, Thailand',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '3.7k',
        caption: 'Skyline from the rooftop bar 🍸 #bangkok #skyline',
        timeAgo: '3 days ago',
        views: 25400,
      ),
      PostItem(
        username: 'night_life',
        location: 'Las Vegas, USA',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '5.3k',
        caption: 'Strip lights and casinos 🎰 #vegas #nightlife',
        timeAgo: '4 days ago',
        views: 36700,
      ),
      PostItem(
        username: 'historic_walker',
        location: 'Rome, Italy',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '2.9k',
        caption: 'Ancient ruins in the city 🏛️ #rome #history',
        timeAgo: '5 days ago',
        views: 19800,
      ),
      PostItem(
        username: 'modern_architect',
        location: 'Dubai, UAE',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '4.6k',
        caption: 'Burj Khalifa architecture marvel 🏙️ #dubai #architecture',
        timeAgo: '1 week ago',
        views: 31200,
      ),
      PostItem(
        username: 'city_culture',
        location: 'Istanbul, Turkey',
        imageUrl: 'assets/images/onboarding/12.jpg',
        likes: '3.3k',
        caption: 'Bosphorus bridge connecting continents 🌉 #istanbul #culture',
        timeAgo: '1 week ago',
        views: 22300,
      ),
    ];
  }

  // Build video thumbnail for grid
  Widget _buildVideoThumbnail(PostItem post) {
    return Stack(
      fit: StackFit.expand,
      children: [
          Container(
          color: Colors.grey[300],
          child: Center(
            child: Icon(
              Icons.videocam,
              color: Colors.grey[600],
              size: 30,
            ),
          ),
        ),
        // Instagram-style post overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username
                Text(
                  post.username,
                  style: const TextStyle(
                      color: Colors.white,
                    fontSize: 10,
                      fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Likes and views
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 10,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      post.likes,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.visibility,
                      color: Colors.white,
                      size: 10,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      _formatViews(post.views),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Location indicator at top
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 10,
                ),
                const SizedBox(width: 2),
                Text(
                  post.location.split(',')[0], // Show only city name
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        // Video play button overlay
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }



  final List<PostItem> _trendingPosts = [
    PostItem(
      username: 'travel_lover',
      location: 'Dubai, UAE',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '2.4k',
      caption: 'Amazing sunset at Burj Khalifa! 🌅 #dubai #travel',
      timeAgo: '2 hours ago',
      views: 15420,
    ),
    PostItem(
      username: 'foodie_adventures',
      location: 'Tokyo, Japan',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '1.8k',
      caption: 'Best ramen in Shibuya! 🍜 #japan #food',
      timeAgo: '5 hours ago',
      views: 12850,
    ),
    PostItem(
      username: 'art_creator',
      location: 'New York, USA',
      imageUrl: 'assets/USA/amazon.png',
      likes: '3.2k',
      caption: 'Street art in Brooklyn 🎨 #art #nyc',
      timeAgo: '1 day ago',
      views: 25680,
    ),
    PostItem(
      username: 'nature_snap',
      location: 'Bali, Indonesia',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '950',
      caption: 'Morning vibes in the rice terraces 🌾 #bali #nature',
      timeAgo: '3 hours ago',
      views: 8750,
    ),
    PostItem(
      username: 'city_lights',
      location: 'Seoul, Korea',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '1.1k',
      caption: 'Neon nights in Hongdae ✨ #seoul #nightlife',
      timeAgo: '7 hours ago',
      views: 11200,
    ),
    PostItem(
      username: 'mountain_go',
      location: 'Zermatt, Switzerland',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '2.1k',
      caption: 'Misty trails under the Matterhorn 🏔️ #hike #alps',
      timeAgo: '12 hours ago',
      views: 18900,
    ),
    PostItem(
      username: 'coffee_daily',
      location: 'Rome, Italy',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '640',
      caption: 'Morning espresso, cobblestone streets ☕ #rome #cafe',
      timeAgo: '18 hours ago',
      views: 5430,
    ),
    PostItem(
      username: 'ocean_eye',
      location: 'Sydney, Australia',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '2.9k',
      caption: 'Blue horizon at Bondi 🌊 #sydney #surf',
      timeAgo: '2 days ago',
      views: 32400,
    ),
    PostItem(
      username: 'desert_rider',
      location: 'Riyadh, Saudi Arabia',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '1.2k',
      caption: 'Dunes and endless skies 🐪 #desert #travel',
      timeAgo: '3 days ago',
      views: 15600,
    ),
    PostItem(
      username: 'urban_explorer',
      location: 'Amsterdam, Netherlands',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '1.7k',
      caption: 'Canal views and tulip dreams 🌷 #amsterdam #spring',
      timeAgo: '4 days ago',
      views: 14200,
    ),
    PostItem(
      username: 'adventure_seeker',
      location: 'Queenstown, New Zealand',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '3.5k',
      caption: 'Bungee jumping over the Kawarau Gorge! 🪂 #adventure #nz',
      timeAgo: '5 days ago',
      views: 28900,
      isVideo: true,
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    ),
    PostItem(
      username: 'culture_vibes',
      location: 'Marrakech, Morocco',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '2.8k',
      caption: 'Souk shopping and mint tea 🍵 #morocco #culture',
      timeAgo: '6 days ago',
      views: 23100,
    ),
  ];

  final List<PostItem> _recentPosts = [
    PostItem(
      username: 'design_daily',
      location: 'Berlin, Germany',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '420',
      caption: 'Minimal desks, maximal focus 💻 #workspace',
      timeAgo: '6 min ago',
      views: 3200,
    ),
    PostItem(
      username: 'street_food',
      location: 'Bangkok, Thailand',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '2.0k',
      caption: 'Pad Thai on the go 🍤 #streetfood',
      timeAgo: '25 min ago',
      views: 15800,
    ),
    PostItem(
      username: 'fit_life',
      location: 'Los Angeles, USA',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '860',
      caption: 'Sunrise run at the pier 🏃 #fitness',
      timeAgo: '1 hour ago',
      views: 7200,
    ),
    PostItem(
      username: 'artsy_me',
      location: 'Paris, France',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '1.4k',
      caption: 'Palette and pastels 🎨 #painting',
      timeAgo: '2 hours ago',
      views: 11200,
    ),
    PostItem(
      username: 'tech_notes',
      location: 'San Francisco, USA',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '3.8k',
      caption: 'Refactoring day, coffee mandatory ☕ #devlife',
      timeAgo: '3 hours ago',
      views: 28900,
    ),
    PostItem(
      username: 'daily_reads',
      location: 'London, UK',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '510',
      caption: 'Chapters and chai 📚 #reading',
      timeAgo: '5 hours ago',
      views: 4100,
    ),
    PostItem(
      username: 'pet_world',
      location: 'Toronto, Canada',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '2.3k',
      caption: 'Corgi zoomies at the park 🐶 #dogs',
      timeAgo: '8 hours ago',
      views: 18700,
    ),
    PostItem(
      username: 'sunset_seekers',
      location: 'Athens, Greece',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '4.1k',
      caption: 'Golden hour over the Acropolis 🌇 #sunset',
      timeAgo: '12 hours ago',
      views: 35600,
    ),
    // Demo video posts
    PostItem(
      username: 'reel_travel',
      location: 'Kyoto, Japan',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '5.2k',
      caption: 'Torii gates walk 🎥',
      timeAgo: '1 day ago',
      isVideo: true,
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      views: 42800,
    ),
    PostItem(
      username: 'skate_vibes',
      location: 'Barcelona, Spain',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '3.3k',
      caption: 'Ollies by the beach 🛹',
      timeAgo: '2 days ago',
      isVideo: true,
      videoUrl: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
      views: 26700,
    ),
    PostItem(
      username: 'food_reels',
      location: 'Singapore',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '2.6k',
      caption: 'Hawker center tour 🍜',
      timeAgo: '3 days ago',
      isVideo: true,
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      views: 19800,
    ),
    PostItem(
      username: 'music_lover',
      location: 'Nashville, USA',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '1.9k',
      caption: 'Country music and cowboy boots 🎸 #nashville #music',
      timeAgo: '4 days ago',
      views: 16500,
    ),
    PostItem(
      username: 'sports_fan',
      location: 'Barcelona, Spain',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '4.2k',
      caption: 'Camp Nou match day! ⚽ #barcelona #football',
      timeAgo: '5 days ago',
      views: 35600,
    ),
    PostItem(
      username: 'bookworm',
      location: 'Oxford, UK',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '890',
      caption: 'Reading in the Bodleian Library 📚 #oxford #books',
      timeAgo: '6 days ago',
      views: 7200,
    ),
    PostItem(
      username: 'tech_geek',
      location: 'Silicon Valley, USA',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '3.1k',
      caption: 'Startup life and coffee ☕ #tech #startup',
      timeAgo: '7 days ago',
      views: 27800,
    ),
    PostItem(
      username: 'yoga_master',
      location: 'Rishikesh, India',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '2.3k',
      caption: 'Sunrise yoga by the Ganges 🧘‍♀️ #yoga #india',
      timeAgo: '8 days ago',
      views: 19400,
    ),
    PostItem(
      username: 'wine_connoisseur',
      location: 'Bordeaux, France',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '1.6k',
      caption: 'Wine tasting in the vineyards 🍷 #wine #france',
      timeAgo: '9 days ago',
      views: 13800,
    ),
    PostItem(
      username: 'fashion_ista',
      location: 'Milan, Italy',
      imageUrl: 'assets/images/onboarding/12.jpg',
      likes: '5.7k',
      caption: 'Fashion Week street style 👗 #milan #fashion',
      timeAgo: '10 days ago',
      views: 48700,
    ),
  ];



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [




            // TikTok-style navigation bar
            SliverToBoxAdapter(
              child: Container(
                height: 44,
                margin: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                                         // Left side - Live icon with spacing
                     Container(
                       margin: const EdgeInsets.only(left: 16),
                       child: _buildTikTokNavItem(
                         icon: Icons.live_tv,
                         label: 'Live',
                         isActive: _activeSecondaryTab == -1,
                         isDark: isDark,
                         onTap: () {
                           setState(() {
                             _activeSecondaryTab = -1;
                             _activeSubTab = 0; // Reset to first sub-tab
                           });
                         },
                       ),
                     ),
                    
                    // Center - 3 main navigation icons
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTikTokNavItem(
                            icon: Icons.public,
                            label: 'World',
                            isActive: _activeSecondaryTab == 0,
                            isDark: isDark,
                            onTap: () {
                              setState(() {
                                _activeSecondaryTab = 0;
                                _activeSubTab = 0; // Reset to first sub-tab
                              });
                            },
                          ),
                          const SizedBox(width: 20),
                          _buildTikTokNavItem(
                            icon: Icons.business,
                            label: 'Business',
                            isActive: _activeSecondaryTab == 1,
                            isDark: isDark,
                            onTap: () {
                              setState(() {
                                _activeSecondaryTab = 1;
                                _activeSubTab = 0; // Reset to first sub-tab
                              });
                            },
                          ),
                          const SizedBox(width: 20),
                          _buildTikTokNavItem(
                            icon: Icons.location_city,
                            label: 'Cities',
                            isActive: _activeSecondaryTab == 2,
                            isDark: isDark,
                            onTap: () {
                              setState(() {
                                _activeSecondaryTab = 2;
                                _activeSubTab = 0; // Reset to first sub-tab
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Right side - Search icon with spacing
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: _buildTikTokNavItem(
                        icon: Icons.search,
                        label: 'Search',
                        isActive: false,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Second tab bar - changes based on selected top icon
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: const EdgeInsets.only(top: 0, left: 0),
                padding: EdgeInsets.zero,
                child: _buildSecondTabBar(isDark),
              ),
            ),

            // Content based on secondary tab selection
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     // Instagram-style grid layout
                     _buildInstagramStyleGrid(),
                  ],
                ),
              ),
            ),


              ],
            ),
      ),
    );
  }

  Widget _buildPostCard(PostItem post, bool isDark) {
    final Size screenSize = MediaQuery.of(context).size;
    final double postHeight = screenSize.height * 0.8; // tall, near full screen

    return SizedBox(
      height: postHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background media (image or video)
          if (post.isVideo && post.videoUrl != null)
            _AutoPlayVideo(videoUrl: post.videoUrl!)
          else
            Image.asset(
              post.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey[300]);
              },
            ),

          // Gradient overlays for readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // (Header removed) Profile will be shown near bottom above likes

          // Right-side action bar
          Positioned(
            right: 12,
            bottom: 60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ActionCircleIcon(icon: Icons.favorite_border, onTap: () {}),
                const SizedBox(height: 6),
                Text(
                  post.likes,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                _ActionCircleIcon(icon: Icons.visibility, onTap: () {}),
                const SizedBox(height: 6),
                Text(
                  _formatViews(post.views),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                _ActionCircleIcon(icon: Icons.chat_bubble_outline, onTap: () {}),
                const SizedBox(height: 6),
                Text(
                  post.comments.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                _ActionCircleIcon(icon: Icons.send, onTap: () {}),
                const SizedBox(height: 6),
                Text(
                  post.shares.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                _ActionCircleIcon(icon: Icons.bookmark_border, onTap: () {}),
                // No count under save; views moved under the eye icon
              ],
            ),
          ),

          // Bottom profile, likes, caption, time
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                 // Profile (avatar + username) above likes on bottom-left
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: AssetImage(post.imageUrl),
                      onBackgroundImageError: (exception, stackTrace) {},
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        post.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${post.location.split(',')[0]}',
                style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      post.timeAgo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.visibility,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatViews(post.views),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white),
          children: [
                      TextSpan(
                        text: post.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(text: post.caption),
                    ],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPostDetail(PostItem post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bool isDarkModal = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: _buildPostCard(post, isDarkModal),
        );
      },
    );
  }
}

class _AutoPlayVideo extends StatefulWidget {
  final String videoUrl;
  const _AutoPlayVideo({required this.videoUrl});

  @override
  State<_AutoPlayVideo> createState() => _AutoPlayVideoState();
}

class _AutoPlayVideoState extends State<_AutoPlayVideo> {
  late final VideoPlayerController _controller;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted && _isVisible) {
          _controller.play();
        }
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(widget.videoUrl),
      onVisibilityChanged: (info) {
        final visible = info.visibleFraction > 0.6;
        if (visible != _isVisible) {
          setState(() => _isVisible = visible);
          if (visible) {
            if (_controller.value.isInitialized) {
              _controller.play();
            }
          } else {
            _controller.pause();
          }
        }
      },
      child: _controller.value.isInitialized
          ? Stack(
              fit: StackFit.expand,
          children: [
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
                if (!_controller.value.isPlaying)
                  Center(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _ActionCircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionCircleIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// Data models for Instagram-style content

class PostItem {
  final String username;
  final String location;
  final String imageUrl;
  final String likes;
  final String caption;
  final String timeAgo;
  final bool isVideo;
  final String? videoUrl;
  final int views;
  final int comments;
  final int shares;

  PostItem({
    required this.username,
    required this.location,
    required this.imageUrl,
    required this.likes,
    required this.caption,
    required this.timeAgo,
    this.isVideo = false,
    this.videoUrl,
    this.views = 0,
    this.comments = 0,
    this.shares = 0,
  });
}

// Simple placeholder screens

class SimpleNotificationsScreen extends StatelessWidget {
  const SimpleNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications, size: 80, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Notifications',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            Text(
              'No new notifications',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleProfileScreen extends StatelessWidget {
  const SimpleProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              user?.displayName ?? 'User Profile',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            Text(
              user?.email ?? 'No email',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB700FF),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slim underline similar to TikTok's tab highlight.
class _TikTokUnderlineIndicator extends Decoration {
  const _TikTokUnderlineIndicator();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _UnderlinePainter();
}

class _UnderlinePainter extends BoxPainter {
  static const double _thickness = 2.4;
  static const double _inset = 6; // inset from left/right of the label

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    if (cfg.size == null) return;
    final rect = offset & cfg.size!;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = _thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final y = rect.bottom - 2; // lift a bit above the very bottom
    final start = Offset(rect.left + _inset, y);
    final end = Offset(rect.right - _inset, y);
    canvas.drawLine(start, end, paint);
  }
}

/// TikTok-style login form widget
class _TikTokLoginForm extends StatefulWidget {
  const _TikTokLoginForm();

  @override
  State<_TikTokLoginForm> createState() => _TikTokLoginFormState();
}

class _TikTokLoginFormState extends State<_TikTokLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // Login
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        // Register
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context); // Close the modal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLogin ? 'Login successful!' : 'Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[600]!
                      : Colors.grey[400]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[600]!
                      : Colors.grey[400]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                  width: 2,
                ),
              ),
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
          
          const SizedBox(height: 20),
          
          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[600]!
                      : Colors.grey[400]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[600]!
                      : Colors.grey[400]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                  width: 2,
                ),
              ),
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
          
          const SizedBox(height: 30),
          
          // Submit button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black87
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    )
                  : Text(
                      _isLogin ? 'Sign In' : 'Sign Up',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Toggle between login and register
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin ? "Don't have an account? " : "Already have an account? ",
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin ? 'Sign Up' : 'Sign In',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
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
                      const SnackBar(
                        content: Text('Failed to send reset email'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
