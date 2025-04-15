import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lobbytalk/pages/check_in_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  void _searchHotels(String query) async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      QuerySnapshot receptionSnapshot;

      // If query is empty, get all hotels
      if (query.isEmpty) {
        receptionSnapshot = await _firestore
            .collection('receptions')
            .where('onboardingCompleted', isEqualTo: true)
            .limit(50) // Limit to avoid loading too many
            .get();
      } else {
        // Search for specific hotel name
        receptionSnapshot = await _firestore
            .collection('receptions')
            .where('hotelName', isGreaterThanOrEqualTo: query)
            .where('hotelName', isLessThanOrEqualTo: query + '\uf8ff')
            .get();
      }

      final results = receptionSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'email': data['email'] ?? 'reception@example.com',
          'hotelName': data['hotelName'] ?? 'Unknown Hotel',
          'location': data['location'] ?? 'Unknown Location',
          'description': data['description'] ?? '',
        };
      }).toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('Error searching hotels: $e');
      setState(() {
        _isSearching = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching hotels: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Find Your Hotel", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search hotel by name or leave empty to see all",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: _searchHotels,
            ),
          ),
          ElevatedButton(
            onPressed: () => _searchHotels(_searchController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text("Search Hotels", style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 16),
          _isSearching
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: !_hasSearched
                ? Center(
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
                    "Search for hotels or press Search to see all",
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : _searchResults.isEmpty
                ? Center(
              child: Text(
                "No hotels found",
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
                : _buildHotelList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelList() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final hotel = _searchResults[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: ExpansionTile(
            title: Text(
              hotel['hotelName'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              hotel['location'],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.lightBlueAccent.withOpacity(0.2),
              child: Icon(
                Icons.hotel,
                color: Colors.lightBlueAccent,
              ),
            ),
            children: [
              if (hotel['description'] != null && hotel['description'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    hotel['description'],
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckInPage(
                          hotelName: hotel['hotelName'],
                          receptionId: hotel['uid'],
                          receptionEmail: hotel['email'],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    minimumSize: Size(double.infinity, 40),
                  ),
                  child: Text('Check In', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}