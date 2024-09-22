import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'artisan_detail_page.dart';
import 'details_page.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String? firstName;
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchCategories();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            firstName = userDoc['firstname'];
          });
        } else {
          setState(() {
            firstName = user!.displayName;
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
        firstName = user!.email;
      }
    }
  }

  // Fetch categories from Firestore
  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot categorySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      List<Map<String, dynamic>> fetchedCategories =
          categorySnapshot.docs.map((doc) => {'name': doc['name']}).toList();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HustleApp'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.notifications),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting and Search Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hello ${firstName ?? 'Loading...'}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for an artisan or service...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Banner Information
            const Text(
              'Welcome to HustleApp',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Categories Section
            const Text(
              'Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.isNotEmpty
                    ? categories
                        .map((category) =>
                            _buildCategoryCard(category['name'], Icons.add))
                        .toList()
                    : [const CircularProgressIndicator()],
              ),
            ),
            const SizedBox(height: 20),

            // Available Services Section
            const Text(
              'Available Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildServiceTile('Fix a leaking tap', 'Plumbing'),
                  _buildServiceTile('Install electrical wiring', 'Electrician'),
                  _buildServiceTile('Repair a broken wall', 'Mason'),
                  _buildServiceTile('Garden maintenance', 'Gardener'),
                  _buildServiceTile('Welding gates', 'Welder'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailsPage(category: category)));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Chip(
          label: Text(category),
          avatar: Icon(icon),
          backgroundColor: Colors.grey[200],
          padding: const EdgeInsets.all(8.0),
        ),
      ),
    );
  }

  Widget _buildServiceTile(String serviceName, String category) {
    return ListTile(
      title: Text(serviceName),
      subtitle: Text(category),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>  const ArtisanDetailsPage(
                  artisanName: 'Kenton',
                  artisanService: "Coding",
                  artisanDescription:
                  'In a land of myth and a time of magic, the destiny of a great kingdom rests on the shoulder of a young warlock and his name is Merlin',
                  profileImageUrl: 'https://picsum.photos/200/300',
                  rating: 5.5,
                )));
      },
    );
  }

  // Helper method to map string to IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'plumbing':
        return Icons.plumbing;
      case 'build':
        return Icons.build;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'local_florist':
        return Icons.local_florist;
      case 'construction':
        return Icons.construction;
      default:
        return Icons.more_horiz;
    }
  }
}
