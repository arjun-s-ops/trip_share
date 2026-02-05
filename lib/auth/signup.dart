import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import this
import 'dart:convert';
import '../routes.dart';
import 'package:flutter_app/config/config.dart';


// Check your IP address: Logic snippet had .36, UI had .37. Using .36 based on recent context.
const String baseUrl = AppConfig.baseUrl;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // State variables from Logic
  bool _obscurePassword = true; 
  bool _isLoading = false;
  String responseText = ""; // Kept from UI just in case, though mostly unused now

  // --- LOGIC FUNCTION (From your 2nd snippet) ---
  Future<void> sendData() async {
    setState(() => _isLoading = true);

    // Prepare full body data
    final body = {
      "email": emailController.text,
      "password": passwordController.text,
      "first_name": firstNameController.text,
      "last_name": lastNameController.text,
    };

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/signup/"), // Endpoint
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Check if server returned a key for auto-login
        if (data.containsKey('key')) {
           final prefs = await SharedPreferences.getInstance();
           await prefs.setString('auth_token', data['key']);
           
           if(mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Created & Logged In!")));
             // Navigate to Home
             Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
           }
        } else {
           // If no key, redirect to login
           if(mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Created! Please Log In.")));
             Navigator.pushNamed(context, AppRoutes.login);
           }
        }
      } else {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup Failed: ${response.body}")));
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI BUILD METHOD (From your 1st snippet) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
            Container(
              height: 180,
              width: double.infinity,
              clipBehavior: Clip.hardEdge, 
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE88B60), Color(0xFFD96548)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -40,
                    left: -40,
                    child: CircleAvatar(
                      radius: 90, 
                      backgroundColor: Color(0xFFDCC169),
                    ),
                  ),
                  
                  Positioned(
                    bottom: -30,
                    right: -30,
                    child: CircleAvatar(
                      radius: 70, 
                      backgroundColor: Color(0xFF8AD3B5),
                    ),
                  ),

                  const SafeArea(
                    child: Center(
                      child: Text(
                        "Create an\naccount",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// FORM BODY
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
              child: Column(
                children: [

                  /// GOOGLE BUTTON
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      side: const BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ensure you have this asset or replace with Icon(Icons.login)
                        Image.asset('assets/google.webp', height: 24, width: 24),
                        const SizedBox(width: 8),
                        const Text(
                          "Sign in with Google",
                          style: TextStyle(
                            color: Colors.black87, 
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("or", style: TextStyle(color: Colors.grey)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(child: _buildTextField(firstNameController, "First Name")),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField(lastNameController, "Last Name")),
                    ],
                  ),

                  const SizedBox(height: 15),

                  _buildTextField(emailController, "Email"),

                  const SizedBox(height: 15),

                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: "Password",
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// CREATE ACCOUNT BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // Update: Disable if loading, call sendData logic
                      onPressed: _isLoading ? null : sendData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      // Update: Show spinner if loading
                      child: _isLoading 
                        ? const SizedBox(
                            height: 20, width: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text(
                            "Create account",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Signing up means you agree to the Privacy Policy and Terms of Service.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        child: const Text(
                          "Log in here",
                          style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method from UI source
  static Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}