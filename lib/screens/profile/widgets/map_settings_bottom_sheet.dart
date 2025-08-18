import 'package:flutter/material.dart';

class MapSettingsBottomSheet extends StatefulWidget {
  const MapSettingsBottomSheet({Key? key}) : super(key: key);

  @override
  State<MapSettingsBottomSheet> createState() => _MapSettingsBottomSheetState();
}

class _MapSettingsBottomSheetState extends State<MapSettingsBottomSheet> {
  bool _showTraffic = false;
  bool _showPOIs = true;
  bool _showPublicTransport = true;
  double _mapRotation = 0.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Map Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Settings options
          SwitchListTile(
            title: const Text('Show Traffic'),
            value: _showTraffic,
            onChanged: (value) {
              setState(() {
                _showTraffic = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text('Show Points of Interest'),
            value: _showPOIs,
            onChanged: (value) {
              setState(() {
                _showPOIs = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text('Show Public Transport'),
            value: _showPublicTransport,
            onChanged: (value) {
              setState(() {
                _showPublicTransport = value;
              });
            },
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Map Rotation',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                Slider(
                  value: _mapRotation,
                  min: 0,
                  max: 360,
                  divisions: 360,
                  label: '${_mapRotation.round()}°',
                  onChanged: (value) {
                    setState(() {
                      _mapRotation = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Apply button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Apply settings
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Apply Settings'),
            ),
          ),
        ],
      ),
    );
  }
}
