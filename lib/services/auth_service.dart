import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  //instaniation the firebase authentication.
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  //registering the regular user.
  Future<User?> register(
    String firstname,
    String lastname,
    String email,
    String phone,
    String password,
    String ghanaCard,
    String dob,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await firebaseFirestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        "uid": userCredential.user!.uid,
        "id": userCredential.user?.uid,
        "firstname": firstname,
        "lastname": lastname,
        "email": email,
        "phone": phone,
        'dob': dob,
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      log('I got here : ${e.toString()}');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    } catch (e) {
      log('catch error: ${e.toString()}');
      debugPrint(e.toString());
    }
    return null;
  }

  //artisan
  //registering the regular user.
  Future<User?> registerArtisans(
      String firstname,
      String lastname,
      String email,
      String category,
      String phone,
      String password,
      String ghanaCard,
      String dob,

      BuildContext context,
      ) async {
    try {
      UserCredential userCredential =
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await firebaseFirestore
          .collection("artisans")
          .doc(userCredential.user!.uid)
          .set({
        "uid": userCredential.user!.uid,
        "id": userCredential.user?.uid,
        "firstname": firstname,
        "lastname": lastname,
        "email": email,
        "category": category,
        "phone": phone,
        'dob': dob,
        "ghanaCard": ghanaCard,
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      log('I got here : ${e.toString()}');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    } catch (e) {
      log('catch error: ${e.toString()}');
      debugPrint(e.toString());
    }
    return null;
  }

  // login method.
  Future<User?> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future logout() async {
    await firebaseAuth.signOut();
  }
}
