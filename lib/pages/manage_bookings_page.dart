import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lobbytalk/models/booking.dart';
import 'package:lobbytalk/services/booking/booking_service.dart';

class ManageBookingsPage extends StatefulWidget {
  const ManageBookingsPage({super.key});

  @override
  State<ManageBookingsPage> createState() => _ManageBookingsPageState();
}

class _ManageBookingsPageState extends State<ManageBookingsPage> {
  final BookingService _bookingService = BookingService();
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Bookings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: StreamBuilder<List<Booking>>(
              stream: _bookingService.getHotelBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading bookings'));
                }

                final bookings = snapshot.data ?? [];

                final filteredBookings = _selectedFilter == 'all'
                    ? bookings
                    : bookings.where((booking) => booking.status == _selectedFilter).toList();

                if (filteredBookings.isEmpty) {
                  return Center(child: Text('No bookings found'));
                }

                return ListView.builder(
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    return _buildBookingCard(booking);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookingDialog(),
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[100],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            SizedBox(width: 8),
            _buildFilterChip('Confirmed', 'confirmed'),
            SizedBox(width: 8),
            _buildFilterChip('Checked In', 'checked_in'),
            SizedBox(width: 8),
            _buildFilterChip('Checked Out', 'checked_out'),
            SizedBox(width: 8),
            _buildFilterChip('Cancelled', 'cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.redAccent.withOpacity(0.2),
      checkmarkColor: Colors.redAccent,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final dateFormat = DateFormat('MMM d, yyyy');

    Color statusColor;
    switch (booking.status) {
      case 'confirmed':
        statusColor = Colors.blue;
        break;
      case 'checked_in':
        statusColor = Colors.green;
        break;
      case 'checked_out':
        statusColor = Colors.grey;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.blue;
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
                Text(
                  'Booking #${booking.id.substring(0, 6)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Guest: ${booking.guestName}',
              style: TextStyle(fontSize: 15),
            ),
            Text(
              'Room: ${booking.roomNumber}',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  '${dateFormat.format(booking.checkInDate)} - ${dateFormat.format(booking.checkOutDate)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Show different action buttons based on booking status
                if (booking.status == 'confirmed')
                  ElevatedButton(
                    onPressed: () => _updateBookingStatus(booking.id, 'checked_in'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text('Check In'),
                  ),
                if (booking.status == 'checked_in')
                  ElevatedButton(
                    onPressed: () => _updateBookingStatus(booking.id, 'checked_out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                    ),
                    child: Text('Check Out'),
                  ),
                SizedBox(width: 8),
                if (booking.status != 'cancelled' && booking.status != 'checked_out')
                  OutlinedButton(
                    onPressed: () => _confirmCancelBooking(booking.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: Text('Cancel'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _bookingService.updateBookingStatus(bookingId, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking status updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating booking status')),
      );
    }
  }

  Future<void> _confirmCancelBooking(String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _updateBookingStatus(bookingId, 'cancelled');
    }
  }

  Future<void> _showAddBookingDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final roomController = TextEditingController();

    DateTime checkInDate = DateTime.now();
    DateTime checkOutDate = DateTime.now().add(Duration(days: 1));

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Booking'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Guest Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Guest Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: roomController,
                  decoration: InputDecoration(labelText: 'Room Number'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text('Check-in: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: checkInDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            checkInDate = picked;
                            if (checkOutDate.isBefore(checkInDate)) {
                              checkOutDate = checkInDate.add(Duration(days: 1));
                            }
                          });
                        }
                      },
                      child: Text(DateFormat('MMM d, yyyy').format(checkInDate)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('Check-out: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: checkOutDate,
                          firstDate: checkInDate.add(Duration(days: 1)),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            checkOutDate = picked;
                          });
                        }
                      },
                      child: Text(DateFormat('MMM d, yyyy').format(checkOutDate)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  // You'd need to add hotel ID and name from your auth service
                  await _bookingService.createBooking(
                    hotelId: 'YOUR_HOTEL_ID', // Replace with actual hotel ID
                    hotelName: 'YOUR_HOTEL_NAME', // Replace with actual hotel name
                    guestName: nameController.text,
                    guestEmail: emailController.text,
                    roomNumber: roomController.text,
                    checkInDate: checkInDate,
                    checkOutDate: checkOutDate,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Booking created successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating booking: $e')),
                  );
                }
              }
            },
            child: Text('Add Booking'),
          ),
        ],
      ),
    );
  }
}