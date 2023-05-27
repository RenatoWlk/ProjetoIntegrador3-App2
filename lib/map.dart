import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



double SPL_MIN = 30;
double SPL_MAX = 130;

class Dados {
  Stream collectionStream = FirebaseFirestore.instance.collection('registers').snapshots();

  final Stream<QuerySnapshot> _data = FirebaseFirestore.instance.collection('registers').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot> (
      stream: ,
    )
  }

}

  // ESSE AQUI USEI DE EXEMPLO SÓ PRA VER SE FUNCIONAVA <----------------------------------------- OLHA AQUI RENAS
  /*static List<Map<String, dynamic>> dadosList = [
    {
      'latitude': -22.833336,
      'longitude': -47.052521,
      'spl':66,
    },
    {
      'latitude': -22.833502,
      'longitude': -47.052558,
      'spl':76,
    }
  ];*/
}





class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  var heatmapData = Dados.dadosList.map((e){
    double splValue = e['spl'].toDouble();
    double normalizedSPL = (splValue - SPL_MIN) /(SPL_MAX - SPL_MIN);
    return WeightedLatLng(
      LatLng(e['latitude'].toDouble(), e['longitude'].toDouble()),
      splValue,
  );
  }).toList();


  List<Map<double, MaterialColor>> gradients =[
    HeatMapOptions.defaultGradient,
    {0.25: Colors.blue, 0.55: Colors.red, 0.85: Colors.pink, 1.0: Colors.purple}
  ];
  var index = 0;

  @override
  Widget build(BuildContext context) {
    final map = FlutterMap(
      options: MapOptions(center: LatLng(-22.833336, -47.052521), zoom:16.0),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        if (heatmapData.isNotEmpty)
          HeatMapLayer(
            heatMapDataSource: InMemoryHeatMapDataSource(data: heatmapData),
            heatMapOptions: HeatMapOptions(
              gradient:gradients[index],
              minOpacity: 0.1,
            ),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela Inicial'),
      ),
      body: Center(
        child: Container(child:map),
      ),
    );
  }
}
