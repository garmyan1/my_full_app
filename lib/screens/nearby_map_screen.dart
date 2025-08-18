import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:math';

class NearbyMapScreen extends StatefulWidget {
  const NearbyMapScreen({Key? key}) : super(key: key);

  @override
  State<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends State<NearbyMapScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _movementTimer;
  geo.Position? _currentPosition;
  bool _isLocationLoaded = false;

  // Users around the world for demonstration
  final List<UserLocation> _users = [
    UserLocation('Alice', 25.2048, 55.2708, 'Online', Colors.green), // Dubai
    UserLocation('Bob', 40.7128, -74.0060, 'Away', Colors.orange), // NYC
    UserLocation('Carol', 51.5074, -0.1278, 'Online', Colors.green), // London
    UserLocation('David', 35.6762, 139.6503, 'Offline', Colors.grey), // Tokyo
    UserLocation('Eve', -33.8688, 151.2093, 'Online', Colors.green), // Sydney
    UserLocation('Frank', 48.8566, 2.3522, 'Away', Colors.orange), // Paris
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _initializeLocation();
    _startLocationUpdates();
  }

  Future<void> _initializeLocation() async {
    // Request location permission
    final permission = await Permission.location.request();
    if (permission.isGranted) {
      try {
        _currentPosition = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high,
        );
        setState(() {
          _isLocationLoaded = true;
        });
      } catch (e) {
        print('Error getting location: $e');
        setState(() {
          _isLocationLoaded = true;
        });
      }
    } else {
      setState(() {
        _isLocationLoaded = true;
      });
    }
  }

  void _startLocationUpdates() {
    _movementTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        // Simulate user movement for demo
        for (var user in _users) {
          user.latitude += (Random().nextDouble() - 0.5) * 0.001;
          user.longitude += (Random().nextDouble() - 0.5) * 0.001;
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _movementTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Earth-like background with map placeholder
          _buildMapBackground(),

          // Top gradient overlay
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const Text(
                    'Nearby Friends',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Settings action
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // User markers overlay
          _buildUserMarkers(),

          // Location info banner
          if (_isLocationLoaded && _currentPosition != null)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your location: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // "Mapbox Coming Soon" banner
          Positioned(
            top: _isLocationLoaded && _currentPosition != null ? 160 : 120,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.8),
                    Colors.purple.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.map,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '🗺️ Custom Mapbox Style Ready',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'mapbox://styles/garmyan/cmdxxo9l0008x01sd6sp187k2\nInteractive maps will replace Earth simulation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.my_location,
                      label: 'My Location',
                      onTap: () => _centerOnCurrentLocation(),
                    ),
                    _buildActionButton(
                      icon: Icons.people,
                      label: 'Find Friends',
                      onTap: () => _showFriendsList(),
                    ),
                    _buildActionButton(
                      icon: Icons.add_location,
                      label: 'Add Place',
                      onTap: () => _addPlace(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Colors.blue[900]!.withOpacity(0.8),
            Colors.indigo[900]!.withOpacity(0.9),
            Colors.black,
          ],
        ),
      ),
      child: CustomPaint(
        painter: EarthMapPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildUserMarkers() {
    return Stack(
      children: _users.map((user) => _buildUserMarker(user)).toList(),
    );
  }

  Widget _buildUserMarker(UserLocation user) {
    return Positioned(
      left: _getScreenX(user.longitude),
      top: _getScreenY(user.latitude),
      child: GestureDetector(
        onTap: () => _showUserProfile(user),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (sin(_animationController.value * 2 * pi) * 0.1),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: user.statusColor,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: user.statusColor.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _getScreenX(double longitude) {
    // This is a simplified conversion - in a real app, you'd use the map's projection
    final screenWidth = MediaQuery.of(context).size.width;
    return (longitude + 180) * screenWidth / 360;
  }

  double _getScreenY(double latitude) {
    // This is a simplified conversion - in a real app, you'd use the map's projection
    final screenHeight = MediaQuery.of(context).size.height;
    return (90 - latitude) * screenHeight / 180;
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _centerOnCurrentLocation() {
    if (_currentPosition != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Your location: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFriendsList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Friends Nearby',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ..._users.map((user) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.statusColor,
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    user.status,
                    style: TextStyle(color: user.statusColor),
                  ),
                  onTap: () => _showUserProfile(user),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _addPlace() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Place feature coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showUserProfile(UserLocation user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          user.name,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${user.status}',
              style: TextStyle(color: user.statusColor),
            ),
            const SizedBox(height: 10),
            Text(
              'Location: ${user.latitude.toStringAsFixed(4)}, ${user.longitude.toStringAsFixed(4)}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Show user location info instead of map navigation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${user.name} is at: ${user.latitude.toStringAsFixed(4)}, ${user.longitude.toStringAsFixed(4)}',
                  ),
                  backgroundColor: Colors.blue,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Show Location'),
          ),
        ],
      ),
    );
  }
}

class UserLocation {
  final String name;
  double latitude;
  double longitude;
  final String status;
  final Color statusColor;

  UserLocation(
    this.name,
    this.latitude,
    this.longitude,
    this.status,
    this.statusColor,
  );
}

class EarthMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw continents with realistic shapes
    _drawContinents(canvas, size, paint);

    // Add stars in background
    _drawStars(canvas, size);
  }

  void _drawContinents(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.green[800]!.withOpacity(0.7);

    // North America (simplified)
    final northAmerica = Path()
      ..moveTo(size.width * 0.15, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.2, size.width * 0.3,
          size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.4,
          size.width * 0.2, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.15, size.height * 0.4,
          size.width * 0.1, size.height * 0.35)
      ..close();
    canvas.drawPath(northAmerica, paint);

    // Europe (simplified)
    final europe = Path()
      ..moveTo(size.width * 0.45, size.height * 0.28)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.25,
          size.width * 0.55, size.height * 0.32)
      ..quadraticBezierTo(size.width * 0.52, size.height * 0.38,
          size.width * 0.48, size.height * 0.35)
      ..close();
    canvas.drawPath(europe, paint);

    // Asia (simplified)
    final asia = Path()
      ..moveTo(size.width * 0.55, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.2,
          size.width * 0.85, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.4, size.width * 0.7,
          size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.4,
          size.width * 0.55, size.height * 0.35)
      ..close();
    canvas.drawPath(asia, paint);

    // Africa (simplified)
    final africa = Path()
      ..moveTo(size.width * 0.48, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.52, size.height * 0.35,
          size.width * 0.56, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.54, size.height * 0.65,
          size.width * 0.5, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.46, size.height * 0.6,
          size.width * 0.48, size.height * 0.4)
      ..close();
    canvas.drawPath(africa, paint);

    // South America (simplified)
    final southAmerica = Path()
      ..moveTo(size.width * 0.3, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.45,
          size.width * 0.38, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.36, size.height * 0.75,
          size.width * 0.32, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.28, size.height * 0.7,
          size.width * 0.3, size.height * 0.5)
      ..close();
    canvas.drawPath(southAmerica, paint);

    // Australia (simplified)
    final australia = Path()
      ..moveTo(size.width * 0.75, size.height * 0.65)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.62,
          size.width * 0.85, size.height * 0.68)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.72,
          size.width * 0.75, size.height * 0.65)
      ..close();
    canvas.drawPath(australia, paint);
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent stars
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
