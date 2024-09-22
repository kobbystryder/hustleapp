import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/artisan_model.dart';

class FirebaseServices {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future fetchCategories() async {
    await firebaseFirestore
        .collection('categories')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        log('doc : ${doc.runtimeType}');
        log(doc["name"]);
      }
    });
  }

  // Post work/handywork service to Firestore, including artisan's UID
  Future postExperience(String title, String date, List<String> imageUrls) async {
    try {
      String uid = firebaseAuth.currentUser!.uid; // Get current user ID

      await firebaseFirestore.collection('works').add({
        'title': title,
        'date': date,
        'images': imageUrls, // List of image URLs
        'artisanId': uid,    // User ID of the artisan
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Fetch all works (to display to all users)
  Future<List<Map<String, dynamic>>> fetchAllWorks() async {
    try {
      QuerySnapshot querySnapshot = await firebaseFirestore
          .collection('works')
          .orderBy('timestamp', descending: true)
          .get();
      List<Map<String, dynamic>> works = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      return works;
    } catch (e) {
      log("Error fetching works: $e");
      throw Exception(e.toString());
    }
  }

  // Fetch works related to a specific artisan
  Future<List<Map<String, dynamic>>> fetchArtisanWorks(String? artisanId) async {
    try {
      log('artisan id: ${artisanId}');
      QuerySnapshot querySnapshot = await firebaseFirestore
          .collection('works')
          .where('artisanId', isEqualTo: artisanId)
          .get();

      log('query snapshot: ${querySnapshot.docs}');

      List<Map<String, dynamic>> works = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id; // Add document ID to the data
        return data;
      }).toList();

      log('works: $works');
      return works;
    } catch (e) {
      log("Error fetching artisan works: $e");
      throw Exception(e.toString());
    }
  }

  // Fetch artisan data based on their UID
  Future<Artisan?> fetchArtisanData(String uid) async {
    try {
      DocumentSnapshot doc = await firebaseFirestore.collection('artisans').doc(uid).get();

      if (doc.exists) {
        // Map Firestore data to Artisan model
        return Artisan.fromFirestore(doc.data() as Map<String, dynamic>, uid);
      }
    } catch (e) {
      print("Error fetching artisan data: $e");
      return null;
    }
  }

  // Function to delete an artisan's work by document ID
  Future<void> deleteArtisanWork(String workId) async {
    try {
      log('workId: $workId');
      await firebaseFirestore.collection('works').doc(workId).delete();
    } catch (e) {
      print("Error deleting work: $e");
      throw Exception("Failed to delete work");
    }
  }
}
