import 'package:aqua_sense/models/reservoir.dart';
import 'package:aqua_sense/widgets/dummy_map.dart';
import 'package:flutter/material.dart';

class ReservoirService {
  // Singleton pattern
  static final ReservoirService _instance = ReservoirService._internal();
  factory ReservoirService() => _instance;
  ReservoirService._internal();

  // Mock reservoir data
  final List<Reservoir> _reservoirs = [
    Reservoir(
      id: 1,
      name: 'Reservoir 1',
      location: 'Place de la Concorde',
      address: 'Gebroeders de Smetstraat 1, 9000 Ghent',
      district: '7TH ARRONDISSEMENT',
      quality: 0.7, // 70% quality
      tankContent: 4567,
      tankPercentage: 0.75,
      temperature: 4.0,
      contactPhone: '0 78 5 368 349',
      latitude: 51.0543,
      longitude: 3.7174,
    ),
    Reservoir(
      id: 2,
      name: 'Reservoir 2',
      location: 'Central Park',
      address: 'Testroad 19000 Ghent',
      district: '3RD DISTRICT',
      quality: 0.9, // 90% quality
      tankContent: 3200,
      tankPercentage: 0.65,
      temperature: 5.5,
      contactPhone: '0 78 5 368 350',
      latitude: 51.0500,
      longitude: 3.7300,
    ),
    Reservoir(
      id: 3,
      name: 'Reservoir 3',
      location: 'South Station',
      address: 'Teststreet 45, 9000 Ghent',
      district: '5TH DISTRICT',
      quality: 0.5, // 50% quality
      tankContent: 2800,
      tankPercentage: 0.45,
      temperature: 6.0,
      contactPhone: '0 78 5 368 351',
      latitude: 51.0600,
      longitude: 3.7250,
    ),
    Reservoir(
      id: 4,
      name: 'My Reservoir',
      location: 'Home',
      address: 'Teststreet 32, 9000 Ghent',
      district: '1ST DISTRICT',
      quality: 0.8, // 80% quality
      tankContent: 1500,
      tankPercentage: 0.90,
      temperature: 3.5,
      contactPhone: '0 78 5 368 352',
      latitude: 51.0550,
      longitude: 3.7200,
    ),
  ];

  // Get all reservoirs
  Future<List<Reservoir>> getAllReservoirs() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _reservoirs;
  }

  // Get reservoir by ID
  Future<Reservoir?> getReservoirById(int id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _reservoirs.firstWhere((reservoir) => reservoir.id == id);
    } catch (e) {
      return null;
    }
  }

  // Convert reservoirs to map markers
  List<MapMarker> getReservoirMarkers() {
    return _reservoirs.map((reservoir) {
      // Convert latitude and longitude to normalized position (0.0 to 1.0)
      // This is a simplified conversion for our dummy map
      final normalizedLat = (reservoir.latitude - 51.0) / 1.0;
      final normalizedLng = (reservoir.longitude - 3.7) / 1.0;
      
      return MapMarker(
        id: reservoir.id,
        title: reservoir.name,
        position: Offset(normalizedLng, normalizedLat),
      );
    }).toList();
  }
}

