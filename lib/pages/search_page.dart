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

  void _searchHotels(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final receptionSnapshot = await _firestore
          .collection('receptions')
          .where('hotelName', isGreaterThanOrEqualTo: query)
          .where('hotelName', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final results = receptionSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'email': data['email'],
          'hotelName': data['hotelName'] ?? 'Unknown Hotel',
          'location': data['location'] ?? 'Unknown Location',
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
                hintText: "Search hotel by name...",
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
            child: Text("Search", style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 16),
          _isSearching
              ? CircularProgressIndicator()
              : Expanded(
                  child: _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isEmpty
                                ? "Search for a hotel to check in"
                                : "No hotels found",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final hotel = _searchResults[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              elevation: 2,
                              child: ListTile(
                                title: Text(hotel['hotelName']),
                                subtitle: Text(hotel['location']),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
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
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}
