class User {
  final int id;
  final String name;
  final String email;
  final String? profileImage;
  final String? phoneNumber;
  final String? address;
  final String? farmName;
  final double? farmSize; // in hectares
  final List<String> preferredCrops;
  final Map<String, bool> appSettings;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.phoneNumber,
    this.address,
    this.farmName,
    this.farmSize,
    this.preferredCrops = const [],
    this.appSettings = const {
      'notifications': true,
      'darkMode': false,
      'waterAlerts': true,
      'weatherAlerts': true,
      'dataSync': true,
    },
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? profileImage,
    String? phoneNumber,
    String? address,
    String? farmName,
    double? farmSize,
    List<String>? preferredCrops,
    Map<String, bool>? appSettings,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      farmName: farmName ?? this.farmName,
      farmSize: farmSize ?? this.farmSize,
      preferredCrops: preferredCrops ?? this.preferredCrops,
      appSettings: appSettings ?? this.appSettings,
    );
  }
}

