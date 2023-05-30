import 'package:cloud_firestore/cloud_firestore.dart';

class Data { // Pega os registros no banco de dados de forma constante/instantânea
  Stream<QuerySnapshot> getRegisters() {
    return FirebaseFirestore.instance.collection('registers').snapshots();
  }
}