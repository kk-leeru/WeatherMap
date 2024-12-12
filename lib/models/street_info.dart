import 'dart:core';

class StreetInfo {
  int? placeId;
  String? licence;
  String? osmType;
  int? osmId;
  String? lat;
  String? lon;
  String? classType;
  String? type;
  int? placeRank;
  double? importance;
  String? addresstype;
  String? name;
  String? displayName;
  Address? address;
  List<String>? boundingbox;
  Geojson? geojson;

  StreetInfo(
      {this.placeId,
      this.licence,
      this.osmType,
      this.osmId,
      this.lat,
      this.lon,
      this.classType,
      this.type,
      this.placeRank,
      this.importance,
      this.addresstype,
      this.name,
      this.displayName,
      this.address,
      this.boundingbox,
      this.geojson})
      : assert(address is Address),
      assert(geojson is Geojson);

  StreetInfo.fromJson(Map<String, dynamic> json) {
    placeId = json['place_id'];
    licence = json['licence'];
    osmType = json['osm_type'];
    osmId = json['osm_id'];
    lat = json['lat'];
    lon = json['lon'];
    classType = json['class'];
    type = json['type'];
    placeRank = json['place_rank'];
    importance = json['importance'];
    addresstype = json['addresstype'];
    name = json['name'];
    displayName = json['display_name'];
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    boundingbox = json['boundingbox'].cast<String>();
    geojson =
        json['geojson'] != null ? new Geojson.fromJson(json['geojson']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['place_id'] = this.placeId;
    data['licence'] = this.licence;
    data['osm_type'] = this.osmType;
    data['osm_id'] = this.osmId;
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    data['class'] = this.classType;
    data['type'] = this.type;
    data['place_rank'] = this.placeRank;
    data['importance'] = this.importance;
    data['addresstype'] = this.addresstype;
    data['name'] = this.name;
    data['display_name'] = this.displayName;
    if (this.address != null) {
      data['address'] = this.address!.toJson();
    }
    data['boundingbox'] = this.boundingbox;
    if (this.geojson != null) {
      data['geojson'] = this.geojson!.toJson();
    }
    return data;
  }
}

class Address {
  String? neighbourhood;
  String? suburb;
  String? village;
  String? city;
  String? iSO31662Lvl4;
  String? postCode;
  String? country;
  String? countryCode;

  Address(
      {this.neighbourhood,
      this.suburb,
      this.village,
      this.city,
      this.iSO31662Lvl4,
      this.postCode,
      this.country,
      this.countryCode});

  Address.fromJson(Map<String, dynamic> json) {
    neighbourhood = json['neighbourhood'];
    suburb = json['suburb'];
    village = json['village'];
    city = json['city'];
    iSO31662Lvl4 = json['ISO3166-2-lvl4'];
    postCode = json['postcode'];
    country = json['country'];
    countryCode = json['country_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['neighbourhood'] = this.neighbourhood;
    data['suburb'] = this.suburb;
    data['village'] = this.village;
    data['city'] = this.city;
    data['ISO3166-2-lvl4'] = this.iSO31662Lvl4;
    data['postcode'] = this.postCode;
    data['country'] = this.country;
    data['country_code'] = this.countryCode;
    return data;
  }
}

class Geojson {
  String? type;
  List<dynamic>? coordinates;

  //constructor 
  Geojson({this.type, this.coordinates});

  factory Geojson.fromJson(Map<String, dynamic> json) {
    return Geojson(
      type: json['type'],
      // coordinates: List<List<List<double>>>.from(json['coordinates'].map(
      //     (item) => List<List<double>>.from(
      //         item.map((coord) => List<double>.from(coord))))),
      coordinates: json['coordinates']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates
          ?.map((item) => item.map((coord) => coord).toList())
          .toList(),
    };
  }

  // Geojson.fromJson(Map<String, dynamic> json) {
  // 	type = json['type'];
  // 	if (json['coordinates'] != null) {
  // 		coordinates = <List>[];
  // 		json['coordinates'].forEach((v) { coordinates!.add(new List.fromJson(v)); });
  // 	}
  // }

  // Map<String, dynamic> toJson() {
  // 	final Map<String, dynamic> data = new Map<String, dynamic>();
  // 	data['type'] = this.type;
  // 	if (this.coordinates != null) {
  //   data['coordinates'] = this.coordinates!.map((v) => v.toJson()).toList();
  // }
  // 	return data;
  // }
}

// class Coordinates {


// 	Coordinates({});

// 	Coordinates.fromJson(Map<String, dynamic> json) {
// 	}

// 	Map<String, dynamic> toJson() {
// 		final Map<String, dynamic> data = new Map<String, dynamic>();
// 		return data;
// 	}
// }
