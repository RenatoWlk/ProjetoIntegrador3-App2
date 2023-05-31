import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';
import 'notification.dart';
import 'data.dart';

double SPL_MIN = 40;
double SPL_MAX = 110;
LatLngBounds bounds = LatLngBounds(LatLng(-22.832709815152366, -47.060968929234015), LatLng(-22.83374460764762, -47.032899552306624));


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

    double splValue, normalizedSPL;
    GeoPoint geoPoint;
    LatLng latLng;
    data.getRegisters().listen((QuerySnapshot snapshot) {
      // Pega os registros do firebase
      List<WeightedLatLng> data = [];
      for (var doc in snapshot.docs) {
        var dataMap = doc.data() as Map<String, dynamic>;
        splValue = dataMap['Média']
            .toDouble(); // Extrai dos docuimentos a média de SPL
        normalizedSPL = (splValue - SPL_MIN) / (SPL_MAX - SPL_MIN);
        geoPoint = dataMap['Localização']; // Extrai a localização
        latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
        data.add(WeightedLatLng(latLng,
            normalizedSPL)); // Objeto que representa um ponto no mapa com valor ponderado
      }
      setState(() {
        heatmapData =
            data; // Atualiza a visualização do mapa com os dados do heatmap
      });
      notify.requestLocationPermission(heatmapData);
    });
    print(heatmapData);
  }

  List<Map<double, MaterialColor>> gradients = [
    // Lista de gradientes para ser usado no heatmap;
    {
      0.25: Colors.blue,
      0.55: Colors.yellow,
      0.85: Colors.orange,
      1.0: Colors.red
    }
  ];
  var index = 0;

  @override
  Widget build(BuildContext context) {
    final map = FlutterMap(
      // Monta o mapa na localização da pucc;
      options: MapOptions(center: LatLng(-22.83409737601791, -47.04946048469378), zoom: 15.0,maxBounds: bounds ),
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
