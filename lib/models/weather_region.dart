import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WeatherRegion {
  final double temperature;
  final int humidity;
  final String forecast;
  // final double lat;
  // final double lng;
  final List<LatLng> boundaryCoordinates;
  final int osmID;
  final String weatherIcon;

  WeatherRegion({
    required this.temperature,
    required this.humidity,
    required this.forecast,
    required this.boundaryCoordinates,
    required this.osmID,
    required this.weatherIcon,
  });
}
