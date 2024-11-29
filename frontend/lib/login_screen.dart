import 'package:flutter/material.dart';
import 'sign_up.dart';
import 'student_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> signIn(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Navigate to the student dashboard upon successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentDashboardPage(userid: emailController.text)),
      );
    } catch (e) {
      _showErrorSnackbar(context, e.toString());
    }
  }

  Future<void> resetPassword(BuildContext context) async {
    if (emailController.text.isEmpty) {
      _showErrorSnackbar(context, 'Please enter your email to reset password');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      _showErrorSnackbar(context, 'Password reset email sent');
    } catch (e) {
      _showErrorSnackbar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 202, 202, 202), // Light background color
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text-based Logo with Icon in Column
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school,
                    color: Color.fromARGB(255, 1, 28, 55),
                    size: 80.0,
                  ),
                  SizedBox(height: 10.0), // Add spacing between icon and text
                  Text(
                    'VSE',
                    style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 5, 98, 228),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Virtual Study Environment',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 2, 74, 146),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40.0),

              // Email TextField
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.person, color: Colors.blue[800]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // Password TextField
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: Colors.blue[800]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => resetPassword(context), // Call resetPassword function
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30.0),

              // Login Button with Gradient Background
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.blue[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    signIn(context);
                    Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentDashboardPage(userid: emailController.text.trim(),)),);// Correctly call signIn with context
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()),
                      ); // Navigate to the signup page
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}