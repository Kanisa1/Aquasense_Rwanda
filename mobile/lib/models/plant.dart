import 'package:flutter/material.dart';

enum PlantType {
  crop,
  tree,
  vegetable,
  fruit,
  flower,
  herb
}

enum GrowthStage {
  seed,
  seedling,
  vegetative,
  budding,
  flowering,
  ripening,
  harvesting
}

class Plant {
  final int id;
  final String name;
  final String species;
  final PlantType type;
  final DateTime plantedDate;
  final GrowthStage currentStage;
  final String? imageUrl;
  final double waterRequirement; // in liters per day
  final int estimatedHarvestDays;
  final double expectedYield; // in kg
  final String location;
  final double area; // in square meters
  final List<PlantNote> notes;
  final List<IrrigationSchedule> irrigationSchedule;

  Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.type,
    required this.plantedDate,
    required this.currentStage,
    this.imageUrl,
    required this.waterRequirement,
    required this.estimatedHarvestDays,
    required this.expectedYield,
    required this.location,
    required this.area,
    required this.notes,
    required this.irrigationSchedule,
  });

  int get daysToHarvest {
    final daysPlanted = DateTime.now().difference(plantedDate).inDays;
    return estimatedHarvestDays - daysPlanted;
  }

  double get growthPercentage {
    final daysPlanted = DateTime.now().difference(plantedDate).inDays;
    return (daysPlanted / estimatedHarvestDays).clamp(0.0, 1.0);
  }
}

class PlantNote {
  final DateTime date;
  final String note;
  final String? imageUrl;

  PlantNote({
    required this.date,
    required this.note,
    this.imageUrl,
  });
}

class IrrigationSchedule {
  final int dayOfWeek; // 1-7 (Monday-Sunday)
  final TimeOfDay time;
  final double amount; // in liters
  final bool isActive;

  IrrigationSchedule({
    required this.dayOfWeek,
    required this.time,
    required this.amount,
    this.isActive = true,
  });
}

