import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBrNZHeIgQ3f5-P9Gxbcsc-WDq-QjQtEh0",
      appId: "1:287105807681:android:ef3207359fe85c26289dc0",
      messagingSenderId: "287105807681",
      projectId: "projeto-integrador-3-234e8",
  ),);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicativo 2',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela Inicial'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height, // Define uma altura fixa
        child: const GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(-22.832784023079014, -47.05114017100681),
            zoom: 15.0,
          ),
          mapType: MapType.normal,
        ),
      ),
    );
  }
}

/* pra deixar salvo como eu peguei os dados do banco na ultima versão

          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('alerts').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Ocorreu um erro');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                return ListView(
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(data['Data'].seconds * 1000);
                    GeoPoint? location = data['Localização'] as GeoPoint?;
                    String formattedLocation = location != null
                        ? 'Latitude: ${location.latitude}, Longitude: ${location.longitude}'
                        : 'Localização não disponível';
                    return ListTile(
                      title: Text(dateTime.toString()),
                      subtitle: Text(formattedLocation),
                    );
                  }).toList(),
                );
              },
            )
          ],
 */