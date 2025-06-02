import 'package:flutter/material.dart';
import 'package:lobbytalk/pages/chat_page.dart';
import 'package:lobbytalk/pages/client_service_request_page.dart'; // Import the new pages
import 'package:lobbytalk/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/my_drawer.dart';
import 'package:lobbytalk/components/language_switcher.dart';
import 'package:lobbytalk/services/translations.dart';

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

        DocumentSnapshot hotelDoc = await _firestore
            .collection("receptions")
            .doc(data['receptionId'])
            .get();

        List<String> hotelServices = [];
        if (hotelDoc.exists) {
          final hotelData = hotelDoc.data() as Map<String, dynamic>?;
          if (hotelData != null && hotelData.containsKey('availableServices')) {
            hotelServices =
                List<String>.from(hotelData['availableServices'] ?? []);
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
    final t = Translations.of(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(t.home, style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.lightBlueAccent,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _loadApprovedReceptions,
                tooltip: 'Refresh',
              ),
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
              const LanguageSwitcher(),
            ],
          ),
          drawer: MyDrawer(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  t.welcome,
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
                                  t.noActiveHotelConnections ??
                                      "No active hotel connections",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  t.findHotelAndCheckIn ??
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
                              final currentUserId =
                                  _authService.getCurrentUser()?.uid;
                              if (currentUserId == null)
                                return SizedBox.shrink();
                              // Generate a chatId based on user IDs (sorted to ensure uniqueness)
                              String chatId =
                                  currentUserId.compareTo(reception['uid']) < 0
                                      ? '${currentUserId}_${reception['uid']}'
                                      : '${reception['uid']}_$currentUserId';
                              return StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('chats')
                                    .doc(chatId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  bool hasUnread = false;
                                  if (snapshot.hasData &&
                                      snapshot.data!.exists) {
                                    final data = snapshot.data!.data()
                                        as Map<String, dynamic>;
                                    hasUnread = (data['unreadBy'] ?? [])
                                        .contains(currentUserId);
                                  }
                                  return Card(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.redAccent,
                                        child: Icon(
                                          Icons.hotel,
                                          color: Colors.white,
                                        ),
                                      ),
                                      title: Text(
                                        reception['hotelName'] ??
                                            t.hotelReceptions,
                                        style: TextStyle(
                                            fontWeight: hasUnread
                                                ? FontWeight.bold
                                                : FontWeight.normal),
                                      ),
                                      subtitle: Text(
                                          '${t.room} ${reception['roomNumber']}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (hasUnread)
                                            Icon(Icons.brightness_1,
                                                color: Colors.red, size: 10),
                                          IconButton(
                                            icon:
                                                Icon(Icons.chat_bubble_outline),
                                            tooltip: t.chatWithReception ??
                                                'Chat with Reception',
                                            onPressed: () async {
                                              // Mark as read when opening chat
                                              await FirebaseFirestore.instance
                                                  .collection('chats')
                                                  .doc(chatId)
                                                  .set({
                                                'unreadBy':
                                                    FieldValue.arrayRemove(
                                                        [currentUserId])
                                              }, SetOptions(merge: true));
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatPage(
                                                    receiveEmail:
                                                        reception['email'],
                                                    receiverID:
                                                        reception['uid'],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      onTap: () async {
                                        // Mark as read when opening chat
                                        await FirebaseFirestore.instance
                                            .collection('chats')
                                            .doc(chatId)
                                            .set({
                                          'unreadBy': FieldValue.arrayRemove(
                                              [currentUserId])
                                        }, SetOptions(merge: true));
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
                              );
                            },
                          ),
                        ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  t.hotelServices ?? "Hotel Services",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: _receptionContacts.isEmpty
                    ? Center(
                        child: Text(
                          t.checkInToSeeServices ??
                              "Check in to a hotel to see available services",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                    : _buildDynamicServicesGrid(context, t),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicServicesGrid(BuildContext context, Translations t) {
    // List of all possible services (translated)
    final List<Map<String, dynamic>> allServices = [
      {'name': t.roomService, 'icon': Icons.room_service},
      {'name': t.housekeeping, 'icon': Icons.cleaning_services},
      {'name': t.spaWellness, 'icon': Icons.spa},
      {'name': t.restaurant, 'icon': Icons.local_dining},
      {'name': t.transport, 'icon': Icons.directions_car},
      {'name': t.information, 'icon': Icons.info},
      {'name': t.concierge, 'icon': Icons.assistant},
      {'name': t.laundry, 'icon': Icons.local_laundry_service},
      {'name': t.gym, 'icon': Icons.fitness_center},
      {'name': t.swimmingPool, 'icon': Icons.pool},
      {'name': t.businessCenter, 'icon': Icons.business_center},
      {'name': t.conferenceRooms, 'icon': Icons.meeting_room},
      {'name': t.airportShuttle, 'icon': Icons.airport_shuttle},
    ];

    List<Widget> serviceTiles = [];
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

    for (int i = 0; i < allServices.length; i++) {
      final service = allServices[i];
      final Color color =
          i < serviceColors.length ? serviceColors[i] : Colors.grey;
      serviceTiles.add(
        _buildServiceTile(
          context,
          service['icon'],
          service['name'],
          color,
          () => _handleServiceTap(context, service['name']),
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

  Widget _buildServiceTile(BuildContext context, IconData icon, String title,
      Color color, VoidCallback onTap) {
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientServiceRequestPage(
          hotelId: reception['uid'],
          hotelName: reception['hotelName'],
          roomNumber: reception['roomNumber'],
          availableServices:
              List<String>.from(reception['availableServices'] ?? []),
          initialSelectedService: service,
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
