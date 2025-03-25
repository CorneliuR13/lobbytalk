import 'package:flutter/material.dart';
import 'package:lobbytalk/models/service_request.dart';
import 'package:intl/intl.dart';

import '../services/request/service_request_service.dart';

class ReceptionServiceRequestsPage extends StatefulWidget {
  const ReceptionServiceRequestsPage({Key? key}) : super(key: key);

  @override
  State<ReceptionServiceRequestsPage> createState() => _ReceptionServiceRequestsPageState();
}

class _ReceptionServiceRequestsPageState extends State<ReceptionServiceRequestsPage> with SingleTickerProviderStateMixin {
  final ServiceRequestService _requestService = ServiceRequestService();
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
      // Load all requests
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

  // Get requests filtered by status
  List<ServiceRequest> _getFilteredRequests(String status) {
    return _allRequests.where((request) => request.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get filtered lists
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
          // Pending requests tab
          _buildRequestsTab(pendingRequests, 'pending'),

          // In progress requests tab
          _buildRequestsTab(inProgressRequests, 'in_progress'),

          // Completed requests tab
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
            if (request.assignedTo != null && request.assignedTo!.isNotEmpty) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.assignment_ind, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    'Assigned to: ${request.assignedTo}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (request.status == 'pending') ...[
                  TextButton(
                    onPressed: () => _showAssignDialog(context, request),
                    child: Text('Assign & Start'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 8),
                ],

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

  // Dialog to assign request to staff
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

  // Dialog to complete request
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

  // Dialog to add notes
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