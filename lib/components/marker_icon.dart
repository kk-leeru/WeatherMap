import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerIcon {
  // String? iconType;
  // MarkerIcon({
  //   required this.iconType
  // })
  MarkerIcon._();

  static Future<BitmapDescriptor> getMarkerIcon(
      String IconName, bool myLocation) async {

    String path = myLocation
        ? 'assets/Weather-Region-icon/'
        : 'assets/Weather-Region-icon-other/';
    Map<String, String> openWeatherToAsset = {
      '01d': 'clear_sky_d',
      '03d': 'cloudy_dn',
      '04d': 'cloudy_dn',
      '03n': 'cloudy_dn',
      '04n': 'cloudy_dn',
      '50d': 'mist_dn',
      '50n': 'mist_dn',
      '01n': 'clear_sky_n',
      '02d': 'few_clouds_d',
      '02n': 'few_clouds_n',
      '10d': 'rain_dn',
      '10n': 'rain_dn',
      '09d': 'shower_rain_d',
      '09n': 'shower_rain_n',
      '13d': 'snow_dn',
      '13n': 'snow_dn',
      '11d': 'thunderstorm_dn',
      '11n': 'thunderstorm_dn'
    };
    path += (openWeatherToAsset[IconName]).toString();
    path += myLocation ? '' : '_other';
    path += '.png';
    // String object =
    return await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 41)), path);
  }
}
