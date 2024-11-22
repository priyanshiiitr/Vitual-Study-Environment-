import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart'; // Import the login screen

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ewvbsmpxcyocfxnqmqsc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3dmJzbXB4Y3lvY2Z4bnFtcXNjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA5MTQ0ODUsImV4cCI6MjA0NjQ5MDQ4NX0.Sk81cMSIO3Youkk9TVdzVh3OuG7JPQPrM37vKo6dDss',
  );
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is initialized
  await Firebase.initializeApp(); // Initializes Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VSEA',
      theme: ThemeData(
        primarySwatch: Colors.blue, // You can customize this theme as needed
      ),
      home: LoginPage(), // Set LoginScreen as the home screen
    );
  }
}
