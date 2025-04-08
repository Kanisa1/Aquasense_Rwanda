import 'package:flutter/material.dart';
import 'package:aqua_sense/models/transaction.dart';
import 'package:aqua_sense/models/user.dart';
import 'package:aqua_sense/models/plant.dart';
import 'package:aqua_sense/models/soil_data.dart';
import 'package:aqua_sense/models/weather.dart';
import 'package:aqua_sense/services/auth_service.dart';
import 'package:aqua_sense/services/transaction_service.dart';
import 'package:aqua_sense/services/plant_service.dart';
import 'package:aqua_sense/services/soil_service.dart';
import 'package:aqua_sense/services/weather_service.dart';
import 'package:aqua_sense/services/notification_service.dart';
import 'package:aqua_sense/widgets/bottom_navigation.dart';
import 'package:aqua_sense/widgets/loading_indicator.dart';
import 'package:aqua_sense/widgets/error_display.dart';
import 'package:aqua_sense/widgets/custom_card.dart';
import 'package:aqua_sense/widgets/stat_card.dart';
import 'package:aqua_sense/widgets/animated_progress_bar.dart';
import 'package:aqua_sense/utils/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  User? _currentUser;
  List<WaterTransaction> _recentTransactions = [];
  List<Plant> _plants = [];
  WeatherData? _currentWeather;
  double _averageSoilMoisture = 0;
  int _unreadNotificationsCount = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current user
      final authService = AuthService();
      _currentUser = authService.currentUser;

      // Get recent transactions
      final transactionService = TransactionService();
      _recentTransactions = await transactionService.getRecentTransactions();

      // Get plants
      final plantService = PlantService();
      _plants = await plantService.getAllPlants();

      // Get weather
      final weatherService = WeatherService();
      _currentWeather = await weatherService.getCurrentWeather();

      // Get soil moisture
      final soilService = SoilService();
      _averageSoilMoisture = await soilService.getAverageSoilMoisture();

      // Get unread notifications count
      final notificationService = NotificationService();
      final unreadNotifications = await notificationService.getUnreadNotifications();
      _unreadNotificationsCount = unreadNotifications.length;

      setState(() {
        _isLoading = false;
      });
      
      // Start animations after data is loaded
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate to different screens based on the tab index
    switch (index) {
      case 0:
        // Already on home screen
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/water_reservoirs');
        break;
      case 2:
        // Refresh action
        _loadData();
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/plants');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const LoadingIndicator()
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadData,
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // App Bar
                      SliverAppBar(
                        expandedHeight: 180.0,
                        floating: false,
                        pinned: true,
                        backgroundColor: AppTheme.primaryColor,
                        flexibleSpace: FlexibleSpaceBar(
                          title: const Text(
                            'AquaSense',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background gradient
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppTheme.primaryColor,
                                      AppTheme.primaryColor.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                              ),
                              // Decorative circles
                              Positioned(
                                top: -50,
                                right: -50,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -20,
                                left: -20,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              // User greeting
                              Positioned(
                                bottom: 60,
                                left: 16,
                                right: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back, ${_currentUser?.name ?? 'Farmer'}!',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Here\'s your farm overview for today',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          // Notifications button
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/notifications');
                                },
                              ),
                              if (_unreadNotificationsCount > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      _unreadNotificationsCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          // Settings button
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              Navigator.pushNamed(context, '/settings');
                            },
                          ),
                        ],
                      ),
                      
                      // Content
                      SliverToBoxAdapter(
                        child: AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Weather card
                                    if (_currentWeather != null) _buildWeatherCard(),
                                    const SizedBox(height: 24),
                                    
                                    // Stats overview
                                    _buildStatsOverview(),
                                    const SizedBox(height: 24),
                                    
                                    // Plants overview
                                    _buildPlantsOverview(),
                                    const SizedBox(height: 24),
                                    
                                    // Recent activity
                                    _buildRecentActivity(),
                                    
                                    // Add extra space at the bottom for the navigation bar
                                    const SizedBox(height: 80),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildWeatherCard() {
    return CustomCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _getWeatherColor(_currentWeather!.type),
          _getWeatherColor(_currentWeather!.type).withOpacity(0.7),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: _getWeatherColor(_currentWeather!.type).withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_currentWeather!.temperature.toInt()}°C',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _currentWeather!.location,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.water_drop,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Humidity: ${_currentWeather!.humidity.toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.air,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Wind: ${_currentWeather!.windSpeed.toInt()} km/h',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _getWeatherIcon(_currentWeather!.type, size: 80, color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/weather');
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
            ),
            child: const Text('View Forecast'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Farm Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Water Level',
                value: '68%',
                icon: Icons.water_drop,
                iconColor: AppTheme.primaryColor,
                showTrend: true,
                trendValue: 5.2,
                isPositiveTrend: true,
                onTap: () {
                  Navigator.pushNamed(context, '/water_reservoirs');
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Soil Moisture',
                value: '${_averageSoilMoisture.toInt()}%',
                icon: Icons.landscape,
                iconColor: AppTheme.secondaryColor,
                showTrend: true,
                trendValue: 2.8,
                isPositiveTrend: false,
                onTap: () {
                  Navigator.pushNamed(context, '/soil_monitoring');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Plants',
                value: _plants.length.toString(),
                icon: Icons.grass,
                iconColor: Colors.green,
                onTap: () {
                  Navigator.pushNamed(context, '/plants');
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Transactions',
                value: _recentTransactions.length.toString(),
                icon: Icons.receipt_long,
                iconColor: Colors.purple,
                onTap: () {
                  Navigator.pushNamed(context, '/water_transactions');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Water usage chart
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Water Usage',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/dashboard');
                    },
                    child: const Text('More'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: _buildWaterUsageChart(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlantsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Plants & Crops',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/plants');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _plants.isEmpty
            ? CustomCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.grass,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No plants or crops added yet',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/add_plant');
                          },
                          child: const Text('Add Plant'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _plants.length,
                  itemBuilder: (context, index) {
                    final plant = _plants[index];
                    return _buildPlantCard(plant);
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildPlantCard(Plant plant) {
    final daysToHarvest = plant.daysToHarvest;
    final growthPercentage = plant.growthPercentage;
    
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      child: CustomCard(
        padding: EdgeInsets.zero,
        onTap: () {
          Navigator.pushNamed(
            context,
            '/plant_details',
            arguments: {'id': plant.id},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plant image or icon
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                image: plant.imageUrl != null
                    ? DecorationImage(
                        image: AssetImage(plant.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: plant.imageUrl == null
                  ? Icon(
                      _getPlantTypeIcon(plant.type),
                      size: 40,
                      color: AppTheme.primaryColor,
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plant.location,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    daysToHarvest > 0
                        ? '$daysToHarvest days to harvest'
                        : 'Ready for harvest!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: daysToHarvest > 0 ? Colors.grey.shade700 : AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedProgressBar(
                    value: growthPercentage,
                    height: 8,
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: AppTheme.secondaryColor,
                    showShadow: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/water_transactions');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _recentTransactions.isEmpty
            ? CustomCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No recent transactions',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Column(
                children: _recentTransactions.map((transaction) {
                  final isPositive = transaction.amount > 0;
                  
                  return CustomCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    onTap: () {
                      // Navigate to transaction details
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: (isPositive ? AppTheme.successColor : AppTheme.primaryColor).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isPositive ? Icons.add_circle : Icons.water_drop,
                            color: isPositive ? AppTheme.successColor : AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.reservoirName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                transaction.location,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isPositive ? '+' : '-'} ${transaction.amount.abs()} L',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isPositive ? AppTheme.successColor : Colors.red,
                              ),
                            ),
                            Text(
                              _formatDate(transaction.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildWaterUsageChart() {
    // Sample data for water usage
    final List<FlSpot> spots = [
      const FlSpot(0, 3),
      const FlSpot(1, 2),
      const FlSpot(2, 5),
      const FlSpot(3, 3.1),
      const FlSpot(4, 4),
      const FlSpot(5, 3),
      const FlSpot(6, 4),
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                final index = value.toInt();
                if (index >= 0 && index < days.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8.0,
                    child: Text(days[index]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text('${value.toInt()} kL'),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlantTypeIcon(PlantType type) {
    switch (type) {
      case PlantType.crop:
        return Icons.grass;
      case PlantType.tree:
        return Icons.park;
      case PlantType.vegetable:
        return Icons.eco;
      case PlantType.fruit:
        return Icons.apple;
      case PlantType.flower:
        return Icons.local_florist;
      case PlantType.herb:
        return Icons.spa;
    }
  }

  Widget _getWeatherIcon(WeatherType type, {double size = 80, Color? color}) {
    IconData iconData;
    Color iconColor = color ?? Colors.white;

    switch (type) {
      case WeatherType.sunny:
        iconData = Icons.wb_sunny;
        iconColor = color ?? Colors.orange;
        break;
      case WeatherType.cloudy:
        iconData = Icons.cloud;
        iconColor = color ?? Colors.grey;
        break;
      case WeatherType.rainy:
        iconData = Icons.water_drop;
        iconColor = color ?? Colors.blue;
        break;
      case WeatherType.partlyCloudy:
        iconData = Icons.cloud_queue;
        iconColor = color ?? Colors.grey;
        break;
      case WeatherType.night:
        iconData = Icons.nightlight_round;
        iconColor = color ?? Colors.indigo;
        break;
    }

    return Icon(
      iconData,
      size: size,
      color: iconColor,
    );
  }

  Color _getWeatherColor(WeatherType type) {
    switch (type) {
      case WeatherType.sunny:
        return Colors.orange;
      case WeatherType.cloudy:
        return Colors.blueGrey;
      case WeatherType.rainy:
        return Colors.blue;
      case WeatherType.partlyCloudy:
        return Colors.lightBlue;
      case WeatherType.night:
        return Colors.indigo;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

