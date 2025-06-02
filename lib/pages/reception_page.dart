import 'package:flutter/material.dart';
import '../components/my_drawer.dart';
import '../services/auth/auth_service.dart';
import '../services/chat/chat_services.dart';
import 'reception_checkin_page.dart';
import 'reception_service_requests_page.dart';
import 'chat_page.dart';
import 'hotel_services_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReceptionPage extends StatelessWidget {
  ReceptionPage({super.key});

  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.getCurrentUser()?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Reception Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      drawer: MyDrawer(),
      body: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection("receptions").doc(currentUserId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error loading hotel data'));
            }

            final data = snapshot.data?.data() as Map<String, dynamic>?;
            final hotelName = data?['hotelName'] ?? 'Hotel Reception';
            final location = data?['location'] ?? '';
            final description = data?['description'] ?? '';
            final availableServices = List<String>.from(data?['availableServices'] ?? []);

            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: 100.0, // Extra padding at bottom to avoid overflow
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.hotel,
                                size: 50.0,
                                color: Colors.redAccent,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hotelName,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (location.isNotEmpty) ...[
                                      SizedBox(height: 4),
                                      Text(
                                        location,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                    SizedBox(height: 4),
                                    Text(
                                      "${_authService.getCurrentUser()?.email}",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editHotelProfile(context),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      _buildQuickStats(context),

                      SizedBox(height: 24),

                      Text(
                        "Reception Tools",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 16),

                      // Check-in requests tool
                      _buildFeatureTileFullWidth(
                        context,
                        Icons.login,
                        "Check-in Requests",
                        Colors.blue,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReceptionCheckInPage(),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 12),

                      // Service requests tool
                      _buildFeatureTileFullWidth(
                        context,
                        Icons.room_service,
                        "Service Requests",
                        Colors.orange,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReceptionServiceRequestsPage(),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 12),

                      // Active chats tool
                      _buildFeatureTileFullWidth(
                        context,
                        Icons.chat,
                        "Active Chats",
                        Colors.green,
                            () {
                          _showActiveChats(context);
                        },
                      ),

                      SizedBox(height: 12),

                      // Manage services tool
                      _buildFeatureTileFullWidth(
                        context,
                        Icons.settings,
                        "Manage Services",
                        Colors.purple,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HotelServicesPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
      ),
    );
  }
  Widget _buildFeatureTileFullWidth(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final currentUserId = _authService.getCurrentUser()?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("check_in_requests")
          .where('receptionId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        int pendingCheckins = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection("service_requests")
                .where('hotelId', isEqualTo: currentUserId)
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              int pendingRequests = snapshot.hasData ? snapshot.data!.docs.length : 0;

              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      Icons.login,
                      pendingCheckins.toString(),
                      "Pending Check-ins",
                      Colors.blue,
                    ),
                    _buildStatItem(
                      context,
                      Icons.room_service,
                      pendingRequests.toString(),
                      "Pending Requests",
                      Colors.orange,
                    ),
                    _buildStatItem(
                      context,
                      Icons.people,
                      "Active",
                      "Reception Status",
                      Colors.green,
                    ),
                  ],
                ),
              );
            }
        );
      },
    );
  }
  void _showCheckOutConfirmation(BuildContext context, String bookingId, String guestName, String roomNumber, String checkInRequestId) {
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Check Out Guest'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to check out:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Guest: $guestName'),
            Text('Room: $roomNumber'),
            SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Checkout Notes (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Enter any checkout notes...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                // 1. Find and update the booking
                final bookingSnapshot = await _firestore
                    .collection('bookings')
                    .where('bookingId', isEqualTo: bookingId)
                    .limit(1)
                    .get();

                if (bookingSnapshot.docs.isNotEmpty) {
                  final bookingDoc = bookingSnapshot.docs.first;

                  // Update booking status
                  await _firestore.collection('bookings').doc(bookingDoc.id).update({
                    'status': 'checked_out',
                    'checkoutNotes': notesController.text,
                    'checkoutTime': FieldValue.serverTimestamp(),
                  });
                }

                // 2. Update check-in request status
                await _firestore.collection('check_in_requests').doc(checkInRequestId).update({
                  'status': 'inactive',
                });

                // 3. Add room to cleaning queue
                await _firestore.collection('cleaning_tasks').add({
                  'hotelId': _authService.getCurrentUser()?.uid,
                  'roomNumber': roomNumber,
                  'status': 'pending',
                  'priority': 'high',
                  'createdAt': FieldValue.serverTimestamp(),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$guestName has been checked out from room $roomNumber'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                print('Error during checkout: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error during checkout: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Check Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureTile(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showActiveChats(BuildContext context) {
    final currentUserId = _authService.getCurrentUser()?.uid;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("Active Chats", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection("check_in_requests")
                .where('receptionId', isEqualTo: currentUserId)
                .where('status', isEqualTo: 'approved')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error loading chats"));
              }

              final activeChatRequests = snapshot.data?.docs ?? [];

              // Get all client IDs to query chat metadata
              List<String> clientIds = activeChatRequests
                  .map((doc) => (doc.data() as Map<String, dynamic>)['clientId'] as String)
                  .toList();

              return StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection("chat_metadata")
                    .where('participants', arrayContains: currentUserId)
                    .snapshots(),
                builder: (context, metadataSnapshot) {
                  if (metadataSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // Create a map of client ID to chat metadata
                  Map<String, Map<String, dynamic>> chatMetadata = {};
                  if (metadataSnapshot.hasData) {
                    for (var doc in metadataSnapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final participants = List<String>.from(data['participants'] ?? []);
                      final otherParticipant = participants.firstWhere(
                            (id) => id != currentUserId,
                        orElse: () => '',
                      );
                      if (clientIds.contains(otherParticipant)) {
                        chatMetadata[otherParticipant] = data;
                      }
                    }
                  }

                  // Create a sortable list of chat requests with metadata
                  List<Map<String, dynamic>> sortableChatRequests = [];
                  for (var doc in activeChatRequests) {
                    final data = doc.data() as Map<String, dynamic>;
                    final clientId = data['clientId'] as String;
                    final metadata = chatMetadata[clientId] ?? {};

                    sortableChatRequests.add({
                      'requestData': data,
                      'docId': doc.id,
                      'lastMessageTimestamp': metadata['lastMessageTimestamp'] ?? Timestamp.fromDate(DateTime(2000)),
                      'unreadCount': metadata['unread_$currentUserId'] ?? 0,
                    });
                  }

                  // Sort by last message timestamp
                  sortableChatRequests.sort((a, b) {
                    Timestamp aTime = a['lastMessageTimestamp'] as Timestamp;
                    Timestamp bTime = b['lastMessageTimestamp'] as Timestamp;
                    return bTime.compareTo(aTime); // Most recent first
                  });

                  return ListView.builder(
                    itemCount: sortableChatRequests.length,
                    itemBuilder: (context, index) {
                      final item = sortableChatRequests[index];
                      final chatRequest = item['requestData'] as Map<String, dynamic>;
                      final unreadCount = item['unreadCount'] as int;
                      final hasUnread = unreadCount > 0;

                      return ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            if (hasUnread)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: unreadCount > 9
                                      ? Text(
                                    '9+',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                      : Text(
                                    '$unreadCount',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          chatRequest['clientName'] ?? 'Guest',
                          style: TextStyle(
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text('Room ${chatRequest['roomNumber']} • Booking ID: ${chatRequest['bookingId']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Check-out button
                            IconButton(
                              icon: Icon(Icons.logout, color: Colors.red),
                              tooltip: 'Check Out Guest',
                              onPressed: () => _showCheckOutConfirmation(
                                context,
                                chatRequest['bookingId'],
                                chatRequest['clientName'],
                                chatRequest['roomNumber'],
                                item['docId'],
                              ),
                            ),
                            // Chat button
                            IconButton(
                              icon: Icon(Icons.chat_bubble_outline),
                              onPressed: () {
                                // Mark as read when opening chat
                                ChatService().markChatAsRead(chatRequest['clientId']);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      receiveEmail: chatRequest['clientEmail'],
                                      receiverID: chatRequest['clientId'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          // Mark as read when opening chat
                          ChatService().markChatAsRead(chatRequest['clientId']);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                receiveEmail: chatRequest['clientEmail'],
                                receiverID: chatRequest['clientId'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _editHotelProfile(BuildContext context) {
    final currentUserId = _authService.getCurrentUser()?.uid;

    _firestore.collection("receptions").doc(currentUserId).get().then((doc) {
      final data = doc.data() ?? {};

      final hotelNameController = TextEditingController(text: data['hotelName'] ?? '');
      final locationController = TextEditingController(text: data['location'] ?? '');
      final descriptionController = TextEditingController(text: data['description'] ?? '');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Edit Hotel Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: hotelNameController,
                  decoration: InputDecoration(
                    labelText: 'Hotel Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _firestore.collection("receptions").doc(currentUserId).update({
                  'hotelName': hotelNameController.text,
                  'location': locationController.text,
                  'description': descriptionController.text,
                }).then((_) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hotel profile updated')),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating profile: $error')),
                  );
                });
              },
              child: Text('Save'),
            ),
          ],
        ),
      );
    });
  }
}