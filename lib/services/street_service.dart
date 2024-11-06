import 'dart:convert';

import 'package:flutter_application_1/models/street_info.dart';
import 'package:flutter_application_1/utils/helpful.dart';
import 'package:http/http.dart' as http;

class StreetService {
  Future<StreetInfo> getStreet(double lat, double lng) async {
    // Map<String, dynamic> m = {};
    late StreetInfo tmp;
    try {
      var zoom = 12;
      // 0-18 zoom
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&zoom=${zoom <= 13 ? zoom : 13}&polygon_geojson=1&format=json'));
      logger.t(
          "manual test getOpenStreet: https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&zoom=$zoom&polygon_geojson=1&format=json");
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        tmp = StreetInfo.fromJson(data);

        // logger.i("Boundary: ${data['geojson']['coordinates']}");
        if (tmp.geojson?.coordinates == null) {
          throw Exception("getOpenStreet retrieved null");
        }
        logger.t("Check in getOpenStreet: ${tmp.geojson!.coordinates}");

        // m = {
        //   "osm_id": data['osm_id'],
        //   "geojson": data['geojson']['coordinates']
        // };
        // return m;
        return tmp;
        // return data['geojson']['coordinates'];
      } else {
        logger.e('cant get request for boundary');
      }
    } catch (e) {
      logger.e("Error at getOpenStreet: $e");
    }
    return tmp;
  }
}
