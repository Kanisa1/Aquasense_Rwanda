import 'package:flutter/material.dart';
import 'package:aqua_sense/models/weather.dart';
import 'package:aqua_sense/services/weather_service.dart';
import 'package:aqua_sense/widgets/bottom_navigation.dart';
import 'package:aqua_sense/widgets/loading_indicator.dart';
import 'package:aqua_sense/widgets/error_display.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  int _currentIndex = 0; // Home tab
  int _selectedTimeIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<WeatherData> _dailyForecast = [];
  List<HourlyForecast> _hourlyForecast = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weatherService = WeatherService();
      _dailyForecast = await weatherService.getDailyForecast();
      _hourlyForecast = await weatherService.getHourlyForecast();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load weather data: ${e.toString()}';
      });
    }
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });

      // Navigate to different screens based on the tab index
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/water_reservoirs');
          break;
        case 2:
          // Refresh action
          _loadData();
          break;
        case 3:
          // Plants/Settings screen
          break;
        case 4:
          // Profile screen
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadData,
                )
              : _dailyForecast.isEmpty
                  ? const Center(
                      child: Text(
                        'No weather data available',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date
                            Text(
                              _formatDate(_dailyForecast[0].date),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Time of day tabs
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildTimeTab('MORNING', 0),
                                _buildTimeTab('DAY', 1),
                                _buildTimeTab('NIGHT', 2),
                              ],
                            ),
                            const SizedBox(height: 30),
                            
                            // Current temperature and location
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_dailyForecast[_selectedTimeIndex].temperature.toInt()}°C',
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _dailyForecast[_selectedTimeIndex].location,
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                // Weather icon
                                _getWeatherIcon(_dailyForecast[_selectedTimeIndex].type),
                              ],
                            ),
                            const SizedBox(height: 30),
                            
                            // Hourly forecast
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _hourlyForecast.length,
                                itemBuilder: (context, index) {
                                  final hourlyData = _hourlyForecast[index];
                                  return Container(
                                    width: 80,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      children: [
                                        Text(
                                          _formatTime(hourlyData.time),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _getWeatherIcon(hourlyData.type, size: 24),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${hourlyData.temperature.toInt()}°C',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            // Weather details
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildWeatherDetail(
                                  'Wind',
                                  '${_dailyForecast[_selectedTimeIndex].windSpeed.toInt()} km/h',
                                  Icons.air,
                                ),
                                _buildWeatherDetail(
                                  'Moisture',
                                  '${_dailyForecast[_selectedTimeIndex].humidity.toInt()}%',
                                  Icons.water_drop,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildWeatherDetail(
                                  'Pressure',
                                  '${_dailyForecast[_selectedTimeIndex].pressure.toInt()} hPa',
                                  Icons.speed,
                                ),
                                _buildWeatherDetail(
                                  'Precipitation',
                                  '${_dailyForecast[_selectedTimeIndex].precipitation} mm komende 4 uur',
                                  Icons.umbrella,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildTimeTab(String title, int index) {
    final isSelected = _selectedTimeIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String title, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _getWeatherIcon(WeatherType type, {double size = 80}) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case WeatherType.sunny:
        iconData = Icons.wb_sunny;
        iconColor = Colors.orange;
        break;
      case WeatherType.cloudy:
        iconData = Icons.cloud;
        iconColor = Colors.grey;
        break;
      case WeatherType.rainy:
        iconData = Icons.water_drop;
        iconColor = Colors.blue;
        break;
      case WeatherType.partlyCloudy:
        iconData = Icons.cloud_queue;
        iconColor = Colors.grey;
        break;
      case WeatherType.night:
        iconData = Icons.nightlight_round;
        iconColor = Colors.indigo;
        break;
    }

    return Icon(
      iconData,
      size: size,
      color: iconColor,
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    
    return '$dayName, $monthName ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

