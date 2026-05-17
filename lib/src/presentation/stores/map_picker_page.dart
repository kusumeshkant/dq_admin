import 'dart:convert';
import 'package:dq_admin/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';

class MapPickerResult {
  final double latitude;
  final double longitude;
  final String address;

  const MapPickerResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class MapPickerPage extends StatefulWidget {
  final double initialLat;
  final double initialLon;

  const MapPickerPage({
    super.key,
    this.initialLat = 20.5937,  // India center
    this.initialLon = 78.9629,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late LatLng _picked;
  late MapController _mapController;
  String _address = 'Tap on the map to place the pin';
  bool _loadingAddress = false;

  @override
  void initState() {
    super.initState();
    _picked = LatLng(widget.initialLat, widget.initialLon);
    _mapController = MapController();
    // If initial coords are not India center, reverse geocode them
    if (widget.initialLat != 20.5937 || widget.initialLon != 78.9629) {
      _reverseGeocode(_picked);
    }
  }

  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _loadingAddress = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json&lat=${point.latitude}&lon=${point.longitude}&addressdetails=1',
      );
      final response = await http.get(uri, headers: {
        'User-Agent': 'dq_admin/1.0 (store-onboarding)',
        'Accept-Language': 'en',
      }).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final displayName = json['display_name'] as String? ?? '';
        if (mounted) setState(() => _address = displayName.isNotEmpty ? displayName : 'Unknown location');
      } else {
        if (mounted) setState(() => _address = 'Could not fetch address');
      }
    } catch (_) {
      if (mounted) setState(() => _address = 'Could not fetch address');
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  void _onMapTap(LatLng point) {
    setState(() {
      _picked = point;
      _address = 'Fetching address...';
    });
    _reverseGeocode(point);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0620),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0D35),
        title: const Text('Pick Store Location'),
        actions: [
          TextButton(
            onPressed: _loadingAddress
                ? null
                : () => Navigator.pop(
                      context,
                      MapPickerResult(
                        latitude: _picked.latitude,
                        longitude: _picked.longitude,
                        address: _address,
                      ),
                    ),
            child: Text(
              'Confirm',
              style: TextStyle(
                color: _loadingAddress ? Colors.white38 : AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _picked,
              initialZoom: widget.initialLat == 20.5937 ? 5 : 15,
              onTap: (_, point) => _onMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.dq_admin',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _picked,
                    width: 48,
                    height: 48,
                    child: const Icon(Icons.location_pin, color: AppColors.error, size: 48),
                  ),
                ],
              ),
            ],
          ),

          // Address confirmation card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: const BoxDecoration(
                color: Color(0xFF1A0D35),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Label
                  const Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Selected Location',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Full address name
                  _loadingAddress
                      ? const Row(
                          children: [
                            SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
                            SizedBox(width: 10),
                            Text('Fetching address...', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          ],
                        )
                      : Text(
                          _address,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),

                  const SizedBox(height: 10),

                  // Coordinates (small, secondary)
                  Text(
                    'Lat: ${_picked.latitude.toStringAsFixed(6)}   Lon: ${_picked.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap anywhere on the map to move the pin',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
