import 'package:flutter/material.dart';
import 'package:lobbytalk/models/service_request.dart';
import 'package:intl/intl.dart';

import '../services/request/service_request_service.dart';

class ClientServiceRequestPage extends StatefulWidget {
  final String hotelId;
  final String hotelName;
  final String roomNumber;
  final List<String> availableServices;

  const ClientServiceRequestPage({
    Key? key,
    required this.hotelId,
    required this.hotelName,
    required this.roomNumber,
    required this.availableServices,
  }) : super(key: key);

  @override
  State<ClientServiceRequestPage> createState() => _ClientServiceRequestPageState();
}

class _ClientServiceRequestPageState extends State<ClientServiceRequestPage> {
  final ServiceRequestService _requestService = ServiceRequestService();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String _selectedService = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.availableServices.isNotEmpty) {
      _selectedService = widget.availableServices.first;
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  IconData _getServiceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'room service':
        return Icons.room_service;
      case 'housekeeping':
        return Icons.cleaning_services;
      case 'spa & wellness':
        return Icons.spa;
      case 'restaurant':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'concierge':
        return Icons.assistant;
      case 'laundry':
        return Icons.local_laundry_service;
      default:
        return Icons.miscellaneous_services;
    }
  }

  Future<void> _submitRequest() async {
    if (_selectedService.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a service')),
      );
      return;
    }

    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final requestId = await _requestService.createServiceRequest(
        hotelId: widget.hotelId,
        hotelName: widget.hotelName,
        roomNumber: widget.roomNumber,
        serviceType: _selectedService,
        requestDetails: _detailsController.text,
        clientName: _nameController.text,
      );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service request submitted successfully (ID: $requestId)')),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Request', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hotelName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Room ${widget.roomNumber}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              Text(
                'Request Service',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 16),

              Text(
                'Select Service',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),

              SizedBox(height: 8),

              if (widget.availableServices.isEmpty)
                Text(
                  'No services available for this hotel',
                  style: TextStyle(color: Colors.red),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedService,
                      items: widget.availableServices.map((service) {
                        return DropdownMenuItem<String>(
                          value: service,
                          child: Row(
                            children: [
                              Icon(_getServiceIcon(service)),
                              SizedBox(width: 12),
                              Text(service),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedService = value!;
                        });
                      },
                    ),
                  ),
                ),

              SizedBox(height: 16),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              SizedBox(height: 16),

              TextField(
                controller: _detailsController,
                decoration: InputDecoration(
                  labelText: 'Request Details',
                  hintText: 'Enter any specific details about your request',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),

              SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Submit Request',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClientActiveRequestsPage extends StatelessWidget {
  final ServiceRequestService _requestService = ServiceRequestService();

  ClientActiveRequestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Requests', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: StreamBuilder<List<ServiceRequest>>(
        stream: _requestService.getClientRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading requests'));
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.room_service_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No service requests found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your requests will appear here',
                    style: TextStyle(
                      color: Colors.grey[500],
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
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, ServiceRequest request) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (request.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Pending';
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusIcon = Icons.pending_actions;
        statusText = 'In Progress';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusText = request.status;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.serviceType,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              request.hotelName,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            Text(
              'Room ${request.roomNumber}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            if (request.requestDetails.isNotEmpty) ...[
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
            if (request.notes != null && request.notes!.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      request.notes!,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
            if (request.status == 'pending') ...[
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _requestService.updateRequestStatus(request.id, 'cancelled');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Request cancelled')),
                      );
                    },
                    child: Text('Cancel Request'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}