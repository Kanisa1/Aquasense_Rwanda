import 'package:aqua_sense/models/plant.dart';
import 'package:flutter/material.dart';

class PlantService {
  // Singleton pattern
  static final PlantService _instance = PlantService._internal();
  factory PlantService() => _instance;
  PlantService._internal();

  // Mock plant data
  final List<Plant> _plants = [
    Plant(
      id: 1,
      name: 'Corn Field A',
      species: 'Zea mays',
      type: PlantType.crop,
      plantedDate: DateTime.now().subtract(const Duration(days: 45)),
      currentStage: GrowthStage.vegetative,
      waterRequirement: 6.5,
      estimatedHarvestDays: 90,
      expectedYield: 8500,
      location: 'North Field',
      area: 5000,
      notes: [
        PlantNote(
          date: DateTime.now().subtract(const Duration(days: 2)),
          note: 'Plants showing good growth. Leaves are dark green.',
        ),
        PlantNote(
          date: DateTime.now().subtract(const Duration(days: 10)),
          note: 'Applied nitrogen fertilizer.',
        ),
      ],
      irrigationSchedule: [
        IrrigationSchedule(
          dayOfWeek: 1, // Monday
          time: const TimeOfDay(hour: 6, minute: 0),
          amount: 2000,
        ),
        IrrigationSchedule(
          dayOfWeek: 4, // Thursday
          time: const TimeOfDay(hour: 6, minute: 0),
          amount: 2000,
        ),
      ],
    ),
    Plant(
      id: 2,
      name: 'Tomato Plot',
      species: 'Solanum lycopersicum',
      type: PlantType.vegetable,
      plantedDate: DateTime.now().subtract(const Duration(days: 30)),
      currentStage: GrowthStage.flowering,
      imageUrl: 'assets/images/tomato.jpg',
      waterRequirement: 4.2,
      estimatedHarvestDays: 75,
      expectedYield: 450,
      location: 'Greenhouse 1',
      area: 200,
      notes: [
        PlantNote(
          date: DateTime.now().subtract(const Duration(days: 5)),
          note: 'Flowers developing well. No signs of pests.',
        ),
      ],
      irrigationSchedule: [
        IrrigationSchedule(
          dayOfWeek: 1, // Monday
          time: const TimeOfDay(hour: 7, minute: 0),
          amount: 100,
        ),
        IrrigationSchedule(
          dayOfWeek: 3, // Wednesday
          time: const TimeOfDay(hour: 7, minute: 0),
          amount: 100,
        ),
        IrrigationSchedule(
          dayOfWeek: 5, // Friday
          time: const TimeOfDay(hour: 7, minute: 0),
          amount: 100,
        ),
      ],
    ),
    Plant(
      id: 3,
      name: 'Apple Orchard',
      species: 'Malus domestica',
      type: PlantType.fruit,
      plantedDate: DateTime.now().subtract(const Duration(days: 1095)), // 3 years
      currentStage: GrowthStage.flowering,
      imageUrl: 'assets/images/apple.jpg',
      waterRequirement: 8.0,
      estimatedHarvestDays: 1460, // 4 years to first harvest
      expectedYield: 2000,
      location: 'East Slope',
      area: 3000,
      notes: [
        PlantNote(
          date: DateTime.now().subtract(const Duration(days: 7)),
          note: 'Trees flowering well. Bees active in the orchard.',
        ),
      ],
      irrigationSchedule: [
        IrrigationSchedule(
          dayOfWeek: 2, // Tuesday
          time: const TimeOfDay(hour: 6, minute: 30),
          amount: 1500,
        ),
        IrrigationSchedule(
          dayOfWeek: 5, // Friday
          time: const TimeOfDay(hour: 6, minute: 30),
          amount: 1500,
        ),
      ],
    ),
    Plant(
      id: 4,
      name: 'Wheat Field',
      species: 'Triticum aestivum',
      type: PlantType.crop,
      plantedDate: DateTime.now().subtract(const Duration(days: 60)),
      currentStage: GrowthStage.ripening,
      waterRequirement: 5.0,
      estimatedHarvestDays: 120,
      expectedYield: 6000,
      location: 'South Field',
      area: 8000,
      notes: [
        PlantNote(
          date: DateTime.now().subtract(const Duration(days: 15)),
          note: 'Grain heads developing well. No signs of rust.',
        ),
      ],
      irrigationSchedule: [
        IrrigationSchedule(
          dayOfWeek: 1, // Monday
          time: const TimeOfDay(hour: 5, minute: 0),
          amount: 3000,
        ),
        IrrigationSchedule(
          dayOfWeek: 5, // Friday
          time: const TimeOfDay(hour: 5, minute: 0),
          amount: 3000,
        ),
      ],
    ),
  ];

  // Get all plants
  Future<List<Plant>> getAllPlants() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _plants;
  }

  // Get plant by ID
  Future<Plant?> getPlantById(int id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _plants.firstWhere((plant) => plant.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add a new plant
  Future<Plant> addPlant(Plant plant) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    _plants.add(plant);
    return plant;
  }

  // Update a plant
  Future<Plant> updatePlant(Plant plant) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    final index = _plants.indexWhere((p) => p.id == plant.id);
    if (index != -1) {
      _plants[index] = plant;
      return plant;
    }
    throw Exception('Plant not found');
  }

  // Delete a plant
  Future<bool> deletePlant(int id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _plants.indexWhere((p) => p.id == id);
    if (index != -1) {
      _plants.removeAt(index);
      return true;
    }
    return false;
  }

  // Add a note to a plant
  Future<Plant> addNoteToPLant(int plantId, PlantNote note) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _plants.indexWhere((p) => p.id == plantId);
    if (index != -1) {
      final plant = _plants[index];
      final updatedNotes = List<PlantNote>.from(plant.notes)..add(note);
      _plants[index] = Plant(
        id: plant.id,
        name: plant.name,
        species: plant.species,
        type: plant.type,
        plantedDate: plant.plantedDate,
        currentStage: plant.currentStage,
        imageUrl: plant.imageUrl,
        waterRequirement: plant.waterRequirement,
        estimatedHarvestDays: plant.estimatedHarvestDays,
        expectedYield: plant.expectedYield,
        location: plant.location,
        area: plant.area,
        notes: updatedNotes,
        irrigationSchedule: plant.irrigationSchedule,
      );
      return _plants[index];
    }
    throw Exception('Plant not found');
  }

  // Get total water requirement for all plants
  Future<double> getTotalWaterRequirement() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    double total = 0;
    for (var plant in _plants) {
      total += plant.waterRequirement;
    }
    return total;
  }

  // Get plants by type
  Future<List<Plant>> getPlantsByType(PlantType type) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _plants.where((plant) => plant.type == type).toList();
  }
}

