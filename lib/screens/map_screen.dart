import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/cafe_info.dart';
import '../services/cafe_service.dart';
import '../services/location_service.dart';
import '../widgets/cafe_marker.dart';
import '../widgets/cafe_info_card.dart';
import '../widgets/cafe_drawer.dart';
import '../widgets/user_location_marker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final CafeService _cafeService = CafeService();
  final LocationService _locationService = LocationService.instance;
  
  // Default location: Taipei, Taiwan
  LatLng _center = const LatLng(25.0330, 121.5654);
  double _currentZoom = 13.0;
  
  List<CafeInfo> _cafes = [];
  bool _isLoading = false;
  bool _isLoadingLocation = false;
  CafeInfo? _selectedCafe;
  UserLocation? _userLocation;
  LocationStatus _locationStatus = LocationStatus.unknown;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Try to get user location first
    await _getCurrentLocation();
    
    // Search for cafes
    await _searchCafesInTaiwan();
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
            onPressed: _goToUserLocation,
            tooltip: 'Go to My Location',
          ),
          IconButton(
            icon: const Icon(Icons.location_city),
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
              // User location markers (accuracy circle + position)
              MarkerLayer(
                markers: UserLocationMarker.buildUserMarker(_userLocation),
              ),
              // Cafe markers
              MarkerLayer(
                markers: CafeMarkerBuilder.buildMarkers(_cafes, _onMarkerTap),
              ),
            ],
          ),
          
          // Loading indicators
          if (_isLoading || _isLoadingLocation)
            Container(
              color: Colors.black26,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      _isLoadingLocation ? 'Getting your location...' : 'Loading cafes...',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          
          // Location status indicator
          Positioned(
            top: 20,
            right: 20,
            child: UserLocationMarker.buildLocationStatusIndicator(
              _locationStatus,
              onTap: _handleLocationStatusTap,
            ),
          ),
          
          // Location accuracy info
          if (_userLocation != null)
            Positioned(
              top: 70,
              right: 20,
              child: UserLocationMarker.buildLocationAccuracyInfo(_userLocation!),
            ),
          
          // Cafe info card
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "location",
            onPressed: _getCurrentLocation,
            tooltip: 'Update My Location',
            backgroundColor: Colors.blue,
            child: _isLoadingLocation 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.gps_fixed, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "search",
            onPressed: _searchNearbycafes,
            tooltip: 'Find Nearby Cafes',
            backgroundColor: Colors.brown,
            child: const Icon(Icons.search, color: Colors.white),
          ),
        ],
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

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatus = LocationStatus.loading;
    });

    try {
      final userLocation = await _locationService.getCurrentLocation();
      
      setState(() {
        _userLocation = userLocation;
        _locationStatus = _locationService.status;
        _isLoadingLocation = false;
      });

      if (userLocation != null) {
        // Center map on user location
        _mapController.move(userLocation.position, 15.0);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location found with ${userLocation.accuracy.round()}m accuracy'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        _handleLocationError();
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _locationStatus = LocationStatus.error;
      });
      _handleLocationError();
    }
  }

  void _handleLocationError() {
    if (!mounted) return;
    
    String message = _locationService.getStatusMessage();
    bool showSettings = false;
    
    if (_locationStatus == LocationStatus.denied || _locationStatus == LocationStatus.disabled) {
      showSettings = true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: showSettings ? SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () {
            if (_locationStatus == LocationStatus.disabled) {
              _locationService.openLocationSettings();
            } else {
              _locationService.openAppSettings();
            }
          },
        ) : null,
      ),
    );
  }

  void _handleLocationStatusTap() {
    switch (_locationStatus) {
      case LocationStatus.denied:
      case LocationStatus.disabled:
      case LocationStatus.error:
        _getCurrentLocation();
        break;
      case LocationStatus.found:
        if (_userLocation != null) {
          _goToUserLocation();
        }
        break;
      default:
        _getCurrentLocation();
    }
  }

  void _goToUserLocation() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!.position, 16.0);
    } else {
      _getCurrentLocation();
    }
  }

  void _goToTaipei() {
    _mapController.move(_center, _currentZoom);
  }

  Future<void> _searchNearbycafes() async {
    if (_userLocation != null) {
      await _searchCafes(_userLocation!.position);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available. Searching in current view...'),
          duration: Duration(seconds: 2),
        ),
      );
      await _searchCafesInCurrentView();
    }
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
        String locationDesc = _userLocation != null ? 'nearby' : 'in this area';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${cafes.length} cafes $locationDesc'),
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
}