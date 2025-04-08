import 'package:flutter/material.dart';
import 'package:aqua_sense/models/soil_data.dart';
import 'package:aqua_sense/services/soil_service.dart';
import 'package:aqua_sense/widgets/loading_indicator.dart';
import 'package:aqua_sense/widgets/custom_card.dart';
import 'package:aqua_sense/utils/app_theme.dart';

class AddSoilDataScreen extends StatefulWidget {
  const AddSoilDataScreen({Key? key}) : super(key: key);

  @override
  State<AddSoilDataScreen> createState() => _AddSoilDataScreenState();
}

class _AddSoilDataScreenState extends State<AddSoilDataScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  
  final _locationController = TextEditingController();
  final _moistureController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _phController = TextEditingController();
  final _nitrogenController = TextEditingController();
  final _phosphorusController = TextEditingController();
  final _potassiumController = TextEditingController();
  final _organicMatterController = TextEditingController();
  final _electricalConductivityController = TextEditingController();

  @override
  void dispose() {
    _locationController.dispose();
    _moistureController.dispose();
    _temperatureController.dispose();
    _phController.dispose();
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    _organicMatterController.dispose();
    _electricalConductivityController.dispose();
    super.dispose();
  }

  Future<void> _saveSoilData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final soilData = SoilData(
          id: DateTime.now().millisecondsSinceEpoch,
          location: _locationController.text,
          timestamp: DateTime.now(),
          moisture: double.parse(_moistureController.text),
          temperature: double.parse(_temperatureController.text),
          ph: double.parse(_phController.text),
          nitrogen: double.parse(_nitrogenController.text),
          phosphorus: double.parse(_phosphorusController.text),
          potassium: double.parse(_potassiumController.text),
          organicMatter: double.parse(_organicMatterController.text),
          electricalConductivity: double.parse(_electricalConductivityController.text),
        );

        final soilService = SoilService();
        await soilService.addSoilData(soilData);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Soil data added successfully')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to add soil data: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Soil Data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Saving soil data...')
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
                    
                    // Location field
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Location Name',
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Soil moisture and temperature
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Basic Properties',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _moistureController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Moisture (%)',
                                    hintText: '0-100',
                                    prefixIcon: Icon(Icons.water_drop),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    final moisture = double.tryParse(value);
                                    if (moisture == null) {
                                      return 'Invalid number';
                                    }
                                    if (moisture < 0 || moisture > 100) {
                                      return 'Range: 0-100';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _temperatureController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Temperature (°C)',
                                    hintText: 'e.g. 22.5',
                                    prefixIcon: Icon(Icons.thermostat),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'pH Level',
                              hintText: '0-14',
                              prefixIcon: Icon(Icons.science),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter pH level';
                              }
                              final ph = double.tryParse(value);
                              if (ph == null) {
                                return 'Invalid number';
                              }
                              if (ph < 0 || ph > 14) {
                                return 'pH must be between 0 and 14';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Nutrient levels
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nutrient Levels',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _nitrogenController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Nitrogen (ppm)',
                                    hintText: 'e.g. 45',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _phosphorusController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Phosphorus (ppm)',
                                    hintText: 'e.g. 35',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _potassiumController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Potassium (ppm)',
                              hintText: 'e.g. 40',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Additional properties
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Additional Properties',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _organicMatterController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Organic Matter (%)',
                                    hintText: 'e.g. 3.2',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _electricalConductivityController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'EC (mS/cm)',
                                    hintText: 'e.g. 0.8',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Save button
                    ElevatedButton(
                      onPressed: _saveSoilData,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Save Soil Data'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

