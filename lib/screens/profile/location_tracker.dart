import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:async';
import '../../config/mapbox_config.dart';

class LocationTracker extends StatefulWidget {
  final MapboxMap mapboxMap;
  final Function(Point location) onLocationUpdate;

  const LocationTracker({
    Key? key,
    required this.mapboxMap,
    required this.onLocationUpdate,
  }) : super(key: key);

  @override
  _LocationTrackerState createState() => _LocationTrackerState();
}

class _LocationTrackerState extends State<LocationTracker> {
  StreamSubscription<geo.Position>? _positionStream;
  bool _isFollowingUser = false;
  Point? _userLocation;
  PointAnnotationManager? _pointAnnotationManager;

  @override
  void initState() {
    super.initState();
    _initializeAnnotations();
    _requestLocationPermission();
  }

  void _initializeAnnotations() async {
    _pointAnnotationManager =
        await widget.mapboxMap.annotations.createPointAnnotationManager();
  }

  Future<void> _requestLocationPermission() async {
    var status = await geo.Geolocator.checkPermission();
    if (status == geo.LocationPermission.denied) {
      status = await geo.Geolocator.requestPermission();
    }

    if (status == geo.LocationPermission.whileInUse ||
        status == geo.LocationPermission.always) {
      _getCurrentLocation();
      _startLocationUpdates();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      _updateLocation(position);
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _startLocationUpdates() {
    _positionStream?.cancel();

    _positionStream = geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen(_updateLocation);
  }

  void _updateLocation(geo.Position position) {
    setState(() {
      _userLocation = Point(
        coordinates: Position(position.longitude, position.latitude),
      );
    });

    widget.onLocationUpdate(_userLocation!);

    if (_isFollowingUser) {
      widget.mapboxMap.flyTo(
        CameraOptions(
          center: _userLocation,
          zoom: 15.0,
        ),
        MapAnimationOptions(duration: 500),
      );
    }

    _updateLocationMarker();
  }

  void _updateLocationMarker() async {
    if (_pointAnnotationManager == null || _userLocation == null) return;

    // Remove existing markers
    await _pointAnnotationManager?.deleteAll();

    // Add new marker at current location
    final pointAnnotation = PointAnnotationOptions(
      geometry: _userLocation!,
      iconImage: 'custom-marker',
      iconSize: 1.0,
      iconColor: Colors.blue.value,
      textField: 'You are here',
      textSize: 12.0,
      textColor: Colors.white.value,
      textOffset: [0.0, -2.0],
    );

    await _pointAnnotationManager?.create(pointAnnotation);
  }

  void toggleFollowUser() {
    setState(() {
      _isFollowingUser = !_isFollowingUser;
      if (_isFollowingUser && _userLocation != null) {
        widget.mapboxMap.flyTo(
          CameraOptions(
            center: _userLocation,
            zoom: 15.0,
          ),
          MapAnimationOptions(duration: 1000),
        );
      }
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: MediaQuery.of(context).size.height * 0.2,
      child: FloatingActionButton(
        heroTag: 'locationButton',
        onPressed: toggleFollowUser,
        backgroundColor: _isFollowingUser ? Colors.blue : Colors.white,
        child: Icon(
          Icons.my_location,
          color: _isFollowingUser ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
