import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lobbytalk/pages/chat_page.dart';
import 'package:lobbytalk/services/booking/booking_service.dart';

class CheckInPage extends StatefulWidget {
  final String hotelName;
  final String receptionId;
  final String receptionEmail;

  const CheckInPage({
    super.key,
    required this.hotelName,
    required this.receptionId,
    required this.receptionEmail,
  });

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final TextEditingController _bookingIdController = TextEditingController();
  final TextEditingController _roomNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isSubmitting = false;
  bool _isVerifying = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final BookingService _bookingService = BookingService();

  Future<void> _submitCheckIn() async {
    if (_bookingIdController.text.isEmpty ||
        _roomNumberController.text.isEmpty ||
        _nameController.text.isEmpty) {
      _showErrorDialog("Please fill all fields");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String currentUserId = _auth.currentUser!.uid;
      final String currentUserEmail = _auth.currentUser!.email!;

      final checkInRequest = await _firestore.collection("check_in_requests").add({
        'clientId': currentUserId,
        'clientEmail': currentUserEmail,
        'clientName': _nameController.text,
        'receptionId': widget.receptionId,
        'receptionEmail': widget.receptionEmail,
        'hotelName': widget.hotelName,
        'bookingId': _bookingIdController.text,
        'roomNumber': _roomNumberController.text,
        'status': 'pending', // pending, approved, or rejected
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isSubmitting = false;
      });

      _showSuccessDialog(checkInRequest.id);
    } catch (e) {
      print('Error submitting check-in: $e');
      setState(() {
        _isSubmitting = false;
      });
      _showErrorDialog("Failed to submit check-in request");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Check-In Request Sent'),
        content: Text(
          'Your check-in request has been sent to the hotel reception. '
              'Please wait for approval. You will be notified when your request is processed.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog

              _listenForApproval(requestId);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _listenForApproval(String requestId) {
    _firestore
        .collection("check_in_requests")
        .doc(requestId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final status = snapshot.data()?['status'];
        if (status == 'approved') {
          if (_bookingIdController.text.isNotEmpty) {
            _bookingService.updateBookingStatus(_bookingIdController.text, 'checked_in');
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiveEmail: widget.receptionEmail,
                receiverID: widget.receptionId,
              ),
            ),
          );
        } else if (status == 'rejected') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Your check-in request was rejected. Please verify your details.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Check In", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hotel info
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hotelName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Please provide your booking details to check in",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Check-in form
              Text(
                "Enter Your Booking Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              // Booking ID
              TextField(
                controller: _bookingIdController,
                decoration: InputDecoration(
                  labelText: "Booking ID",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
              ),
              SizedBox(height: 16),

              // Room Number
              TextField(
                controller: _roomNumberController,
                decoration: InputDecoration(
                  labelText: "Room Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.hotel),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              // Guest Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name (as on booking)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitCheckIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      _isVerifying
                          ? "Verifying booking..."
                          : "Submitting request...",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                    : Text(
                  "Submit Check-In Request",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
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