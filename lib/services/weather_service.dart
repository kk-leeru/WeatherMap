import 'dart:convert';

import 'package:flutter_application_1/models/weather_info.dart';
import 'package:http/http.dart' as http;

import '../utils/helpful.dart';

class WeatherService {
  Future<WeatherInfo> fetchWeather(double lat, double lng) async {
    //makes call to pyflask
    late WeatherInfo weather;

    // final response = await http.get(Uri.parse(
    //     'http://localhost:8080/get_weather?lat=${lat}&lng=${lng}'));
    // final response = await http.get(Uri.parse(
    //     'https://weather-kk.jojonosaur.us/get_weather?lat=${lat}&lng=${lng}'));
    final response = await http.get(Uri.parse(
            'https://fastapi-1-79wt.onrender.com/weather?lat=${lat}&lng=${lng}'));

        
    logger.i(
        "manul test pyflask: 'https://weather-kk.jojonosaur.us/get_weather?lat=${lat}&lng=${lng}");

    // var API_key = '38f33ed494f4d613172c435d00620a54';
    // final response = await http.get(Uri.parse(
    //     'https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lng}&units=${units}&appid=${API_key}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (true) {
        weather = WeatherInfo.fromJson(data);
        // forecast = data['forecast'] ?? 'Cloudy';
        // temperature = data['temperature'] ?? '25';
        // humidity = data['humidity'] ?? '30';
      }
    } else {
      logger.e(
          "can't fetch from server. Status code: ${response.statusCode}, Body: ${response.body}");
      weather = WeatherInfo(
          temperature: 0.0, humidity: 0, forecast: "Error", weatherIcon: "01d");
    }
    return weather;
  }
}
