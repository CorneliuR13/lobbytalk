import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lobbytalk/pages/chat_page.dart';
import 'package:lobbytalk/services/auth/auth_service.dart';

import '../services/notifications/notification_service.dart';



class ReceptionCheckInPage extends StatefulWidget {
  const ReceptionCheckInPage({super.key});

  @override
  State<ReceptionCheckInPage> createState() => _ReceptionCheckInPageState();
}

class _ReceptionCheckInPageState extends State<ReceptionCheckInPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  late TabController _tabController;

  List<QueryDocumentSnapshot> _pendingRequests = [];
  List<QueryDocumentSnapshot> _processedRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUserId = _authService.getCurrentUser()?.uid;


      final snapshot = await _firestore
          .collection("check_in_requests")
          .where('receptionId', isEqualTo: currentUserId)
          .get();

      final allRequests = snapshot.docs;

      final pendingDocs = allRequests
          .where((doc) => doc.data()['status'] == 'pending')
          .toList();

      pendingDocs.sort((a, b) {
        final aData = a.data();
        final bData = b.data();
        final aTime = aData['timestamp'] as Timestamp?;
        final bTime = bData['timestamp'] as Timestamp?;

        if (aTime == null) return 1;
        if (bTime == null) return -1;

        return bTime.compareTo(aTime);
      });

      final processedDocs = allRequests
          .where((doc) {
        final status = doc.data()['status'];
        return status == 'approved' || status == 'rejected';
      })
          .toList();

      processedDocs.sort((a, b) {
        final aData = a.data();
        final bData = b.data();
        final aTime = aData['timestamp'] as Timestamp?;
        final bTime = bData['timestamp'] as Timestamp?;

        if (aTime == null) return 1;
        if (bTime == null) return -1;

        return bTime.compareTo(aTime);
      });

      if (mounted) {
        setState(() {
          _pendingRequests = pendingDocs;
          _processedRequests = processedDocs;
          _isLoading = false;
        });
      }

    } catch (e) {
      print('Error loading check-in requests: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading requests: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _validateCheckIn(String requestId, String clientId, String clientEmail, bool approve) async {
    try {
      // Update request status in Firestore
      await _firestore.collection("check_in_requests").doc(requestId).update({
        'status': approve ? 'approved' : 'rejected',
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': _authService.getCurrentUser()?.uid,
      });

      _loadData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve
              ? 'Check-in approved. Chat room is now available.'
              : 'Check-in rejected.'),
          backgroundColor: approve ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      print('Error processing check-in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing check-in request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check-In Requests', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Processed'),
          ],
          labelColor: Colors.white,
          indicatorColor: Colors.white,
        ),
        actions: [
          // Add refresh button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pending Requests Tab
          _buildRequestsList('pending'),

          // Processed Requests Tab
          _buildRequestsList('processed'),
        ],
      ),
    );
  }

  Widget _buildRequestsList(String type) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    final requests = type == 'pending' ? _pendingRequests : _processedRequests;

    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'pending' ? Icons.inbox : Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              type == 'pending'
                  ? 'No pending check-in requests'
                  : 'No processed check-in requests',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index].data() as Map<String, dynamic>;
        final requestId = requests[index].id;
        final timestamp = request['timestamp'] as Timestamp?;
        final dateTime = timestamp?.toDate() ?? DateTime.now();
        final formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking ID: ${request['bookingId']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    type == 'processed'
                        ? _buildStatusBadge(request['status'])
                        : SizedBox(),
                  ],
                ),
                SizedBox(height: 8),
                Text('Guest: ${request['clientName']}'),
                Text('Room: ${request['roomNumber']}'),
                Text('Email: ${request['clientEmail']}'),
                Text('Requested: $formattedDate'),
                SizedBox(height: 12),

                type == 'pending'
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _validateCheckIn(
                        requestId,
                        request['clientId'],
                        request['clientEmail'],
                        false,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text('Reject'),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        await _validateCheckIn(
                          requestId,
                          request['clientId'],
                          request['clientEmail'],
                          true,
                        );

                        // Open chat with client
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              receiveEmail: request['clientEmail'],
                              receiverID: request['clientId'],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('Approve & Chat', style: TextStyle(color: Colors.black),),
                    ),
                  ],
                )
                    : _buildActionForProcessed(request),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'approved' ? Colors.green : Colors.red;
    String text = status == 'approved' ? 'Approved' : 'Rejected';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionForProcessed(Map<String, dynamic> request) {
    // For approved requests, show a chat button
    if (request['status'] == 'approved') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiveEmail: request['clientEmail'],
                    receiverID: request['clientId'],
                  ),
                ),
              );
            },
            icon: Icon(Icons.chat),
            label: Text('Open Chat', style: TextStyle(color: Colors.black),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
            ),
          ),
        ],
      );
    }

    return SizedBox();
  }
}