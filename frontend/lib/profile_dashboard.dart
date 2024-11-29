import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile.dart';

class ProfilePage extends StatelessWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found.'));
          }

          // User data retrieved
          Map<String, dynamic>? userData =
              snapshot.data?.data() as Map<String, dynamic>?;

          // Extracting user information
          String name = userData?['name'] ?? 'No Name';
          String email = userData?['email'] ?? 'No Email';
          String mobile = userData?['mobile'] ?? 'No Mobile';
          String username = userData?['username'] ?? 'No Username';
          String targetExam = userData?['exam'] ?? 'No Exam';
          String preferredSlot = userData?['slot'] ?? 'No Slot';
          String? profilePicUrl = userData?['profilePicUrl'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture with Shadow
                CircleAvatar(
                  radius: 60.0,
                  backgroundColor: Colors.blue[100],
                  child: CircleAvatar(
                    radius: 55.0,
                    backgroundImage: profilePicUrl != null
                        ? NetworkImage(profilePicUrl)
                        : const AssetImage('assets/Beginner.png')
                            as ImageProvider,
                  ),
                ),
                const SizedBox(height: 20.0),

                // Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8.0),

                // Profile Details
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileDetailItem(
                        icon: Icons.email,
                        title: 'Email',
                        value: email,
                      ),
                      const Divider(color: Colors.grey),
                      ProfileDetailItem(
                        icon: Icons.phone,
                        title: 'Mobile',
                        value: mobile,
                      ),
                      const Divider(color: Colors.grey),
                      ProfileDetailItem(
                        icon: Icons.person,
                        title: 'Username',
                        value: username,
                      ),
                      const Divider(color: Colors.grey),
                      ProfileDetailItem(
                        icon: Icons.school,
                        title: 'Target Exam',
                        value: targetExam,
                      ),
                      const Divider(color: Colors.grey),
                      ProfileDetailItem(
                        icon: Icons.access_time,
                        title: 'Preferred Slot',
                        value: preferredSlot,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30.0),

                // Edit Profile Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfile(userId: userId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileDetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileDetailItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue[800], size: 28.0),
          const SizedBox(width: 15.0),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
