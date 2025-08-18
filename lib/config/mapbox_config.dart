class MapboxConfig {
  // Replace with your actual Mapbox access token
  // Get your free token from https://account.mapbox.com/access-tokens/
  static const String accessToken =
      'pk.eyJ1IjoiZ2FybXlhbiIsImEiOiJjbWR4eGZqa2swM2NtMmxwOGZyZjFjYzlwIn0.6s-EuQ4G7PFixs8sGTZW6Q';

  // Mapbox styles
  static const String streetStyle = 'mapbox://styles/mapbox/streets-v12';
  static const String satelliteStyle = 'mapbox://styles/mapbox/satellite-v9';
  static const String darkStyle = 'mapbox://styles/mapbox/dark-v11';
  static const String lightStyle = 'mapbox://styles/mapbox/light-v11';

  // 3D Styles with terrain and buildings
  static const String street3DStyle = 'mapbox://styles/mapbox/streets-v12';
  static const String satellite3DStyle =
      'mapbox://styles/mapbox/satellite-streets-v12';
  static const String outdoors3DStyle = 'mapbox://styles/mapbox/outdoors-v12';

  // Default map settings
  static const double defaultZoom = 15.0; // Increased for better 3D view
  static const double defaultLatitude = 25.2048; // Dubai coordinates
  static const double defaultLongitude = 55.2708;
}
