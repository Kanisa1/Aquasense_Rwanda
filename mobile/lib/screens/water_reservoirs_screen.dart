import 'package:flutter/material.dart';
import 'package:aqua_sense/models/reservoir.dart';
import 'package:aqua_sense/services/reservoir_service.dart';
import 'package:aqua_sense/widgets/bottom_navigation.dart';
import 'package:aqua_sense/widgets/dummy_map.dart';
import 'package:aqua_sense/widgets/loading_indicator.dart';
import 'package:aqua_sense/widgets/error_display.dart';

class WaterReservoirsScreen extends StatefulWidget {
  const WaterReservoirsScreen({Key? key}) : super(key: key);

  @override
  State<WaterReservoirsScreen> createState() => _WaterReservoirsScreenState();
}

class _WaterReservoirsScreenState extends State<WaterReservoirsScreen> {
  int _currentIndex = 1; // Water tab
  bool _showListView = false;
  bool _isLoading = true;
  String? _errorMessage;
  List<Reservoir> _reservoirs = [];
  List<MapMarker> _markers = [];

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
      final reservoirService = ReservoirService();
      _reservoirs = await reservoirService.getAllReservoirs();
      _markers = reservoirService.getReservoirMarkers();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load reservoirs: ${e.toString()}';
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
          // Already on water reservoirs screen
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

  void _toggleView() {
    setState(() {
      _showListView = !_showListView;
    });
  }

  void _navigateToReservoirDetails(int reservoirId) {
    Navigator.pushNamed(
      context,
      '/reservoir_details',
      arguments: {'id': reservoirId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Water reservoirs'),
            const SizedBox(width: 10),
            InkWell(
              onTap: _toggleView,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add, size: 16),
                    const SizedBox(width: 2),
                    Text(
                      _showListView ? 'MAP' : 'LIST',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadData,
                )
              : _showListView ? _buildListView() : _buildMapView(),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        // Custom dummy map
        DummyMap(
          markers: _markers,
          onMarkerTap: _navigateToReservoirDetails,
          initialZoom: 1.0,
        ),
        
        // Info text at the top
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'See all available pickup points for water',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _reservoirs.length,
      itemBuilder: (context, index) {
        final reservoir = _reservoirs[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(
              Icons.water_drop,
              color: Colors.white,
            ),
          ),
          title: Text(reservoir.name),
          subtitle: Text(reservoir.address),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _navigateToReservoirDetails(reservoir.id),
        );
      },
    );
  }
}

