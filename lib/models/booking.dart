import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String hotelId;
  final String hotelName;
  final String guestName;
  final String guestEmail;
  final String roomNumber;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic>? additionalInfo;

  Booking({
    required this.id,
    required this.hotelId,
    required this.hotelName,
    required this.guestName,
    required this.guestEmail,
    required this.roomNumber,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
    required this.createdAt,
    this.additionalInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'hotelId': hotelId,
      'hotelName': hotelName,
      'guestName': guestName,
      'guestEmail': guestEmail,
      'roomNumber': roomNumber,
      'checkInDate': Timestamp.fromDate(checkInDate),
      'checkOutDate': Timestamp.fromDate(checkOutDate),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'additionalInfo': additionalInfo,
    };
  }

  factory Booking.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Booking(
      id: doc.id,
      hotelId: data['hotelId'] ?? '',
      hotelName: data['hotelName'] ?? '',
      guestName: data['guestName'] ?? '',
      guestEmail: data['guestEmail'] ?? '',
      roomNumber: data['roomNumber'] ?? '',
      checkInDate: (data['checkInDate'] as Timestamp).toDate(),
      checkOutDate: (data['checkOutDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'confirmed',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      additionalInfo: data['additionalInfo'],
    );
  }
}