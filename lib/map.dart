import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

import 'data.dart';
import 'notification.dart';

const double SPL_MIN = 40;
const double SPL_MAX = 110;

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Data data = Data();
  final Notify notify = Notify();

  List<WeightedLatLng> heatmapData = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    double splValue, normalizedSPL;
    GeoPoint geoPoint;
    LatLng latLng;
    Map<String, dynamic> dataMap;
    data.getRegisters().listen((QuerySnapshot snapshot) {
      // Pega os registros do firebase
      List<WeightedLatLng> data = [];
      for (var doc in snapshot.docs) {
        dataMap = doc.data() as Map<String, dynamic>;
        // Extrai dos documentos a média de SPL
        splValue = dataMap['Média'].toDouble();
        // Normaliza o valor do SPL
        normalizedSPL = (splValue - SPL_MIN) / (SPL_MAX - SPL_MIN);
        // Extrai a localização
        geoPoint = dataMap['Localização'];
        latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
        // Objeto que representa um ponto no mapa com valor ponderado
        data.add(WeightedLatLng(latLng, normalizedSPL));
      }
      setState(() {
        heatmapData = data; // Atualiza a visualização do mapa com os dados do heatmap
      });
      notify.requestLocationPermission(heatmapData);
    });
  }

  // Lista de gradientes que vão ser usados no Heatmap
  List<Map<double, MaterialColor>> gradients = [
    {
      0.25: Colors.blue,
      0.55: Colors.yellow,
      0.85: Colors.orange,
      1.0: Colors.red
    }
  ];
  var index = 0;

  LatLng initialPos   = LatLng(-22.833846358163328, -47.05151268341514);
  double initialZoom  = 17.5;
  //LatLngBounds bounds = LatLngBounds(
    //  LatLng(-22.832709815152366, -47.060968929234015), // esquerda em cima da PUC
    //    LatLng(-22.83374460764762, -47.032899552306624)   // direita em baixo da PUC
  //);

  @override
  Widget build(BuildContext context) {
    final map = FlutterMap(
      options: MapOptions(
        center: initialPos,
        zoom: initialZoom,
        interactiveFlags: InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.rotate,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        if (heatmapData.isNotEmpty)
          HeatMapLayer(
            heatMapDataSource: InMemoryHeatMapDataSource(data: heatmapData),
            heatMapOptions: HeatMapOptions(
              gradient: gradients[index],
              minOpacity: 1,
            ),
          ),
      ],
    );

    return Scaffold(
      body: Center(
        child: Container(child: map),
      ),
    );
  }
}
