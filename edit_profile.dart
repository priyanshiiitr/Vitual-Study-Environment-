import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vsea/profile_dashboard.dart';

class EditProfile extends StatefulWidget {
  final String userId;

  const EditProfile({super.key, required this.userId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late String name = '';
  late String email = '';
  late String mobile = '';
  late String username = '';
  late String targetExam = '';
  late String preferredSlot = '';
  String profilePicUrl = 'assets\Beginner.png'; // Default image

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController targetExamController = TextEditingController();
  final TextEditingController preferredSlotController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data on initialization
  }

  Future<void> fetchUserData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;
      setState(() {
        name = userData?['name'] ?? 'No Name';
        email = userData?['email'] ?? 'No Email';
        mobile = userData?['mobile'] ?? 'No Mobile';
        username = userData?['username'] ?? 'No Username';
        targetExam = userData?['exam'] ?? 'No Exam';
        preferredSlot = userData?['slot'] ?? 'No Slot';
        profilePicUrl = userData?['profilePicUrl'] ?? profilePicUrl; // Default if not available

        // Set the text controllers with fetched data
        nameController.text = name;
        emailController.text = email;
        mobileController.text = mobile;
        usernameController.text = username;
        targetExamController.text = targetExam;
        preferredSlotController.text = preferredSlot;
      });
    }
  }

  Future<void> updateUserData() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'name': nameController.text,
        'email': emailController.text,
        'mobile': mobileController.text,
        'username': usernameController.text,
        'exam': targetExamController.text,
        'slot': preferredSlotController.text,
        'profilePicUrl': profilePicUrl,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50.0,
              backgroundImage: NetworkImage(profilePicUrl),
            ),
            const SizedBox(height: 16.0),

            Container(
              padding: const EdgeInsets.all(16.0),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileDetailItem(
                    icon: Icons.person,
                    title: 'Name',
                    controller: nameController,
                  ),
                  const Divider(),

                  ProfileDetailItem(
                    icon: Icons.email,
                    title: 'Email',
                    controller: emailController,
                  ),
                  const Divider(),

                  ProfileDetailItem(
                    icon: Icons.phone,
                    title: 'Mobile No',
                    controller: mobileController,
                  ),
                  const Divider(),

                  ProfileDetailItem(
                    icon: Icons.person,
                    title: 'Username',
                    controller: usernameController,
                  ),
                  const Divider(),

                  ProfileDetailItem(
                    icon: Icons.school,
                    title: 'Target Exam',
                    controller: targetExamController,
                  ),
                  const Divider(),

                  ProfileDetailItem(
                    icon: Icons.access_time,
                    title: 'Preferred Slot',
                    controller: preferredSlotController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30.0),

            ElevatedButton(
              onPressed: () {
                updateUserData();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.userId)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileDetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final TextEditingController controller;

  const ProfileDetailItem({super.key, 
    required this.icon,
    required this.title,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.blue[800], size: 24.0),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Edit $title',
            ),
          ),
        ),
      ],
    );
  }
}
