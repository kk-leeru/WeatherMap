import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scale/scale.dart';
import 'dart:ui' as ui;
import 'dart:io' as io;

import '../utils/helpful.dart';

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  // SizeConfig({
  //   mediaQueryData,
  //   screenWidth,
  //   screenHeight,
  //   blockSizeHorizontal,
  //   blockSizeVertical,
  // });

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData?.size.width;
    screenHeight = _mediaQueryData?.size.height;
    blockSizeHorizontal = screenWidth! / 50;
    blockSizeVertical = screenHeight! / 50;
  }
}

class ScaleWrapper {
  void init(BuildContext context) {
    Scale.setup(
        context, Size(SizeConfig.screenWidth!, SizeConfig.screenHeight!));
  }
}

class MarkerIcon {
  // String? iconType;
  // MarkerIcon({
  //   required this.iconType
  // })
  MarkerIcon._();
  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

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

    var unit = SizeConfig.blockSizeHorizontal > SizeConfig.blockSizeVertical
        ? SizeConfig.blockSizeHorizontal
        : SizeConfig.blockSizeVertical;

    if (kIsWeb) {
      unit = unit * 2;
    } else if (io.Platform.isAndroid) {
      unit = unit * 5;
    } else {
      unit = unit * 3; 
    }
    // return await BitmapDescriptor.fromAssetImage(
    //     const ImageConfiguration(size: Size(32, 41)), path);
    logger.t("Unit: $unit");
    final Uint8List markerIcon = await getBytesFromAsset(path, (unit).toInt());
    return BitmapDescriptor.fromBytes(markerIcon);
    // return await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(size: Size(32.0* unit, 41.0* unit)), path,);

    // return await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(
    //         size: Size((Scale.scaleVertically(41)).toDouble(),
    //             Scale.scaleVertically(32).toDouble() )),
    //     path);
  }
}
