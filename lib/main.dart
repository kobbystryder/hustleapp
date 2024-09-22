import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hustle_app/firebase_options.dart';
import 'package:hustle_app/services/auth_service.dart';
import 'package:hustle_app/views/artisan_view/artisan_landing_page.dart';
import 'package:hustle_app/views/user_views/landing_screen.dart';
import 'package:hustle_app/views/user_views/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Get the stored account type from SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accountType = prefs.getString('accountType');
  log('accountType: $accountType');

  runApp(MyApp(accountType: accountType));
}

class MyApp extends StatelessWidget {
  final String? accountType;
  const MyApp({super.key, required this.accountType});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: AuthService().firebaseAuth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // If the user is logged in, route them based on their account type
            if (accountType == 'AccountType.employer') {
              return const LandingScreen(); // Employer goes to UserPage
            } else if (accountType == 'AccountType.employee') {
              return const ArtisanLandingPage(); // Employee (Artisan) goes to ArtisanPage
            }
            // If account type is not found, default to the main screen
            return const LoginScreen();
          }
          // If not logged in, show login screen
          return const LoginScreen();
        },
      ),
    );
  }
}
