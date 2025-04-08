class Reservoir {
  final int id;
  final String name;
  final String location;
  final String address;
  final String district;
  final double quality; // 0.0 to 1.0
  final int tankContent; // in liters
  final double tankPercentage; // 0.0 to 1.0
  final double temperature; // in Celsius
  final String contactPhone;
  final double latitude;
  final double longitude;

  Reservoir({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.district,
    required this.quality,
    required this.tankContent,
    required this.tankPercentage,
    required this.temperature,
    required this.contactPhone,
    required this.latitude,
    required this.longitude,
  });
}

