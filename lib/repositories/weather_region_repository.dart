import 'package:flutter_application_1/models/street_info.dart';
import 'package:flutter_application_1/models/weather_info.dart';
import 'package:flutter_application_1/models/weather_region.dart';
import 'package:flutter_application_1/services/street_service.dart';
import 'package:flutter_application_1/services/weather_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/helpful.dart';

class WeatherRegionRepository {
  final WeatherService _weatherService = WeatherService();
  final StreetService _streetService = StreetService();

  Future<WeatherRegion> getWeatherRegion(double lat, double lng) async {
    late WeatherRegion weatherRegion;
    try {
      WeatherInfo weatherInfo = await _weatherService.fetchWeather(lat, lng);
      StreetInfo streetInfo = await _streetService.getStreet(lat, lng);

      List<LatLng> boundaryCoords =
          convertCoordinates(streetInfo.geojson!.coordinates!);

      //convert the street
      return weatherRegion = WeatherRegion(
        temperature: weatherInfo.temperature,
        humidity: weatherInfo.humidity,
        forecast: weatherInfo.forecast,
        boundaryCoordinates: boundaryCoords,
        osmID: streetInfo.osmId!,
        weatherIcon: weatherInfo.weatherIcon,
      );
    } catch (e) {
      logger.e("Error in weather region repos: $e");
    }
    return weatherRegion;
  }

  List<LatLng> convertCoordinates(dynamic geoJsonCoordinates) {
    late List<LatLng> boundaryCoords;
    assert(geoJsonCoordinates is List<List<List<double>>>);
    try {
      boundaryCoords = geoJsonCoordinates[0]
          .map((item) {
            if (item.length >= 2) {
              double lat_tmp = item[1];
              double lng_tmp = item[0];
              logger.t("lat_tmp=$lat_tmp, lng_tmp=$lng_tmp");
              return LatLng(lat_tmp, lng_tmp);
            } else {
              logger.e(
                  "invalid item format: ${item[0].runtimeType} and ${item[1].runtimeType}");
            }
          })
          .where((latlng) => latlng != null)
          .cast<LatLng>()
          .toList();
    } catch (e) {
      logger
          .e("error found in weather_region_repository convertCoordinates: $e");
    }
    logger.i("CHECK REPOS Convert Coord: $boundaryCoords");
    return boundaryCoords;
  }
}
