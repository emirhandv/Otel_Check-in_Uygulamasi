import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/reservation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  int _requestFilter = 0;
  bool _isClearing = false;

  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color deepBg = Color(0xFF020B10);
  static const Color glassColor = Colors.white10;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 850;

    return Scaffold(
      backgroundColor: deepBg,
      body: Stack(
        children: [
          _buildBackgroundPattern(),
          StreamBuilder<List<HotelReservation>>(
            stream: _firestoreService.getReservationsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: primaryCyan));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Sistem Hatası: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
              }

              final allRes = snapshot.data ?? [];
              final activeRes = allRes.where((r) => r.isCheckedIn && !r.isCheckedOut).toList();

              return Column(
                children: [
                  _buildCyberHeader(isMobile),
                  Expanded(
                    child: _buildResponsiveBody(activeRes, allRes, isMobile),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveBody(List<HotelReservation> activeRes, List<HotelReservation> allRes, bool isMobile) {
    if (isMobile) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(height: 500, child: _buildGlassContainer(child: _buildFloorContainer(activeRes, isMobile))),
          const SizedBox(height: 16),
          SizedBox(height: 450, child: _buildGlassContainer(child: _requestFilter == 3 ? _buildHistoryPanel() : _buildRequestsPanel(activeRes))),
          const SizedBox(height: 16),
          SizedBox(height: 350, child: _buildGlassContainer(child: _buildReceptionTrafficTable(allRes))),
          const SizedBox(height: 16),
          SizedBox(height: 350, child: _buildGlassContainer(child: _buildRegisteredUsersTable())),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 7, child: _buildGlassContainer(child: _buildFloorContainer(activeRes, isMobile))),
                const SizedBox(width: 20),
                Expanded(flex: 3, child: _buildGlassContainer(child: _requestFilter == 3 ? _buildHistoryPanel() : _buildRequestsPanel(activeRes))),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SizedBox(
            height: 250,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 1, child: _buildGlassContainer(child: _buildReceptionTrafficTable(allRes))),
                const SizedBox(width: 20),
                Expanded(flex: 1, child: _buildGlassContainer(child: _buildRegisteredUsersTable())),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundPattern() {
    return Opacity(
      opacity: 0.1,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
            repeat: ImageRepeat.repeat,
          ),
        ),
      ),
    );
  }

  Widget _buildCyberHeader(bool isMobile) {
    Widget titleWidget = Row(
      children: [
        const Icon(Icons.security, size: 35, color: primaryCyan),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SYNTAX ERROR HOTEL', style: TextStyle(fontSize: isMobile ? 18 : 24, fontWeight: FontWeight.w200, color: Colors.white, letterSpacing: 2)),
              Text('ADMIN TERMINAL // LOBBY STREAM: ${DateFormat('HH:mm:ss').format(DateTime.now())}', style: TextStyle(fontSize: isMobile ? 9 : 11, color: primaryCyan, fontFamily: 'monospace')),
            ],
          ),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 15 : 20, horizontal: isMobile ? 15 : 30),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: const Border(bottom: BorderSide(color: primaryCyan, width: 0.5)),
      ),
      child: isMobile
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titleWidget,
          const SizedBox(height: 15),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: _buildFilterBar()),
        ],
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: titleWidget),
          _buildFilterBar(),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryCyan.withOpacity(0.2), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildRequestsPanel(List<HotelReservation> reservations) {
    List<Map<String, dynamic>> requests = [];

    for (var res in reservations) {
      if (_requestFilter == 0 || _requestFilter == 1) {
        for (var order in res.roomServiceOrders) {
          final List dynamicItems = order['cart'] ?? order['items'] ?? [];
          String itemsDescription = dynamicItems.isNotEmpty
              ? dynamicItems.map((item) => "${item['name']} (x${item['quantity']})").join(', ')
              : order['text'] ?? order['name'] ?? "İçerik Belirsiz";

          requests.add({
            'resId': res.id,
            'room': res.roomNumber,
            'type': 'Servis',
            'dbField': 'roomServiceOrders',
            'text': itemsDescription,
            'icon': Icons.restaurant,
            'color': Colors.orangeAccent,
            'original': order,
            'timestamp': order['timestamp'] ?? res.checkInDate,
          });
        }
      }

      if (_requestFilter == 0 || _requestFilter == 2) {
        for (var request in res.housekeepingRequests) {
          requests.add({
            'resId': res.id,
            'room': res.roomNumber,
            'type': 'Temizlik',
            'dbField': 'housekeepingRequests',
            'text': request['item'] ?? "İhtiyaç Belirtilmedi",
            'icon': Icons.cleaning_services,
            'color': Colors.lightBlueAccent,
            'original': request,
            'timestamp': request['time'] != null ? DateTime.parse(request['time']) : res.checkInDate,
          });
        }
      }
    }

    requests.sort((a, b) => (b['timestamp'] as dynamic).compareTo(a['timestamp']));

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: Text('AKTİF TALEPLER', style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        Expanded(
          child: requests.isEmpty
              ? const Center(child: Text('Bekleyen talep yok.', style: TextStyle(color: Colors.white54, fontFamily: 'monospace')))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: requests.length,
            itemBuilder: (context, index) => _buildRequestCard(requests[index]),
          ),
        ),
        _buildActionFooter(reservations),
      ],
    );
  }

  Widget _buildHistoryPanel() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: Text('SİSTEM LOGLARI', style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('completed_requests').orderBy('timestamp', descending: true).limit(50).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Geçmiş kaydı bulunamadı.', style: TextStyle(color: Colors.white54, fontFamily: 'monospace')));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final log = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  bool isApp = log['status'] == 'approved';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      dense: true,
                      leading: Icon(isApp ? Icons.verified_user : Icons.gpp_bad, color: isApp ? Colors.greenAccent : Colors.redAccent, size: 18),
                      title: Text('ROOM ${log['room']} - ${log['type']}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      subtitle: Text(log['text'], style: const TextStyle(color: Colors.white60, fontSize: 10), maxLines: 1),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: req['color'], width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ROOM ${req['room']}', style: TextStyle(color: req['color'], fontWeight: FontWeight.bold, fontSize: 13)),
                Text(req['text'], style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 2),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.done_all, color: Colors.greenAccent, size: 20), onPressed: () => _handleAction(req, 'approved')),
          IconButton(icon: const Icon(Icons.close, color: Colors.redAccent, size: 20), onPressed: () => _handleAction(req, 'deleted')),
        ],
      ),
    );
  }

  Widget _buildFloorContainer(List<HotelReservation> activeRes, bool isMobile) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Text('CANLI ODA DURUM HARİTASI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300, letterSpacing: 2)),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Column(
              children: [
                for (int i = 1; i <= 3; i++) _buildFloorSection(i, activeRes, isMobile),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloorSection(int floor, List<HotelReservation> activeRes, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('0$floor // FLOOR', style: const TextStyle(color: primaryCyan, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 13)),
              const SizedBox(width: 15),
              Expanded(child: Container(height: 1, color: primaryCyan.withOpacity(0.3))),
            ],
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 5 : 10,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              int roomSuffix = index + 1;
              String roomNum = "$floor${roomSuffix.toString().padLeft(2, '0')}";
              var res = activeRes.where((r) => r.roomNumber == roomNum).firstOrNull;
              return _buildCyberRoomBox(roomNum, res);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCyberRoomBox(String roomNum, HotelReservation? res) {
    bool isFull = res != null;
    return Container(
      decoration: BoxDecoration(
        color: isFull ? Colors.redAccent.withOpacity(0.15) : Colors.greenAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isFull ? Colors.redAccent.withOpacity(0.8) : Colors.greenAccent.withOpacity(0.3),
            width: 1
        ),
        boxShadow: isFull ? [BoxShadow(color: Colors.redAccent.withOpacity(0.2), blurRadius: 4)] : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(roomNum, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          if (isFull)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                res.name.toUpperCase(),
                style: const TextStyle(color: Colors.white70, fontSize: 8, letterSpacing: 0.5),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    List<String> labels = ['TÜMÜ', 'SERVİS', 'TEMİZLİK', 'LOG'];
    return ToggleButtons(
      isSelected: List.generate(4, (index) => _requestFilter == index),
      onPressed: (index) => setState(() => _requestFilter = index),
      borderRadius: BorderRadius.circular(10),
      selectedColor: Colors.black,
      fillColor: primaryCyan,
      color: primaryCyan,
      constraints: const BoxConstraints(minHeight: 35, minWidth: 80),
      children: labels.map((l) => Text(l, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))).toList(),
    );
  }

  Widget _buildReceptionTrafficTable(List<HotelReservation> traffic) {
    final todayTraffic = traffic.where((r) => r.isCheckedIn || r.isCheckedOut).toList();
    todayTraffic.sort((a, b) => b.checkInDate.compareTo(a.checkInDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: Text('RESEPSİYON TRAFİĞİ', style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Theme(
                    data: Theme.of(context).copyWith(cardColor: Colors.transparent, dividerColor: Colors.white10),
                    child: DataTable(
                      columnSpacing: 30,
                      headingTextStyle: const TextStyle(color: primaryCyan, fontWeight: FontWeight.bold),
                      dataTextStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                      columns: const [
                        DataColumn(label: Text('SAAT')),
                        DataColumn(label: Text('ODA')),
                        DataColumn(label: Text('MİSAFİR')),
                        DataColumn(label: Text('DURUM')),
                        DataColumn(label: Text('PDF')),
                      ],
                      rows: todayTraffic.map((res) {
                        return DataRow(cells: [
                          DataCell(Text(DateFormat('HH:mm').format(res.checkInDate))),
                          DataCell(Text(res.roomNumber, style: const TextStyle(color: primaryCyan, fontWeight: FontWeight.bold))),
                          DataCell(Text('${res.name} ${res.surname}')),
                          DataCell(Text(res.isCheckedOut ? 'OUT' : 'IN', style: TextStyle(color: res.isCheckedOut ? Colors.orange : Colors.greenAccent, fontWeight: FontWeight.bold))),
                          DataCell(IconButton(icon: const Icon(Icons.picture_as_pdf, color: primaryCyan, size: 18), onPressed: () => _generateGuestReport(res))),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionFooter(List<HotelReservation> reservations) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: OutlinedButton(
        onPressed: _isClearing ? null : () => _clearAll(reservations),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent),
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isClearing
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent))
            : const Text('SİSTEMİ SIFIRLA', style: TextStyle(color: Colors.redAccent, letterSpacing: 2, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _handleAction(Map<String, dynamic> req, String status) async {
    await FirebaseFirestore.instance.collection('completed_requests').add({
      'room': req['room'],
      'type': req['type'],
      'text': req['text'],
      'status': status,
      'timestamp': FieldValue.serverTimestamp()
    });
    await FirebaseFirestore.instance.collection('hotel_reservations').doc(req['resId']).update({req['dbField']: FieldValue.arrayRemove([req['original']])});
  }

  Future<void> _clearAll(List<HotelReservation> reservations) async {
    setState(() => _isClearing = true);
    for (var res in reservations) {
      Map<String, dynamic> up = {};
      if (_requestFilter == 0 || _requestFilter == 1) up['roomServiceOrders'] = [];
      if (_requestFilter == 0 || _requestFilter == 2) up['housekeepingRequests'] = [];
      if (up.isNotEmpty) await FirebaseFirestore.instance.collection('hotel_reservations').doc(res.id).update(up);
    }
    setState(() => _isClearing = false);
  }

  Future<void> _generateGuestReport(HotelReservation res) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    final PdfColor darkColor = PdfColor.fromHex('#0A192F');
    final PdfColor goldColor = PdfColor.fromHex('#CFA052');
    final PdfColor lightGrey = PdfColor.fromHex('#F5F6F8');

    String invoiceNo = 'FOLIO-${res.id.length > 5 ? res.id.substring(0, 5).toUpperCase() : 'SYS'}';

    double nightlyRate = 120.0;
    if (res.roomType.contains('Suit')) nightlyRate = 250.0;
    else if (res.roomType.contains('Köşe')) nightlyRate = 170.0;
    double roomTotal = nightlyRate * res.stayDays;

    List<List<String>> dynamicTableRows = [];

    dynamicTableRows.add([
      '${res.roomType} Konaklama',
      'Oda ${res.roomNumber}',
      '${res.stayDays}',
      'Gün',
      '${roomTotal.toStringAsFixed(2)} €'
    ]);

    for (var item in res.roomServiceOrders) {
      String itemName = (item['name'] ?? 'Ürün').toString();
      double itemPrice = (item['price'] ?? 0.0).toDouble();
      int itemQty = (item['quantity'] ?? 1).toInt();

      dynamicTableRows.add([
        itemName,
        'Servis',
        '$itemQty',
        'Adet',
        '${(itemPrice * itemQty).toStringAsFixed(2)} €'
      ]);
    }

    String checkInStr = DateFormat('dd/MM/yyyy HH:mm').format(res.checkInDate);
    String statusStr = res.isCheckedOut ? 'Check-out Yapıldı (KAPALI)' : 'Konaklıyor (AKTİF)';

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.RichText(
                    text: pw.TextSpan(
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                      children: [
                        pw.TextSpan(text: 'Syntax Error ', style: pw.TextStyle(color: darkColor)),
                        pw.TextSpan(text: 'Hotel', style: pw.TextStyle(color: goldColor)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('YÖNETİM TERMİNALİ SİSTEM ÇIKTISI', style: pw.TextStyle(fontSize: 10, color: darkColor, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Çıktı Tarihi: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('YÖNETİCİ KOPYASI', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: darkColor)),
                  pw.SizedBox(height: 8),
                  pw.Text('Kayıt No: $invoiceNo', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Durum: $statusStr', style: pw.TextStyle(fontSize: 10, color: res.isCheckedOut ? PdfColors.red800 : PdfColors.green800, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 35),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(color: lightGrey, borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('MÜŞTERİ BİLGİLERİ', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: darkColor)),
                    pw.SizedBox(height: 6),
                    pw.Text('Ad Soyad: ${res.name.toUpperCase()} ${res.surname.toUpperCase()}', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('T.C./Pasaport: ${res.identityNumber}', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Sistem ID: ${res.id}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('KONAKLAMA DETAYLARI', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: darkColor)),
                    pw.SizedBox(height: 6),
                    pw.Text('Oda: ${res.roomNumber} (${res.roomType})', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Giriş Zamanı: $checkInStr', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Konaklama: ${res.stayDays} Gece', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          pw.TableHelper.fromTextArray(
            border: const pw.TableBorder(
              bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
            ),
            headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
            headerDecoration: pw.BoxDecoration(
                color: darkColor,
                borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(6))
            ),
            cellStyle: pw.TextStyle(fontSize: 10, color: darkColor),
            cellPadding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.centerRight,
            },
            headers: ['AÇIKLAMA (HİZMET/ÜRÜN)', 'BİRİM DETAYI', 'MİKTAR', 'BİRİM', 'TUTAR'],
            data: dynamicTableRows,
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.SizedBox(
                width: 220,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Ara Toplam:', style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('${res.totalPrice.toStringAsFixed(2)} €', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('KDV (%10):', style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('0.00 € (Dahil)', style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: pw.BoxDecoration(color: darkColor, borderRadius: pw.BorderRadius.circular(6)),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('HESAP TOPLAMI', style: pw.TextStyle(color: goldColor, fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          pw.Text('${res.totalPrice.toStringAsFixed(2)} €', style: pw.TextStyle(color: goldColor, fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.Spacer(),
          pw.Divider(color: goldColor, thickness: 1),
          pw.SizedBox(height: 6),
          pw.Center(
            child: pw.Text(
                'Bu belge Syntax Error Hotel Yönetim Paneli tarafından otomatik oluşturulmuştur. Müşteriye verilemez, sadece dahili kayıt ve raporlama içindir.',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Widget _buildRegisteredUsersTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: Text('KAYITLI MİSAFİRLER', style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'guest').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: primaryCyan));
              }

              final users = snapshot.data!.docs;

              if (users.isEmpty) {
                return const Center(child: Text('Kayıtlı misafir bulunamadı.', style: TextStyle(color: Colors.white54, fontFamily: 'monospace')));
              }

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Theme(
                        data: Theme.of(context).copyWith(cardColor: Colors.transparent, dividerColor: Colors.white10),
                        child: DataTable(
                          columnSpacing: 40,
                          headingTextStyle: const TextStyle(color: primaryCyan, fontWeight: FontWeight.bold),
                          dataTextStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                          columns: const [
                            DataColumn(label: Text('İSİM SOYİSİM')),
                            DataColumn(label: Text('TELEFON')),
                            DataColumn(label: Text('E-POSTA')),
                          ],
                          rows: users.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final ad = data['name']?.toString().toUpperCase() ?? '';
                            final soyad = data['surname']?.toString().toUpperCase() ?? '';

                            return DataRow(cells: [
                              DataCell(Text('$ad $soyad', overflow: TextOverflow.ellipsis)),
                              DataCell(Text(data['phone'] ?? '-', style: const TextStyle(fontFamily: 'monospace'))),
                              DataCell(Text(data['email'] ?? '-', overflow: TextOverflow.ellipsis)),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}