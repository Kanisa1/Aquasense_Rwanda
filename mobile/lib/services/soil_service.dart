import 'package:aqua_sense/models/soil_data.dart';

class SoilService {
  // Singleton pattern
  static final SoilService _instance = SoilService._internal();
  factory SoilService() => _instance;
  SoilService._internal();

  // Mock soil data
  final List<SoilData> _soilData = [
    SoilData(
      id: 1,
      location: 'North Field',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      moisture: 45.2,
      temperature: 22.5,
      ph: 6.8,
      nitrogen: 45,
      phosphorus: 35,
      potassium: 40,
      organicMatter: 3.2,
      electricalConductivity: 0.8,
    ),
    SoilData(
      id: 2,
      location: 'South Field',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      moisture: 38.7,
      temperature: 23.1,
      ph: 7.2,
      nitrogen: 38,
      phosphorus: 28,
      potassium: 35,
      organicMatter: 2.8,
      electricalConductivity: 0.7,
    ),
    SoilData(
      id: 3,
      location: 'East Slope',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      moisture: 52.3,
      temperature: 21.8,
      ph: 6.5,
      nitrogen: 50,
      phosphorus: 40,
      potassium: 45,
      organicMatter: 3.5,
      electricalConductivity: 0.9,
    ),
    SoilData(
      id: 4,
      location: 'Greenhouse 1',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      moisture: 65.8,
      temperature: 25.2,
      ph: 6.9,
      nitrogen: 55,
      phosphorus: 45,
      potassium: 50,
      organicMatter: 4.0,
      electricalConductivity: 1.1,
    ),
  ];

  // Get all soil data
  Future<List<SoilData>> getAllSoilData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _soilData;
  }

  // Get soil data by location
  Future<List<SoilData>> getSoilDataByLocation(String location) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _soilData.where((data) => data.location == location).toList();
  }

  // Get latest soil data by location
  Future<SoilData?> getLatestSoilDataByLocation(String location) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final locationData = _soilData.where((data) => data.location == location).toList();
      locationData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return locationData.first;
    } catch (e) {
      return null;
    }
  }

  // Get average soil moisture across all locations
  Future<double> getAverageSoilMoisture() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    if (_soilData.isEmpty) return 0;
    final total = _soilData.fold(0.0, (sum, data) => sum + data.moisture);
    return total / _soilData.length;
  }

  // Add new soil data
  Future<SoilData> addSoilData(SoilData data) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    _soilData.add(data);
    return data;
  }
}

