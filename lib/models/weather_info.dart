class WeatherInfo {
  final double temperature;
  final int humidity;
  final String forecast;
  final String weatherIcon;

  //regular constructor
  WeatherInfo(
      {required this.temperature,
      required this.humidity,
      required this.forecast,
      required this.weatherIcon,
      });
  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
        temperature: double.parse(json['temperature']),
        humidity: int.parse(json['humidity']),
        forecast: json['forecast'].toString(),
        weatherIcon: json['weatherIcon'].toString()
        );
  }
}
