class MapboxConfig {
  static const String accessToken =
      'pk.eyJ1IjoiZ2FybXlhbiIsImEiOiJjbWR4eG85bDAwMDh4MDFzZDZzcDE4N2syIn0.example_token_here';

  // Default map center (Dubai, UAE)
  static const double defaultLatitude = 25.2048;
  static const double defaultLongitude = 55.2708;
  static const double defaultZoom = 12.0;

  // Map styles - Using your custom style
  static const String customStyle =
      'mapbox://styles/garmyan/cmdxxo9l0008x01sd6sp187k2';
  static const String streetStyle = 'mapbox://styles/mapbox/streets-v12';
  static const String satelliteStyle =
      'mapbox://styles/mapbox/satellite-streets-v12';
  static const String darkStyle = 'mapbox://styles/mapbox/dark-v11';
  static const String lightStyle = 'mapbox://styles/mapbox/light-v11';
}
