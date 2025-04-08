class WaterTransaction {
  final int id;
  final int reservoirId;
  final String reservoirName;
  final String location;
  final int amount; // Negative for pickup, positive for deposit
  final DateTime timestamp;

  WaterTransaction({
    required this.id,
    required this.reservoirId,
    required this.reservoirName,
    required this.location,
    required this.amount,
    required this.timestamp,
  });
}

