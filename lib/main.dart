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
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'components/marker_icon.dart';
import 'services/geolocation_service.dart';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// import 'dart:js' as js;
// import GoogleMaps;

Future<void> main() async {
  logger.i("Run app entry");

  final String dummy = 'abcdefg';
  final String gglMapApiKey = dummy;
  String apiKey = dummy;
  if (kIsWeb) {
    // String apiKey = js.context['API_KEY'];
    // logger.t("APIKEY: $apiKey");
    // await DotEnv.load(fileName: ".env");
    logger.t("ENTER WEB");
    await dotenv.load(fileName: ".env");
    if (dotenv.env['GGL_MAP_API_KEY'] == null) {
      throw Exception("GGL_MAP_API_KEY not found in .env file");
    } else {
      apiKey = dotenv.env['GGL_MAP_API_KEY']!;
      logger.t("SHOW $apiKey");
    }

    runApp(MyApp(gglMapApiKey: apiKey));
  } else if (io.Platform.isAndroid) {
    // // await dotenv.load(fileName: "assets/.env");
    // // if (dotenv.env['GGL_MAP_API_KEY'] == null) {
    // //   throw Exception("GGL_MAP_API_KEY not found in .env file");
    // }
    // final String gglMapApiKey = dotenv.env['GGL_MAP_API_KEY'] ?? '';
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterConfig.loadEnvVariables();
    runApp(MyApp(gglMapApiKey: apiKey));
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
  bool _isSelectionMode = false;

  dynamic geoJsonCoordinates;
  List<LatLng> boundaryCoords = <LatLng>[];

  final Set<Marker> _markers = <Marker>{};
  // final GlobalKey globalKey = GlobalKey();

  // Define the regions using polgons
  final Set<Polygon> _districtPolygons = <Polygon>{};

  final Set<String> _selectedWeatherRegion = <String>{};
  // final Set<PolygonId> _selectedPolygonIds = <PolygonId>{};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  //toggle marker selection
  // void _toggleWeatherRegionSelected(String osmId) {
  //   setState(() {
  //     if (_selectedWeatherRegion.contains(osmId)) {
  //       _selectedWeatherRegion.remove(osmId);
  //       // _selectedPolygonIds.remove(osmId);
  //     } else {
  //       _selectedWeatherRegion.add(osmId);
  //       // _selectedPolygonIds.add(osmId);
  //     }
  //   });
  // }
  //whenever delete button is pressed (enable del selection or cancel)
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedWeatherRegion.clear(); //clear previous selections
    });
  }

  void _confirmDeletion() {
    setState(() {
      //marker is identified by markerID, value of osmid
      _markers.removeWhere(
        (marker) => _selectedWeatherRegion.contains(marker.markerId.value),
      );
      _districtPolygons.removeWhere((polygon) =>
          _selectedWeatherRegion.contains(polygon.polygonId.value));
      _selectedWeatherRegion.clear();
      _isSelectionMode = false; //exit selection mode
    });
  }

  void _selectRegion(String id) {
    setState(() {
      if (_selectedWeatherRegion.contains(id)) {
        _selectedWeatherRegion.remove(id);
      } else {
        _selectedWeatherRegion.add(id);
      }
    });
  }

  void _getCurrentLocation() async {
    try {
      //sequentially
      LatLng position = await GeolocationService.getLocation();
      _currentPosition = position;
      _isLoading = false;
      logger.t("Got location");
      //since the function below has set state
      addWeatherMarkerAndBoundary(position, true);
    } catch (e) {
      logger.e('Error in get current location: $e');
    }
  }

  void addWeatherMarkerAndBoundary(LatLng position, bool myLocation) async {
    try {
      late WeatherRegion weatherRegion;
      late BitmapDescriptor customIcon;
      try {
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
              markerId: MarkerId('${weatherRegion.osmID}'),
              position: position,
              infoWindow: InfoWindow(
                  // title: 'Current Location: ${weatherRegion.osmID}','Lat: ${position.latitude}, Lng: ${position.longitude}
                  // title: '${weatherRegion.forecast}, Temp: ${weatherRegion.temperature}°C, Humidty: ${weatherRegion.humidity}%',
                  title: '${weatherRegion.forecast}',
                  snippet:
                      'Temp: ${weatherRegion.temperature}°C, Humidty: ${weatherRegion.humidity}%'),
              // snippet: 'Temp: ${weatherRegion.temperature}°C, Humidty: ${weatherRegion.humidity}%'),
              // icon: /*BitmapDescriptor.defaultMarker,*/ //Marker icon
              icon: customIcon,
              onTap: () {
                if (_isSelectionMode) {
                  logger.t("MARKER TOUCHED");
                  _selectRegion(weatherRegion.osmID.toString());
                }
              }),
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
            onTap: () {
              if (_isSelectionMode) {
                logger.t("POLYGON TOUCHED");
                _selectRegion(weatherRegion.osmID.toString());
              }
            },
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
    SizeConfig().init(context);
    ScaleWrapper().init(context);
    logger.t("PRINT KEY: ${widget.gglMapApiKey}");
    return Scaffold(
        appBar: AppBar(
          title: const Text("Weather Region"),
        ),
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
                    mapType: MapType.normal,
                    initialCameraPosition:
                        CameraPosition(target: _currentPosition!, zoom: 17),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    markers: _markers.map((marker) {
                      final isSelected = _selectedWeatherRegion
                          .contains(marker.markerId.value);
                      return marker.copyWith(
                        iconParam: isSelected
                            ? BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueGreen)
                            : marker.icon,
                      );
                    }).toSet(),
                    polygons: _districtPolygons.map((polygon) {
                      final isSelected = _selectedWeatherRegion
                          .contains(polygon.polygonId.value);
                      return polygon.copyWith(
                        fillColorParam: isSelected
                            ? Colors.yellow.withOpacity(0.5)
                            : polygon.fillColor,
                      );
                    }).toSet(),

                    onTap: (LatLng tapPosition) {
                      if (!_isSelectionMode) {
                        logger.i(
                            "Show: ${tapPosition.latitude}, ${tapPosition.longitude}");
                        addWeatherMarkerAndBoundary(tapPosition, false);
                      }
                    },
                  ),
                ],
              ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 8.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PointerInterceptor(
                child: FloatingActionButton(
                  onPressed: _goToMyLocation,
                  child: const Icon(Icons.add_location_alt_sharp),
                  // label: const Text('My location'),
                ),
              ),
            ),
            _isSelectionMode
                ? Row(
                    children: [
                      PointerInterceptor(
                        child: FloatingActionButton(
                          // label: const Text("Confirm"),
                          onPressed: _confirmDeletion,
                          // backgroundColor: Color.fromARGB(255, 37, 223, 43),
                          child: const Icon(Icons.check),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      PointerInterceptor(
                        child: FloatingActionButton(
                          // label: const Text("Cancel"),
                          onPressed: _toggleSelectionMode,
                          // backgroundColor: Colors.red,
                          child: const Icon(Icons.close),
                        ),
                      ),
                    ],
                  )
                : PointerInterceptor(
                    child: FloatingActionButton(
                      // label: const Text('Delete Weather Region'),
                      onPressed: _toggleSelectionMode,
                      child: const Icon(Icons.highlight_remove),
                    ),
                  )
          ],
        ));
  }

  void _deleteSelectedRegions() {
    setState(() {
      _markers.removeWhere(
          (element) => _selectedWeatherRegion.contains(element.markerId.value));
      _districtPolygons.removeWhere((element) =>
          _selectedWeatherRegion.contains(element.polygonId.value));
      _selectedWeatherRegion.clear();
    });
  }

  Future<void> _goToMyLocation() async {
    final GoogleMapController controller = await _controller.future;
    LatLng updatePosition = await GeolocationService.getLocation();

    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: updatePosition, zoom: 17)));
  }
}
