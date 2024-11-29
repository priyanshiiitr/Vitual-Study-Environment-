import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:open_file/open_file.dart';

class GroupChatPage extends StatefulWidget {
  final String userid;

  const GroupChatPage({super.key, required this.userid});

  @override
  GroupChatPageState createState() => GroupChatPageState();
}

class GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool isUploading = false;

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectFile(BuildContext context, String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type == 'image'
            ? FileType.image
            : type == 'audio'
                ? FileType.audio
                : FileType.any,
        withData: true,
      );

      if (result != null) {
        final file = result.files.single;
        setState(() {
          isUploading = true;
        });
        await _uploadFileToSupabase(file, type);
        setState(() {
          isUploading = false;
        });
      } else {
        _showErrorSnackbar('No valid file selected. Try again.');
      }
    } catch (e) {
      _showErrorSnackbar('File selection failed: $e');
    }
  }

  Future<void> _uploadFileToSupabase(PlatformFile file, String type) async {
    final supabaseClient = Supabase.instance.client;
    final bucket = type == 'image' ? 'images' : type == 'audio' ? 'audio' : 'documents';

    try {
      final fileData = file.bytes ?? await File(file.path!).readAsBytes();
      final filePath = '${DateTime.now().toIso8601String()}_${file.name}';
      await supabaseClient.storage.from(bucket).uploadBinary(
        filePath,
        fileData,
      );

      final publicUrl = supabaseClient.storage.from(bucket).getPublicUrl(filePath);
      await _saveFileUrlToFirestore(publicUrl, type);
    } catch (e) {
      _showErrorSnackbar('File upload failed: $e');
    }
  }

  Future<void> _saveFileUrlToFirestore(String publicUrl, String type) async {
    try {
      await FirebaseFirestore.instance.collection('Messages').add({
        'message': messageController.text,
        'sender': widget.userid,
        'fileUrl': publicUrl,
        'fileType': type,
        'timestamp': DateTime.now(),
      });
      messageController.clear();
    } catch (e) {
      _showErrorSnackbar('Failed to save file to Firestore: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> sendMessage() async {
    if (messageController.text.isEmpty) {
      _showErrorSnackbar('Message cannot be empty');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Messages').add({
        'message': messageController.text,
        'sender': widget.userid,
        'timestamp': DateTime.now(),
      });
      messageController.clear();
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      _showErrorSnackbar('Failed to send message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Group Chat',
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo[800],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Messages')
                  .orderBy('timestamp', descending: true)
                  .limit(50) // Limit messages to improve performance
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return {
                    'text': data['message'] ?? '',
                    'sentByMe': data['sender'] == widget.userid,
                    'fileUrl': data['fileUrl'],
                    'fileType': data['fileType'],
                  };
                }).toList();

                return ListView.builder(
                  reverse: true,
                  controller: scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ChatBubble(message: message, sentByMe: message['sentByMe']);
                  },
                );
              },
            ),
          ),
          if (isUploading)
            const LinearProgressIndicator(), // Show a progress bar during file uploads
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.indigo),
                  onPressed: () => _selectFile(context, 'document'),
                ),
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.indigo),
                  onPressed: () => _selectFile(context, 'image'),
                ),
                IconButton(
                  icon: const Icon(Icons.audiotrack, color: Colors.indigo),
                  onPressed: () => _selectFile(context, 'audio'),
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.indigo),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool sentByMe;

  const ChatBubble({required this.message, required this.sentByMe});

  @override
  Widget build(BuildContext context) {
    final isFile = message['fileUrl'] != null;

    Widget messageContent;
    if (isFile) {
      switch (message['fileType']) {
        case 'image':
          messageContent = ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(message['fileUrl'], fit: BoxFit.cover),
          );
          break;
        case 'audio':
          messageContent = GestureDetector(
            onTap: () => OpenFile.open(message['fileUrl']),
            child: const Row(
              children: [
                Icon(Icons.audiotrack, color: Colors.indigo),
                SizedBox(width: 8),
                Text('Audio File - Tap to Play', style: TextStyle(color: Colors.indigo)),
              ],
            ),
          );
          break;
        case 'document':
          messageContent = GestureDetector(
            onTap: () => OpenFile.open(message['fileUrl']),
            child: const Row(
              children: [
                Icon(Icons.insert_drive_file, color: Colors.indigo),
                SizedBox(width: 8),
                Text('Document - Tap to View', style: TextStyle(color: Colors.indigo)),
              ],
            ),
          );
          break;
        default:
          messageContent = const Text('Unknown file type');
      }
    } else {
      messageContent = Text(
        message['text'],
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16.0,
        ),
      );
    }

    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        decoration: BoxDecoration(
          color: sentByMe ? Colors.indigo[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: messageContent,
      ),
    );
  }
}
