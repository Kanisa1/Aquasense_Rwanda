import 'package:flutter/material.dart';
import 'package:aqua_sense/models/plant.dart';
import 'package:aqua_sense/services/plant_service.dart';
import 'package:aqua_sense/widgets/bottom_navigation.dart';
import 'package:aqua_sense/widgets/loading_indicator.dart';
import 'package:aqua_sense/widgets/error_display.dart';
import 'package:aqua_sense/widgets/custom_card.dart';
import 'package:aqua_sense/widgets/animated_progress_bar.dart';
import 'package:aqua_sense/utils/app_theme.dart';

class PlantsScreen extends StatefulWidget {
  const PlantsScreen({Key? key}) : super(key: key);

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 3; // Plants tab
  bool _isLoading = true;
  String? _errorMessage;
  List<Plant> _plants = [];
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Crops', 'Vegetables', 'Fruits', 'Others'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final plantService = PlantService();
      _plants = await plantService.getAllPlants();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load plants: ${e.toString()}';
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
          // Already on plants screen
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }
    }
  }

  void _navigateToPlantDetails(int plantId) {
    Navigator.pushNamed(
      context,
      '/plant_details',
      arguments: {'id': plantId},
    );
  }

  void _addNewPlant() {
    Navigator.pushNamed(context, '/add_plant').then((_) => _loadData());
  }

  List<Plant> _getFilteredPlants() {
    if (_tabController.index == 0) {
      return _plants;
    } else {
      final PlantType type = PlantType.values[_tabController.index - 1];
      return _plants.where((plant) => plant.type == type).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plants & Crops'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          onTap: (_) {
            setState(() {});
          },
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadData,
                )
              : _plants.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.grass,
                            size: 80,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No plants or crops added yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap the + button to add your first plant',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _getFilteredPlants().length,
                        itemBuilder: (context, index) {
                          final plant = _getFilteredPlants()[index];
                          return _buildPlantCard(plant);
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPlant,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildPlantCard(Plant plant) {
    final daysToHarvest = plant.daysToHarvest;
    final growthPercentage = plant.growthPercentage;
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => _navigateToPlantDetails(plant.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant image or icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
              const SizedBox(width: 16),
              
              // Plant details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plant.species,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          plant.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${plant.waterRequirement} L/day',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Growth stage badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getGrowthStageColor(plant.currentStage),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getGrowthStageName(plant.currentStage),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Growth progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Growth Progress',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    daysToHarvest > 0
                        ? '$daysToHarvest days to harvest'
                        : 'Ready for harvest!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: daysToHarvest > 0 ? Colors.grey.shade700 : AppTheme.successColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedProgressBar(
                value: growthPercentage,
                height: 12,
                backgroundColor: Colors.grey.shade200,
                foregroundColor: AppTheme.secondaryColor,
              ),
            ],
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
}

