import 'package:cloud_firestore/cloud_firestore.dart';

class HotelReservation {
  final String id;
  final String reservationCode;
  final String name;
  final String surname;
  final String identityNumber;
  final String hotelName;
  final String roomType;
  final String roomNumber;
  final DateTime checkInDate;
  final int stayDays;
  final int personCount;
  final bool isCheckedIn;
  final bool isCheckedOut;
  final bool includeBreakfast;
  final bool includeDinner;
  final List<Map<String, dynamic>> housekeepingRequests; // BUNU EKLE
  final double totalPrice;
  final List<Map<String, dynamic>> roomServiceOrders;

  HotelReservation({
    required this.id,
    required this.reservationCode,
    required this.name,
    required this.surname,
    required this.identityNumber,
    required this.hotelName,
    required this.roomType,
    required this.roomNumber,
    required this.checkInDate,
    required this.stayDays,
    required this.personCount,
    this.isCheckedIn = false,
    this.isCheckedOut = false,
    required this.includeBreakfast,
    required this.includeDinner,
    required this.totalPrice,
    this.roomServiceOrders = const [],
    this.housekeepingRequests = const [], // BUNU EKLE
  });

  factory HotelReservation.fromFirestore(Map<String, dynamic> data, String documentId) {
    return HotelReservation(
      housekeepingRequests: List<Map<String, dynamic>>.from(data['housekeepingRequests'] ?? []), // BUNU EKLE
      id: documentId,
      reservationCode: data['reservationCode'] ?? '',
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      identityNumber: data['identityNumber'] ?? '',
      hotelName: data['hotelName'] ?? '',
      roomType: data['roomType'] ?? '',
      roomNumber: data['roomNumber'] ?? '',
      checkInDate: (data['checkInDate'] as Timestamp).toDate(),
      stayDays: data['stayDays'] ?? 1,
      personCount: data['personCount'] ?? 1,
      isCheckedIn: data['isCheckedIn'] ?? false,
      isCheckedOut: data['isCheckedOut'] ?? false,
      includeBreakfast: data['includeBreakfast'] ?? false,
      includeDinner: data['includeDinner'] ?? false,
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      roomServiceOrders: List<Map<String, dynamic>>.from(data['roomServiceOrders'] ?? []),
    );
  }
}
