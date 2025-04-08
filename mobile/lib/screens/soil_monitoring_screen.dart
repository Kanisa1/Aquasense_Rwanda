import 'package:flutter/material.dart';
import 'package:aqua_sense/models/soil_data.dart';
import 'package:aqua_sense/services/soil_service.dart';
import 'package:aqua_sense/widgets/bottom_navigation.dart';
import 'package:aqua_sense/widgets/loading_indicator.dart';
import 'package:aqua_sense/widgets/error_display.dart';
import 'package:aqua_sense/widgets/custom_card.dart';
import 'package:aqua_sense/widgets/animated_progress_bar.dart';
import 'package:aqua_sense/widgets/stat_card.dart';
import 'package:aqua_sense/utils/app_theme.dart';

class SoilMonitoringScreen extends StatefulWidget {
  const SoilMonitoringScreen({Key? key}) : super(key: key);

  @override
  State<SoilMonitoringScreen> createState() => _SoilMonitoringScreenState();
}

class _SoilMonitoringScreenState extends State<SoilMonitoringScreen> {
  int _currentIndex = 3; // Plants tab
  bool _isLoading = true;
  String? _errorMessage;
  List<SoilData> _soilData = [];
  String? _selectedLocation;

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
      final soilService = SoilService();
      _soilData = await soilService.getAllSoilData();
      
      if (_soilData.isNotEmpty && _selectedLocation == null) {
        _selectedLocation = _soilData.first.location;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load soil data: ${e.toString()}';
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
          Navigator.pushReplacementNamed(context, '/plants');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }
    }
  }

  void _onLocationChanged(String? location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  SoilData? _getSelectedSoilData() {
    if (_selectedLocation == null) return null;
    
    final locationData = _soilData.where((data) => data.location == _selectedLocation).toList();
    if (locationData.isEmpty) return null;
    
    locationData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return locationData.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to soil data history
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
              : _soilData.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.landscape,
                            size: 80,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No soil data available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Connect soil sensors to start monitoring',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Location selector
                          CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Select Location',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: _selectedLocation,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.location_on),
                                    hintText: 'Select a location',
                                  ),
                                  items: _soilData
                                      .map((data) => data.location)
                                      .toSet()
                                      .map((location) {
                                        return DropdownMenuItem<String>(
                                          value: location,
                                          child: Text(location),
                                        );
                                      })
                                      .toList(),
                                  onChanged: _onLocationChanged,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          if (_selectedLocation != null && _getSelectedSoilData() != null) ...[
                            // Soil moisture
                            _buildSoilMoistureCard(_getSelectedSoilData()!),
                            const SizedBox(height: 20),
                            
                            // Soil properties
                            _buildSoilPropertiesCard(_getSelectedSoilData()!),
                            const SizedBox(height: 20),
                            
                            // Nutrient levels
                            _buildNutrientLevelsCard(_getSelectedSoilData()!),
                            const SizedBox(height: 20),
                            
                            // Recommendations
                            _buildRecommendationsCard(_getSelectedSoilData()!),
                          ],
                        ],
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add manual soil data entry
          Navigator.pushNamed(context, '/add_soil_data').then((_) => _loadData());
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildSoilMoistureCard(SoilData soilData) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Soil Moisture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getMoistureStatusColor(soilData.moisture).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  soilData.moistureStatus,
                  style: TextStyle(
                    color: _getMoistureStatusColor(soilData.moisture),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${soilData.moisture.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Last updated: ${_formatDateTime(soilData.timestamp)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: soilData.moisture / 100,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(_getMoistureStatusColor(soilData.moisture)),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.water_drop,
                        size: 30,
                        color: _getMoistureStatusColor(soilData.moisture),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Moisture Trend (Last 7 Days)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Moisture Trend Chart',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilPropertiesCard(SoilData soilData) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Soil Properties',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Temperature',
                  value: '${soilData.temperature.toStringAsFixed(1)}°C',
                  icon: Icons.thermostat,
                  iconColor: AppTheme.warningColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'pH Level',
                  value: soilData.ph.toStringAsFixed(1),
                  subtitle: soilData.phStatus,
                  icon: Icons.science,
                  iconColor: _getPhStatusColor(soilData.ph),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Organic Matter',
                  value: '${soilData.organicMatter.toStringAsFixed(1)}%',
                  icon: Icons.compost,
                  iconColor: Colors.brown,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'EC',
                  value: '${soilData.electricalConductivity.toStringAsFixed(1)} mS/cm',
                  icon: Icons.bolt,
                  iconColor: Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientLevelsCard(SoilData soilData) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrient Levels',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildNutrientRow('Nitrogen (N)', soilData.nitrogen, 'ppm', 0, 100),
          const SizedBox(height: 16),
          _buildNutrientRow('Phosphorus (P)', soilData.phosphorus, 'ppm', 0, 100),
          const SizedBox(height: 16),
          _buildNutrientRow('Potassium (K)', soilData.potassium, 'ppm', 0, 100),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(SoilData soilData) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommendations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb,
                  color: AppTheme.secondaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fertilizer Recommendation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(soilData.fertilizerRecommendation),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Irrigation Recommendation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Based on current soil moisture levels, adjust your irrigation schedule to maintain optimal moisture levels for your crops.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String title, double value, String unit, double min, double max) {
    final percentage = (value - min) / (max - min);
    final color = _getNutrientColor(percentage);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value $unit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedProgressBar(
          value: percentage.clamp(0.0, 1.0),
          height: 10,
          backgroundColor: Colors.grey.shade200,
          foregroundColor: color,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Low',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'Optimal',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'High',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getMoistureStatusColor(double moisture) {
    if (moisture < 20) return Colors.red;
    if (moisture < 40) return Colors.orange;
    if (moisture < 60) return AppTheme.secondaryColor;
    if (moisture < 80) return AppTheme.primaryColor;
    return Colors.blue;
  }

  Color _getPhStatusColor(double ph) {
    if (ph < 5.5) return Colors.red;
    if (ph < 7.0) return AppTheme.secondaryColor;
    if (ph < 7.5) return Colors.green;
    if (ph < 8.5) return Colors.orange;
    return Colors.red;
  }

  Color _getNutrientColor(double percentage) {
    if (percentage < 0.3) return Colors.red;
    if (percentage < 0.7) return AppTheme.secondaryColor;
    if (percentage < 0.9) return Colors.green;
    return Colors.orange;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

