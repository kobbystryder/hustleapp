import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'landing_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for input fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _ghanaCardIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State variables
  DateTime? _selectedDateOfBirth;
  List<Map<String, dynamic>> category = [];
  String _selectedUserType = 'Regular User';
  String? _selectedCategory;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Method for fetching categories
  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot categorySnapshot =
      await FirebaseFirestore.instance.collection('categories').get();
      List<Map<String, dynamic>> fetchedCategories =
      categorySnapshot.docs.map((doc) => {'name': doc['name']}).toList();
      setState(() {
        category = fetchedCategories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // First Name
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),

                  // Last Name
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  // User Type Selection
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('User'),
                          value: 'User',
                          groupValue: _selectedUserType,
                          onChanged: (value) {
                            setState(() {
                              _selectedUserType = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Artisan'),
                          value: 'Artisan',
                          groupValue: _selectedUserType,
                          onChanged: (value) {
                            setState(() {
                              _selectedUserType = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // Category Selection (only for Artisans)
                  if (_selectedUserType == 'Artisan')
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Select Category'),
                      items: category
                          .map((cat) => DropdownMenuItem<String>(
                        value: cat['name'],
                        child: Text(cat['name']),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (_selectedUserType == 'Artisan' && value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),

                  // Contact Number
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(labelText: 'Contact'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your contact number';
                      }
                      return null;
                    },
                  ),

                  // Ghana Card ID
                  TextFormField(
                    controller: _ghanaCardIdController,
                    decoration: const InputDecoration(labelText: 'Ghana Card ID'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your Ghana Card ID';
                      }
                      return null;
                    },
                  ),

                  // Date of Birth
                  TextFormField(
                    controller: _dateOfBirthController,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(labelText: 'Date of Birth'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your Date of Birth';
                      }
                      return null;
                    },
                  ),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Register Button
                  isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          if (_selectedUserType != "Artisan") {
                            User? user = await AuthService().register(
                              _firstNameController.text,
                              _lastNameController.text,
                              _emailController.text,
                              _contactController.text,
                              _passwordController.text,
                              _ghanaCardIdController.text,
                              _dateOfBirthController.text,
                              context,
                            );

                            if (user != null) {
                              // Navigate to LandingScreen
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const LandingScreen()),
                                    (route) => false,
                              );
                            }
                          } else {
                            User? user = await AuthService().registerArtisans(
                              _firstNameController.text,
                              _lastNameController.text,
                              _emailController.text,
                              _selectedCategory!,
                              _contactController.text,
                              _passwordController.text,
                              _ghanaCardIdController.text,
                              _dateOfBirthController.text,
                              context,
                            );
                            if (user != null) {
                              // Navigate to LandingScreen
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const LandingScreen()),
                                    (route) => false,
                              );
                            }
                          }
                        }
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: const Text('Register'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
