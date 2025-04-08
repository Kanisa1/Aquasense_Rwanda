enum WeatherType { sunny, cloudy, rainy, partlyCloudy, night }

class WeatherData {
  final String location;
  final DateTime date;
  final WeatherType type;
  final double temperature;
  final double windSpeed;
  final double humidity;
  final double pressure;
  final double precipitation;

  WeatherData({
    required this.location,
    required this.date,
    required this.type,
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.pressure,
    required this.precipitation,
  });
}

class HourlyForecast {
  final DateTime time;
  final WeatherType type;
  final double temperature;

  HourlyForecast({
    required this.time,
    required this.type,
    required this.temperature,
  });
}

