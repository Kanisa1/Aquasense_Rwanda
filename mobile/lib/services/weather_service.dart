import 'package:aqua_sense/models/weather.dart';

class WeatherService {
  // Singleton pattern
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  // Mock weather data
  final WeatherData _currentWeather = WeatherData(
    location: 'Kigali',
    date: DateTime(2021, 1, 25),
    type: WeatherType.sunny,
    temperature: 23.0,
    windSpeed: 31.0,
    humidity: 86.0,
    pressure: 1013.0,
    precipitation: 6.0,
  );

  final List<WeatherData> _dailyForecast = [
    WeatherData(
      location: 'Kigali',
      date: DateTime(2021, 1, 25),
      type: WeatherType.sunny,
      temperature: 28.0,
      windSpeed: 31.0,
      humidity: 86.0,
      pressure: 1013.0,
      precipitation: 6.0,
    ),
    WeatherData(
      location: 'Kigali',
      date: DateTime(2021, 1, 25),
      type: WeatherType.partlyCloudy,
      temperature: 23.0,
      windSpeed: 31.0,
      humidity: 86.0,
      pressure: 1013.0,
      precipitation: 6.0,
    ),
    WeatherData(
      location: 'Kigali',
      date: DateTime(2021, 1, 25),
      type: WeatherType.night,
      temperature: 18.0,
      windSpeed: 31.0,
      humidity: 86.0,
      pressure: 1013.0,
      precipitation: 6.0,
    ),
  ];

  final List<HourlyForecast> _hourlyForecast = [
    HourlyForecast(
      time: DateTime(2021, 1, 25, 20, 0),
      type: WeatherType.night,
      temperature: 18.0,
    ),
    HourlyForecast(
      time: DateTime(2021, 1, 25, 21, 0),
      type: WeatherType.night,
      temperature: 18.0,
    ),
    HourlyForecast(
      time: DateTime(2021, 1, 25, 22, 0),
      type: WeatherType.night,
      temperature: 18.0,
    ),
    HourlyForecast(
      time: DateTime(2021, 1, 25, 23, 0),
      type: WeatherType.night,
      temperature: 18.0,
    ),
  ];

  // Get current weather
  Future<WeatherData> getCurrentWeather() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _currentWeather;
  }

  // Get daily forecast
  Future<List<WeatherData>> getDailyForecast() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _dailyForecast;
  }

  // Get hourly forecast
  Future<List<HourlyForecast>> getHourlyForecast() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _hourlyForecast;
  }
}

