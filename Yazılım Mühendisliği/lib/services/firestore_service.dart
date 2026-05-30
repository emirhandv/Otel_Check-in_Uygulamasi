  import 'package:cloud_firestore/cloud_firestore.dart';
  import '../models/reservation.dart';
  import 'dart:math';
  
  class FirestoreService {
    final FirebaseFirestore _db = FirebaseFirestore.instance;
  
    // Get all reservations for a specific identity number
    Future<List<HotelReservation>> getUserReservations(String identityNumber) async {
      try {
        var querySnapshot = await _db
            .collection('hotel_reservations')
            .where('identityNumber', isEqualTo: identityNumber)
            .get();
  
        return querySnapshot.docs
            .map((doc) => HotelReservation.fromFirestore(doc.data(), doc.id))
            .toList();
      } catch (e) {
        print("Firestore Error: $e");
        rethrow;
      }
    }
  
    // Search for a hotel reservation by Reservation Code and Surname
    Future<HotelReservation?> getReservation(String code, String surname) async {
      try {
        var querySnapshot = await _db
            .collection('hotel_reservations')
            .where('reservationCode', isEqualTo: code.toUpperCase())
            .where('surname', isEqualTo: surname.toUpperCase())
            .limit(1)
            .get();
  
        if (querySnapshot.docs.isNotEmpty) {
          var doc = querySnapshot.docs.first;
          return HotelReservation.fromFirestore(doc.data(), doc.id);
        }
        return null;
      } catch (e) {
        rethrow;
      }
    }
  
    // Complete hotel check-in process
    Future<bool> completeHotelCheckIn(String docId) async {
      try {
        await _db.collection('hotel_reservations').doc(docId).update({
          'isCheckedIn': true,
          'isCheckedOut': false,
        });
        return true;
      } catch (e) {
        rethrow;
      }
    }
  
    // Complete hotel check-out process
    Future<bool> completeHotelCheckOut(String docId) async {
      try {
        await _db.collection('hotel_reservations').doc(docId).update({
          'isCheckedOut': true,
        });
        return true;
      } catch (e) {
        rethrow;
      }
    }

    // Add room service cost and items to the reservation
    Future<void> addRoomServiceOrder(String docId, double totalAmount, List<Map<String, dynamic>> items) async {
      await _db.collection('hotel_reservations').doc(docId).update({
        'totalPrice': FieldValue.increment(totalAmount), // Mevcut fiyatın üstüne ekler
        'roomServiceOrders': FieldValue.arrayUnion(items), // Ürünleri listeye ekler
      });
    }

    // Add room service cost to the reservation (Legacy)
    Future<void> addRoomServiceCost(String docId, double amount) async {
      try {
        await _db.collection('hotel_reservations').doc(docId).update({
          'totalPrice': FieldValue.increment(amount),
        });
      } catch (e) {
        rethrow;
      }
    }
  
    // Delete a reservation
    Future<bool> deleteReservation(String docId) async {
      try {
        await _db.collection('hotel_reservations').doc(docId).delete();
        return true;
      } catch (e) {
        rethrow;
      }
    }
  
    // Register a new user
    Future<bool> registerUser({
      required String name,
      required String surname,
      required String identityType,
      required String identityNumber,
      required String country,
      required String phone,
      required String email,
      required String password,
    }) async {
      try {
        await _db.collection('users').add({
          'name': name,
          'surname': surname,
          'identityType': identityType,
          'identityNumber': identityNumber,
          'country': country,
          'phone': phone,
          'email': email,
          'password': password,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'guest',
        });
        return true;
      } catch (e) {
        rethrow;
      }
    }
    Future<void> addHousekeepingRequest(String docId, String requestItem) async {
      await FirebaseFirestore.instance.collection('hotel_reservations').doc(docId).update({
        'housekeepingRequests': FieldValue.arrayUnion([
          {'item': requestItem, 'time': DateTime.now().toString(), 'status': 'Pending'}
        ]),
      });
    }
    // Login for Guest
    Future<Map<String, dynamic>?> loginGuest(String email, String password) async {
      try {
        var querySnapshot = await _db
            .collection('users')
            .where('email', isEqualTo: email)
            .where('password', isEqualTo: password)
            .where('role', isEqualTo: 'guest')
            .limit(1)
            .get();
  
        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.first.data();
        }
        return null;
      } catch (e) {
        rethrow;
      }
    }
    // Admin panelinde verilerin canlı akması için (3 saniyede bir güncelleme mantığı)
    Stream<List<HotelReservation>> getReservationsStream() {
      return _db.collection('hotel_reservations').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => HotelReservation.fromFirestore(doc.data(), doc.id)).toList();
      });
    }
    // Tüm rezervasyonları (admin için) getiren metod
    Future<List<HotelReservation>> getAllReservationsForAdmin() async {
      try {
        var querySnapshot = await _db
            .collection('hotel_reservations')
            .orderBy('createdAt', descending: true) // En yeni rezervasyon üstte
            .get();

        return querySnapshot.docs
            .map((doc) => HotelReservation.fromFirestore(doc.data(), doc.id))
            .toList();
      } catch (e) {
        print("Firestore Admin Hatası: $e");
        rethrow;
      }
    }
    // Create a new reservation
    Future<String> createReservation({
      required String name,
      required String surname,
      required String identityNumber,
      required DateTime checkInDate,
      required int stayDays,
      required int personCount,
      required String roomNumber,
      required String roomType,
      required bool includeBreakfast,
      required bool includeDinner,
      required double totalPrice,
    }) async {
      try {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        String resCode = String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(Random().nextInt(chars.length))));
  
        await _db.collection('hotel_reservations').add({
          'reservationCode': resCode,
          'name': name.toUpperCase(),
          'surname': surname.toUpperCase(),
          'identityNumber': identityNumber,
          'checkInDate': Timestamp.fromDate(checkInDate),
          'stayDays': stayDays,
          'personCount': personCount,
          'roomNumber': roomNumber,
          'roomType': roomType,
          'includeBreakfast': includeBreakfast,
          'includeDinner': includeDinner,
          'totalPrice': totalPrice,
          'isCheckedIn': false,
          'isCheckedOut': false,
          'hotelName': 'Syntax Error Hotel',
          'createdAt': FieldValue.serverTimestamp(),
          'roomServiceOrders': [],
        });
  
        return resCode;
      } catch (e) {
        rethrow;
      }

    }

  }
