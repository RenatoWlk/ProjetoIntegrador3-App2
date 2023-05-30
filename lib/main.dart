import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

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
        primarySwatch: Colors.lightBlue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MapScreen(),
    );
  }
}