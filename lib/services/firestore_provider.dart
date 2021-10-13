import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreProvider {
  FirebaseFirestore firestore;
  FirebaseAuth firebaseAuth;

  FirestoreProvider(this.firestore, this.firebaseAuth);

  Future<void> setData({
    required String collectionPath,
    required String? documentPath,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    final reference = firestore.collection(collectionPath).doc(documentPath);
    print('$documentPath: $data');
    await reference.set(data, SetOptions(merge: merge));
  }

  Future<void> updateData({
    required String collectionPath,
    required String? documentPath,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(collectionPath).doc(documentPath).update(data);
  }

  Future<Map<String, dynamic>?> fetchDocument<T>({
    required String collectionPath,
    required String? documentPath,
    bool cache = true,
  }) async {
    final DocumentReference reference =
        firestore.collection(collectionPath).doc(documentPath);
    final DocumentSnapshot snapshot = await reference
        .get(GetOptions(source: cache ? Source.serverAndCache : Source.server));
    return snapshot.data() as Map<String, dynamic>;
  }
}
