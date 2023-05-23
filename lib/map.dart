import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  double lat = -22.83440850296931;
  double lng = -47.04811293698064;
  double initialZoom = 16.5;
  double minZoom = 16.5;
  double maxZoom = 23.0;

  void _onMapCreated(GoogleMapController controller){
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela Inicial'),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(lat, lng),
            zoom: initialZoom,
            bearing: 90,
          ),
          minMaxZoomPreference: MinMaxZoomPreference(minZoom,maxZoom),
          //cameraTargetBounds: CameraTargetBounds(),
          mapType: MapType.normal,
        ),
      ),
    );
  }
}