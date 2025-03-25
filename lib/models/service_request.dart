import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequest {
  final String id;
  final String clientId;
  final String clientName;
  final String clientEmail;
  final String hotelId;
  final String hotelName;
  final String roomNumber;
  final String serviceType;
  final String requestDetails;
  final String status; // 'pending', 'in_progress', 'completed', 'cancelled'
  final DateTime requestTime;
  final DateTime? completionTime;
  final String? notes;
  final String? assignedTo;

  ServiceRequest({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.hotelId,
    required this.hotelName,
    required this.roomNumber,
    required this.serviceType,
    required this.requestDetails,
    required this.status,
    required this.requestTime,
    this.completionTime,
    this.notes,
    this.assignedTo,
  });

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'roomNumber': roomNumber,
      'serviceType': serviceType,
      'requestDetails': requestDetails,
      'status': status,
      'requestTime': requestTime,
      'completionTime': completionTime,
      'notes': notes,
      'assignedTo': assignedTo,
    };
  }

  // Create a service request from a Firestore document
  factory ServiceRequest.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle Firestore timestamps
    DateTime requestTime = DateTime.now();
    if (data['requestTime'] != null) {
      if (data['requestTime'] is Timestamp) {
        requestTime = (data['requestTime'] as Timestamp).toDate();
      }
    }

    DateTime? completionTime;
    if (data['completionTime'] != null) {
      if (data['completionTime'] is Timestamp) {
        completionTime = (data['completionTime'] as Timestamp).toDate();
      }
    }

    return ServiceRequest(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      clientName: data['clientName'] ?? '',
      clientEmail: data['clientEmail'] ?? '',
      hotelId: data['hotelId'] ?? '',
      hotelName: data['hotelName'] ?? '',
      roomNumber: data['roomNumber'] ?? '',
      serviceType: data['serviceType'] ?? '',
      requestDetails: data['requestDetails'] ?? '',
      status: data['status'] ?? 'pending',
      requestTime: requestTime,
      completionTime: completionTime,
      notes: data['notes'],
      assignedTo: data['assignedTo'],
    );
  }

  // Create a copy of the request with updated fields
  ServiceRequest copyWith({
    String? status,
    DateTime? completionTime,
    String? notes,
    String? assignedTo,
  }) {
    return ServiceRequest(
      id: this.id,
      clientId: this.clientId,
      clientName: this.clientName,
      clientEmail: this.clientEmail,
      hotelId: this.hotelId,
      hotelName: this.hotelName,
      roomNumber: this.roomNumber,
      serviceType: this.serviceType,
      requestDetails: this.requestDetails,
      status: status ?? this.status,
      requestTime: this.requestTime,
      completionTime: completionTime ?? this.completionTime,
      notes: notes ?? this.notes,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}