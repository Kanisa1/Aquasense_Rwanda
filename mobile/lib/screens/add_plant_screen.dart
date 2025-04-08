import 'package:flutter/material.dart';
import 'package:aqua_sense/models/plant.dart';
import 'package:aqua_sense/services/plant_service.dart';
import 'package:aqua_sense/widgets/loading_indicator.dart';
import 'package:aqua_sense/widgets/custom_card.dart';
import 'package:aqua_sense/utils/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({Key? key}) : super(key: key);

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _locationController = TextEditingController();
  final _areaController = TextEditingController();
  final _waterRequirementController = TextEditingController();
  final _expectedYieldController = TextEditingController();
  final _harvestDaysController = TextEditingController();
  
  PlantType _selectedType = PlantType.crop;
  GrowthStage _selectedStage = GrowthStage.seed;
  DateTime _plantedDate = DateTime.now();
  String? _imageUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _waterRequirementController.dispose();
    _expectedYieldController.dispose();
    _harvestDaysController.dispose();
    super.dispose();
  }

  Future<void> _savePlant() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final plant = Plant(
          id: DateTime.now().millisecondsSinceEpoch,
          name: _nameController.text,
          species: _speciesController.text,
          type: _selectedType,
          plantedDate: _plantedDate,
          currentStage: _selectedStage,
          imageUrl: _imageUrl,
          waterRequirement: double.parse(_waterRequirementController.text),
          estimatedHarvestDays: int.parse(_harvestDaysController.text),
          expectedYield: double.parse(_expectedYieldController.text),
          location: _locationController.text,
          area: double.parse(_areaController.text),
          notes: [],
          irrigationSchedule: [
            IrrigationSchedule(
              dayOfWeek: 1, // Monday
              time: const TimeOfDay(hour: 7, minute: 0),
              amount: double.parse(_waterRequirementController.text) * 100,
            ),
            IrrigationSchedule(
              dayOfWeek: 4, // Thursday
              time: const TimeOfDay(hour: 7, minute: 0),
              amount: double.parse(_waterRequirementController.text) * 100,
            ),
          ],
        );

        final plantService = PlantService();
        await plantService.addPlant(plant);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plant added successfully')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to add plant: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // In a real app, you would upload the image to a server
      // and update the plant's image URL
      setState(() {
        _imageUrl = 'assets/images/plant_placeholder.jpg';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plant image selected')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _plantedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _plantedDate) {
      setState(() {
        _plantedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Plant'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Saving plant data...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!.replaceAll('Exception: ', ''),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Plant image
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: _imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    _imageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add Plant Image',
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Basic information
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
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Plant Name',
                              hintText: 'e.g. Corn Field A',
                              prefixIcon: Icon(Icons.eco),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _speciesController,
                            decoration: const InputDecoration(
                              labelText: 'Species',
                              hintText: 'e.g. Zea mays',
                              prefixIcon: Icon(Icons.spa),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the species';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<PlantType>(
                            value: _selectedType,
                            decoration: const InputDecoration(
                              labelText: 'Plant Type',
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: PlantType.values.map((type) {
                              return DropdownMenuItem<PlantType>(
                                value: type,
                                child: Text(_getPlantTypeName(type)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedType = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Growth information
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Growth Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Planted Date',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                '${_plantedDate.day}/${_plantedDate.month}/${_plantedDate.year}',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<GrowthStage>(
                            value: _selectedStage,
                            decoration: const InputDecoration(
                              labelText: 'Current Growth Stage',
                              prefixIcon: Icon(Icons.trending_up),
                            ),
                            items: GrowthStage.values.map((stage) {
                              return DropdownMenuItem<GrowthStage>(
                                value: stage,
                                child: Text(_getGrowthStageName(stage)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedStage = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _harvestDaysController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Days to Harvest',
                              hintText: 'e.g. 90',
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter days to harvest';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Location and area
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location & Area',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              hintText: 'e.g. North Field',
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a location';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _areaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Area (m²)',
                              hintText: 'e.g. 5000',
                              prefixIcon: Icon(Icons.crop_square),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the area';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Water and yield
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Water & Yield',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _waterRequirementController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Water Requirement (L/day)',
                              hintText: 'e.g. 6.5',
                              prefixIcon: Icon(Icons.water_drop),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter water requirement';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _expectedYieldController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Expected Yield (kg)',
                              hintText: 'e.g. 8500',
                              prefixIcon: Icon(Icons.agriculture),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter expected yield';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Save button
                    ElevatedButton(
                      onPressed: _savePlant,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Save Plant'),
                    ),
                  ],
                ),
              ),
            ),
    );
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
}

