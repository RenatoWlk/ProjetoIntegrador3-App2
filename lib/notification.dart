import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class Notify {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void requestLocationPermission(List<WeightedLatLng> heatmapData) async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      print('Permissão de localização negada');
    } else {
      requestNotification(heatmapData);
    }
  }

  void requestNotification(List<WeightedLatLng> heatmapData) async{
    var _permissionNotification = await Permission.notification.status;

    if (_permissionNotification != PermissionStatus.granted){
      PermissionStatus permissionStatus = await Permission.notification.request();
      _permissionNotification = permissionStatus;
    }
    if (_permissionNotification != PermissionStatus.denied) {
      startLocationTracking(heatmapData);
    }
  }

  void startLocationTracking(List<WeightedLatLng> heatmapData) {
    Geolocator.getPositionStream().listen((Position position) {
      double latitude = position.latitude;
      double longitude = position.longitude;
      print('Latitude: $latitude, Longitude: $longitude');
      checkNoisyRegion(latitude, longitude, heatmapData);
    });
  }

  void checkNoisyRegion(double latitude, double longitude, List<WeightedLatLng> heatmapData) {
    print(heatmapData);
    double distance;
    double distanceLimit = 5;
    for (WeightedLatLng dataPoint in heatmapData) {
      LatLng region = dataPoint.latLng;
      distance = Geolocator.distanceBetween(latitude, longitude, region.latitude, region.longitude);
      if (distance <= distanceLimit){
        showNotification();
        break;
      }
    }
  }

  void showNotification() async {
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
}