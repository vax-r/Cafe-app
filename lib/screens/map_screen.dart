import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/cafe_info.dart';
import '../services/cafe_service.dart';
import '../widgets/cafe_marker.dart';
import '../widgets/cafe_info_card.dart';
import '../widgets/cafe_drawer.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final CafeService _cafeService = CafeService();
  
  // Default location: Taipei, Taiwan
  LatLng _center = const LatLng(25.0330, 121.5654);
  double _currentZoom = 13.0;
  
  List<CafeInfo> _cafes = [];
  bool _isLoading = false;
  CafeInfo? _selectedCafe;

  @override
  void initState() {
    super.initState();
    _searchCafesInTaiwan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taiwan Cafe Map'),
        backgroundColor: Colors.brown.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.coffee),
            onPressed: _searchCafesInCurrentView,
            tooltip: 'Search Cafes in Current View',
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToTaipei,
            tooltip: 'Go to Taipei',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _currentZoom,
              minZoom: 8.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedCafe = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.taiwan_cafe_map',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: CafeMarkerBuilder.buildMarkers(_cafes, _onMarkerTap),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (_selectedCafe != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: CafeInfoCard(
                cafe: _selectedCafe!,
                onClose: () {
                  setState(() {
                    _selectedCafe = null;
                  });
                },
              ),
            ),
        ],
      ),
      drawer: CafeDrawer(
        cafes: _cafes,
        onCafeSelected: _onCafeSelected,
      ),
    );
  }

  void _onMarkerTap(CafeInfo cafe) {
    setState(() {
      _selectedCafe = cafe;
    });
    _mapController.move(cafe.location, 16.0);
  }

  void _onCafeSelected(CafeInfo cafe) {
    setState(() {
      _selectedCafe = cafe;
    });
    _mapController.move(cafe.location, 16.0);
  }

  Future<void> _searchCafesInTaiwan() async {
    await _searchCafes(const LatLng(23.8, 121.0));
  }

  Future<void> _searchCafesInCurrentView() async {
    final center = _mapController.camera.center;
    await _searchCafes(center);
  }

  Future<void> _searchCafes(LatLng center) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cafes = await _cafeService.searchCafes(center);
      
      setState(() {
        _cafes = cafes;
        _isLoading = false;
      });

      if (cafes.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${cafes.length} cafes with enhanced information'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching cafes: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _goToTaipei() {
    _mapController.move(_center, _currentZoom);
  }
}