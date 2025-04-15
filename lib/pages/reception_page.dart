import 'package:flutter/material.dart';
import '../components/my_drawer.dart';
import '../services/auth/auth_service.dart';
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

            return Padding(
              padding: const EdgeInsets.all(16.0),
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

                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        // Check-in requests tile
                        _buildFeatureTile(
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

                        // Service requests tile (new)
                        _buildFeatureTile(
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

                        _buildFeatureTile(
                          context,
                          Icons.chat,
                          "Active Chats",
                          Colors.green,
                              () {
                            _showActiveChats(context);
                          },
                        ),

                        _buildFeatureTile(
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
                ],
              ),
            );
          }
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

              return ListView.builder(
                itemCount: activeChatRequests.length,
                itemBuilder: (context, index) {
                  final chatRequest = activeChatRequests[index].data() as Map<String, dynamic>;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(chatRequest['clientName'] ?? 'Guest'),
                    subtitle: Text('Room ${chatRequest['roomNumber']} • Booking ID: ${chatRequest['bookingId']}'),
                    trailing: Icon(Icons.chat_bubble_outline),
                    onTap: () {
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