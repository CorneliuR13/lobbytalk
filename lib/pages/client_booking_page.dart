import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lobbytalk/models/booking.dart';
import 'package:lobbytalk/pages/check_in_page.dart';
import 'package:lobbytalk/services/booking/booking_service.dart';

class ClientBookingsPage extends StatelessWidget {
  ClientBookingsPage({super.key});

  final BookingService _bookingService = BookingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: StreamBuilder<List<Booking>>(
        stream: _bookingService.getUserBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading bookings'));
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hotel_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No bookings found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your hotel bookings will appear here',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingCard(context, booking);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking booking) {
    final dateFormat = DateFormat('MMM d, yyyy');

    final nights = booking.checkOutDate.difference(booking.checkInDate).inDays;

    Color statusColor;
    String statusText;

    switch (booking.status) {
      case 'confirmed':
        statusColor = Colors.blue;
        statusText = 'CONFIRMED';
        break;
      case 'checked_in':
        statusColor = Colors.green;
        statusText = 'CHECKED IN';
        break;
      case 'checked_out':
        statusColor = Colors.grey;
        statusText = 'CHECKED OUT';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'CANCELLED';
        break;
      default:
        statusColor = Colors.blue;
        statusText = booking.status.toUpperCase();
    }

    final isUpcoming = booking.checkInDate.isAfter(DateTime.now().subtract(Duration(days: 1)));

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Hotel name bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.hotelName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Booking details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Dates row
                Row(
                  children: [
                    // Check-in column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CHECK-IN',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            dateFormat.format(booking.checkInDate),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Nights indicator
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$nights ${nights == 1 ? 'night' : 'nights'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Check-out column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'CHECK-OUT',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            dateFormat.format(booking.checkOutDate),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Divider(height: 24),

                // Room info
                Row(
                  children: [
                    Icon(Icons.hotel, color: Colors.grey[600], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Room ${booking.roomNumber}',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Booking reference
                Row(
                  children: [
                    Icon(Icons.confirmation_number, color: Colors.grey[600], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Booking ID: ${booking.id.substring(0, 6).toUpperCase()}',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                if (booking.status == 'confirmed' && isUpcoming)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckInPage(
                            hotelName: booking.hotelName,
                            receptionId: booking.hotelId,
                            receptionEmail: '${booking.hotelName.toLowerCase().replaceAll(' ', '')}@reception.com',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      minimumSize: Size(double.infinity, 40),
                    ),
                    child: Text('Check In Now'),
                  ),

                if (booking.status == 'checked_in')
                  ElevatedButton.icon(
                    onPressed: () {

                    },
                    icon: Icon(Icons.chat),
                    label: Text('Chat with Reception'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(double.infinity, 40),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}