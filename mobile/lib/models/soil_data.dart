class SoilData {
  final int id;
  final String location;
  final DateTime timestamp;
  final double moisture; // percentage
  final double temperature; // celsius
  final double ph; // pH level
  final double nitrogen; // ppm
  final double phosphorus; // ppm
  final double potassium; // ppm
  final double organicMatter; // percentage
  final double electricalConductivity; // mS/cm

  SoilData({
    required this.id,
    required this.location,
    required this.timestamp,
    required this.moisture,
    required this.temperature,
    required this.ph,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.organicMatter,
    required this.electricalConductivity,
  });

  String get moistureStatus {
    if (moisture < 20) return 'Very Dry';
    if (moisture < 40) return 'Dry';
    if (moisture < 60) return 'Moderate';
    if (moisture < 80) return 'Moist';
    return 'Very Moist';
  }

  String get phStatus {
    if (ph < 5.5) return 'Acidic';
    if (ph < 7.0) return 'Slightly Acidic';
    if (ph < 7.5) return 'Neutral';
    if (ph < 8.5) return 'Slightly Alkaline';
    return 'Alkaline';
  }

  String get fertilizerRecommendation {
    if (nitrogen < 40 && phosphorus < 30 && potassium < 30) {
      return 'Complete NPK fertilizer recommended';
    } else if (nitrogen < 40) {
      return 'Nitrogen-rich fertilizer recommended';
    } else if (phosphorus < 30) {
      return 'Phosphorus-rich fertilizer recommended';
    } else if (potassium < 30) {
      return 'Potassium-rich fertilizer recommended';
    }
    return 'No fertilizer needed at this time';
  }
}

