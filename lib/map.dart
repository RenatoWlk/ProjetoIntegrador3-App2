import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';





double SPL_MIN = 40;
double SPL_MAX = 110;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
    requestNotification();

    dados.getRegisters().listen((QuerySnapshot snapshot) { // Pega os registros do firebase
      List<WeightedLatLng> data = [];
      for (var doc in snapshot.docs) {
        var dataMap = doc.data() as Map<String, dynamic>;
        double splValue = dataMap['Média'].toDouble(); // Extrai dos docuimentos a média de SPL
        double normalizedSPL = (splValue - SPL_MIN) / (SPL_MAX - SPL_MIN);
        GeoPoint geoPoint = dataMap['Localização']; // Extrai a localização
        LatLng latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
        //print('Latitude: ${latLng.latitude}, Longitude: ${latLng.longitude}, SPL: $splValue'); pra saber se tava pegando a localização direito;
        data.add(WeightedLatLng(latLng, normalizedSPL)); // Objeto que representa um ponto no mapa com valor ponderado
      }
      setState((){
        heatmapData = data; // Atualiza a visualização do mapa com os dados do heatmap
      });
    });
  }
  List<Map<double, MaterialColor>> gradients =[ // Lista de gradientes para ser usado no heatmap;
    {0.25: Colors.blue, 0.55: Colors.yellow, 0.85: Colors.orange, 1.0: Colors.red}
  ];
  var index = 0;

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

  void requestNotification() async{
    var _permissionNotification = await Permission.notification.status;

    if (_permissionNotification != PermissionStatus.granted){
      PermissionStatus permissionStatus = await Permission.notification.request();

      _permissionNotification = permissionStatus;

    } else {
      print("passou");
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
    List<LatLng> noisyRegions = [LatLng(-22.83727583, 47.04749566)];

    for (LatLng region in noisyRegions) {
      double distance = Geolocator.distanceBetween(latitude, longitude, region.latitude, region.longitude);
      print("localização bd: $region"); // ERRO: essas coordenadas tão dando em uma ilha de madagascar O_o https://imgur.com/xjQkY2g
      print(distance); // resultado da função *certo!
      print('latitude: $latitude longitude: $longitude'); //coordenadas usuario *certo!
      double distanceLimit = 50;

      if (distance <= distanceLimit){
        showNotification();
        break;
      }
    }
  }

  void showNotification() async { // *certo!
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
      body: Center(
        child: Container(child:map),
      ),
    );
  }
}
