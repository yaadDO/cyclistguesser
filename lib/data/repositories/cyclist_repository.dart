import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cyclist.dart';

class CyclistRepository {
  final FirebaseFirestore firestore;

  CyclistRepository({required this.firestore, required client});

  Future<Cyclist> fetchRandomCyclist() async {
    final query = await firestore.collection('cyclists')
        .orderBy(FieldPath.documentId)
        .limit(100)
        .get();

    final randomDoc = query.docs[Random().nextInt(query.docs.length)];
    return Cyclist.fromJson(randomDoc.data());
  }
}