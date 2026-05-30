import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Temizleme işlemi için eklendi
import '../services/firestore_service.dart';
import '../models/reservation.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirestoreService _firestoreService = FirestoreService();

  // 0: Tümü, 1: Sadece Yemek, 2: Sadece Temizlik
  int _requestFilter = 0;
  bool _isClearing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.apartment, size: 36, color: Color(0xFF5C7285)),
                const SizedBox(width: 10),
                const Text(
                  'Syntax Error Hotel - Canlı Lobi Ekranı',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2C3E50)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Odalar ve Gelen Talepler anlık olarak senkronize edilmektedir.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            Expanded(
              child: StreamBuilder<List<HotelReservation>>(
                stream: _firestoreService.getReservationsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final activeReservations = (snapshot.data ?? []).where((r) => r.isCheckedIn && !r.isCheckedOut).toList();

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- SOL PANEL: KAT KROKİSİ ---
                      Expanded(
                        flex: 7,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Text('Oda Yerleşimi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF34495E))),
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildFloorLayout(1, activeReservations),
                                      const SizedBox(height: 30),
                                      _buildFloorLayout(2, activeReservations),
                                      const SizedBox(height: 30),
                                      _buildFloorLayout(3, activeReservations),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 24),

                      // --- SAĞ PANEL: CANLI TALEPLER (FİLTRELİ) ---
                      Expanded(
                        flex: 3,
                        child: _buildRequestsPanel(activeReservations),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorLayout(int floor, List<HotelReservation> activeRes) {
    List<String> odds = [];
    List<String> evens = [];
    for (int i = 1; i <= 10; i++) {
      String roomNum = '$floor${i.toString().padLeft(2, '0')}';
      if (i % 2 != 0) odds.add(roomNum);
      else evens.add(roomNum);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$floor. Kat', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF424242))),
        const SizedBox(height: 10),
        const Text('Deniz Tarafı', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Row(children: odds.map((room) => _buildRoomBox(room, activeRes.cast<HotelReservation?>().firstWhere((r) => r?.roomNumber == room, orElse: () => null))).toList()),
        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(thickness: 2, color: Color(0xFFEEEEEE))),
        Row(children: evens.map((room) => _buildRoomBox(room, activeRes.cast<HotelReservation?>().firstWhere((r) => r?.roomNumber == room, orElse: () => null))).toList()),
        const SizedBox(height: 8),
        const Text('Şehir Tarafı', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRoomBox(String roomNum, HotelReservation? res) {
    bool isFull = res != null;
    Color bgColor = isFull ? const Color(0xFFEF5350) : const Color(0xFF66BB6A);
    Color innerColor = isFull ? const Color(0xFFC62828) : const Color(0xFF388E3C);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 85,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: bgColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(roomNum, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(color: innerColor, borderRadius: BorderRadius.circular(6)),
              child: Text(
                isFull ? 'DOLU\n${res.name.toLowerCase()} ${res.surname.toLowerCase()}' : 'ŞU AN BOŞ',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                maxLines: 2, overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SAĞ KOYU PANEL (YEMEK / TEMİZLİK FİLTRELİ) ---
  Widget _buildRequestsPanel(List<HotelReservation> reservations) {
    List<Map<String, dynamic>> requests = [];

    for (var res in reservations) {
      // YEMEK TALEPLERİ (Filtre 0 veya 1 ise göster)
      if (res.roomServiceOrders.isNotEmpty && (_requestFilter == 0 || _requestFilter == 1)) {
        String details = res.roomServiceOrders.map((e) => "${e['name']} (x${e['quantity']})").join(', ');
        requests.add({
          'room': res.roomNumber,
          'type': 'Oda Servisi',
          'text': details,
          'time': DateFormat('HH:mm').format(DateTime.now()),
          'icon': Icons.room_service,
          'color': Colors.orangeAccent,
        });
      }

      // TEMİZLİK TALEPLERİ (Filtre 0 veya 2 ise göster)
      if (res.housekeepingRequests.isNotEmpty && (_requestFilter == 0 || _requestFilter == 2)) {
        var pendingHK = res.housekeepingRequests.where((hk) => hk['status'] == 'Pending').toList();
        if (pendingHK.isNotEmpty) {
          String hkDetails = pendingHK.map((e) => e['item']).join(', ');
          requests.add({
            'room': res.roomNumber,
            'type': 'Housekeeping',
            'text': hkDetails,
            'time': pendingHK.last['time'] != null
                ? DateFormat('HH:mm').format(DateTime.parse(pendingHK.last['time']))
                : DateFormat('HH:mm').format(DateTime.now()),
            'icon': Icons.cleaning_services,
            'color': Colors.lightBlueAccent,
          });
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF263238),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.white),
                    SizedBox(width: 10),
                    Text('CANLI TALEPLER', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),
                // YENİ FİLTRE BUTONLARI (Tümü, Yemek, Temizlik)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFilterChip('Tümü', 0, Colors.white),
                    _buildFilterChip('Yemek', 1, Colors.orangeAccent),
                    _buildFilterChip('Temizlik', 2, Colors.lightBlueAccent),
                  ],
                ),
                const SizedBox(height: 10),
                Container(height: 2, color: Colors.grey.withOpacity(0.3)),
              ],
            ),
          ),

          Expanded(
            child: requests.isEmpty
                ? const Center(child: Text('Şu an bekleyen talep yok.', style: TextStyle(color: Colors.white54)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                var req = requests[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF37474F),
                    borderRadius: BorderRadius.circular(8),
                    border: Border(left: BorderSide(color: req['color'], width: 4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(req['icon'], color: req['color'], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('ODA ${req['room']} - ${req['type']}', style: TextStyle(color: req['color'], fontSize: 13, fontWeight: FontWeight.bold)),
                                Text(req['time'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(req['text'], style: const TextStyle(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              // TEMİZLE BUTONU ARTIK VERİTABANINDAN SİLİYOR
              onPressed: _isClearing ? null : () async {
                setState(() => _isClearing = true);
                for (var res in reservations) {
                  Map<String, dynamic> updates = {};
                  // Eğer sekme "Tümü" veya "Yemek" ise ve yemek siparişi varsa temizle
                  if ((_requestFilter == 0 || _requestFilter == 1) && res.roomServiceOrders.isNotEmpty) {
                    updates['roomServiceOrders'] = [];
                  }
                  // Eğer sekme "Tümü" veya "Temizlik" ise ve temizlik siparişi varsa temizle
                  if ((_requestFilter == 0 || _requestFilter == 2) && res.housekeepingRequests.isNotEmpty) {
                    updates['housekeepingRequests'] = [];
                  }

                  if (updates.isNotEmpty) {
                    await FirebaseFirestore.instance.collection('hotel_reservations').doc(res.id).update(updates);
                  }
                }
                setState(() => _isClearing = false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF5350),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isClearing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_requestFilter == 0 ? 'Tüm Talepleri Temizle' : 'Seçili Talepleri Temizle', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // Filtre butonları tasarımı
  Widget _buildFilterChip(String label, int filterIndex, Color color) {
    bool isSelected = _requestFilter == filterIndex;
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) setState(() => _requestFilter = filterIndex);
      },
      selectedColor: color,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? color : Colors.grey)
      ),
    );
  }
}