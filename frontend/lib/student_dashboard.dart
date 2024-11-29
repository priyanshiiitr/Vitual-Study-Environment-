import 'package:flutter/material.dart';
import 'package:vsea/profile_dashboard.dart';
import 'group_chat.dart';
import 'login_screen.dart';

class StudentDashboardPage extends StatefulWidget {
  final String userid;
  const StudentDashboardPage({super.key, required this.userid});

  @override
  _StudentDashboardPageState createState() => _StudentDashboardPageState(userid: userid);
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  final String userid;

  _StudentDashboardPageState({required this.userid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light background
      appBar: AppBar(
        title: const Text(
          'Student Dashboard',
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF005A9C), // Darker blue
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              color: Colors.white,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[800]!, Colors.blue[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Hello, Student!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Welcome to VSEA',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            buildDrawerOption(Icons.settings, 'Settings', () {}),
            buildDrawerOption(Icons.contact_support, 'Contact Us', () {}),
            buildDrawerOption(Icons.account_circle, 'Profile', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(userId: userid)),
              );
            }),
            buildDrawerOption(Icons.star, 'Rewards', () {}),
            buildDrawerOption(Icons.logout, 'Logout', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            }),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight, // Ensure full-screen coverage
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Profile Section
                    CircleAvatar(
                      radius: 60.0,
                      backgroundImage: const AssetImage('assets/Beginner.png'),
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Beginner',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Dashboard Buttons
                    buildDashboardButton(
                      icon: Icons.book,
                      label: 'Self Study Session',
                      gradientColors: [Colors.purple, Colors.pink],
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),
                    buildDashboardButton(
                      icon: Icons.chat,
                      label: 'Group Chat',
                      gradientColors: [Colors.green, Colors.teal],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GroupChatPage(userid: userid)),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    buildDashboardButton(
                      icon: Icons.video_call,
                      label: 'Live Study Session',
                      gradientColors: [Colors.orange, Colors.deepOrange],
                      onTap: () {},
                    ),
                    const Spacer(), // Pushes content upwards for even spacing
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper function to build each dashboard button with a gradient background
  Widget buildDashboardButton({
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    required Function onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Center(
        child: Container(
          width: 240,
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                offset: const Offset(0, 5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build each drawer option
  Widget buildDrawerOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[800]),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}
