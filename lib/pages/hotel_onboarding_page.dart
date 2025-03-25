import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lobbytalk/pages/reception_page.dart';

class HotelOnboardingPage extends StatefulWidget {
  const HotelOnboardingPage({super.key});

  @override
  State<HotelOnboardingPage> createState() => _HotelOnboardingPageState();
}

class _HotelOnboardingPageState extends State<HotelOnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  // Hotel information
  final TextEditingController _hotelNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Available services
  final Map<String, bool> _availableServices = {
    'Room Service': true,
    'Housekeeping': true,
    'Spa & Wellness': false,
    'Restaurant': true,
    'Transport': false,
    'Concierge': false,
    'Laundry': true,
    'Gym': false,
    'Swimming Pool': false,
    'Business Center': false,
    'Conference Rooms': false,
    'Airport Shuttle': false,
  };

  // Check-in options
  bool _requireBookingId = true;
  bool _requireGuestIdentification = true;
  bool _allowEarlyCheckIn = false;
  bool _allowLateCheckOut = false;

  @override
  void dispose() {
    _pageController.dispose();
    _hotelNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitOnboarding() async {
    // Validate first page
    if (_hotelNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your hotel name')),
      );
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final email = FirebaseAuth.instance.currentUser!.email;

      // Get the list of enabled services
      final List<String> enabledServices = _availableServices.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // Save the hotel data to Firestore
      await FirebaseFirestore.instance.collection("receptions").doc(userId).set({
        'uid': userId,
        'email': email,
        'hotelName': _hotelNameController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'availableServices': enabledServices,
        'checkInOptions': {
          'requireBookingId': _requireBookingId,
          'requireGuestIdentification': _requireGuestIdentification,
          'allowEarlyCheckIn': _allowEarlyCheckIn,
          'allowLateCheckOut': _allowLateCheckOut,
        },
        'onboardingCompleted': true,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Navigate to the reception page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ReceptionPage()),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving hotel information: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Up Your Hotel', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        leading: _currentPage > 0
            ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _previousPage,
        )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / 3,
            backgroundColor: Colors.grey[200],
            color: Colors.redAccent,
          ),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                // Page 1: Basic Hotel Information
                _buildHotelInfoPage(),

                // Page 2: Available Services
                _buildServicesPage(),

                // Page 3: Check-in Options
                _buildCheckInOptionsPage(),
              ],
            ),
          ),

          // Bottom navigation buttons
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildHotelInfoPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about your hotel',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'This information will be shown to guests when they search for hotels.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          SizedBox(height: 32),

          // Hotel name
          TextField(
            controller: _hotelNameController,
            decoration: InputDecoration(
              labelText: 'Hotel Name *',
              hintText: 'Enter your hotel name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.hotel),
            ),
          ),
          SizedBox(height: 16),

          // Location
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location',
              hintText: 'City, State, Country',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          SizedBox(height: 16),

          // Description
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Tell guests about your hotel',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
          ),
          SizedBox(height: 16),

          Text(
            '* Required field',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What services do you offer?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Guests will be able to request these services through the app.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            children: _availableServices.entries.map((entry) {
              return SwitchListTile(
                title: Text(entry.key),
                value: entry.value,
                activeColor: Colors.redAccent,
                onChanged: (bool value) {
                  setState(() {
                    _availableServices[entry.key] = value;
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckInOptionsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Check-in Preferences',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Set your check-in and check-out policies.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        SwitchListTile(
          title: Text('Require Booking ID'),
          subtitle: Text('Guests must provide a booking ID to check in'),
          value: _requireBookingId,
          activeColor: Colors.redAccent,
          onChanged: (bool value) {
            setState(() {
              _requireBookingId = value;
            });
          },
        ),

        SwitchListTile(
          title: Text('Require Guest Identification'),
          subtitle: Text('Guests must provide identification to check in'),
          value: _requireGuestIdentification,
          activeColor: Colors.redAccent,
          onChanged: (bool value) {
            setState(() {
              _requireGuestIdentification = value;
            });
          },
        ),

        SwitchListTile(
          title: Text('Allow Early Check-in'),
          subtitle: Text('Guests can check in before the standard time'),
          value: _allowEarlyCheckIn,
          activeColor: Colors.redAccent,
          onChanged: (bool value) {
            setState(() {
              _allowEarlyCheckIn = value;
            });
          },
        ),

        SwitchListTile(
          title: Text('Allow Late Check-out'),
          subtitle: Text('Guests can check out after the standard time'),
          value: _allowLateCheckOut,
          activeColor: Colors.redAccent,
          onChanged: (bool value) {
            setState(() {
              _allowLateCheckOut = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentPage > 0
              ? TextButton(
            onPressed: _previousPage,
            child: Text('Back'),
          )
              : SizedBox(width: 80),
          Text(
            '${_currentPage + 1} of 3',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: _isSubmitting
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              _currentPage == 2 ? 'Finish' : 'Next',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}