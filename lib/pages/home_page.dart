// Adimport 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lobbytalk/pages/chat_page.dart';
import 'package:lobbytalk/pages/client_service_request_page.dart'; // Import the new pages
import 'package:lobbytalk/pages/debug_page.dart'; // Import the debug page
import 'package:lobbytalk/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/my_drawer.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _receptionContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApprovedReceptions();
  }

  Future<void> _loadApprovedReceptions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUserId = _authService.getCurrentUser()?.uid;

      final snapshot = await _firestore
          .collection("check_in_requests")
          .where('clientId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'approved')
          .get();

      List<Map<String, dynamic>> receptionContacts = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Get hotel services information
        DocumentSnapshot hotelDoc = await _firestore
            .collection("receptions")
            .doc(data['receptionId'])
            .get();

        List<String> hotelServices = [];
        if (hotelDoc.exists) {
          final hotelData = hotelDoc.data() as Map<String, dynamic>?;
          if (hotelData != null && hotelData.containsKey('availableServices')) {
            hotelServices = List<String>.from(hotelData['availableServices'] ?? []);
          }
        }

        receptionContacts.add({
          'uid': data['receptionId'],
          'email': data['receptionEmail'],
          'hotelName': data['hotelName'],
          'roomNumber': data['roomNumber'],
          'availableServices': hotelServices,
        });
      }

      setState(() {
        _receptionContacts = receptionContacts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reception contacts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          // Add refresh button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadApprovedReceptions,
            tooltip: 'Refresh',
          ),
          // Add my requests button
          if (_receptionContacts.isNotEmpty)
            IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClientActiveRequestsPage(),
                  ),
                );
              },
              tooltip: 'My Requests',
            ),
          // Add debug button
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DebugPage(),
                ),
              );
            },
            tooltip: 'Debug',
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reception contacts section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Hotel Receptions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _receptionContacts.isEmpty
              ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hotel,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No active hotel connections",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Find a hotel and check in to chat with reception",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
              : Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: _receptionContacts.length,
              itemBuilder: (context, index) {
                final reception = _receptionContacts[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      child: Icon(
                        Icons.hotel,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(reception['hotelName'] ?? 'Hotel Reception'),
                    subtitle: Text('Room ${reception['roomNumber']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chat_bubble_outline),
                          tooltip: 'Chat with Reception',
                          onPressed: () {
                            // Navigate to chat with reception
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  receiveEmail: reception['email'],
                                  receiverID: reception['uid'],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to chat with reception
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            receiveEmail: reception['email'],
                            receiverID: reception['uid'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Hotel Services section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Hotel Services",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Services available for the checked-in hotel
          Expanded(
            flex: 2,
            child: _receptionContacts.isEmpty
                ? Center(
              child: Text(
                "Check in to a hotel to see available services",
                style: TextStyle(color: Colors.grey[500]),
              ),
            )
                : _buildDynamicServicesGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicServicesGrid(BuildContext context) {
    // Get services from the first hotel (assuming one hotel at a time)
    final reception = _receptionContacts.first;
    final List<String> availableServices = List<String>.from(reception['availableServices'] ?? []);

    // Default services if none are defined
    if (availableServices.isEmpty) {
      availableServices.addAll(['Room Service', 'Housekeeping', 'Information']);
    }

    // Create service tiles
    List<Widget> serviceTiles = [];

    // Map of service names to icons and colors
    final Map<String, IconData> serviceIcons = {
      'Room Service': Icons.room_service,
      'Housekeeping': Icons.cleaning_services,
      'Spa & Wellness': Icons.spa,
      'Restaurant': Icons.local_dining,
      'Transport': Icons.directions_car,
      'Information': Icons.info,
      'Concierge': Icons.assistant,
      'Laundry': Icons.local_laundry_service,
      'Gym': Icons.fitness_center,
      'Swimming Pool': Icons.pool,
      'Business Center': Icons.business_center,
      'Conference Rooms': Icons.meeting_room,
      'Airport Shuttle': Icons.airport_shuttle,
    };

    final List<Color> serviceColors = [
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.green,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
      Colors.deepOrange,
      Colors.lightBlue,
      Colors.deepPurple,
      Colors.amber,
      Colors.cyan,
    ];

    // Create a tile for each available service
    for (int i = 0; i < availableServices.length; i++) {
      final service = availableServices[i];
      final IconData icon = serviceIcons[service] ?? Icons.miscellaneous_services;
      final Color color = i < serviceColors.length ? serviceColors[i] : Colors.grey;

      serviceTiles.add(
        _buildServiceTile(
          context,
          icon,
          service,
          color,
              () => _handleServiceTap(context, service),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: serviceTiles,
    );
  }

  Widget _buildServiceTile(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
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

  void _handleServiceTap(BuildContext context, String service) {
    if (_receptionContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please check in to a hotel first')),
      );
      return;
    }

    final reception = _receptionContacts.first;

    // Navigate to the service request page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientServiceRequestPage(
          hotelId: reception['uid'],
          hotelName: reception['hotelName'],
          roomNumber: reception['roomNumber'],
          availableServices: List<String>.from(reception['availableServices'] ?? []),
        ),
      ),
    );
  }
}