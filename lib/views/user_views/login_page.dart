import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hustle_app/views/artisan_view/artisan_landing_page.dart';
import 'package:hustle_app/views/user_views/landing_screen.dart';
import 'package:hustle_app/views/user_views/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';

enum AccountType { employee, employer }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AccountType _selectedAccount = AccountType.employee;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;
  bool _isPasswordVisible = false;  // Password visibility toggle
  bool _rememberMe = false;  // Remember me checkbox

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HU\$TLE APP'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Account type toggle
              Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Image.asset('assets/images/logo.png')),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('User'),
                  Radio(
                    value: AccountType.employer,
                    groupValue: _selectedAccount,
                    onChanged: (value) {
                      setState(() {
                        _selectedAccount = (value!);
                        log('user: $value');
                      });
                    },
                  ),
                  const Text('Artisan'),
                  Radio(
                    value: AccountType.employee,
                    groupValue: _selectedAccount,
                    onChanged: (value) {
                      setState(() {
                        _selectedAccount = (value!);
                        log('value: $_selectedAccount');
                      });
                    },
                  ),
                ],
              ),
              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                (value!.isEmpty) ? 'Email is required' : null,
                onSaved: (value) =>
                    setState(() => _emailController.text = value!),
              ),
              // Password field with visibility toggle
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,  // Toggle obscure text
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) =>
                (value!.isEmpty) ? 'Password is required' : null,
                onSaved: (value) =>
                    setState(() => _passwordController.text = value!),
              ),
              // Remember Me checkbox
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                  ),
                  const Text("Remember Me"),
                ],
              ),
              // Login button
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () async {
                  // Set loading indicator in motion
                  setState(() {
                    isLoading = true;
                  });
                  // Validating the input fields
                  if (_emailController.text == "" ||
                      _passwordController.text == "") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('All Fields Are Required')),
                    );
                  } else {
                    User? user = await AuthService().login(
                        _emailController.text,
                        _passwordController.text,
                        context);
                    if (user != null) {
                      // Save account type to SharedPreferences
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString('accountType', _selectedAccount.toString());
                      // Check the type of account and route user to the defined screen
                      if (_selectedAccount == AccountType.employer) {
                        // Route to UserPage
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LandingScreen(),
                          ),
                              (route) => false,
                        );
                      } else {
                        // Route to ArtisanPage
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ArtisanLandingPage(),
                          ),
                              (route) => false,
                        );
                      }
                    }
                  }
                  // Terminate loading indicator
                  setState(() {
                    isLoading = false;
                  });
                },
                child: const Text('Login'),
              ),

              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()));
                  },
                  child: const Text("Create an Account")),
            ],
          ),
        ),
      ),
    );
  }
}
//
// // Dummy ArtisanPage
// class ArtisanPage extends StatelessWidget {
//   const ArtisanPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Artisan Page'),
//       ),
//       body: Center(
//         child: Text('Welcome, Artisan!'),
//       ),
//     );
//   }
// }
//
// // Dummy UserPage
// class UserPage extends StatelessWidget {
//   const UserPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Page'),
//       ),
//       body: Center(
//         child: Text('Welcome, User!'),
//       ),
//     );
//   }
// }
