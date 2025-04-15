import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lobbytalk/components/chat_bubble.dart';
import 'package:lobbytalk/components/my_textfields.dart';
import 'package:lobbytalk/services/auth/auth_service.dart';
import 'package:lobbytalk/services/chat/chat_services.dart';

class ChatPage extends StatefulWidget {
  final String receiveEmail;
  final String receiverID;
  final String? initialMessage;

  ChatPage({
    super.key,
    required this.receiveEmail,
    required this.receiverID,
    this.initialMessage,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  FocusNode myfocusNode = FocusNode();
  bool _isSendingImage = false;

  @override
  void initState() {
    super.initState();

    myfocusNode.addListener(() {
      if (myfocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
              () => scrollDown(),
        );
      }
    });

    Future.delayed(
      const Duration(milliseconds: 500),
          () => scrollDown(),
    );

    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _messageController.text = widget.initialMessage!;
        Future.delayed(Duration(milliseconds: 800), () {
          sendMessage();
        });
      });
    }
  }

  @override
  void dispose() {
    myfocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
    }
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);
      _messageController.clear();
    }
    scrollDown();
  }

  Future<void> sendImage(ImageSource source) async {
    setState(() {
      _isSendingImage = true;
    });

    try {
      print("Opening image picker with source: $source");

      final imageFile = await _chatService.pickImage(source);

      if (imageFile != null) {
        print("Image picked: ${imageFile.path}, size: ${await imageFile.length()} bytes");

        await _chatService.sendImageMessage(widget.receiverID, imageFile);

        print("Image sent successfully");

        scrollDown();
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error sending image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending image: $e'),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSendingImage = false;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                sendImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                sendImage(ImageSource.camera);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.receiveEmail,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              widget.receiveEmail.endsWith('@reception.com')
                  ? 'Hotel Reception'
                  : 'Guest',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: widget.receiveEmail.endsWith('@reception.com')
            ? Colors.redAccent
            : Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          if (_isSendingImage)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              color: Colors.yellow[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Sending image...'),
                ],
              ),
            ),

          Expanded(
            child: _buildMessageList(),
          ),

          //user input
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
        stream: _chatService.getMessages(widget.receiverID, senderID),
        builder: (context, snapshot) {
          //errors
          if (snapshot.hasError) {
            return const Text("Error");
          }
          //loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No messages yet",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Start the conversation!",
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          //listView
          return ListView(
            controller: _scrollController,
            children:
            snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //is current user
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

    //align message to the right
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    // get message type,
    String messageType = data['type'] ?? 'text';

    return Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ChatBubble(
              message: data["message"],
              isCurrentUser: isCurrentUser,
              messageType: messageType,
            ),
          ],
        ));
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.photo),
                onPressed: _showImageSourceDialog,
                color: Colors.grey[700],
              ),

              Expanded(
                child: MyTextfields(
                  controller: _messageController,
                  hintText: "Type a message",
                  obscureText: false,
                  focusNode: myfocusNode,
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: widget.receiveEmail.endsWith('@reception.com')
                      ? Colors.redAccent
                      : Colors.lightBlueAccent,
                  shape: BoxShape.circle,
                ),
                margin: EdgeInsets.only(right: 25),
                child: IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.white,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}