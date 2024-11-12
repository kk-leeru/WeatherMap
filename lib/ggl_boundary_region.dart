import 'dart:convert';
import 'package:http/http.dart' as http;

import 'utils/helpful.dart';

Future<String?> getPlaceIdFromLatLng(double lat, double lng) async {
  final String apiKey = '';
  // final String url ='https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';
  final String url =
      'https://maps.googleapis.com/maps/api/geocode/json?key=$apiKey&latlng=$lat,$lng';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print("API result: ${response.body}");
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        logger.i('found something');
        return data['results'][0]['place_id'];
      }
    } else {
      logger.e('failed to retrieve page placeID');
    }
  } catch (e) {
    logger.e("Can't get placeID from api");
  }
  return null;
}

Future<Map<String, dynamic>> getPlaceDetails(String placeID) async {
  final String apiKey = '';
  final String url =
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data;
  } else {
    throw Exception('Failed to load place details');
  }
}
