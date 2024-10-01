import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  final latlong2.LatLng marker;
  const MapPage({super.key, required this.marker});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  latlong2.LatLng get _center => widget.marker;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text('Map', style: TextStyle(color: Colors.white)),
        ),
        body: FlutterMap(
          options: MapOptions(
            initialZoom: 14.0,
            initialCenter: _center,
            minZoom: 1.0,
            maxZoom: 19.0,
            cameraConstraint: CameraConstraint.contain(bounds: LatLngBounds(LatLng(-90, -180), LatLng(90, 180))),
            interactionOptions: InteractionOptions(
              flags: ~InteractiveFlag.rotate,
            ),
          ),
          children: <Widget>[
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              panBuffer: 0,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  point: _center,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 50.0,
                  ),
                  alignment: Alignment(0.0, -2.0),
                ),
              ],
            ),
          ],
        ));
  }
}
