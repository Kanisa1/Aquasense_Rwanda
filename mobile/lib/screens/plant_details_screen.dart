import 'package:flutter/material.dart';
import 'package:aqua_sense/models/plant.dart';
import 'package:aqua_sense/models/soil_data.dart';
import 'package:aqua_sense/services/plant_service.dart';
import 'package:aqua_sense/services/soil_service.dart';
import 'package:aqua_sense/widgets/bottom_navigation.dart';
import 'package:aqua_sense/widgets/loading_indicator.dart';
import 'package:aqua_sense/widgets/error_display.dart';
import 'package:aqua_sense/widgets/animated_progress_bar.dart';
import 'package:aqua_sense/widgets/custom_card.dart';
import 'package:aqua_sense/utils/app_theme.dart';

class PlantDetailsScreen extends StatefulWidget {
  const PlantDetailsScreen({Key? key}) : super(key: key);

  @override
  State<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 3; // Plants tab
  bool _isLoading = true;
  String? _errorMessage;
  Plant? _plant;
  SoilData? _soilData;
  late TabController _tabController;
  final List<String> _tabs = ['Overview', 'Irrigation', 'Notes', 'Analytics'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final plantId = args?['id'] ?? 1;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final plantService = PlantService();
      _plant = await plantService.getPlantById(plantId);
      
      if (_plant != null) {
        final soilService = SoilService();
        _soilData = await soilService.getLatestSoilDataByLocation(_plant!.location);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load plant details: ${e.toString()}';
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
          Navigator.pop(context);
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }
    }
  }

  void _addNote() {
    // Show dialog to add a note
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter your note here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Add note logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note added successfully')),
              );
              _loadData();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_plant?.name ?? 'Plant Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit plant screen
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                // Show delete confirmation
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Plant'),
                    content: const Text('Are you sure you want to delete this plant? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Plant deleted successfully')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadData,
                )
              : _plant == null
                  ? const ErrorDisplay(
                      message: 'Plant not found',
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(),
                        _buildIrrigationTab(),
                        _buildNotesTab(),
                        _buildAnalyticsTab(),
                      ],
                    ),
      floatingActionButton: _tabController.index == 2
          ? FloatingActionButton(
              onPressed: _addNote,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_plant == null) return const SizedBox.shrink();
    
    final daysToHarvest = _plant!.daysToHarvest;
    final growthPercentage = _plant!.growthPercentage;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plant image or icon
          if (_plant!.imageUrl != null)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(_plant!.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getPlantTypeIcon(_plant!.type),
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
          const SizedBox(height: 20),
          
          // Basic info
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Species', _plant!.species),
                _buildInfoRow('Type', _getPlantTypeName(_plant!.type)),
                _buildInfoRow('Planted Date', _formatDate(_plant!.plantedDate)),
                _buildInfoRow('Location', _plant!.location),
                _buildInfoRow('Area', '${_plant!.area} m²'),
                _buildInfoRow('Water Requirement', '${_plant!.waterRequirement} L/day'),
                _buildInfoRow('Expected Yield', '${_plant!.expectedYield} kg'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Growth progress
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Growth Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Stage',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getGrowthStageColor(_plant!.currentStage),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getGrowthStageName(_plant!.currentStage),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Days to Harvest',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      daysToHarvest > 0
                          ? '$daysToHarvest days'
                          : 'Ready for harvest!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: daysToHarvest > 0 ? Colors.black : AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedProgressBar(
                  value: growthPercentage,
                  height: 16,
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: AppTheme.secondaryColor,
                  showPercentage: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Soil data
          if (_soilData != null)
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Soil Conditions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Moisture', '${_soilData!.moisture.toStringAsFixed(1)}% (${_soilData!.moistureStatus})'),
                  _buildInfoRow('Temperature', '${_soilData!.temperature.toStringAsFixed(1)}°C'),
                  _buildInfoRow('pH Level', '${_soilData!.ph.toStringAsFixed(1)} (${_soilData!.phStatus})'),
                  _buildInfoRow('Last Updated', _formatDateTime(_soilData!.timestamp)),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Recommendation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_soilData!.fertilizerRecommendation),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIrrigationTab() {
    if (_plant == null) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Irrigation Schedule',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Navigate to edit irrigation schedule
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._plant!.irrigationSchedule.map((schedule) => _buildScheduleItem(schedule)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Water Usage',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Daily Requirement', '${_plant!.waterRequirement} L'),
                _buildInfoRow('Weekly Requirement', '${(_plant!.waterRequirement * 7).toStringAsFixed(1)} L'),
                _buildInfoRow('Monthly Requirement', '${(_plant!.waterRequirement * 30).toStringAsFixed(1)} L'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          ElevatedButton.icon(
            onPressed: () {
              // Trigger manual irrigation
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Manual Irrigation'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('How much water would you like to apply?'),
                      const SizedBox(height: 16),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount (L)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Irrigation started')),
                        );
                      },
                      child: const Text('Start'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.water_drop),
            label: const Text('Manual Irrigation'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    if (_plant == null) return const SizedBox.shrink();
    
    return _plant!.notes.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  size: 80,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No notes yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap the + button to add your first note',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _plant!.notes.length,
            itemBuilder: (context, index) {
              final note = _plant!.notes[index];
              return CustomCard(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(note.date),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () {
                            // Delete note
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(note.note),
                    if (note.imageUrl != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(note.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
  }

  Widget _buildAnalyticsTab() {
    if (_plant == null) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Growth Analytics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Growth Chart',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Water Usage Analytics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Water Usage Chart',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yield Prediction',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Expected Yield', '${_plant!.expectedYield} kg'),
                _buildInfoRow('Current Estimate', '${(_plant!.expectedYield * _plant!.growthPercentage).toStringAsFixed(1)} kg'),
                _buildInfoRow('Harvest Date', _formatDate(_plant!.plantedDate.add(Duration(days: _plant!.estimatedHarvestDays)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(IrrigationSchedule schedule) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = days[schedule.dayOfWeek - 1];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                dayName.substring(0, 3),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${schedule.time.format(context)} - ${schedule.amount} L',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: schedule.isActive,
            onChanged: (value) {
              // Toggle schedule active state
            },
            activeColor: AppTheme.primaryColor,
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

  String _getPlantTypeName(PlantType type) {
    switch (type) {
      case PlantType.crop:
        return 'Crop';
      case PlantType.tree:
        return 'Tree';
      case PlantType.vegetable:
        return 'Vegetable';
      case PlantType.fruit:
        return 'Fruit';
      case PlantType.flower:
        return 'Flower';
      case PlantType.herb:
        return 'Herb';
    }
  }

  String _getGrowthStageName(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.seed:
        return 'Seed';
      case GrowthStage.seedling:
        return 'Seedling';
      case GrowthStage.vegetative:
        return 'Vegetative';
      case GrowthStage.budding:
        return 'Budding';
      case GrowthStage.flowering:
        return 'Flowering';
      case GrowthStage.ripening:
        return 'Ripening';
      case GrowthStage.harvesting:
        return 'Harvesting';
    }
  }

  Color _getGrowthStageColor(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.seed:
        return Colors.brown;
      case GrowthStage.seedling:
        return Colors.lightGreen;
      case GrowthStage.vegetative:
        return AppTheme.secondaryColor;
      case GrowthStage.budding:
        return Colors.teal;
      case GrowthStage.flowering:
        return Colors.purple;
      case GrowthStage.ripening:
        return Colors.orange;
      case GrowthStage.harvesting:
        return AppTheme.successColor;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

