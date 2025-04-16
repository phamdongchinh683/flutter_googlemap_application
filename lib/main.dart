import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(const MaterialApp(home: MapsDemo()));
}

class MapsDemo extends StatelessWidget {
  const MapsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps Full Features')),
      body: const MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();
  final Location _location = Location();

  MapType _currentMapType = MapType.normal;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  static const LatLng _center = LatLng(16.0319021945843, 108.22156252262303);
  late LatLng _currentPosition;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _setInitialMarkers();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
    }

    final locData = await _location.getLocation();
    setState(() {
      _currentPosition = LatLng(locData.latitude!, locData.longitude!);
    });
  }

  void _setInitialMarkers() {
    _markers.add(Marker(
      markerId: MarkerId("my_school"),
      position: _center,
      infoWindow: InfoWindow(title: "My School", snippet: "This is my school"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ));

    _polylines.add(Polyline(
      polylineId: const PolylineId("route1"),
      visible: true,
      color: Colors.blue,
      width: 4,
      points: [
        _center,
        const LatLng(16.0400, 108.2200),
        const LatLng(16.0450, 108.2250),
      ],
    ));
  }

  Future<void> _goToCurrentLocation() async {
    final locData = await _location.getLocation();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(locData.latitude!, locData.longitude!), 16));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        infoWindow: const InfoWindow(title: "Custom Marker"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    });
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          mapType: _currentMapType,
          initialCameraPosition: const CameraPosition(
            target: _center,
            zoom: 14.5,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          markers: _markers,
          polylines: _polylines,
          onTap: _onMapTapped,
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'locate',
                onPressed: _goToCurrentLocation,
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'maptype',
                onPressed: _toggleMapType,
                child: const Icon(Icons.map),
              ),
            ],
          ),
        )
      ],
    );
  }
}
