import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'services/firestore_service.dart';
import 'models/reservation.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'admin/admin_dashboard.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HotelCheckInApp());
}

class HotelCheckInApp extends StatelessWidget {
  const HotelCheckInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otel Online Check-in',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hotel_class, size: 80, color: Color(0xFF009688)),
                const SizedBox(height: 30),
                const Text(
                  'Hoş Geldiniz',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Lütfen devam etmek için giriş türünü seçin',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                _SelectionButton(
                  title: 'Misafir Girişi',
                  subtitle: 'İşlemlerinizi yönetmek için',
                  icon: Icons.person_outline,
                  imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=200&auto=format&fit=crop',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckInSearchScreen())),
                ),
                const SizedBox(height: 20),
                _SelectionButton(
                  title: 'Yönetici Girişi',
                  subtitle: 'Panel yönetimi için',
                  icon: Icons.admin_panel_settings_outlined,
                  imageUrl: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?q=80&w=200&auto=format&fit=crop',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminLoginScreen())),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String imageUrl;
  final VoidCallback onTap;

  const _SelectionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.imageUrl,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black26,
                ),
                child: Icon(icon, color: Colors.white),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class DateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length < oldValue.text.length) return newValue;
    var text = newValue.text;
    if (text.length == 2 || text.length == 5) {
      return newValue.copyWith(
        text: '$text/',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }
    return newValue;
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'\s+\b|\b\s'), '');
    if (newValue.text.length < oldValue.text.length) return newValue;

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final TextCapitalization textCapitalization;
  final TextInputType keyboardType;
  final int? maxLength;
  final String? labelText;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final bool readOnly;

  const _CustomTextField({
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.labelText,
    this.onChanged,
    this.inputFormatters,
    this.suffixIcon,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) Padding(padding: const EdgeInsets.only(bottom: 4, left: 2), child: Text(labelText!, style: const TextStyle(color: Color(0xFF5C5B7F), fontWeight: FontWeight.bold, fontSize: 13))),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEBE8F2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD1CFDB)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            textCapitalization: textCapitalization,
            keyboardType: keyboardType,
            maxLength: maxLength,
            onChanged: onChanged,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hintText,
              counterText: "",
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}

// KAYIT OLMA EKRANI
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _identityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedIdentityType = 'TC';
  String _selectedCountryName = 'Türkiye';
  final List<Map<String, String>> _countries = [
    {'name': 'Türkiye', 'flag': '🇹🇷'},
    {'name': 'Almanya', 'flag': '🇩🇪'},
    {'name': 'ABD', 'flag': '🇺🇸'},
    {'name': 'Fransa', 'flag': '🇫🇷'},
    {'name': 'İngiltere', 'flag': '🇬🇧'},
    {'name': 'İtalya', 'flag': '🇮🇹'},
    {'name': 'İspanya', 'flag': '🇪🇸'},
    {'name': 'Rusya', 'flag': '🇷🇺'},
    {'name': 'Çin', 'flag': '🇨🇳'},
    {'name': 'Japonya', 'flag': '🇯🇵'},
  ];

  void _register() async {
    if (_selectedIdentityType == 'TC' && _identityController.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('TC Kimlik No 11 hane olmalıdır.')));
      return;
    }
    try {
      await FirestoreService().registerUser(
        name: _nameController.text,
        surname: _surnameController.text,
        identityType: _selectedIdentityType,
        identityNumber: _identityController.text,
        country: _selectedCountryName,
        phone: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Başarıyla kayıt olundu!'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata oluştu: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(children: [
              const Text('Yeni Hesap Oluştur', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _identityDropdown(),
              const SizedBox(height: 10),
              _CustomTextField(hintText: 'Ad', controller: _nameController),
              const SizedBox(height: 10),
              _CustomTextField(hintText: 'Soyad', controller: _surnameController),
              const SizedBox(height: 10),
              _CustomTextField(
                hintText: _selectedIdentityType == 'TC' ? 'TC Kimlik No' : 'Pasaport No',
                controller: _identityController,
                maxLength: _selectedIdentityType == 'TC' ? 11 : 20,
                keyboardType: _selectedIdentityType == 'TC' ? TextInputType.number : TextInputType.text,
              ),
              const SizedBox(height: 10),
              _countryDropdown(),
              const SizedBox(height: 10),
              _CustomTextField(hintText: 'Telefon', controller: _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              _CustomTextField(hintText: 'E-posta', controller: _emailController),
              const SizedBox(height: 10),
              _CustomTextField(hintText: 'Şifre', isPassword: true, controller: _passwordController),
              const SizedBox(height: 30),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _register, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009688)), child: const Text('KAYIT OL', style: TextStyle(color: Colors.white)))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _identityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: const Color(0xFFEBE8F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD1CFDB))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedIdentityType,
          isExpanded: true,
          items: ['TC', 'Pasaport'].map((e) => DropdownMenuItem(value: e, child: Text(e == 'TC' ? 'T.C. Vatandaşı' : 'Yabancı Misafir'))).toList(),
          onChanged: (v) => setState(() { _selectedIdentityType = v!; if (v == 'TC') _selectedCountryName = 'Türkiye'; }),
        ),
      ),
    );
  }

  Widget _countryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: _selectedIdentityType == 'TC' ? const Color(0xFFF2F1F7) : const Color(0xFFEBE8F2), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD1CFDB))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountryName,
          isExpanded: true,
          onChanged: _selectedIdentityType == 'TC' ? null : (v) => setState(() => _selectedCountryName = v!),
          items: _countries.map((c) => DropdownMenuItem(value: c['name'], child: Row(children: [Text(c['flag']!), const SizedBox(width: 10), Text(c['name']!)]))).toList(),
        ),
      ),
    );
  }
}

// MİSAFİR DASHBOARD
class GuestDashboardScreen extends StatelessWidget {
  final Map<String, dynamic> guestData;
  const GuestDashboardScreen({super.key, required this.guestData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(title: Text('Hoş Geldin, ${guestData['name']}'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                _DashCard(
                    title: 'Rezervasyon\nOluştur',
                    icon: Icons.add_business,
                    color: Colors.blue,
                    imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=500&auto=format&fit=crop',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateReservationScreen(guestData: guestData)))
                ),
                _DashCard(
                    title: 'Check-in',
                    icon: Icons.vpn_key,
                    color: Colors.teal,
                    imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?q=80&w=500&auto=format&fit=crop',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReservationSearchStepScreen(identityNumber: guestData['identityNumber'])))
                ),
                _DashCard(
                    title: 'In House Room',
                    icon: Icons.home_work,
                    color: Colors.indigo,
                    imageUrl: 'https://images.unsplash.com/photo-1590490360182-c33d57733427?q=80&w=500&auto=format&fit=crop',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InHouseRoomScreen(identityNumber: guestData['identityNumber'])))
                ),
                _DashCard(
                    title: 'Fatura',
                    icon: Icons.receipt_long,
                    color: Colors.green,
                    imageUrl: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?q=80&w=200&auto=format&fit=crop',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InvoiceScreen(identityNumber: guestData['identityNumber'])))
                ),
                _DashCard(
                    title: 'Destek',
                    icon: Icons.help,
                    color: Colors.redAccent,
                    imageUrl: 'https://images.unsplash.com/photo-1534536281715-e28d76689b4d?q=80&w=500&auto=format&fit=crop',
                    onTap: () => _showComingSoon(context, 'Destek')
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature yakında aktif edilecektir.')));
  }
}

// FATURA EKRANI (GEÇMİŞ KONAKLAMALAR)
class InvoiceScreen extends StatefulWidget {
  final String identityNumber;
  const InvoiceScreen({super.key, required this.identityNumber});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final _firestoreService = FirestoreService();

  void _deleteInvoice(String id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydı Sil'),
        content: const Text('Bu konaklama kaydını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('VAZGEÇ')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('SİL', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _firestoreService.deleteReservation(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kayıt başarıyla silindi.'), backgroundColor: Colors.red));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(title: const Text('Faturalarım / Geçmiş'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: FutureBuilder<List<HotelReservation>>(
            future: _firestoreService.getUserReservations(widget.identityNumber),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final pastRes = (snapshot.data ?? []).where((r) => r.isCheckedOut).toList();

              if (pastRes.isEmpty) {
                return const Center(child: Text('Geçmiş konaklamanız bulunmamaktadır.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pastRes.length,
                itemBuilder: (context, index) {
                  final res = pastRes[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.receipt, color: Colors.green),
                      title: Text('Oda ${res.roomNumber} - ${res.roomType}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tarih: ${DateFormat('dd/MM/yyyy').format(res.checkInDate)}'),
                          Text('Konaklama: ${res.stayDays} Gün, ${res.personCount} Kişi'),
                          Text('Toplam: ${res.totalPrice.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('ÖDENDİ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deleteInvoice(res.id),
                          ),
                        ],
                      ),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InvoiceFormScreen(reservation: res))),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

// FATURA OLUŞTURMA VE PDF EKRANI
class InvoiceFormScreen extends StatefulWidget {
  final HotelReservation reservation;
  const InvoiceFormScreen({super.key, required this.reservation});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _addressController = TextEditingController();
  final _taxOfficeController = TextEditingController();
  final _taxNumberController = TextEditingController();
  bool _isGenerating = false;

  double _calculateRoomServiceTotal() {
    double total = 0;
    for (var order in widget.reservation.roomServiceOrders) {
      total += (order['price'] ?? 0) * (order['quantity'] ?? 1);
    }
    return total;
  }

  Future<void> _generateAndPrintPdf() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen fatura adresi giriniz.')));
      return;
    }

    setState(() => _isGenerating = true);

    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final italicFont = await PdfGoogleFonts.robotoItalic();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: font,
        bold: boldFont,
        italic: italicFont,
      ),
    );

    final List<List<String>> invoiceData = [
      <String>['Açıklama', 'Oda/Detay', 'Miktar', 'Birim', 'Tutar'],
    ];

    invoiceData.add(<String>[
      '${widget.reservation.roomType} Konaklama',
      widget.reservation.roomNumber,
      '${widget.reservation.stayDays}',
      'Gün',
      '${(widget.reservation.totalPrice - _calculateRoomServiceTotal()).toStringAsFixed(2)} €'
    ]);

    for (var order in widget.reservation.roomServiceOrders) {
      invoiceData.add(<String>[
        order['name'] ?? 'Oda Servisi',
        'Servis',
        '${order['quantity'] ?? 1}',
        'Adet',
        '${((order['price'] ?? 0) * (order['quantity'] ?? 1)).toStringAsFixed(2)} €'
      ]);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Syntax Error Hotel', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                        pw.Text('Merkez, İstanbul, Türkiye'),
                        pw.Text('Tel: +90 242 123 45 67'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('FATURA', style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                        pw.Text('Tarih: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'),
                        pw.Text('Fatura No: INV-${widget.reservation.reservationCode}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Text('SAYIN (MÜŞTERİ BİLGİLERİ)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.Text('${widget.reservation.name} ${widget.reservation.surname}'),
                pw.Text('T.C./Pasaport: ${widget.reservation.identityNumber}'),
                pw.Text('Adres: ${_addressController.text}'),
                pw.SizedBox(height: 40),

                pw.TableHelper.fromTextArray(
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo900),
                  context: context,
                  data: invoiceData,
                ),

                pw.SizedBox(height: 30),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Ara Toplam: ${widget.reservation.totalPrice.toStringAsFixed(2)} €'),
                        pw.Text('KDV (%10): 0.00 € (Dahil)'),
                        pw.Divider(),
                        pw.Text('GENEL TOPLAM: ${widget.reservation.totalPrice.toStringAsFixed(2)} €', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Center(child: pw.Text('Bizi tercih ettiğiniz için teşekkür ederiz.', style: pw.TextStyle(fontStyle: pw.FontStyle.italic))),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    setState(() => _isGenerating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(title: const Text('Fatura Bilgilerini Girin')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fatura Detayları', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _CustomTextField(hintText: 'Fatura Adresi (Zorunlu)', controller: _addressController, labelText: 'Açık Adres'),
                const SizedBox(height: 15),
                _CustomTextField(hintText: 'Vergi Dairesi (Opsiyonel)', controller: _taxOfficeController, labelText: 'Vergi Dairesi'),
                const SizedBox(height: 15),
                _CustomTextField(hintText: 'Vergi No (Opsiyonel)', controller: _taxNumberController, labelText: 'Vergi Numarası'),
                const SizedBox(height: 40),
                _isGenerating
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _generateAndPrintPdf,
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text('PROFESYONEL FATURA OLUŞTUR VE İNDİR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ODA SERVİSİ KATEGORİ DETAY EKRANI
class RoomServiceCategoryScreen extends StatelessWidget {
  final String category;
  final String roomNumber;
  final String reservationId;
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>) onAddToCart;

  const RoomServiceCategoryScreen({
    super.key,
    required this.category,
    required this.roomNumber,
    required this.reservationId,
    required this.items,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(title: Text(category), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(item['imageUrl'] ?? 'https://via.placeholder.com/150'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(
                      item['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                  subtitle: Text(
                      '${item['price']} €',
                      style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600)
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      onAddToCart(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item['name']} sepete eklendi!'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          )
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ),
                    child: const Text('EKLE'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ODA SERVİSİ SİPARİŞLERİM EKRANI
class RoomServiceOrdersScreen extends StatefulWidget {
  final String roomNumber;
  final String reservationId;
  final List<Map<String, dynamic>> cart;
  final Function(String, int) onUpdateQuantity;
  final VoidCallback onClearCart;

  const RoomServiceOrdersScreen({
    super.key,
    required this.roomNumber,
    required this.reservationId,
    required this.cart,
    required this.onUpdateQuantity,
    required this.onClearCart,
  });

  @override
  State<RoomServiceOrdersScreen> createState() => _RoomServiceOrdersScreenState();
}

class _RoomServiceOrdersScreenState extends State<RoomServiceOrdersScreen> {
  bool _isProcessing = false;

  double get _totalPrice => widget.cart.fold(0, (sum, item) => sum + ((item['price'] as num).toDouble() * (item['quantity'] as int)));

  void _completeOrder() async {
    if (widget.cart.isEmpty) return;

    setState(() => _isProcessing = true);
    try {
      await FirestoreService().addRoomServiceOrder(
          widget.reservationId,
          _totalPrice,
          widget.cart
      );

      widget.onClearCart();
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Icon(Icons.check_circle, color: Colors.green, size: 50),
          content: const Text('Siparişiniz başarıyla alındı! Ücret faturanıza eklenmiştir.', textAlign: TextAlign.center),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('TAMAM'))],
        ),
      ).then((_) => Navigator.pop(context));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(title: const Text('Siparişleriniz'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: widget.cart.isEmpty
              ? const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('Henüz bir siparişiniz bulunmamaktadır.', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          )
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.cart.length,
                  itemBuilder: (context, index) {
                    final item = widget.cart[index];
                    final double subtotal = (item['price'] as num).toDouble() * (item['quantity'] as int);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('${item['price']} € / Adet', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  Text('Alt Toplam: ${subtotal.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Row(
                              children: [

                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      widget.onUpdateQuantity(item['name'], -1);
                                    });
                                  },
                                ),

                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                  onPressed: () {
                                    setState(() {
                                      widget.onUpdateQuantity(item['name'], 1);
                                    });
                                  },
                                ),

                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      widget.onUpdateQuantity(item['name'], -999);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Toplam Tutar:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${_totalPrice.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _isProcessing
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _completeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('SİPARİŞİ TAMAMLA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ODA SERVİSİ ANA EKRANI
class RoomServiceScreen extends StatefulWidget {
  final String roomNumber;
  final String reservationId;
  const RoomServiceScreen({super.key, required this.roomNumber, required this.reservationId});

  @override
  State<RoomServiceScreen> createState() => _RoomServiceScreenState();
}

class _RoomServiceScreenState extends State<RoomServiceScreen> {
  final List<Map<String, dynamic>> _cart = [];

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      final index = _cart.indexWhere((element) => element['name'] == item['name']);
      if (index != -1) {
        _cart[index]['quantity'] = (_cart[index]['quantity'] as int) + 1;
      } else {
        _cart.add({
          'name': item['name'],
          'price': item['price'],
          'quantity': 1,
        });
      }
    });
  }

  void _updateQuantity(String name, int delta) {
    setState(() {
      final index = _cart.indexWhere((element) => element['name'] == name);
      if (index != -1) {
        if (delta == -999) {
          _cart.removeAt(index);
        } else {
          int newQty = (_cart[index]['quantity'] as int) + delta;
          if (newQty <= 0) {
            _cart.removeAt(index);
          } else {
            _cart[index]['quantity'] = newQty;
          }
        }
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> menuData = {
      'Kahvaltı': [
        {
          'name': 'Kontinental Kahvaltı',
          'price': 15.0,
          'imageUrl': 'https://st3.depositphotos.com/1027198/19437/i/450/depositphotos_194373632-stock-photo-continental-breakfast-coffee-tea-croissants.jpg'
        },
        {
          'name': 'Türk Kahvaltısı',
          'price': 20.0,
          'imageUrl': 'https://cdn.shopify.com/s/files/1/1259/6441/files/kahvalti-tabagi.jpg?v=1645104466'
        },
        {
          'name': 'Omlet',
          'price': 8.0,
          'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkL9Uxb-fECRSyb4I8XJXzIsK1yrsfCDJtXQ&s'
        },
        {
          'name': 'Menemen',
          'price': 10.0,
          'imageUrl': 'https://i.tmgrup.com.tr/sfr/2026/04/16/menemen-1776333016435.jpg'
        },
        {
          'name': 'Yulaf Ezmesi',
          'price': 7.0,
          'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRqBMEmEDUtehPAz_bsDuCsPHZnaUajVqBSYQ&s'
        },
        {
          'name': 'Taze Meyve Tabağı',
          'price': 9.0,
          'imageUrl': 'https://www.shutterstock.com/image-photo/beautifully-arranged-fruit-platter-featuring-260nw-2673724315.jpg'
        },
      ],
      'Atıştırmalıklar ve Başlangıçlar': [
        {
          'name': 'Mercimek Çorbası',
          'price': 6.0,
          'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRLvwsMnTe3X8DBGIIWw7M-rAlf19osq1CJOQ&sp'
        },
        {
          'name': 'Club Sandwich',
          'price': 12.0,
          'imageUrl': 'https://ichef.bbci.co.uk/food/ic/food_16x9_1600/recipes/club_sandwich_16496_16x9.jpg'
        },
        {
          'name': 'Pankek Tabağı',
          'price': 12.0,
          'imageUrl': 'https://images.unsplash.com/photo-1528207776546-365bb710ee93?q=80&w=400'
        },
        {
          'name': 'Avokadolu Tost',
          'price': 14.0,
          'imageUrl': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?q=80&w=400'
        },
        {
          'name': 'Cheeseburger',
          'price': 14.0,
          'imageUrl': 'https://images.themodernproper.com/production/posts/2016/ClassicCheeseBurger_8.jpg?w=960&h=960&q=82&fm=jpg&fit=crop&dm=1749310221&s=4c1a1c61f1babda90104ca8d7afed249'
        },
        {
          'name': 'Patates Kızartması',
          'price': 5.0,
          'imageUrl': 'https://i.nefisyemektarifleri.com/2020/01/25/karbonatsiz-citir-citir-patates-kizartmasi-600x400.jpg'
        },
        {
          'name': 'Peynir Tabağı',
          'price': 15.0,
          'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTkVj-YBd7AetAFvGv8DWS0UbeFVXm7OGAs3g&s'
        },
      ],
      'Ana Yemekler': [
        {
          'name': 'Izgara Antrikot',
          'price': 25.0,
          'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTjbuhVUAislVKZQW7vcT0M3o_zPBmlJqlz9A&s'
        },
        {
          'name': 'Kuzu İncik',
          'price': 32.0,
          'imageUrl': 'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=400'
        },
        {
          'name': 'Deniz Mahsüllü Pasta',
          'price': 22.0,
          'imageUrl': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=400'
        },
        {
          'name': 'Sebzeli Risotto',
          'price': 18.0,
          'imageUrl': 'https://images.unsplash.com/photo-1476124369491-e7addf5db371?q=80&w=400'
        },
        {
          'name': 'Nachos Deluxe',
          'price': 11.0,
          'imageUrl': 'https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?q=80&w=400'
        },
        {
          'name': 'Çıtır Tavuk Sepeti',
          'price': 13.0,
          'imageUrl': 'https://images.unsplash.com/photo-1562967914-608f82629710?q=80&w=400'
        },
        {
          'name': 'Izgara Köfte',
          'price': 16.0,
          'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTTlTyF4oUN9X2v1SAmG-yMrUodJ6uMy5tDlQ&s'
        },
        {
          'name': 'Izgara Somon',
          'price': 22.0,
          'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvSY_jc3mmSm5lgCMryVwXAh0nBKbtb9Rnwg&s'
        },
        {
          'name': 'Margherita Pizza',
          'price': 12.0,
          'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSwOGbJHE8FPBBUlPqWd0c_blJ15gYUILFaqg&s'
        },
        {
          'name': 'Spaghetti Bolognese',
          'price': 13.0,
          'imageUrl': 'https://images.immediate.co.uk/production/volatile/sites/30/2020/08/classic-spaghetti-bolognese-0f3c807.jpg?quality=90&resize=440,400'
        },
      ],
      'Tatlılar ve Meyveler': [
        {
          'name': 'Sufle',
          'price': 8.0,
          'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTvdsk54TV3sY8BZTWrULla0H3t68gNG0tzTg&s'
        },
        {
          'name': 'Cheesecake',
          'price': 9.0,
          'imageUrl': 'https://assets.tmecosys.com/image/upload/t_web_rdp_recipe_584x480/img/recipe/ras/Assets/63437ceaaca08392d64a4f54abcbe225/Derivates/d34ad6dd998b08781eb1b5cebdb014f3673fcf81.jpg'
        },
        {
          'name': 'Tiramisu',
          'price': 9.0,
          'imageUrl': 'https://cdn.myikas.com/images/52036155-b163-4fc0-a730-34e056fc0d79/d812d40f-1f2a-4a91-a536-63863ea46803/image_1080.webp'
        },
        {
          'name': 'San Sebastian',
          'price': 11.0,
          'imageUrl': 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?q=80&w=400'
        },
        {
          'name': 'Fıstıklı Baklava (4 Adet)',
          'price': 12.0,
          'imageUrl': 'https://images.unsplash.com/photo-1519676867240-f03562e64548?q=80&w=400'
        },
        {
          'name': 'Profiterol',
          'price': 9.0,
          'imageUrl': 'https://images.unsplash.com/photo-1551024601-bec78aea704b?q=80&w=400'
        },
        {
          'name': 'Waffle',
          'price': 13.0,
          'imageUrl': 'https://images.unsplash.com/photo-1562329265-95a6d7a83440?q=80&w=400'
        },
        {
          'name': 'Magnolia',
          'price': 8.0,
          'imageUrl': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?q=80&w=400'
        },
      ],
      'İçecekler': [
        {
          'name': 'Türk Kahvesi',
          'price': 4.0,
          'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmg_lywjJZbtnYKI6TnJwLD0b5FGUYXu3smg&s'
        },
        {
          'name': 'Taze Portakal Suyu',
          'price': 7.0,
          'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSzh58daOIC_Hn9tx6Y4Hqa4b6drYCjAhJX7w&s'
        },
        {
          'name': 'Coca Turka',
          'price': 4.0,
          'imageUrl': 'https://cdn.dsmcdn.com/ty1617/prod/QC/20241225/22/bbc0c5e0-c687-3183-8691-2f89e5e0b563/1_org_zoom.jpg'
        },
        {
          'name': 'Bira',
          'price': 8.0,
          'imageUrl': 'https://www.lav.com.tr/cdn/shop/files/LV-SRG375M-10.jpg?v=1772037260'
        },
        {
          'name': 'Viski',
          'price': 40.0,
          'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT5DFPw_xFHRbYMd-PbmsCZWEYWd27zkPasIw&s'
        },
        {
          'name': 'Detoks Suyu',
          'price': 6.0,
          'imageUrl': 'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?q=80&w=400'
        },
        {
          'name': 'Buzlu Latte',
          'price': 8.0,
          'imageUrl': 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?q=80&w=400'
        },
        {
          'name': 'Ev Yapımı Limonata',
          'price': 6.5,
          'imageUrl': 'https://i.lezzet.com.tr/images-xxlarge-recipe/ev-yapimi-konsantre-limonata-01e50b99-5890-411f-a4c2-997a71e8a5cc.jpg'
        },
      ],
    };

    final List<Map<String, dynamic>> categories = [
      {'title': 'Kahvaltı', 'icon': Icons.breakfast_dining, 'color': Colors.orange, 'imageUrl': 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?q=80&w=200&auto=format&fit=crop', 'items': menuData['Kahvaltı']},
      {'title': 'Atıştırmalıklar', 'icon': Icons.tapas, 'color': Colors.amber, 'imageUrl': 'https://images.unsplash.com/photo-1541014741259-de529411b96a?q=80&w=200&auto=format&fit=crop', 'items': menuData['Atıştırmalıklar ve Başlangıçlar']},
      {'title': 'Ana Yemekler', 'icon': Icons.restaurant, 'color': Colors.red, 'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=200&auto=format&fit=crop', 'items': menuData['Ana Yemekler']},
      {'title': 'Tatlılar', 'icon': Icons.icecream, 'color': Colors.pink, 'imageUrl': 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?q=80&w=200&auto=format&fit=crop', 'items': menuData['Tatlılar ve Meyveler']},
      {'title': 'İçecekler', 'icon': Icons.local_bar, 'color': Colors.blue, 'imageUrl': 'https://images.unsplash.com/photo-1544145945-f904253d0c71?q=80&w=200&auto=format&fit=crop', 'items': menuData['İçecekler']},
      {'title': 'Siparişleriniz', 'icon': Icons.shopping_basket, 'color': Colors.teal, 'imageUrl': 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?q=80&w=200&auto=format&fit=crop', 'items': []},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(
        title: Text('Oda Servisi - Oda: ${widget.roomNumber}'),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RoomServiceOrdersScreen(
                            roomNumber: widget.roomNumber,
                            reservationId: widget.reservationId,
                            cart: _cart,
                            onUpdateQuantity: _updateQuantity,
                            onClearCart: _clearCart,
                          )
                      )
                  ),
                  icon: const Icon(Icons.shopping_cart)
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text('${_cart.length}', style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                  ),
                )
            ],
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(cat['imageUrl'] as String),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black26,
                      ),
                      child: Icon(cat['icon'] as IconData, color: Colors.white),
                    ),
                  ),
                  title: Text(cat['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (cat['title'] == 'Siparişleriniz') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RoomServiceOrdersScreen(
                                roomNumber: widget.roomNumber,
                                reservationId: widget.reservationId,
                                cart: _cart,
                                onUpdateQuantity: _updateQuantity,
                                onClearCart: _clearCart,
                              )
                          )
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomServiceCategoryScreen(
                          category: cat['title'] as String,
                          roomNumber: widget.roomNumber,
                          reservationId: widget.reservationId,
                          items: cat['items'] as List<Map<String, dynamic>>? ?? [],
                          onAddToCart: _addToCart,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// IN HOUSE ROOM EKRANI
class InHouseRoomScreen extends StatefulWidget {
  final String identityNumber;
  const InHouseRoomScreen({super.key, required this.identityNumber});

  @override
  State<InHouseRoomScreen> createState() => _InHouseRoomScreenState();
}

class _InHouseRoomScreenState extends State<InHouseRoomScreen> {
  final _firestoreService = FirestoreService();

  void _checkOut(HotelReservation res) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check-out Başlatılsın mı?'),
        content: Text('Oda ${res.roomNumber} için toplam borcunuz: ${res.totalPrice.toStringAsFixed(2)} €\n\n(Oda + Oda Servisi Toplamı)\n\nÖdeme ekranına yönlendirileceksiniz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('VAZGEÇ')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('ÖDEMEYE GİT', style: TextStyle(color: Colors.orange))),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen(reservation: res, isCheckOut: true)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(title: const Text('Aktif Odalarım'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: FutureBuilder<List<HotelReservation>>(
            future: _firestoreService.getUserReservations(widget.identityNumber),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final activeRes = (snapshot.data ?? []).where((r) => r.isCheckedIn && !r.isCheckedOut).toList();

              if (activeRes.isEmpty) {
                return const Center(child: Text('Şu an aktif bir odanız bulunmamaktadır.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: activeRes.length,
                itemBuilder: (context, index) {
                  final res = activeRes[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ExpansionTile(
                      leading: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.meeting_room, color: Colors.white)),
                      title: Text('Oda: ${res.roomNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(res.roomType),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            children: [
                              _ActionItem(
                                  icon: Icons.room_service,
                                  label: 'Room Service',
                                  color: Colors.lightBlue,
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RoomServiceScreen(roomNumber: res.roomNumber, reservationId: res.id)))
                              ),
                          _ActionItem(
                              icon: Icons.cleaning_services,
                              label: 'Housekeeping',
                              color: Colors.purple,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HousekeepingScreen(roomNumber: res.roomNumber, reservationId: res.id))
                              )
                          ),
                              _ActionItem(icon: Icons.exit_to_app, label: 'Check-out', color: Colors.orange, onTap: () => _checkOut(res)),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$feature yakında aktif edilecektir.')));
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _ActionItem({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(children: [
        CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color, size: 20)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _DashCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String imageUrl;
  final VoidCallback onTap;

  const _DashCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.imageUrl,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(color: Colors.grey[200]);
                },
                errorBuilder: (context, error, stackTrace) => Container(color: color.withValues(alpha: 0.1)),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 28, color: Colors.white),
                  const SizedBox(height: 4),
                  Text(
                      title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black87, blurRadius: 4)]
                      )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// REZERVASYON OLUŞTURMA EKRANI
class CreateReservationScreen extends StatefulWidget {
  final Map<String, dynamic> guestData;
  const CreateReservationScreen({super.key, required this.guestData});

  @override
  State<CreateReservationScreen> createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  DateTime _checkInDate = DateTime.now();
  final TextEditingController _stayDaysController = TextEditingController(text: '1');
  final TextEditingController _dateController = TextEditingController();
  int _personCount = 1;
  String? _selectedRoom;
  bool _includeBreakfast = false;
  bool _includeDinner = false;
  bool _isSaving = false;

  Map<String, String> _roomStatus = {};

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_checkInDate);
    _updateAvailability();
  }

  void _updateAvailability() {
    setState(() {
      _roomStatus = {};
    });
  }

  String _getRoomType(String roomNum) {
    if (roomNum.endsWith('01') || roomNum.endsWith('02') || roomNum.endsWith('09') || roomNum.endsWith('10')) return 'Köşe Oda';
    if (roomNum.endsWith('05') || roomNum.endsWith('06')) return 'Suit Oda';
    return 'Standart Oda';
  }

  double _getRoomBasePrice(String roomNum) {
    String type = _getRoomType(roomNum);
    if (type == 'Köşe Oda') return 150.0;
    if (type == 'Suit Oda') return 250.0;
    return 120.0;
  }

  double _calculateTotal() {
    if (_selectedRoom == null) return 0.0;
    int stayDays = int.tryParse(_stayDaysController.text) ?? 1;
    double roomBase = _getRoomBasePrice(_selectedRoom!);

    double dailyBase = roomBase + ((_personCount - 1) * 20.0);

    double dailyExtras = 0;
    if (_includeBreakfast) dailyExtras += 20.0 * _personCount;
    if (_includeDinner) dailyExtras += 40.0 * _personCount;

    return (dailyBase + dailyExtras) * stayDays;
  }

  void _confirmReservation() async {
    if (_selectedRoom == null) return;
    setState(() => _isSaving = true);
    try {
      String code = await FirestoreService().createReservation(
        name: widget.guestData['name'],
        surname: widget.guestData['surname'],
        identityNumber: widget.guestData['identityNumber'],
        checkInDate: _checkInDate,
        stayDays: int.tryParse(_stayDaysController.text) ?? 1,
        personCount: _personCount,
        roomNumber: _selectedRoom!,
        roomType: _getRoomType(_selectedRoom!),
        includeBreakfast: _includeBreakfast,
        includeDinner: _includeDinner,
        totalPrice: _calculateTotal(),
      );

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rezervasyon Başarılı!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              const Text('Konfirmasyon Numaranız:'),
              const SizedBox(height: 5),
              Text(code, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3F51B5))),
              const SizedBox(height: 15),
              const Text('Lütfen bu numarayı not ediniz.', textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('TAMAM'),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F9),
      appBar: AppBar(
        title: const Text('Rezervasyon Yap'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('Misafir Bilgileri', [
                  _CustomTextField(hintText: '', labelText: 'Ad Soyad', readOnly: true, controller: TextEditingController(text: '${widget.guestData['name']} ${widget.guestData['surname']}')),
                  const SizedBox(height: 12),
                  _CustomTextField(hintText: '', labelText: 'Kimlik/Pasaport No', readOnly: true, controller: TextEditingController(text: widget.guestData['identityNumber'])),
                ]),
                _buildSection('Rezervasyon Detayları', [
                  Row(children: [
                    Expanded(child: _CustomTextField(
                      hintText: 'GG/AA/YYYY',
                      labelText: 'Giriş Tarihi',
                      controller: _dateController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      inputFormatters: [DateTextFormatter()],
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(context: context, initialDate: _checkInDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
                          if (picked != null) {
                            setState(() {
                              _checkInDate = picked;
                              _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
                              _updateAvailability();
                            });
                          }
                        },
                      ),
                      onChanged: (v) {
                        if (v.length == 10) {
                          try {
                            DateTime parsed = DateFormat('dd/MM/yyyy').parse(v);
                            setState(() {
                              _checkInDate = parsed;
                              _updateAvailability();
                            });
                          } catch (_) {}
                        }
                      },
                    )),
                    const SizedBox(width: 15),
                    Expanded(child: _CustomTextField(
                      hintText: '1',
                      labelText: 'Gün Sayısı',
                      controller: _stayDaysController,
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setState(() {}),
                    )),
                  ]),
                  const SizedBox(height: 12),
                  const Text('Kişi Sayısı (Max 3)', style: TextStyle(color: Color(0xFF5C5B7F), fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(children: [1, 2, 3].map((n) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text('$n Kişi'),
                      selected: _personCount == n,
                      selectedColor: const Color(0xFF5C5B7F),
                      onSelected: (s) => setState(() => _personCount = n),
                    ),
                  )).toList()),
                ]),
                _buildSection('Kat Krokisi ve Oda Seçimi', [
                  for (int floor = 1; floor <= 3; floor++) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Text('$floor. Kat', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF424242))),
                    ),
                    _buildFloorLayout(floor),
                    const SizedBox(height: 20),
                  ],
                ]),
                if (_selectedRoom != null) _buildSection('Özet ve Onay', [
                  Text('Seçili Oda: $_selectedRoom (${_getRoomType(_selectedRoom!)})', style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  SwitchListTile(
                      title: const Text('Kahvaltı Dahil (+20€ / Gün)', style: TextStyle(fontSize: 15)),
                      value: _includeBreakfast,
                      activeThumbColor: const Color(0xFF6750A4),
                      onChanged: (v) => setState(() => _includeBreakfast = v)
                  ),
                  SwitchListTile(
                      title: const Text('Akşam Yemeği Dahil (+40€ / Gün)', style: TextStyle(fontSize: 15)),
                      value: _includeDinner,
                      activeThumbColor: const Color(0xFF6750A4),
                      onChanged: (v) => setState(() => _includeDinner = v)
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(thickness: 1.2),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('GENEL TOPLAM:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF424242))),
                      Text('${_calculateTotal().toStringAsFixed(2)} €', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                          onPressed: _isSaving ? null : _confirmReservation,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3F51B5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('REZERVASYONU ONAYLA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
                      )
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloorLayout(int floor) {
    List<String> odds = [];
    List<String> evens = [];
    for (int i = 1; i <= 10; i++) {
      String roomNum = '$floor${i < 10 ? '0' : ''}$i';
      if (i % 2 != 0) {
        odds.add(roomNum);
      } else {
        evens.add(roomNum);
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 4),
          child: Text('Deniz Tarafı', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF757575))),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: odds.map((r) => _buildRoomTile(r)).toList()),
        const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(thickness: 2.5, color: Color(0xFFD1CFDB))),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: evens.map((r) => _buildRoomTile(r)).toList()),
        const Padding(
          padding: EdgeInsets.only(left: 4, top: 4),
          child: Text('Şehir Tarafı', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF757575))),
        ),
      ],
    );
  }

  Widget _buildRoomTile(String roomNum) {
    bool isOccupied = _roomStatus[roomNum] == 'DOLU';
    bool isSelected = _selectedRoom == roomNum;
    return Expanded(
      child: InkWell(
        onTap: isOccupied ? null : () => setState(() => _selectedRoom = roomNum),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 52,
          decoration: BoxDecoration(
            color: isOccupied ? const Color(0xFFF44336) : (isSelected ? const Color(0xFF00897B) : const Color(0xFFB2EBF2)),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [if (isSelected) BoxShadow(color: Colors.teal.withValues(alpha: 0.3), blurRadius: 4, spreadRadius: 1)],
          ),
          alignment: Alignment.center,
          child: Text(
            roomNum + (isOccupied ? '\nDOLU' : '\nSEÇ'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: (isOccupied || isSelected) ? Colors.white : const Color(0xFF006064)),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1DDEB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1D1B20))),
        const SizedBox(height: 18),
        ...children,
      ]),
    );
  }
}

// MİSAFİR GİRİŞ EKRANI
class CheckInSearchScreen extends StatefulWidget {
  const CheckInSearchScreen({super.key});
  @override
  State<CheckInSearchScreen> createState() => _CheckInSearchScreenState();
}

class _CheckInSearchScreenState extends State<CheckInSearchScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen alanları doldurun.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      var guestData = await _firestoreService.loginGuest(_emailController.text, _passwordController.text);
      if (guestData != null) {
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (context) => GuestDashboardScreen(guestData: guestData)));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hatalı e-posta veya şifre!'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Misafir Girişi', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF424242))),
                const SizedBox(height: 40),
                _CustomTextField(hintText: 'E-posta Adresiniz', controller: _emailController, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 15),
                _CustomTextField(hintText: 'Şifreniz', isPassword: true, controller: _passwordController),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009688), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    child: const Text('Giriş Yap', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                  child: const Text('Hesabın yok mu? Hemen Kayıt Ol', style: TextStyle(color: Color(0xFF009688), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// REZERVASYON SORGULAMA -> ARTIK REZERVASYONLARIM
class ReservationSearchStepScreen extends StatefulWidget {
  final String identityNumber;
  const ReservationSearchStepScreen({super.key, required this.identityNumber});
  @override
  State<ReservationSearchStepScreen> createState() => _ReservationSearchStepScreenState();
}

class _ReservationSearchStepScreenState extends State<ReservationSearchStepScreen> {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(title: const Text('Rezervasyonlarım')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: FutureBuilder<List<HotelReservation>>(
            future: _firestoreService.getUserReservations(widget.identityNumber),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
              }
              final pendingReservations = (snapshot.data ?? []).where((res) => !res.isCheckedIn).toList();

              if (pendingReservations.isEmpty) {
                return const Center(child: Text('Bekleyen bir rezervasyonunuz bulunmamaktadır.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pendingReservations.length,
                itemBuilder: (context, index) {
                  final res = pendingReservations[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text('Oda: ${res.roomNumber} - ${res.roomType}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Kod: ${res.reservationCode}', style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold)),
                          Text('Tarih: ${DateFormat('dd/MM/yyyy').format(res.checkInDate)}'),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReservationDetailsScreen(reservation: res))).then((_) => setState(() {})),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class ReservationDetailsScreen extends StatefulWidget {
  final HotelReservation reservation;
  const ReservationDetailsScreen({super.key, required this.reservation});
  @override
  State<ReservationDetailsScreen> createState() => _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  bool _isProcessing = false;
  final _firestoreService = FirestoreService();

  void _checkIn() async {
    setState(() => _isProcessing = true);
    try {
      await _firestoreService.completeHotelCheckIn(widget.reservation.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check-in başarıyla tamamlandı! Hoş geldiniz.'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _delete() async {
    bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rezervasyonu İptal Et'),
          content: const Text('Bu rezervasyonu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('VAZGEÇ')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('SİL', style: TextStyle(color: Colors.red))),
          ],
        )
    ) ?? false;

    if (confirm) {
      setState(() => _isProcessing = true);
      await _firestoreService.deleteReservation(widget.reservation.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rezervasyon başarıyla silindi.'), backgroundColor: Colors.red));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rezervasyon Bilgileri')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(widget.reservation.hotelName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Oda No:'),
                            Text(widget.reservation.roomNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Oda Tipi:'),
                            Text(widget.reservation.roomType, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Rezervasyon Kodu:'),
                            Text(widget.reservation.reservationCode, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3F51B5))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Giriş Tarihi:'),
                            Text(DateFormat('dd/MM/yyyy').format(widget.reservation.checkInDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (_isProcessing)
                  const CircularProgressIndicator()
                else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      onPressed: _checkIn,
                      child: const Text('Check-in Yap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      onPressed: _delete,
                      child: const Text('Rezervasyonu İptal Et', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  final HotelReservation reservation;
  final bool isCheckOut;
  const PaymentScreen({super.key, required this.reservation, this.isCheckOut = false});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  void _processPayment() async {
    String cardNo = _cardNumberController.text.replaceAll(' ', '');
    if (cardNo.length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kart numarası 16 hane olmalıdır.')));
      return;
    }

    if (_expiryMonthController.text.isEmpty || _expiryYearController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geçerli bir son kullanma tarihi girin.')));
      return;
    }

    try {
      int month = int.parse(_expiryMonthController.text);
      int year = int.parse('20${_expiryYearController.text}');
      DateTime now = DateTime.now();

      if (month < 1 || month > 12) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geçersiz ay girdiniz.')));
        return;
      }
      if (year < now.year || (year == now.year && month < now.month)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kartınızın süresi dolmuş.')));
        return;
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geçerli tarih formatı.')));
      return;
    }

    if (_cvvController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geçerli bir CVV girin.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (widget.isCheckOut) {
        await _firestoreService.completeHotelCheckOut(widget.reservation.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ödeme Başarılı! Check-out tamamlandı.'), backgroundColor: Colors.orange));
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => InvoiceScreen(identityNumber: widget.reservation.identityNumber))
        );
      } else {
        await _firestoreService.completeHotelCheckIn(widget.reservation.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ödeme Başarılı! Check-in tamamlandı.'), backgroundColor: Colors.green));
        int count = 0;
        Navigator.popUntil(context, (route) => count++ == 3);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(title: Text(widget.isCheckOut ? 'Check-out Ödemesi' : 'Ödeme İşlemi')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Icon(Icons.credit_card, size: 60, color: Colors.indigo),
                const SizedBox(height: 20),
                Text('Ödenecek Tutar: ${widget.reservation.totalPrice.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (widget.isCheckOut) ...[
                  const SizedBox(height: 10),
                  const Text('(Konaklama + Oda Servisi Toplamı)', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
                const SizedBox(height: 30),
                _CustomTextField(
                  hintText: 'XXXX XXXX XXXX XXXX',
                  labelText: 'Kart Numarası',
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, CardNumberFormatter()],
                ),
                const SizedBox(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _CustomTextField(
                        hintText: 'AA',
                        labelText: 'Ay',
                        controller: _expiryMonthController,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: _CustomTextField(
                        hintText: 'YY',
                        labelText: 'Yıl',
                        controller: _expiryYearController,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 1,
                      child: _CustomTextField(
                        hintText: 'XXX',
                        labelText: 'CVV',
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        isPassword: true,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _processPayment,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text(
                        widget.isCheckOut ? 'TOPLU ÖDEMEYİ YAP VE AYRIL' : 'Ödemeyi Tamamla ve Check-in Yap',
                        style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    if (_emailController.text == 'admin@admin.com' && _passwordController.text == 'admin123') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hatalı e-posta veya şifre!'), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Yönetici Girişi', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF424242))),
                const SizedBox(height: 40),
                _CustomTextField(hintText: 'E-posta Adresiniz', controller: _emailController, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 15),
                _CustomTextField(hintText: 'Şifreniz', isPassword: true, controller: _passwordController),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009688), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    child: const Text('Giriş Yap', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
class HousekeepingScreen extends StatelessWidget {
  final String roomNumber;
  final String reservationId;

  const HousekeepingScreen({super.key, required this.roomNumber, required this.reservationId});

  final Map<String, List<Map<String, String>>> supplies = const {
    'Tekstil ve Uyku': [
      {
        'name': 'Ekstra Yastık',
        'img': 'https://www.idas.com.tr/Upload/Fluffy-yastik_n.jpg'
      },
      {
        'name': 'Battaniye',
        'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSAwMEBq0K1RQZuFFEmFs0G0CHwF-N_UI-DnA&s'
      },
      {
        'name': 'Temiz Havlu',
        'img': 'https://dantela.com.tr/cdn/shop/files/pamuk-50x90cm-6-li-karisik-el-havlu-seti-kod-9090-1982_800x.jpg?v=1715217879'
      },
      {
        'name': 'Bornoz',
        'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ_vFvnd5EGl-nH-vP0ttPWWwVP6H8qS8csdg&s'
      },
    ],
    'Bakım ve Hijyen': [
      {
        'name': 'Şampuan & Sabun',
        'img': 'https://img.kwcdn.com/product/Fancyalgo/VirtualModelMatting/098664a9e3848cbf009ed9c2c543840f.jpg?imageMogr2/auto-orient%7CimageView2/2/w/800/q/70/format/webp'
      },
      {
        'name': 'Diş Seti',
        'img': 'https://cdn.dsmcdn.com/ty1560/product/media/images/ty1560/prod/QC/20240920/10/54715ae4-e735-3953-a3cd-99838601bb44/1_org_zoom.jpg'
      },
      {
        'name': 'Tıraş Seti',
        'img': 'https://static.ticimax.cloud/76059/uploads/urunresimleri/buyuk/yuma-tras-makinasi-arko-berber-tras-sabu-5cab.jpg'
      },
      {
        'name': 'Pamuk & Kulak Çubuğu',
        'img': 'https://cdn.dsmcdn.com/mnresize/420/620/ty1604/prod/QC/20241115/15/ba73324f-b48c-3384-8c4c-75c80e4255d4/1_org_zoom.jpg'
      },
    ],
    'Oda İçi Gereçler': [
      {
        'name': 'Ütü ve Masası',
        'img': 'https://cdn-img.pttavm.com/pimages/592/537/597/c_65ca1abfec616.webp?v=202402141157'
      },
      {
        'name': 'Su Takviyesi',
        'img': 'https://cdn2.a101.com.tr/dbmk89vnr/CALL/Image/get/ZUpXJ8drSq_1024x1024.png'
      },
      {
        'name': 'Çay & Kahve Seti',
        'img': 'https://cdn.medicalpark.com.tr/cay-mi-kahve-mi.jpg'
      },
      {
        'name': 'Açacak',
        'img': 'https://cdn.dsmcdn.com/ty1818/prod/QC_ENRICHMENT/20260201/23/b7d168b4-6a18-3da3-834b-08ac13e9bc9d/1_org_zoom.jpg'
      },
    ],
    'Diğer Hizmetler': [
      {
        'name': 'Çöp Boşaltma',
        'img': 'https://media.istockphoto.com/id/1890820206/tr/vekt%C3%B6r/recycle-bin-icon.jpg?s=170667a&w=0&k=20&c=g0TzihI_u_ZenJH9tw_3zo6JVp6uHIzyZOzTQY9bpRs='
      },
      {
        'name': 'Seccade / Mat',
        'img': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKdNVP69FpCY87ujVbMP2ONCZLt89WlQSN5g&s'
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      appBar: AppBar(title: Text('Oda $roomNumber - Temizlik & İhtiyaç'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: supplies.entries.map((category) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  title: Text(category.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                  initiallyExpanded: true,
                  children: category.value.map((item) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(item['img']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        await FirestoreService().addHousekeepingRequest(reservationId, item['name']!);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${item['name']} talebiniz iletildi.'), backgroundColor: Colors.purple),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[50],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Text('TALEP ET', style: TextStyle(color: Colors.purple[900], fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  )).toList(),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}