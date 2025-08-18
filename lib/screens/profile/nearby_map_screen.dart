import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../config/mapbox_config.dart';
import 'location_tracker.dart';
import 'widgets/search_bottom_sheet.dart';
import 'widgets/map_settings_bottom_sheet.dart';
import 'widgets/friends_list_bottom_sheet.dart';
import 'widgets/trending_list_bottom_sheet.dart';
import 'widgets/user_profile_bottom_sheet.dart';
import 'widgets/trending_place_bottom_sheet.dart';

class NearbyMapScreen extends StatefulWidget {
  final String? userId;
  final String? currentLocation;

  const NearbyMapScreen({
    Key? key,
    this.userId,
    this.currentLocation,
  }) : super(key: key);

  @override
  State<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends State<NearbyMapScreen>
    with TickerProviderStateMixin {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;

  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  // Location tracking
  bool _isLocationPermissionGranted = false;
  bool _isFollowingUser = false;
  Point? _userLocation;
  StreamSubscription<geo.Position>? _positionStream;
  Timer? _locationUpdateTimer;

  // Map settings
  bool _is3DMode = false;
  bool _isSatelliteMode = false;
  double _currentZoom = 10.0;
  double _currentPitch = 0.0;
  double _currentBearing = 0.0;

  // Mock user data - in real app, this would come from Firebase
  List<MapUser> nearbyUsers = [];
  List<TrendingPlace> trendingPlaces = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateMockData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _generateMockData() {
    // Initialize current zoom from MapboxConfig
    _currentZoom = MapboxConfig.defaultZoom;

    // Generate mock nearby users with realistic geographic positions
    nearbyUsers = [
      MapUser(
        id: '1',
        name: 'Sarah Johnson',
        avatar: '👩‍💼',
        x: 0.65, // Dubai area
        y: 0.35,
        isOnline: true,
        hasStory: true,
        lastSeen: 'Just now',
        location: 'Dubai, UAE',
        shareLocation: false, // Location is private
      ),
      MapUser(
        id: '2',
        name: 'Mike Chen',
        avatar: '👨‍💻',
        x: 0.75, // Tokyo area
        y: 0.32,
        isOnline: true,
        hasStory: false,
        lastSeen: '2 min ago',
        location: 'Tokyo, Japan',
        shareLocation: true, // Location is shared
      ),
      MapUser(
        id: '3',
        name: 'Emma Wilson',
        avatar: '👩‍🎨',
        x: 0.25, // New York area
        y: 0.3,
        isOnline: false,
        hasStory: true,
        lastSeen: '1 hour ago',
        location: 'New York, USA',
      ),
      MapUser(
        id: '4',
        name: 'Alex Turner',
        avatar: '👨‍🎤',
        x: 0.48, // London area
        y: 0.25,
        isOnline: true,
        hasStory: true,
        lastSeen: 'Just now',
        location: 'London, UK',
      ),
      MapUser(
        id: '5',
        name: 'Priya Sharma',
        avatar: '👩‍🔬',
        x: 0.62, // Mumbai area
        y: 0.42,
        isOnline: true,
        hasStory: false,
        lastSeen: '5 min ago',
        location: 'Mumbai, India',
      ),
      MapUser(
        id: '6',
        name: 'Carlos Silva',
        avatar: '👨‍🎨',
        x: 0.32, // São Paulo area
        y: 0.68,
        isOnline: false,
        hasStory: true,
        lastSeen: '30 min ago',
        location: 'São Paulo, Brazil',
      ),
    ];

    // Generate trending places with geographic accuracy
    trendingPlaces = [
      TrendingPlace(
        name: 'Dubai Mall',
        x: 0.65,
        y: 0.35,
        userCount: 127,
        type: TrendingType.shopping,
        country: 'UAE',
      ),
      TrendingPlace(
        name: 'Times Square',
        x: 0.25,
        y: 0.3,
        userCount: 89,
        type: TrendingType.landmark,
        country: 'USA',
      ),
      TrendingPlace(
        name: 'Shibuya Crossing',
        x: 0.75,
        y: 0.32,
        userCount: 156,
        type: TrendingType.landmark,
        country: 'Japan',
      ),
      TrendingPlace(
        name: 'Tower Bridge',
        x: 0.48,
        y: 0.25,
        userCount: 78,
        type: TrendingType.landmark,
        country: 'UK',
      ),
      TrendingPlace(
        name: 'Marina Beach',
        x: 0.62,
        y: 0.42,
        userCount: 56,
        type: TrendingType.beach,
        country: 'India',
      ),
    ];
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }

    setState(() {
      _isLocationPermissionGranted = status.isGranted;
    });

    if (_isLocationPermissionGranted) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      setState(() {
        _userLocation = Point(
          coordinates: Position(position.longitude, position.latitude),
        );
      });

      // Center map on user location if following
      if (_isFollowingUser && _mapboxMap != null) {
        _mapboxMap!.flyTo(
          CameraOptions(
            center: _userLocation,
            zoom: 15.0,
          ),
          MapAnimationOptions(duration: 1000),
        );
      }

      // Start listening to location updates
      _startLocationUpdates();
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Could not get your location. Please check permissions.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startLocationUpdates() {
    // Cancel any existing subscription
    _positionStream?.cancel();

    // Start listening to location changes
    _positionStream = geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((geo.Position position) {
      setState(() {
        _userLocation = Point(
          coordinates: Position(position.longitude, position.latitude),
        );
      });

      // Update map center if following user
      if (_isFollowingUser && _mapboxMap != null) {
        _mapboxMap!.flyTo(
          CameraOptions(
            center: _userLocation,
            zoom: 15.0,
          ),
          MapAnimationOptions(duration: 1000),
        );
      }
    });
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _initializeAnnotations();

    // Initialize location tracking after map is created
    setState(() {});
  }

  void _initializeAnnotations() async {
    _pointAnnotationManager =
        await _mapboxMap?.annotations.createPointAnnotationManager();
    _addUserAnnotations();
    _addTrendingPlaceAnnotations();
    _addCurrentLocationMarker();
  }

  void _addCurrentLocationMarker() async {
    if (_pointAnnotationManager == null || _userLocation == null) return;

    final pointAnnotation = PointAnnotationOptions(
      geometry: _userLocation!,
      iconImage: 'custom-marker', // Using a default marker image
      iconSize: 1.0,
      iconColor: Colors.blue.value,
      textField: 'You are here',
      textSize: 12.0,
      textColor: Colors.white.value,
      textOffset: [0.0, -2.0],
    );

    await _pointAnnotationManager?.create(pointAnnotation);
  }

  void _addUserAnnotations() async {
    if (_pointAnnotationManager == null) return;

    for (var user in nearbyUsers) {
      // Convert screen coordinates to geographical coordinates
      final point = Point(
          coordinates: Position(
        _convertXToLongitude(user.x),
        _convertYToLatitude(user.y),
      ));

      final pointAnnotation = PointAnnotationOptions(
        geometry: point,
        textField: user.name,
        textSize: 12.0,
        textColor: Colors.white.value,
        textOffset: [0.0, -2.0],
        iconImage: _getUserIcon(user),
        iconSize: 0.8,
      );

      await _pointAnnotationManager?.create(pointAnnotation);
    }
  }

  void _addTrendingPlaceAnnotations() async {
    if (_pointAnnotationManager == null) return;

    for (var place in trendingPlaces) {
      // Convert screen coordinates to geographical coordinates
      final point = Point(
          coordinates: Position(
        _convertXToLongitude(place.x),
        _convertYToLatitude(place.y),
      ));

      final pointAnnotation = PointAnnotationOptions(
        geometry: point,
        textField: place.name,
        textSize: 10.0,
        textColor: Colors.orange.value,
        textOffset: [0.0, -1.5],
        iconImage: _getTrendingPlaceIcon(place.type),
        iconSize: 0.6,
      );

      await _pointAnnotationManager?.create(pointAnnotation);
    }
  }

  // Convert normalized screen coordinates to geographical coordinates
  double _convertXToLongitude(double x) {
    // Convert from 0-1 screen coordinates to longitude (-180 to 180)
    return (x * 360.0) - 180.0;
  }

  double _convertYToLatitude(double y) {
    // Convert from 0-1 screen coordinates to latitude (85 to -85, Web Mercator limits)
    return 85.0 - (y * 170.0);
  }

  String _getUserIcon(MapUser user) {
    return user.isOnline ? 'user-online-icon' : 'user-offline-icon';
  }

  String _getTrendingPlaceIcon(TrendingType type) {
    switch (type) {
      case TrendingType.shopping:
        return 'shopping-icon';
      case TrendingType.landmark:
        return 'landmark-icon';
      case TrendingType.beach:
        return 'beach-icon';
      case TrendingType.restaurant:
        return 'restaurant-icon';
      case TrendingType.nightlife:
        return 'nightlife-icon';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _locationUpdateTimer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Map Background - this will contain all markers through native annotations
            _buildMapBackground(isDark),

            // Location tracker
            if (_mapboxMap != null)
              LocationTracker(
                mapboxMap: _mapboxMap!,
                onLocationUpdate: (Point location) {
                  // Handle location updates if needed
                },
              ),

            // Top UI overlay - positioned to not interfere with map gestures
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopOverlay(isDark),
            ),

            // Bottom UI overlay - positioned to not interfere with map gestures
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomOverlay(isDark),
            ),

            // Right side control bar - positioned to not interfere with map gestures
            Positioned(
              right: 16,
              top: MediaQuery.of(context).size.height * 0.35,
              child: _buildRightControlBar(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapBackground(bool isDark) {
    String mapStyle;

    // Select style based on current mode - use 3D styles when in 3D mode
    if (_is3DMode) {
      if (_isSatelliteMode) {
        mapStyle = MapboxConfig.satellite3DStyle;
      } else {
        mapStyle = MapboxConfig.street3DStyle;
      }
    } else {
      if (_isSatelliteMode) {
        mapStyle = MapboxConfig.satelliteStyle;
      } else {
        mapStyle = isDark ? MapboxConfig.darkStyle : MapboxConfig.lightStyle;
      }
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: MapWidget(
        key: const ValueKey('mapWidget'),
        cameraOptions: CameraOptions(
          center: Point(
              coordinates: Position(
            MapboxConfig.defaultLongitude,
            MapboxConfig.defaultLatitude,
          )),
          zoom: _currentZoom,
          pitch: _currentPitch, // Enable pitch for 3D view
          bearing: _currentBearing, // Enable bearing for rotation
        ),
        mapOptions: MapOptions(
          pixelRatio: MediaQuery.of(context).devicePixelRatio,
        ),
        styleUri: mapStyle,
        onMapCreated: _onMapCreated,
      ),
    );
  }

  Widget _buildRightControlBar(bool isDark) {
    return Container(
      width: 56,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]?.withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 3D Toggle Button with enhanced visual feedback
          _buildControlButton(
            icon: _is3DMode ? Icons.view_in_ar : Icons.map,
            isActive: _is3DMode,
            onTap: _toggle3DMode,
            isDark: isDark,
            tooltip: _is3DMode ? 'Switch to 2D' : 'Switch to 3D',
          ),

          const SizedBox(height: 2),

          // Tilt/Pitch Control (only show in 3D mode)
          if (_is3DMode) ...[
            _buildControlButton(
              icon: Icons.rotate_90_degrees_ccw,
              onTap: _increasePitch,
              isDark: isDark,
              tooltip: 'Increase Tilt',
            ),
            const SizedBox(height: 2),
            _buildControlButton(
              icon: Icons.rotate_90_degrees_cw,
              onTap: _decreasePitch,
              isDark: isDark,
              tooltip: 'Decrease Tilt',
            ),
            const SizedBox(height: 2),
          ],

          // Zoom In Button
          _buildControlButton(
            icon: Icons.add,
            onTap: _zoomIn,
            isDark: isDark,
            tooltip: 'Zoom In',
          ),

          const SizedBox(height: 2),

          // Zoom Out Button
          _buildControlButton(
            icon: Icons.remove,
            onTap: _zoomOut,
            isDark: isDark,
            tooltip: 'Zoom Out',
          ),

          const SizedBox(height: 2),

          // Bearing/Rotation Reset (only show in 3D mode)
          if (_is3DMode) ...[
            _buildControlButton(
              icon: Icons.explore,
              onTap: _resetBearing,
              isDark: isDark,
              tooltip: 'Reset North',
            ),
            const SizedBox(height: 2),
          ],

          // Satellite/Map Toggle Button with enhanced 3D awareness
          _buildControlButton(
            icon: _isSatelliteMode ? Icons.layers : Icons.satellite_alt,
            isActive: _isSatelliteMode,
            onTap: _toggleSatelliteMode,
            isDark: isDark,
            tooltip: _isSatelliteMode
                ? (_is3DMode ? 'Switch to 3D Streets' : 'Switch to Map')
                : (_is3DMode
                    ? 'Switch to 3D Satellite'
                    : 'Switch to Satellite'),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required String tooltip,
    bool isActive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? Colors.blue[600] : Colors.blue[500])
                : (isDark ? Colors.grey[700] : Colors.grey[100]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive
                  ? (isDark ? Colors.blue[400]! : Colors.blue[300]!)
                  : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isActive
                ? Colors.white
                : (isDark ? Colors.white : Colors.black87),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildTopOverlay(bool isDark) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            // Search button
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => _showSearchBottomSheet(),
                icon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomOverlay(bool isDark) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomButton(
                Icons.my_location,
                'My Location',
                () => _centerOnUser(),
                isDark,
              ),
              _buildBottomButton(
                Icons.people,
                'Friends',
                () => _showFriendsList(),
                isDark,
              ),
              _buildBottomButton(
                Icons.trending_up,
                'Trending',
                () => _showTrendingList(),
                isDark,
              ),
              _buildBottomButton(
                Icons.settings,
                'Settings',
                () => _showMapSettings(),
                isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(
    IconData icon,
    String label,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isDark ? Colors.white : Colors.black87,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[300] : Colors.grey[600],
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

  void _showUserProfile(MapUser user) {
    // Only show location if user has allowed sharing
    if (user.shareLocation) {
      if (_mapboxMap != null) {
        _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(
                _convertXToLongitude(user.x),
                _convertYToLatitude(user.y),
              ),
            ),
            zoom: 14.0,
          ),
          MapAnimationOptions(duration: 1000),
        );
      }
    } else {
      // Show message that user's location is private
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name}\'s location is private'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.grey[600],
        ),
      );
    }

    // Show user profile
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => UserProfileBottomSheet(user: user),
    );
  }

  void _showTrendingPlace(TrendingPlace place) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => TrendingPlaceBottomSheet(place: place),
    );
  }

  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SearchBottomSheet(),
    );
  }

  void _centerOnUser() async {
    if (!_isLocationPermissionGranted) {
      await _requestLocationPermission();
    }

    if (_isLocationPermissionGranted) {
      setState(() {
        _isFollowingUser = true;
      });

      if (_userLocation != null && _mapboxMap != null) {
        _mapboxMap!.flyTo(
          CameraOptions(
            center: _userLocation,
            zoom: 15.0,
          ),
          MapAnimationOptions(duration: 1000),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Following your location'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        // Get current location if we don't have it
        await _getCurrentLocation();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is required to use this feature'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFriendsList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FriendsListBottomSheet(users: nearbyUsers),
    );
  }

  void _showTrendingList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => TrendingListBottomSheet(places: trendingPlaces),
    );
  }

  void _showMapSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const MapSettingsBottomSheet(),
    );
  }

  // Map control functions
  void _toggle3DMode() {
    setState(() {
      _is3DMode = !_is3DMode;
      _currentPitch = _is3DMode ? 60.0 : 0.0;
    });

    if (_mapboxMap != null) {
      // Use appropriate 3D style
      final isDark = Theme.of(context).brightness == Brightness.dark;
      String newStyle;

      if (_is3DMode) {
        newStyle = _isSatelliteMode
            ? MapboxConfig.satellite3DStyle
            : MapboxConfig.street3DStyle;
      } else {
        if (_isSatelliteMode) {
          newStyle = MapboxConfig.satelliteStyle;
        } else {
          newStyle = isDark ? MapboxConfig.darkStyle : MapboxConfig.lightStyle;
        }
      }

      // Animate camera to 3D view with enhanced parameters
      _mapboxMap!.flyTo(
        CameraOptions(
          pitch: _currentPitch,
          zoom: _is3DMode
              ? _currentZoom + 1
              : _currentZoom, // Slightly closer zoom for 3D
        ),
        MapAnimationOptions(
            duration: 1500), // Longer duration for smooth transition
      );

      // Change style for 3D buildings and terrain
      _mapboxMap!.loadStyleURI(newStyle);

      // Re-initialize annotations after style change
      Future.delayed(const Duration(milliseconds: 1500), () {
        _initializeAnnotations();
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _is3DMode ? '3D view with buildings enabled' : '2D view enabled'),
        duration: const Duration(seconds: 2),
        backgroundColor: _is3DMode ? Colors.blue[600] : Colors.grey[600],
      ),
    );
  }

  void _increasePitch() {
    if (_mapboxMap != null && _is3DMode) {
      _currentPitch = (_currentPitch + 15).clamp(0.0, 60.0);
      _mapboxMap!.flyTo(
        CameraOptions(pitch: _currentPitch),
        MapAnimationOptions(duration: 500),
      );
    }
  }

  void _decreasePitch() {
    if (_mapboxMap != null && _is3DMode) {
      _currentPitch = (_currentPitch - 15).clamp(0.0, 60.0);
      _mapboxMap!.flyTo(
        CameraOptions(pitch: _currentPitch),
        MapAnimationOptions(duration: 500),
      );
    }
  }

  void _resetBearing() {
    if (_mapboxMap != null) {
      _currentBearing = 0.0;
      _mapboxMap!.flyTo(
        CameraOptions(bearing: _currentBearing),
        MapAnimationOptions(duration: 800),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compass reset to North'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _zoomIn() {
    if (_mapboxMap != null) {
      _currentZoom = (_currentZoom + 1).clamp(1.0, 20.0);
      _mapboxMap!.flyTo(
        CameraOptions(zoom: _currentZoom),
        MapAnimationOptions(duration: 500),
      );
    }
  }

  void _zoomOut() {
    if (_mapboxMap != null) {
      _currentZoom = (_currentZoom - 1).clamp(1.0, 20.0);
      _mapboxMap!.flyTo(
        CameraOptions(zoom: _currentZoom),
        MapAnimationOptions(duration: 500),
      );
    }
  }

  void _toggleSatelliteMode() {
    setState(() {
      _isSatelliteMode = !_isSatelliteMode;
    });

    if (_mapboxMap != null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      String newStyle;

      // Select appropriate style based on 3D mode and satellite preference
      if (_is3DMode) {
        newStyle = _isSatelliteMode
            ? MapboxConfig.satellite3DStyle
            : MapboxConfig.street3DStyle;
      } else {
        if (_isSatelliteMode) {
          newStyle = MapboxConfig.satelliteStyle;
        } else {
          newStyle = isDark ? MapboxConfig.darkStyle : MapboxConfig.lightStyle;
        }
      }

      _mapboxMap!.loadStyleURI(newStyle);

      // Re-initialize annotations after style change
      Future.delayed(const Duration(milliseconds: 1000), () {
        _initializeAnnotations();
      });
    }

    String modeText = _isSatelliteMode
        ? (_is3DMode
            ? '3D Satellite view with buildings'
            : 'Satellite view enabled')
        : (_is3DMode ? '3D Streets view with buildings' : 'Map view enabled');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(modeText),
        duration: const Duration(seconds: 2),
        backgroundColor:
            _isSatelliteMode ? Colors.green[600] : Colors.blue[600],
      ),
    );
  }
}

// Data Models
class MapUser {
  final String id;
  final String name;
  final String avatar;
  double x;
  double y;
  final bool isOnline;
  final bool hasStory;
  final String lastSeen;
  final String? location;
  final bool shareLocation;

  MapUser({
    required this.id,
    required this.name,
    required this.avatar,
    required this.x,
    required this.y,
    required this.isOnline,
    required this.hasStory,
    required this.lastSeen,
    this.location,
    this.shareLocation = false, // Default to not sharing location
  });
}

class TrendingPlace {
  final String name;
  final double x;
  final double y;
  final int userCount;
  final TrendingType type;
  final String country;

  TrendingPlace({
    required this.name,
    required this.x,
    required this.y,
    required this.userCount,
    required this.type,
    required this.country,
  });
}

enum TrendingType {
  shopping,
  landmark,
  beach,
  restaurant,
  nightlife,
}
