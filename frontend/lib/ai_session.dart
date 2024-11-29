import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSessionActive = false; // To track the session state
  String videoFeedUrl = 'http://127.0.0.1:5000/video_feed';

  Future<void> startSession() async {
    try {
      // Attempt to start the video feed session
      final response = await http.get(Uri.parse(videoFeedUrl));
      if (response.statusCode == 200) {
        setState(() {
          isSessionActive = true;
        });
      } else {
        showErrorDialog('Failed to start session: ${response.body}');
      }
    } catch (e) {
      showErrorDialog('Error starting session: $e');
    }
  }

  Future<void> stopSession() async {
    try {
      // Attempt to stop the session
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/stop_session'));
      if (response.statusCode == 200) {
        setState(() {
          isSessionActive = false;
        });
      } else {
        showErrorDialog('Failed to stop session: ${response.body}');
      }
    } catch (e) {
      showErrorDialog('Error stopping session: $e');
    }
  }

  void showErrorDialog(String message) {
    // Display an error dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Tracker'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black12,
              child: isSessionActive
                  ? Image.network(
                      videoFeedUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        return progress == null
                            ? child
                            : Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            'Failed to load video feed',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'Session not active',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isSessionActive ? null : startSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(
                      'Start Session',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: isSessionActive ? stopSession : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      'End Session',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
