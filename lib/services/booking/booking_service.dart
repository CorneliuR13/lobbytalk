import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lobbytalk/models/booking.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Booking>> getHotelBookings() {
    final currentUserId = _auth.currentUser?.uid;

    return _firestore
        .collection('bookings')
        .where('hotelId', isEqualTo: currentUserId)
        .orderBy('checkInDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Booking.fromDocument(doc)).toList();
    });
  }

  Stream<List<Booking>> getUserBookings() {
    final currentUserEmail = _auth.currentUser?.email;

    return _firestore
        .collection('bookings')
        .where('guestEmail', isEqualTo: currentUserEmail)
        .orderBy('checkInDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Booking.fromDocument(doc)).toList();
    });
  }

  Future<String> createBooking({
    required String hotelId,
    required String hotelName,
    required String guestName,
    required String guestEmail,
    required String roomNumber,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    Map<String, dynamic>? additionalInfo,
  }) async {
    final booking = Booking(
      id: '',
      hotelId: hotelId,
      hotelName: hotelName,
      guestName: guestName,
      guestEmail: guestEmail,
      roomNumber: roomNumber,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      status: 'confirmed',
      createdAt: DateTime.now(),
      additionalInfo: additionalInfo,
    );

    final docRef = await _firestore.collection('bookings').add(booking.toMap());
    return docRef.id;
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': newStatus,
    });
  }

  Future<Booking?> getBookingById(String bookingId) async {
    final doc = await _firestore.collection('bookings').doc(bookingId).get();

    if (doc.exists) {
      return Booking.fromDocument(doc);
    }

    return null;
  }

  Future<bool> verifyBooking({
    required String bookingId,
    required String roomNumber,
    required String guestName,
  }) async {
    try {
      final booking = await getBookingById(bookingId);

      if (booking == null) {
        return false;
      }

      bool isValid = booking.roomNumber == roomNumber &&
          booking.guestName.toLowerCase() == guestName.toLowerCase();

      bool isActive =
          booking.status == 'confirmed' || booking.status == 'checked_in';

      return isValid && isActive;
    } catch (e) {
      print('Error verifying booking: $e');
      return false;
    }
  }

  Future<void> addCheckoutNotes(String bookingId, String notes) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'checkoutNotes': notes,
      'checkoutTime': FieldValue.serverTimestamp(),
    });
  }
}
