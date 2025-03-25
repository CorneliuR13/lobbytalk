import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({Key? key}) : super(key: key);

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _allRequests = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _inProgressRequests = [];
  List<Map<String, dynamic>> _completedRequests = [];

  bool _isLoading = false;
  String _errorMessage = '';
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _debugInfo = '';
    });

    try {
      final String userId = _auth.currentUser!.uid;
      bool isReception = _auth.currentUser!.email!.endsWith('@reception.com');

      // Get all service requests
      QuerySnapshot snapshot;
      if (isReception) {
        // For reception, get requests where hotelId matches
        snapshot = await _firestore
            .collection('service_requests')
            .where('hotelId', isEqualTo: userId)
            .get();
      } else {
        // For clients, get requests where clientId matches
        snapshot = await _firestore
            .collection('service_requests')
            .where('clientId', isEqualTo: userId)
            .get();
      }

      List<Map<String, dynamic>> allRequests = [];
      List<Map<String, dynamic>> pendingRequests = [];
      List<Map<String, dynamic>> inProgressRequests = [];
      List<Map<String, dynamic>> completedRequests = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final request = {
          'id': doc.id,
          ...data,
          'requestTime': data['requestTime'] is Timestamp
              ? (data['requestTime'] as Timestamp).toDate().toString()
              : 'unknown',
        };

        allRequests.add(request);

        // Sort by status
        switch(data['status']) {
          case 'pending':
            pendingRequests.add(request);
            break;
          case 'in_progress':
            inProgressRequests.add(request);
            break;
          case 'completed':
            completedRequests.add(request);
            break;
        }
      }

      // Debug info
      _debugInfo = '''
User ID: $userId
Is Reception: $isReception
Total Requests: ${allRequests.length}
Pending: ${pendingRequests.length}
In Progress: ${inProgressRequests.length}
Completed: ${completedRequests.length}
      ''';

      setState(() {
        _allRequests = allRequests;
        _pendingRequests = pendingRequests;
        _inProgressRequests = inProgressRequests;
        _completedRequests = completedRequests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Service Requests'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage.isNotEmpty)
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.red[100],
                child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
              ),

            Text(
              'Debug Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Text(_debugInfo),
            ),

            SizedBox(height: 20),

            // Create a test request button
            ElevatedButton(
              onPressed: _createTestRequest,
              child: Text('Create Test Request'),
            ),

            // Request lists
            _buildRequestSection('All Requests', _allRequests),
            _buildRequestSection('Pending Requests', _pendingRequests),
            _buildRequestSection('In Progress Requests', _inProgressRequests),
            _buildRequestSection('Completed Requests', _completedRequests),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestSection(String title, List<Map<String, dynamic>> requests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (requests.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('No requests found'),
          )
        else
          ...requests.map((request) => _buildRequestCard(request)).toList(),
      ],
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${request['id']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Divider(),
            Text('Service Type: ${request['serviceType'] ?? 'unknown'}'),
            Text('Status: ${request['status'] ?? 'unknown'}'),
            Text('Room: ${request['roomNumber'] ?? 'unknown'}'),
            Text('Client: ${request['clientName'] ?? 'unknown'}'),
            Text('Time: ${request['requestTime'] ?? 'unknown'}'),
            if (request['requestDetails'] != null && request['requestDetails'].toString().isNotEmpty)
              Text('Details: ${request['requestDetails']}'),

            // Action buttons
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (request['status'] == 'pending')
                  ElevatedButton(
                    onPressed: () => _updateStatus(request['id'], 'in_progress'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text('Start'),
                  ),
                if (request['status'] == 'in_progress')
                  ElevatedButton(
                    onPressed: () => _updateStatus(request['id'], 'completed'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text('Complete'),
                  ),
                SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _deleteRequest(request['id']),
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTestRequest() async {
    try {
      final String userId = _auth.currentUser!.uid;
      final String userEmail = _auth.currentUser!.email!;
      final bool isReception = userEmail.endsWith('@reception.com');

      // If the user is reception, we need to fetch a client to create the request
      String clientId = '';
      String clientName = 'Test Client';
      String clientEmail = 'test@example.com';
      String hotelId = '';
      String hotelName = 'Test Hotel';

      if (isReception) {
        // Reception creating a test request
        hotelId = userId;

        // Try to find a client
        final clientsSnapshot = await _firestore.collection('Users').limit(1).get();
        if (clientsSnapshot.docs.isNotEmpty) {
          final clientDoc = clientsSnapshot.docs.first;
          clientId = clientDoc.id;
          final clientData = clientDoc.data();
          clientEmail = clientData['email'] ?? 'test@example.com';
        } else {
          // No clients found, create a fake one
          clientId = 'test_client_id';
        }
      } else {
        // Client creating a test request
        clientId = userId;
        clientName = userEmail.split('@')[0];
        clientEmail = userEmail;

        // Try to find a hotel
        final receptionSnapshot = await _firestore.collection('receptions').limit(1).get();
        if (receptionSnapshot.docs.isNotEmpty) {
          final receptionDoc = receptionSnapshot.docs.first;
          hotelId = receptionDoc.id;
          final hotelData = receptionDoc.data();
          hotelName = hotelData['hotelName'] ?? 'Test Hotel';
        } else {
          // No hotels found, create a fake one
          hotelId = 'test_hotel_id';
        }
      }

      // Create the test request
      await _firestore.collection('service_requests').add({
        'clientId': clientId,
        'clientName': clientName,
        'clientEmail': clientEmail,
        'hotelId': hotelId,
        'hotelName': hotelName,
        'roomNumber': '101',
        'serviceType': 'Room Service',
        'requestDetails': 'This is a test request',
        'status': 'pending',
        'requestTime': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test request created')),
      );

      // Reload data
      _loadData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creating test request: $e';
      });
    }
  }

  Future<void> _updateStatus(String requestId, String newStatus) async {
    try {
      await _firestore.collection('service_requests').doc(requestId).update({
        'status': newStatus,
        if (newStatus == 'completed') 'completionTime': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request status updated to $newStatus')),
      );

      // Reload data
      _loadData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating status: $e';
      });
    }
  }

  Future<void> _deleteRequest(String requestId) async {
    try {
      await _firestore.collection('service_requests').doc(requestId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request deleted')),
      );

      // Reload data
      _loadData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error deleting request: $e';
      });
    }
  }
}