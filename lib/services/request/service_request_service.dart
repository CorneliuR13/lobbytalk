import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lobbytalk/models/service_request.dart';
import 'package:lobbytalk/services/auth/auth_service.dart';

class ServiceRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  // Create a new service request
  Future<String> createServiceRequest({
    required String hotelId,
    required String hotelName,
    required String roomNumber,
    required String serviceType,
    required String requestDetails,
    required String clientName,
  }) async {
    try {
      final String clientId = _auth.currentUser!.uid;
      final String clientEmail = _auth.currentUser!.email!;

      // Create request data map
      final Map<String, dynamic> requestData = {
        'clientId': clientId,
        'clientName': clientName,
        'clientEmail': clientEmail,
        'hotelId': hotelId,
        'hotelName': hotelName,
        'roomNumber': roomNumber,
        'serviceType': serviceType,
        'requestDetails': requestDetails,
        'status': 'pending',
        'requestTime': FieldValue.serverTimestamp(),
      };

      // Add to Firestore
      final docRef = await _firestore
          .collection('service_requests')
          .add(requestData);

      print('Created service request with ID: ${docRef.id}');

      return docRef.id;
    } catch (e) {
      print('Error creating service request: $e');
      throw Exception('Failed to create service request: $e');
    }
  }

  // Get all service requests for a client
  Stream<List<ServiceRequest>> getClientRequests() {
    final String clientId = _auth.currentUser!.uid;

    return _firestore
        .collection('service_requests')
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ServiceRequest.fromDocument(doc)).toList();
    });
  }

  // Get all service requests for a hotel
  Future<List<ServiceRequest>> getAllHotelRequests() async {
    final String hotelId = _auth.currentUser!.uid;

    try {
      // Simple query without ordering (to avoid index issues)
      final snapshot = await _firestore
          .collection('service_requests')
          .where('hotelId', isEqualTo: hotelId)
          .get();

      final requests = snapshot.docs.map((doc) => ServiceRequest.fromDocument(doc)).toList();
      // Sort in memory instead
      requests.sort((a, b) => b.requestTime.compareTo(a.requestTime));

      return requests;
    } catch (e) {
      print('Error getting hotel requests: $e');
      throw Exception('Failed to get hotel requests: $e');
    }
  }

  // Update service request status
  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    try {
      await _firestore.collection('service_requests').doc(requestId).update({
        'status': newStatus,
        if (newStatus == 'completed') 'completionTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating service request status: $e');
      throw Exception('Failed to update service request status: $e');
    }
  }

  // Add notes to a service request
  Future<void> addRequestNotes(String requestId, String notes) async {
    try {
      await _firestore.collection('service_requests').doc(requestId).update({
        'notes': notes,
      });
    } catch (e) {
      print('Error adding notes to service request: $e');
      throw Exception('Failed to add notes to service request: $e');
    }
  }

  // Assign a service request to staff
  Future<void> assignRequest(String requestId, String staffName) async {
    try {
      await _firestore.collection('service_requests').doc(requestId).update({
        'assignedTo': staffName,
        'status': 'in_progress',
      });
    } catch (e) {
      print('Error assigning service request: $e');
      throw Exception('Failed to assign service request: $e');
    }
  }
}