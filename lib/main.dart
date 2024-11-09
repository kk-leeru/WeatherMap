import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/weather_region.dart';
import 'package:flutter_application_1/repositories/weather_region_repository.dart';
import 'package:flutter_application_1/utils/helpful.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'components/marker_icon.dart';
import 'services/geolocation_service.dart';

import 'package:geocoding/geocoding.dart';
import 'ggl_boundary_region.dart';
import 'package:http/http.dart' as http;
// import 'dart:js' as js;
// import GoogleMaps;

Future<void> main() async {
  logger.i("Run app entry");

  final String dummy = 'abcdefg';
  final String gglMapApiKey = dummy;
  final String apiKey = dummy;
  if (kIsWeb) {
    // String apiKey = js.context['API_KEY'];
    // logger.t("APIKEY: $apiKey");
    runApp(MyApp(gglMapApiKey: apiKey));
  } else if (io.Platform.isAndroid) {
    // // await dotenv.load(fileName: "assets/.env");
    // // if (dotenv.env['GGL_MAP_API_KEY'] == null) {
    // //   throw Exception("GGL_MAP_API_KEY not found in .env file");
    // }
    // final String gglMapApiKey = dotenv.env['GGL_MAP_API_KEY'] ?? '';
    runApp(MyApp(gglMapApiKey: gglMapApiKey));
  } else if (io.Platform.isIOS) {
    // final String gglMapApiKey = dotenv.env['GGL_MAP_API_KEY'] ?? '';
    runApp(MyApp(
      gglMapApiKey: gglMapApiKey,
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.gglMapApiKey});
  final String gglMapApiKey;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    logger.i('Build home page');
    // final String gglMapApiKey = dotenv.get('GGL_MAP_API_KEY');

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
          title: 'Flutter Demo Home Page', gglMapApiKey: gglMapApiKey),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key, required this.title, required this.gglMapApiKey});

  final String title;
  final String gglMapApiKey;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final WeatherRegionRepository _weatherRegionRepository =
      WeatherRegionRepository();

  // final GeolocationService _geolocationService = GeolocationService();

  LatLng? _currentPosition;
  bool _isLoading = true;
  String forecast = 'Loading...';
  String temperature = "Loading...";
  String humidity = "Loading...";
  String address = "Loading...";
  var region;
  dynamic geoJsonCoordinates;
  List<LatLng> boundaryCoords = <LatLng>[];

  final Set<Marker> _markers = <Marker>{};
  final GlobalKey globalKey = GlobalKey();

  // Define the regions using polgons
  final Set<Polygon> _districtPolygons = <Polygon>{};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      //sequentially
      LatLng position = await GeolocationService.getLocation();
      _currentPosition = position;
      _isLoading = false;
      //since the function below has set state
      addWeatherMarkerAndBoundary(position, true);
    } catch (e) {
      logger.e('Error in get current location: $e');
    }
  }

  void addWeatherMarkerAndBoundary(LatLng position, bool myLocation) async {
    try {
      // var osmID;
      // String? placeID =
      //     await getPlaceIdFromLatLng(position.latitude, position.longitude);
      //scarpe
      // final response = await http.get(Uri.parse('http://192.168.1.107:8080/scrape/lat=${position.latitude},lng=${position.longitude}'));

      //using py-flask
      // final response = await http.get(Uri.parse(
      //     'http://localhost:8080/get_weather?lat=${position.latitude}&lng=${position.longitude}'));
      // logger.i(
      //     "manul test pyflask: 'http://192.168.1.157:8080/get_weather?lat=${position.latitude}&lng=${position.longitude}");

      // var API_key = '38f33ed494f4d613172c435d00620a54';
      // final response = await http.get(Uri.parse(
      //     'https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lng}&units=${units}&appid=${API_key}'));

      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   if (true) {
      //     forecast = data['forecast'] ?? 'Cloudy';
      //     temperature = data['temperature'] ?? '25';
      //     humidity = data['humidity'] ?? '30';
      //   }
      // } else {
      //   logger.e(
      //       "can't fetch from server. Status code: ${response.statusCode}, Body: ${response.body}");
      // }

      // await eat(position.latitude, position.longitude);
      // var geoJsonCoordinates;

      // Map<String, dynamic> tmp =
      //     await getBoundary(position.latitude, position.longitude);
      late WeatherRegion weatherRegion;
      late BitmapDescriptor customIcon;
      try {
        // osmID = tmp["osm_id"];
        // geoJsonCoordinates = tmp["geojson"];
        // convertCoordinates(geoJsonCoordinates);

        //REFACTOR
        weatherRegion = await _weatherRegionRepository.getWeatherRegion(
            position.latitude, position.longitude);

        logger.t(
            "TEST REFACTOR weatherRegion: ${weatherRegion.osmID}, ${weatherRegion.temperature}, ${weatherRegion.humidity}, ${weatherRegion.forecast}, ${weatherRegion.boundaryCoordinates}");
        boundaryCoords = weatherRegion.boundaryCoordinates;

        // customIcon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(55,55)), './clear_sky_d.png');
        customIcon = await MarkerIcon.getMarkerIcon(
            weatherRegion.weatherIcon, myLocation);
      } catch (e) {
        throw Exception("ERROR HERE: $e");
      }
      logger.t("Check boundaryCoords= $boundaryCoords");
      setState(() {
        //update the marker
        // _currentPosition = position;
        // _isLoading = false;
        //add markers when map is initialized
        _markers.add(
          Marker(
            markerId: MarkerId('osm_id=${weatherRegion.osmID}'),
            position: position,
            infoWindow: InfoWindow(
                // title: 'Current Location: ${weatherRegion.osmID}','Lat: ${position.latitude}, Lng: ${position.longitude}
                // title: '${weatherRegion.forecast}, Temp: ${weatherRegion.temperature}°C, Humidty: ${weatherRegion.humidity}%',
                title: '',
                snippet:
                    '${weatherRegion.forecast}, Temp: ${weatherRegion.temperature}°C, Humidty: ${weatherRegion.humidity}%'),
            // snippet: 'Temp: ${weatherRegion.temperature}°C, Humidty: ${weatherRegion.humidity}%'),
            // icon: /*BitmapDescriptor.defaultMarker,*/ //Marker icon
            icon: customIcon,
          ),
        );
        //update polygon
        _districtPolygons.add(
          Polygon(
            polygonId: PolygonId('${weatherRegion.osmID}'),
            points: boundaryCoords,
            strokeColor: myLocation ? Colors.red : Colors.blue,
            strokeWidth: 2,
            fillColor: /*Colors
                .transparent*/
                const Color.fromARGB(0, 255, 255, 255).withOpacity(0.5),
          ),
        );
      });
    } catch (e) {
      logger.e('Error in get current location: $e');
    } finally {
      return null;
    }
  }

  //function to add marker at specific position
  void _addMarker(LatLng position) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()), //use position as unique)
          position: position,
          infoWindow: InfoWindow(
            title: 'New Marker',
            snippet: 'Fetch Weather API',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    });
  }

  convertCoordinates(dynamic geoJsonCoordinates) {
    //NOTE: geoJsonCoordinates format is [[[lng, lat], ... ]]]
    try {
      boundaryCoords = geoJsonCoordinates[0]
          .map((item) {
            // logger.i("show each item= ${item[0].runtimeType}");
            if (item is List && item.length >= 2) {
              double lat_tmp = item[1] is double ? item[1] : item[1].toDouble();
              double lng_tmp = item[0] is double ? item[0] : item[0].toDouble();
              logger.t("lat_tmp= $lat_tmp, lng_tmp= $lng_tmp");
              return LatLng(lat_tmp, lng_tmp);
            } else {
              logger.e(
                  "invalid item format: ${item[0].runtimeType} and ${item[1].runtimeType}");
            }
          })
          .where((latlng) => latlng != null)
          .cast<LatLng>()
          .toList();
      logger.i("check: ${boundaryCoords.runtimeType}");
      logger.i("Check value of List<LatLng>= $boundaryCoords");
      //create polgyons for each district
    } catch (e) {
      logger.e("Error found in createDistrictPolgyon: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.t("PRINT KEY: ${widget.gglMapApiKey}");
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                // MyMarker(globalKey),

                GoogleMap(
                  // key: Key(widget.gglMapApiKey),
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                    new Factory<OneSequenceGestureRecognizer>(
                      () => new EagerGestureRecognizer(),
                    ),
                  ].toSet(),
                  mapType: MapType.hybrid,
                  initialCameraPosition:
                      CameraPosition(target: _currentPosition!, zoom: 17),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: _markers,
                  polygons: _districtPolygons,

                  onTap: (LatLng tapPosition) {
                    logger.i(
                        "Show: ${tapPosition.latitude}, ${tapPosition.longitude}");
                    addWeatherMarkerAndBoundary(tapPosition, false);
                  },
                  // onTap: (LatLng position) {
                  //   print('Tapped at this $position');
                  // },
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToMyLocation,
        label: const Text('My location'),
        icon: const Icon(Icons.add_location_alt_sharp),
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    final GoogleMapController controller = await _controller.future;
    LatLng updatePosition = await GeolocationService.getLocation();

    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: updatePosition, zoom: 17)));
  }
}
