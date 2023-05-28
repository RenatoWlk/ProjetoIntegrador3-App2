import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';




double SPL_MIN = 30;
double SPL_MAX = 130;

class Dados { // Pega os registros no banco de dados de forma constante/instantânea
  Stream<QuerySnapshot> getRegisters() {
    return FirebaseFirestore.instance.collection('registers').snapshots();
  }
}


class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  Dados dados = Dados();  // Inicializa a classe de dados (pega do firebase)

  List<WeightedLatLng> heatmapData = [];  // Inicializa uma lista vazia para pegar dados para o heatmap;

  @override
  void initState() {
    super.initState();
    requestLocationPermission(); //Permissão de localização

    dados.getRegisters().listen((QuerySnapshot snapshot) { // Pega os registros do firebase
      List<WeightedLatLng> data = [];
      for (var doc in snapshot.docs) {
        var dataMap = doc.data() as Map<String, dynamic>;
        double splValue = dataMap['Média'].toDouble(); // Extrai dos docuimentos a média de SPL
        double normalizedSPL = (splValue - SPL_MIN) / (SPL_MAX - SPL_MIN);
        GeoPoint geoPoint = dataMap['Localização']; // Extrai a localização
        LatLng latLng = LatLng(geoPoint.latitude, geoPoint.longitude);

        //print('Latitude: ${latLng.latitude}, Longitude: ${latLng.longitude}, SPL: $splValue'); pra saber se tava pegando a localização direito;

        data.add(WeightedLatLng(latLng, splValue)); // Objeto que representa um ponto no mapa com valor ponderado
      }
      setState((){
        heatmapData = data; // Atualiza a visualização do mapa com os dados do heatmap
      });
    });
  }

  void requestLocationPermission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      print('Permissão de localização negada');
    } else {
      startLocationTracking();
    }
  }

  void startLocationTracking() {
    Geolocator.getPositionStream().listen((Position position) {
      double latitude = position.latitude;
      double longitude = position.longitude;
      //print('Latitude: $latitude, Longitude: $longitude');
      checkNoisyRegion(latitude, longitude);
    });
  }

  void checkNoisyRegion(double latitude, double longitude) {
    List<LatLng> noisyRegions = [];

    for (LatLng region in noisyRegions) {
      double distance = Geolocator.distanceBetween(latitude, longitude, region.latitude, region.longitude);
      double distanceLimit = 50;

      if (distance <= distanceLimit){
        showNotification();
        break;
      }
    }
  }

  void showNotification() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'local_ruidoso',
        'Alerta de local ruídoso',
        importance: Importance.high,
        priority: Priority.high
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    const String notTitle = 'Atenção';
    const String notBody = 'Próximo a local ruidoso';

    await flutterLocalNotificationsPlugin.show(0, notTitle, notBody, platformChannelSpecifics);


  }


  List<Map<double, MaterialColor>> gradients =[ // Lista de gradientes para ser usado no heatmap;
    HeatMapOptions.defaultGradient,
    {0.25: Colors.blue, 0.55: Colors.red, 0.85: Colors.pink, 1.0: Colors.purple}
  ];
  var index = 0;

  @override
  Widget build(BuildContext context) {
    final map = FlutterMap( // Monta o mapa na localização da pucc;
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
              minOpacity: 1,
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
