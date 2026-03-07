import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';

class MapPickerPage extends StatefulWidget {
  final double initialLat;
  final double initialLon;

  const MapPickerPage({
    super.key,
    this.initialLat = 12.9716,
    this.initialLon = 77.5946,
  });

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late LatLng _picked;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _picked = LatLng(widget.initialLat, widget.initialLon);
    _mapController = MapController();
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
            onPressed: () => Navigator.pop(context, _picked),
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: AppTheme.primary,
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
              initialZoom: 15,
              onTap: (_, point) => setState(() => _picked = point),
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
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Coordinate display bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF1A0D35),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36, height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: AppTheme.primary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Lat: ${_picked.latitude.toStringAsFixed(6)}   '
                        'Lon: ${_picked.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap anywhere on the map to place the pin',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
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
