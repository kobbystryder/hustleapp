import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hustle_app/services/auth_service.dart';
import 'package:hustle_app/services/firebase_services.dart';
import 'package:hustle_app/views/user_views/login_page.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/artisan_model.dart';

class ArtisanLandingPage extends StatefulWidget {
  const ArtisanLandingPage({super.key});

  @override
  State<ArtisanLandingPage> createState() => _ArtisanLandingPageState();
}

class _ArtisanLandingPageState extends State<ArtisanLandingPage> {
  User? user = FirebaseAuth.instance.currentUser;
  String? firstName;
  List<String> workImages = [];
  List<Map<String, dynamic>> artisanWorks = [];
  bool isLoading = false;

  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load artisan data, works, etc.
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _showAddSkillDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter name of job',
                  labelText: 'Name of Job',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: dateController,
                decoration: const InputDecoration(
                  hintText: 'Select Date',
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 80,
                        width: 80,
                        color: Colors.orange,
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Image.file(
                              _images[index],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isNotEmpty &&
                            dateController.text.isNotEmpty) {
                          List<String> imageUrls =
                              []; // You would upload images to Firebase Storage here
                          try {
                            await FirebaseServices().postExperience(
                              nameController.text,
                              dateController.text,
                              imageUrls,
                            );
                            // Optionally refresh the works list
                            // fetchArtisanData(user!.uid);
                          } catch (e) {
                            // Handle error (show snackbar or dialog)
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')));
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add Skill'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        nameController.clear();
                        dateController.clear();
                        setState(() {
                          _images.clear();
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  User? _user = FirebaseAuth.instance.currentUser;

  // function to make a request to firebase to get user data
  Future getCurrentUserData(final id) async {
    final data =
        FirebaseFirestore.instance.collection('artisans').doc(id).get().then(
      (value) {
        return value;
      },
    );
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${firstName ?? 'Artisan'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle Notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          FutureBuilder<Artisan?>(
            future: FirebaseServices().fetchArtisanData(_user?.uid ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('No user data found.'));
              }

              // If data exists, display the profile info
              final artisan = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text('${artisan.firstname} ${artisan.lastname}',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      subtitle: Text('Email: ${artisan.email}'),
                    ),
                    const SizedBox(height: 20),
                    Text('Category: ${artisan.category}',
                        style: const TextStyle(fontSize: 16)),
                    // const SizedBox(height: 10),
                    // Text('Date of Birth: ${artisan.dob}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Text('Phone: ${artisan.phone}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    // Text('Ghana Card: ${artisan.ghanaCard}', style: const TextStyle(fontSize: 16)),
                    // const SizedBox(height: 10),
                    // Text('ID: ${artisan.id}', style: const TextStyle(fontSize: 16)),
                    // const SizedBox(height: 10),
                    // Text('UID: ${artisan.uid}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              );
            },
          ),
          const Text(
            'Your Works',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showAddSkillDialog,
            child: const Text('Add Skill / Experience'),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: FirebaseServices().fetchArtisanWorks(
                  FirebaseAuth.instance.currentUser?.uid ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                // Check if data exists
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No works available.'));
                }

                // Data available, map the list of works
                List<Map<String, dynamic>> artisanWorks = snapshot.data!;

                return ListView.builder(
                  itemCount: artisanWorks.length,
                  itemBuilder: (context, index) {
                    // Extract data for each work
                    final work = artisanWorks[index];
                    String title = work['title'] ?? 'Untitled';
                    String date = work['date'] ?? 'Unknown Date';
                    String imageUrl = work['image'] ??
                        'https://via.placeholder.com/150'; // Dummy image link

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image,
                                  size: 60); // Handle missing/broken images
                            },
                          ),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Date: $date',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        trailing: InkWell(
                          child: const Icon(Icons.delete_outline, size: 16),
                          onTap: () async {
                            await FirebaseServices()
                                .deleteArtisanWork(work['docId'])
                                .then((value) {
                              setState(() {});
                              return ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Delete successfully'),
                                ),
                              );
                            }).catchError(
                              (err) =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(err.toString()),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
