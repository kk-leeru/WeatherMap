<<<<<<< HEAD
import 'dart:math';

import 'package:flutter/material.dart';
=======
>>>>>>> 3a7cfcbd3123eee81dbf43c84e859265b748199a
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

<<<<<<< HEAD
      // List<LatLng> boundaryCoords =
      //     convertCoordinates(streetInfo.geojson!.coordinates!);
      List<LatLng> boundaryCoords = convertCoordinates(streetInfo.geojson!);
      logger.i("Somebody is here");
=======
      List<LatLng> boundaryCoords =
          convertCoordinates(streetInfo.geojson!.coordinates!);

>>>>>>> 3a7cfcbd3123eee81dbf43c84e859265b748199a
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

<<<<<<< HEAD
  List<LatLng> convertCoordinates(Geojson geoJson) {
    late List<LatLng> boundaryCoords;
    //List<dynamic> geoJsonCoordinates

    // assert(geoJsonCoordinates is List<List<List<double>>>);
    try {
      // var children = geoJsonCoordinates; //triple list
      // var children = geoJsonCoordinates;
      // logger.t("Q:${children[0].runtimeType}");
      // logger.t("Q: ${children[0][0].runtimeType}"); //double list
      // logger.t("Q: ${children[0][0][0].runtimeType}"); // list
      // logger.t("Q: ${children[0][0][0][0].runtimeType}"); // double

      // while (true) {
      //   if (children.runtimeType is List<dynamic> && children[0].runtimeType is List<dynamic> &&
      //       children[0][0].runtimeType is double) {
      //     logger.t("done");
      //     break;
      //   }
      //   children = children[0];
      // }
      late var currentLevel;
      if (geoJson.type == 'MultiPolygon') {
        currentLevel = geoJson.coordinates![0];
      } else if (geoJson.type == 'Polygon') {
        currentLevel = geoJson.coordinates!;
      }
      // currentLevel = geoJsonCoordinates;

      // Drill down until we reach a List<List<double>> structure
      // while (currentLevel.isNotEmpty && currentLevel[0] is List) {
      //   // Check if we've reached the coordinate level (List<List<double>>)
      //   if (currentLevel[0] is List && currentLevel[0][0] is double) {
      //     break;
      //   }
      //   currentLevel = currentLevel[0];
      // }
      // while (true) {
      //   logger.t("Check Children: ${children.runtimeType}");
      //   if (children is List<dynamic>) {
      //     if (children.isNotEmpty &&
      //         children.every((element) => element is List<double>)) {
      //       // logger.t("Children element Type: ${children[0].runtimeType}");
      //       break;
      //     }
      //     children = children[0];
      //   }
      // }
      boundaryCoords = currentLevel[0]
=======
  List<LatLng> convertCoordinates(dynamic geoJsonCoordinates) {
    late List<LatLng> boundaryCoords;
    assert(geoJsonCoordinates is List<List<List<double>>>);
    try {
      boundaryCoords = geoJsonCoordinates[0]
>>>>>>> 3a7cfcbd3123eee81dbf43c84e859265b748199a
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
