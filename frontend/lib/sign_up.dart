import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vsea/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Study Environment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SignUpPage(),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController reenterPasswordController = TextEditingController();

  String? selectedExam;
  String? preferredSlot;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> register() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await createUser(emailController.text);

      // Show success message and navigate to login page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      _showErrorSnackbar(context, e.toString());
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> createUser(String? userId) async {
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

    try {
      await userCollection.doc(userId).set({
        'name': nameController.text,
        'email': emailController.text,
        'mobile': mobileController.text,
        'username': usernameController.text,
        'exam': selectedExam,
        'slot': preferredSlot,
      });
    } catch (e) {
      _showErrorSnackbar(context, e.toString());
    }
  }

  bool validateFields() {
    if (nameController.text.isEmpty) {
      showError("Name is required.");
      return false;
    }
    if (emailController.text.isEmpty ||
        !RegExp(r'^[\w-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
      showError("Please enter a valid email address.");
      return false;
    }
    if (mobileController.text.isEmpty ||
        mobileController.text.length != 10 ||
        !RegExp(r'^\d{10}$').hasMatch(mobileController.text)) {
      showError("Please enter a valid 10-digit mobile number.");
      return false;
    }
    if (usernameController.text.isEmpty) {
      showError("Username is required.");
      return false;
    }
    if (passwordController.text.isEmpty) {
      showError("Password is required.");
      return false;
    }
    if (passwordController.text.length < 6) {
      showError("Password must be at least 6 characters.");
      return false;
    }
    if (reenterPasswordController.text != passwordController.text) {
      showError("Passwords do not match.");
      return false;
    }
    if (selectedExam == null) {
      showError("Please select a target exam.");
      return false;
    }
    if (preferredSlot == null) {
      showError("Please select a preferred study slot.");
      return false;
    }
    return true;
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white, ),
      ),
      backgroundColor: const Color.fromARGB(255, 140, 143, 146),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 20.0),
                buildTextField('Name', Icons.person, nameController),
                buildTextField('Email', Icons.email, emailController, inputType: TextInputType.emailAddress),
                buildTextField('Mobile No', Icons.phone, mobileController, inputType: TextInputType.phone),
                buildTextField('Username', Icons.account_circle, usernameController),
                buildTextField('Password', Icons.lock, passwordController, obscureText: true),
                buildTextField('Re-enter Password', Icons.lock, reenterPasswordController, obscureText: true),
                const SizedBox(height: 20.0),
                buildDropdown('Target Exam', selectedExam, (value) {
                  setState(() {
                    selectedExam = value;
                  });
                }, ['IIIT JEE', 'NEET', 'GATE', 'UPSC', 'NDA']),
                const SizedBox(height: 20.0),
                buildDropdown('Preferred Slot', preferredSlot, (value) {
                  setState(() {
                    preferredSlot = value;
                  });
                }, ['Morning (4 am to 12 pm)', 'Afternoon (12 pm to 8 pm)', 'Night (8 pm to 4 am)']),
                const SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: () {
                    if (validateFields()) {
                      register();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, IconData icon, TextEditingController controller,
      {TextInputType inputType = TextInputType.text, bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
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
        child: TextFormField(
          controller: controller,
          keyboardType: inputType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: label,
            prefixIcon: Icon(icon, color: Colors.blue[800]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(String label, String? value, ValueChanged<String?> onChanged, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
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
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
        ),
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
