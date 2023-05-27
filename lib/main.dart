import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app.icon');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);*/
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
      home: const MapScreen(),
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