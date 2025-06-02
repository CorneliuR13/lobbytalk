import 'package:flutter/material.dart';
import 'package:lobbytalk/models/service_request.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lobbytalk/pages/home_page.dart';

import '../services/request/service_request_service.dart';

class ReceptionServiceRequestsPage extends StatefulWidget {
  const ReceptionServiceRequestsPage({Key? key}) : super(key: key);

  @override
  State<ReceptionServiceRequestsPage> createState() => _ReceptionServiceRequestsPageState();
}

class _ReceptionServiceRequestsPageState extends State<ReceptionServiceRequestsPage> with SingleTickerProviderStateMixin {
  final ServiceRequestService _requestService = ServiceRequestService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;

  bool _isLoading = true;
  String _errorMessage = '';

  List<ServiceRequest> _allRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final allRequests = await _requestService.getAllHotelRequests();

      print('Found ${allRequests.length} total requests');

      if (mounted) {
        setState(() {
          _allRequests = allRequests;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading requests: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading requests: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<ServiceRequest> _getFilteredRequests(String status) {
    return _allRequests.where((request) => request.status == status).toList();
  }

  Future<void> _checkOut() async {
    try {
      // Show confirmation dialog
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Check Out'),
          content: Text('Are you sure you want to check out? This will clear your connection with the hotel.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Check Out'),
            ),
          ],
        ),
      ) ?? false;

      if (!confirm) return;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      final userId = _auth.currentUser?.uid;

      // Update check-in status in Firestore
      QuerySnapshot checkInRequests = await _firestore
          .collection("check_in_requests")
          .where('clientId', isEqualTo: userId)
          .where('status', isEqualTo: 'approved')
          .get();

      // Update all approved check-ins to checked-out
      for (var doc in checkInRequests.docs) {
        await _firestore.collection("check_in_requests").doc(doc.id).update({
          'status': 'checked_out',
          'checkOutTime': FieldValue.serverTimestamp(),
        });
      }

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to home page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false, // This clears the navigation stack
      );

    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context, rootNavigator: true).pop();

      print('Error checking out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingRequests = _getFilteredRequests('pending');
    final inProgressRequests = _getFilteredRequests('in_progress');
    final completedRequests = _getFilteredRequests('completed');

    return Scaffold(
      appBar: AppBar(
        title: Text('Service Requests', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending (${pendingRequests.length})'),
            Tab(text: 'In Progress (${inProgressRequests.length})'),
            Tab(text: 'Completed (${completedRequests.length})'),
          ],
          labelColor: Colors.white,
          indicatorColor: Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadRequests,
            tooltip: 'Refresh',
          ),
          // Add Check Out button

        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(_errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRequests,
              child: Text('Retry'),
            ),
          ],
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsTab(pendingRequests, 'pending'),

          _buildRequestsTab(inProgressRequests, 'in_progress'),

          _buildRequestsTab(completedRequests, 'completed'),
        ],
      ),
    );
  }

  Widget _buildRequestsTab(List<ServiceRequest> requests, String status) {
    if (requests.isEmpty) {
      String message = '';
      IconData icon = Icons.info;

      switch (status) {
        case 'pending':
          message = 'No pending requests';
          icon = Icons.hourglass_empty;
          break;
        case 'in_progress':
          message = 'No requests in progress';
          icon = Icons.pending_actions;
          break;
        case 'completed':
          message = 'No completed requests';
          icon = Icons.check_circle;
          break;
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(context, request);
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, ServiceRequest request) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getServiceIcon(request.serviceType),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.serviceType,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Room ${request.roomNumber}',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(request.status),
                    color: _getStatusColor(request.status),
                    size: 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  'Guest: ${request.clientName}',
                  style: TextStyle(
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (request.requestDetails.isNotEmpty) ...[
              Text(
                'Details:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                request.requestDetails,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
            ],
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  'Requested: ${dateFormat.format(request.requestTime)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (request.completionTime != null) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'Completed: ${dateFormat.format(request.completionTime!)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (request.status == 'pending') ...[
                  // Remove the Assign button and replace with direct "Start" functionality
                  TextButton(
                    onPressed: () => _startRequest(context, request),
                    child: Text('Start Request'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 8),
                ],

                // Keep the rest of the buttons
                if (request.status == 'in_progress') ...[
                  TextButton(
                    onPressed: () => _showCompleteDialog(context, request),
                    child: Text('Complete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                  SizedBox(width: 8),
                ],

                if (request.status != 'completed' && request.status != 'cancelled') ...[
                  TextButton(
                    onPressed: () => _showAddNotesDialog(context, request),
                    child: Text('Add Notes'),
                  ),
                ],
              ],
            ),

            if (request.notes != null && request.notes!.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      request.notes!,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _startRequest(BuildContext context, ServiceRequest request) {
    try {
      _requestService.updateRequestStatus(
        request.id,
        'in_progress',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request marked as in progress')),
      );

      _loadRequests(); // Reload the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating request: $e')),
      );
    }
  }

  Widget _getServiceIcon(String service) {
    IconData iconData = Icons.miscellaneous_services;
    Color iconColor = Colors.blueGrey;

    switch (service.toLowerCase()) {
      case 'room service':
        iconData = Icons.room_service;
        iconColor = Colors.orange;
        break;
      case 'housekeeping':
        iconData = Icons.cleaning_services;
        iconColor = Colors.blue;
        break;
      case 'spa & wellness':
        iconData = Icons.spa;
        iconColor = Colors.purple;
        break;
      case 'restaurant':
        iconData = Icons.restaurant;
        iconColor = Colors.red;
        break;
      case 'transport':
        iconData = Icons.directions_car;
        iconColor = Colors.green;
        break;
      case 'concierge':
        iconData = Icons.assistant;
        iconColor = Colors.indigo;
        break;
      case 'laundry':
        iconData = Icons.local_laundry_service;
        iconColor = Colors.teal;
        break;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'in_progress':
        return Icons.pending_actions;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Future<void> updateRequestToInProgress(String requestId) async {
    try {
      // Use the _requestService instead of directly accessing Firestore
      await _requestService.updateRequestStatus(requestId, 'in_progress');

      // Reload the requests list
      _loadRequests();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request marked as in progress')),
      );
    } catch (e) {
      print('Error updating service request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating request: $e')),
      );
    }
  }

  void _showAssignDialog(BuildContext context, ServiceRequest request) {
    final TextEditingController staffNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Assign this ${request.serviceType} request to:'),
            SizedBox(height: 16),
            TextField(
              controller: staffNameController,
              decoration: InputDecoration(
                labelText: 'Staff Name',
                hintText: 'Enter staff member name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (staffNameController.text.isNotEmpty) {
                _requestService.assignRequest(
                  request.id,
                  staffNameController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Request assigned to ${staffNameController.text}')),
                );
                _loadRequests(); // Reload the list
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a staff name')),
                );
              }
            },
            child: Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, ServiceRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete Request'),
        content: Text('Mark this ${request.serviceType} request as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _requestService.updateRequestStatus(
                request.id,
                'completed',
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Request marked as completed')),
              );
              _loadRequests(); // Reload the list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showAddNotesDialog(BuildContext context, ServiceRequest request) {
    final TextEditingController notesController = TextEditingController();
    if (request.notes != null) {
      notesController.text = request.notes!;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Notes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter notes about this request',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _requestService.addRequestNotes(
                request.id,
                notesController.text,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notes updated')),
              );
              _loadRequests(); // Reload the list
            },
            child: Text('Save Notes'),
          ),
        ],
      ),
    );
  }
}
