import 'package:flutter/material.dart';
import 'package:aqua_sense/models/transaction.dart';
import 'package:aqua_sense/services/transaction_service.dart';
import 'package:aqua_sense/widgets/bottom_navigation.dart';
import 'package:aqua_sense/widgets/loading_indicator.dart';
import 'package:aqua_sense/widgets/error_display.dart';

class WaterTransactionsScreen extends StatefulWidget {
  const WaterTransactionsScreen({Key? key}) : super(key: key);

  @override
  State<WaterTransactionsScreen> createState() => _WaterTransactionsScreenState();
}

class _WaterTransactionsScreenState extends State<WaterTransactionsScreen> {
  int _currentIndex = 1; // Water tab
  bool _isLoading = true;
  String? _errorMessage;
  List<WaterTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transactionService = TransactionService();
      _transactions = await transactionService.getAllTransactions();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load transactions: ${e.toString()}';
      });
    }
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });

      // Navigate to different screens based on the tab index
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pop(context);
          break;
        case 2:
          // Refresh action
          _loadData();
          break;
        case 3:
          // Plants/Settings screen
          break;
        case 4:
          // Profile screen
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Transactions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadData,
                )
              : Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'See amounts of water picked up by you',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    
                    // Transactions list
                    Expanded(
                      child: _transactions.isEmpty
                          ? const Center(
                              child: Text(
                                'No transactions found',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = _transactions[index];
                                final isPositive = transaction.amount > 0;
                                
                                return _buildTransactionItem(
                                  transaction.reservoirName,
                                  transaction.location,
                                  transaction.amount,
                                  transaction.timestamp,
                                  isPositive: isPositive,
                                );
                              },
                            ),
                    ),
                  ],
                ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildTransactionItem(
    String name,
    String location,
    int amount,
    DateTime date, {
    bool isPositive = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            location,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${isPositive ? '+ ' : '- '}${amount.abs()} L',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
              Text(
                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

