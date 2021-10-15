import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keleya_app/models/firestore_user.dart';

class AuthenticationProvider {
  final FirebaseAuth? firebaseAuth;
  final FirebaseFirestore? firestore;

  AuthenticationProvider({
    this.firestore,
    this.firebaseAuth,
  });

  signIn({required String email, required String password, bool isForTesting = false}) async {
    try {
      await firebaseAuth!.signInWithEmailAndPassword(email: email, password: password);

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    bool isForTesting = false,
  }) async {
    try {
      var create = await firebaseAuth!.createUserWithEmailAndPassword(email: email, password: password);

      if (!isForTesting)
        await _userCreate(
          email: email,
          uid: create.user!.uid,
        );

      return true;
    } catch (e) {
      print(e);

      return false;
    }
  }

  _userCreate({
    required String email,
    required String uid,
  }) async {
    var user = FirestoreUser(
      email: email,
      uid: uid,
      babyBirthDate: DateTime.now(),
      privacyPolicy: true,
      onboardingDone: false,
      termsNConditions: true,
    );

    await checkAndAddUser(user);
  }

  @visibleForTesting
  checkAndAddUser(FirestoreUser user) async {
    var snapshot = await firestore!.collection('users').doc(user.uid).get();

    print("snapshot from auth " + snapshot.toString());

    print('snapshot exists ' + snapshot.exists.toString());

    if (!snapshot.exists) {
      await firestore!.collection('users').doc(user.uid).set(user.toJson());
    }
  }
}
