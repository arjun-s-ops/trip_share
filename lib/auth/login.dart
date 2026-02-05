import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import this
import 'dart:convert';
import '../routes.dart';
import 'package:flutter_app/config/config.dart';

// Check your IP if you are on a real device. Use 10.0.2.2 for Android Emulator.
const String baseUrl = AppConfig.baseUrl;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // Function to handle Login logic
  Future<void> loginUser() async {
    setState(() => _isLoading = true);

    final body = {
      "email": emailController.text,
      "password": passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/login/"), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 1. GET THE KEY
        // We assume the Django server sends: {"key": "your_token_string", "user_id": 1}
        String? token = data['key']; 
        
        if (token != null) {
          // 2. STORE THE KEY
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Login Successful!")),
            );
            // 3. NAVIGATE TO HOME
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
          }
        } else {
           if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: No token received")));
        }

      } else {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login Failed: ${response.body}")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Connection Error: $e")));
        }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            Container(
              height: 280,
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
                    top: -40, left: -40,
                    child: CircleAvatar(radius: 90, backgroundColor: const Color(0xFFDCC169)),
                  ),
                  Positioned(
                    bottom: -30, right: -30,
                    child: CircleAvatar(radius: 70, backgroundColor: const Color(0xFF8AD3B5)),
                  ),
                  const SafeArea(
                    child: Center(
                      child: Text(
                        "Login Here",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2,
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
                  // ... (I omitted the Google button & Divider for brevity, keep them if you wish) ...
                  const SizedBox(height: 40),

                  /// EMAIL INPUT
                  _buildTextField(emailController, "Email"),

                  const SizedBox(height: 15),

                  /// PASSWORD INPUT
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: "Password",
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : loginUser, // Disable if loading
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("Log In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  // Links
                  GestureDetector(
                    onTap: () {}, // Forgot password logic
                    child: const Text("Request a New Password", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("New here? "),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
                        child: const Text("Create an account", style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}