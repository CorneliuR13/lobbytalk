import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lobbytalk/models/message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Future<void> sendMessage(String receiverID, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserId,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
      type: 'text',
    );

    List<String> ids = [currentUserId, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // Send the message
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());

    // Update chat metadata with last message timestamp
    await _firestore.collection("chat_metadata").doc(chatRoomID).set({
      'lastMessageTimestamp': timestamp,
      'lastMessage': message,
      'participants': [currentUserId, receiverID],
    }, SetOptions(merge: true));

    // Increment unread counter for receiver
    await _firestore.collection("chat_metadata").doc(chatRoomID).update({
      'unread_$receiverID': FieldValue.increment(1),
    });
  }

  Future<void> sendImageMessage(String receiverID, File imageFile) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    try {
      // Create IDs for chat room
      List<String> ids = [currentUserId, receiverID];
      ids.sort();
      String chatRoomID = ids.join('_');

      // First send a "Sending image..." message to show progress
      Message progressMessage = Message(
        senderID: currentUserId,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: "Sending image...",
        timestamp: timestamp,
        type: 'text',
      );

      final docRef = await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .add(progressMessage.toMap());

      // Generate a unique filename
      String fileName = '${Uuid().v4()}.jpg';
      Reference storageRef =
          _storage.ref().child('chat_images/$chatRoomID/$fileName');

      // Upload the file
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Update the message with the actual image URL
      await docRef.update({'message': imageUrl, 'type': 'image'});

      print("Image uploaded successfully: $imageUrl");
    } catch (e) {
      print("Error sending image: $e");
    }
  }

  Future<File?> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1000,
      );

      if (pickedImage != null) {
        File file = File(pickedImage.path);
        print("Image picked: ${file.path}, size: ${await file.length()} bytes");
        return file;
      } else {
        print("No image selected");
        return null;
      }
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }

  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<void> markChatAsRead(String otherUserId) async {
    final String currentUserId = _auth.currentUser!.uid;

    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore.collection("chat_metadata").doc(chatRoomID).update({
      'unread_$currentUserId': 0,
    });
  }
}
