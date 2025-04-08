import 'package:aqua_sense/models/transaction.dart';

class TransactionService {
  // Singleton pattern
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  // Mock transaction data
  final List<WaterTransaction> _transactions = [
    WaterTransaction(
      id: 1,
      reservoirId: 1,
      reservoirName: 'Reservoir 1',
      location: 'Teststreet 32 900 Ghent',
      amount: -1001,
      timestamp: DateTime(2023, 2, 19, 23, 50),
    ),
    WaterTransaction(
      id: 2,
      reservoirId: 2,
      reservoirName: 'Reservoir 2',
      location: 'Testroad 19000 Ghent',
      amount: -230,
      timestamp: DateTime(2023, 2, 18, 22, 8),
    ),
    WaterTransaction(
      id: 3,
      reservoirId: 1,
      reservoirName: 'Reservoir 1',
      location: 'Teststreet 32 900 Ghent',
      amount: -1203,
      timestamp: DateTime(2023, 2, 10, 13, 23),
    ),
    WaterTransaction(
      id: 4,
      reservoirId: 4,
      reservoirName: 'My Reservoir',
      location: 'Teststreet 32 900 Ghent',
      amount: 562,
      timestamp: DateTime(2023, 2, 10, 13, 23),
    ),
  ];

  // Get all transactions
  Future<List<WaterTransaction>> getAllTransactions() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _transactions;
  }

  // Get recent transactions (last 3)
  Future<List<WaterTransaction>> getRecentTransactions() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _transactions.take(3).toList();
  }

  // Get transactions for a specific reservoir
  Future<List<WaterTransaction>> getTransactionsForReservoir(int reservoirId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _transactions.where((transaction) => transaction.reservoirId == reservoirId).toList();
  }
}

