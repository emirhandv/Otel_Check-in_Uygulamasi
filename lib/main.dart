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
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
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
        // Global temayı siberpunk neon yerine Alapros renklerine çekiyoruz
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC61111),
          primary: const Color(0xFFC61111),
          secondary: const Color(0xFF1D1D1F),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Sayfanın en yukarısına yapışan ve tam yazı yüksekliğine göre şık kurumsal kırmızı alan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 18,
            ), // Yazıya göre daraltılmış şık yükseklik
            decoration: const BoxDecoration(
              color: Color(0xFFC61111),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const SafeArea(
              bottom:
                  false, // Üst bara tam yapışması için alt güvenli alanı kapatıyoruz
              child: Center(
                child: Text(
                  'Giriş Ekranı',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),

          // İçerik alanı
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // "Sisteme erişmek için giriş yapın!" metni
                    const Text(
                      ''
                      'Siteme erişebilmek için giriş yapın',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1D1D1F),
                        letterSpacing: -0.8,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Giriş Seçenekleri Kartları
                    _SelectionButton(
                      title: 'Misafir Girişi',
                      subtitle: 'Rezervasyon kontrolü ve oda hizmetleri için',
                      icon: Icons.person_outline_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckInSearchScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _SelectionButton(
                      title: 'Yönetici Girişi',
                      subtitle: 'Resepsiyon ve sistem paneli erişimi için',
                      icon: Icons.admin_panel_settings_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminLoginScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SelectionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBEBEB), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC61111).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFFC61111),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D1D1F),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888888),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Color(0xFFB0B0B0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
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
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
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

//Özel metin alanı
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
        if (labelText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              labelText!,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
              width: 1.5,
            ),
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
            cursorColor: const Color(0xFF00E5FF),
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              counterText: "",
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}

// KAYIT OLMA EKRANI (EmailJS ile Gerçek E-Posta Gönderimi)
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

  bool _isLoading = false;
  String _generatedOtp = '';

  final List<Map<String, String>> _countries = [
    {'name': 'Türkiye', 'flag': '🇹🇷'},
    {'name': 'Almanya', 'flag': '🇩🇪'},
    {'name': 'İngiltere', 'flag': '🇬🇧'},
    {'name': 'Fransa', 'flag': '🇫🇷'},
    {'name': 'İtalya', 'flag': '🇮🇹'},
    {'name': 'ABD', 'flag': '🇺🇸'},
    {'name': 'Azerbaycan', 'flag': '🇦🇿'},
    // ... Diğer ülkeler listenizde kalabilir, sadece örnek olarak birkaçı düzenlendi
  ];

  Future<void> _startRegistration() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      _showErrorSnackBar('Lütfen tüm alanları doldurun.');
      return;
    }
    setState(() => _isLoading = true);
    _generatedOtp = (Random().nextInt(900000) + 100000).toString();

    try {
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: json.encode({
          'service_id': 'service_acivp19',
          'template_id': 'template_7xq3kct',
          'user_id': 'KmUfRkQm1aEUXFtQ5',
          'template_params': {
            'to_email': _emailController.text,
            'user_name': _nameController.text,
            'otp_code': _generatedOtp,
          },
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        _showOtpVerificationDialog();
      } else {
        _showErrorSnackBar('E-posta gönderilemedi.');
      }
    } catch (e) {
      _showErrorSnackBar('Bağlantı hatası: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFC61111)),
    );
  }

  void _showOtpVerificationDialog() {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Column(
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 50,
                color: Color(0xFFC61111),
              ),
              SizedBox(height: 15),
              Text(
                'E-Posta Doğrulama',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_emailController.text} adresine gönderilen 6 haneli kodu giriniz.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: Color(0xFFC61111),
                ),
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İPTAL', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC61111),
              ),
              onPressed: () {
                if (otpController.text == _generatedOtp) {
                  Navigator.pop(context);
                  _registerUserToDatabase();
                } else {
                  _showErrorSnackBar('Hatalı kod!');
                }
              },
              child: const Text(
                'DOĞRULA',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _registerUserToDatabase() async {
    setState(() => _isLoading = true);
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
      Navigator.pop(context, true);
    } catch (e) {
      _showErrorSnackBar('Kayıt hatası: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // İSTEDİĞİN KIRMIZI ÜST ŞERİT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFFC61111),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Text(
                    'Kayıt Ol',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildLabel('Kimlik Türü'),
                  _buildIdentityDropdown(),
                  const SizedBox(height: 16),
                  _buildInputField(
                    hint: 'Adınız',
                    label: 'Ad',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    hint: 'Soyadınız',
                    label: 'Soyad',
                    controller: _surnameController,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    hint: _selectedIdentityType == 'TC'
                        ? '11 Haneli TC No'
                        : 'Pasaport No',
                    label: 'Kimlik / Pasaport No',
                    controller: _identityController,
                    type: _selectedIdentityType == 'TC'
                        ? TextInputType.number
                        : TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Ülke'),
                  _buildCountryDropdown(),
                  const SizedBox(height: 16),
                  _buildInputField(
                    hint: '05xx xxx xx xx',
                    label: 'Telefon',
                    controller: _phoneController,
                    type: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    hint: 'E-posta adresiniz',
                    label: 'E-posta',
                    controller: _emailController,
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    hint: '••••••',
                    label: 'Şifre',
                    controller: _passwordController,
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const CircularProgressIndicator(
                          color: Color(0xFFC61111),
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _startRegistration,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC61111),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'KAYIT OL',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1D1D1F),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hint,
    required String label,
    required TextEditingController controller,
    TextInputType type = TextInputType.text,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEBEBEB), width: 1.5),
          ),
          child: TextField(
            controller: controller,
            keyboardType: type,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFB0B0B0),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBEBEB), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedIdentityType,
          isExpanded: true,
          items: ['TC', 'Pasaport']
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e == 'TC' ? 'T.C. Vatandaşı' : 'Yabancı Misafir'),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() {
            _selectedIdentityType = v!;
            if (v == 'TC') _selectedCountryName = 'Türkiye';
          }),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBEBEB), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountryName,
          isExpanded: true,
          onChanged: _selectedIdentityType == 'TC'
              ? null
              : (v) => setState(() => _selectedCountryName = v!),
          items: _countries
              .map(
                (c) => DropdownMenuItem(
                  value: c['name'],
                  child: Row(
                    children: [
                      Text(c['flag']!),
                      const SizedBox(width: 10),
                      Text(c['name']!),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// 12. TALEP BİLDİR EKRANI (ALAPROS KURUMSAL TASARIM)
class SupportRequestScreen extends StatefulWidget {
  final String identityNumber;
  const SupportRequestScreen({super.key, required this.identityNumber});

  @override
  State<SupportRequestScreen> createState() => _SupportRequestScreenState();
}

class _SupportRequestScreenState extends State<SupportRequestScreen> {
  String? _lastRequestedItem;
  bool _showNotify = false;

  void _triggerNotify(String item) async {
    setState(() {
      _lastRequestedItem = item;
      _showNotify = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _showNotify = false);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Su ve Sıhhi Tesisat',
        'icon': Icons.build_rounded,
        'items': ['Sıcak Su Sorunu', 'Gider Tıkanıklığı', 'Su Sızıntısı'],
      },
      {
        'title': 'Multimedya ve Teknoloji',
        'icon': Icons.devices_other_rounded,
        'items': [
          'Televizyon ve Uydu Sorunları',
          'Kasa (Safe Box) Yardımı',
          'Telefon Sorunları',
          'Elektrik/Aydınlatma',
        ],
      },
      {
        'title': 'Enerji ve Donanım',
        'icon': Icons.electrical_services_rounded,
        'items': [
          'Kart Okuyucu (Energy Saver)',
          'Priz ve Şarj',
          'Mobilya ve Kapı',
        ],
      },
      {
        'title': 'Ses ve İzolasyon',
        'icon': Icons.volume_off_rounded,
        'items': ['Gürültü Şikayeti'],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Temiz kırık beyaz zemin
      body: Stack(
        children: [
          Column(
            children: [
              // ALAPROS KURUMSAL APPBAR
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: const BoxDecoration(
                  color: Color(0xFFC61111),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Text(
                        'Talep Bildir',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // TALEP SEÇENEKLERİ LİSTESİ
              Expanded(
                child: FutureBuilder<List<HotelReservation>>(
                  future: FirestoreService().getUserReservations(
                    widget.identityNumber,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFC61111),
                        ),
                      );
                    }

                    // Aktif konaklamayı bulma mantığı
                    HotelReservation? activeRes;
                    if (snapshot.hasData) {
                      for (var r in snapshot.data!) {
                        if (r.isCheckedIn && !r.isCheckedOut) {
                          activeRes = r;
                          break;
                        }
                      }
                    }

                    if (activeRes == null) {
                      return Center(
                        child: Text(
                          'Aktif bir odanız bulunmamaktadır.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 14,
                                bottom: 10,
                                left: 4,
                              ),
                              child: Text(
                                cat['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFFC61111),
                                ),
                              ),
                            ),
                            ...(cat['items'] as List<String>).map(
                              (item) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFEBEBEB),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.01),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFC61111,
                                      ).withOpacity(0.06),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      cat['icon'] as IconData,
                                      color: const Color(0xFFC61111),
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    item,
                                    style: const TextStyle(
                                      color: Color(0xFF1D1D1F),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.send_rounded,
                                    color: Color(0xFFC61111),
                                    size: 18,
                                  ),
                                  onTap: () async {
                                    await FirestoreService()
                                        .addHousekeepingRequest(
                                          activeRes!.id,
                                          item,
                                        );
                                    _triggerNotify(item);
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // BAŞARILI BİLDİRİM TOAST POP-UP
          if (_showNotify)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '$_lastRequestedItem talebiniz iletildi.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// MİSAFİR DASHBOARD
// MİSAFİR ANA PANELİ (HATA RİSKSİZ, KARTLARI İÇİNE GÖMÜLMÜŞ SÜRÜM)
class GuestDashboardScreen extends StatelessWidget {
  final Map<String, dynamic> guestData;
  const GuestDashboardScreen({super.key, required this.guestData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // REFERANSA UYGUN KIRMIZI ÜST BAR VE BAŞLIK ALANI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFC61111),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Text(
                      'Hoş Geldin, ${guestData['name']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileSettingsScreen(guestData: guestData),
                        ),
                      ),
                      child: const Icon(
                        Icons.account_circle_outlined,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Alt Karşılama Metni
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 10),
            child: Text(
              'Size nasıl yardımcı olabiliriz?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),

          // REFERANSTAKİ GİBİ TEMİZ VE MODERN GRİ/BEYAZ HİZMET KARTLARI
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildDashCard(
                  context,
                  title: 'Rezervasyon\nOluştur',
                  icon: Icons.add_business_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateReservationScreen(guestData: guestData),
                    ),
                  ),
                ),
                _buildDashCard(
                  context,
                  title: 'Check-in Yap',
                  icon: Icons.vpn_key_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationSearchStepScreen(
                        identityNumber: guestData['identityNumber'],
                      ),
                    ),
                  ),
                ),
                _buildDashCard(
                  context,
                  title: 'Aktif Odam',
                  icon: Icons.meeting_room_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InHouseRoomScreen(
                        identityNumber: guestData['identityNumber'],
                      ),
                    ),
                  ),
                ),
                _buildDashCard(
                  context,
                  title: 'Fatura / Geçmiş',
                  icon: Icons.receipt_long_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InvoiceScreen(
                        identityNumber: guestData['identityNumber'],
                      ),
                    ),
                  ),
                ),
                _buildDashCard(
                  context,
                  title: 'Destek Merkezi',
                  icon: Icons.help_outline_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FAQScreen()),
                  ),
                ),
                _buildDashCard(
                  context,
                  title: 'Talep Bildir',
                  icon: Icons.assignment_late_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SupportRequestScreen(
                        identityNumber: guestData['identityNumber'],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Alt Kurumsal İmza
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Syntax Error Hotel',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sınıf içi lokal fonksiyon yardımıyla hatasız kart oluşturma metodu
  Widget _buildDashCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEBEB), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC61111).withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: const Color(0xFFC61111)),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1D1F),
                    height: 1.2,
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

// Profil ayarları seçeneği
class ProfileSettingsScreen extends StatefulWidget {
  final Map<String, dynamic> guestData;
  const ProfileSettingsScreen({super.key, required this.guestData});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  bool _isLoading = false;
  bool _showNotify = false;
  String _notifyMsg = '';

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.guestData['phone']);
    _passwordController = TextEditingController(
      text: widget.guestData['password'],
    );
  }

  void _triggerNotify(String msg) async {
    setState(() {
      _notifyMsg = msg;
      _showNotify = true;
    });
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _showNotify = false);
  }

  void _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      await FirestoreService().updateUserInfo(
        widget.guestData['email'],
        phone: _phoneController.text,
        password: _passwordController.text,
      );
      _triggerNotify('Bilgileriniz başarıyla güncellendi.');
    } catch (e) {
      _triggerNotify('Hata: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F3D4E),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [Color(0xFF161F2A), Color(0xFF0A0F14)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 20,
                    right: 20,
                    bottom: 15,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Profil Ayarlarım',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFF1E293B),
                          child: Icon(
                            Icons.person,
                            size: 45,
                            color: Color(0xFF00E5FF),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          '${widget.guestData['name']} ${widget.guestData['surname']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.guestData['email'],
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 40),

                        _AdminTextField(
                          hintText: 'Telefon No',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                        _AdminTextField(
                          hintText: 'Yeni Şifre',
                          controller: _passwordController,
                          isPassword: true,
                          obscureText: true,
                        ),

                        const SizedBox(height: 50),
                        _isLoading
                            ? const CircularProgressIndicator(
                                color: Color(0xFF00E5FF),
                              )
                            : _NeonButton(
                                text: 'DEĞİŞİKLİKLERİ KAYDET',
                                onPressed: _updateProfile,
                              ),

                        const SizedBox(height: 30),
                        const Text(
                          'Kayıtlı Kimlik: ',
                          style: TextStyle(color: Colors.white24, fontSize: 12),
                        ),
                        Text(
                          widget.guestData['identityNumber'],
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_showNotify)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _notifyMsg,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 13. SIKÇA SORULAN SORULAR / DESTEK EKRANI (ALAPROS KURUMSAL TASARIM)
class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> faqData = [
      {
        'category': '🏨 Genel Otel Bilgileri',
        'questions': [
          {
            'q': 'Check-in ve Check-out saatleri nedir?',
            'a':
                'Giriş saati 14:00, çıkış saati ise 12:00\'dir. Müsaitlik durumuna göre erken giriş veya geç çıkış taleplerinizi uygulama üzerinden bize iletebilirsiniz.',
          },
          {
            'q': 'Otele evcil hayvan kabul ediliyor mu?',
            'a':
                'Evet, dostlarımızı seviyoruz! 5 kg altındaki evcil hayvanlarınızı ek ücret karşılığında misafir edebiliyoruz.',
          },
        ],
      },
      {
        'category': '📋 Talep Kategorileri ve Örnek İçerikler',
        'questions': [
          {
            'q': '1. Oda Temizliği ve Bakım',
            'a':
                '• Ekstra Havlu/Çarşaf: "2 adet banyo havlusu ve temiz çarşaf rica ediyorum."\n'
                '• Oda Temizliği: "Odamın saat 14:00\'e kadar temizlenmesini istiyorum."\n'
                '• Mini Bar Dolumu: "Mini barın kontrol edilerek eksiklerin tamamlanması."',
          },
          {
            'q': '2. Teknik Destek (Arıza Bildirimi)',
            'a':
                '• Klima Sorunu: "Klima soğutmuyor veya gürültülü çalışıyor."\n'
                '• İnternet Bağlantısı: "Wi-Fi bağlantısı sürekli kopuyor veya hız düşük."\n'
                '• Elektrik/Aydınlatma: "Banyodaki lamba yanmıyor."',
          },
          {
            'q': '3. Oda Servisi ve İkram',
            'a':
                '• Su Talebi: "Odaya acil içme suyu gönderilmesini istiyorum."\n'
                '• Yastık Menüsü: "Daha sert/yumuşak bir yastık talebi."',
          },
        ],
      },
      {
        'category': '🍴 Yeme & İçme',
        'questions': [
          {
            'q': 'Kahvaltı saatleri ve yeri neresidir?',
            'a':
                'Açık büfe kahvaltımız her sabah 07:00 - 10:30 saatleri arasında giriş katındaki Turkuaz Restoran\'da servis edilmektedir.',
          },
          {
            'q': 'Oda servisi 24 saat açık mı?',
            'a':
                'Evet, oda servisi menümüze "In House Room" sekmesinden ulaşabilir ve 7/24 sipariş verebilirsiniz.',
          },
        ],
      },
      {
        'category': '🚗 Ulaşım & Park',
        'questions': [
          {
            'q': 'Otelde ücretsiz otopark veya vale hizmeti var mı?',
            'a':
                'Konaklayan misafirlerimiz için kapalı otopark ve vale hizmetimiz ücretsizdir.',
          },
          {
            'q': 'Havalimanı transfer servisiniz bulunuyor mu?',
            'a':
                'Evet, uçuş detaylarınızı destek hattımıza bildirerek ücretli transfer rezervasyonu yaptırabilirsiniz.',
          },
        ],
      },
      {
        'category': '🌐 Teknoloji & Oda Hizmetleri',
        'questions': [
          {
            'q': 'Wi-Fi şifresi nedir?',
            'a':
                'Wi-Fi ağına bağlanmak için oda numaranızı ve soyadınızı kullanmanız yeterlidir. Herhangi bir şifre gerekmemektedir.',
          },
          {
            'q': 'Odamdaki klimayı/TV\'yi nasıl kullanırım?',
            'a':
                'Oda içerisindeki dijital rehbere göz atabilir veya teknik destek için "Talep Bildir" kısmından yardım isteyebilirsiniz.',
          },
        ],
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Temiz kırık beyaz zemin
      body: Column(
        children: [
          // ALAPROS KURUMSAL ÜST APPBAR
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFFC61111),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Text(
                    'Destek ve Bilgi Merkezi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // AKORDEON DESTEK LİSTESİ
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: faqData.length,
              itemBuilder: (context, index) {
                final category = faqData[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 4,
                      ),
                      child: Text(
                        category['category'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC61111),
                        ),
                      ),
                    ),
                    ...(category['questions'] as List).map(
                      (faq) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFEBEBEB),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            iconColor: const Color(0xFFC61111),
                            collapsedIconColor: const Color(0xFF1D1D1F),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFC61111,
                                ).withOpacity(0.06),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFFC61111),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              faq['q'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1D1D1F),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: Text(
                                  faq['a'],
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    height: 1.5,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// FATURA / GEÇMİŞ EKRANI (ALAPROS KURUMSAL TASARIM)
class InvoiceScreen extends StatefulWidget {
  final String identityNumber;
  const InvoiceScreen({super.key, required this.identityNumber});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final _firestoreService = FirestoreService();

  // BİLDİRİM KONTROLLERİ
  bool _showNotify = false;
  String _notifyMsg = '';

  // SİLME ONAYI KONTROLLERİ
  bool _showConfirmDialog = false;
  String? _itemToDelete;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerNotify('Ödeme Başarılı! Check-out tamamlandı.');
    });
  }

  void _triggerNotify(String msg) async {
    setState(() {
      _notifyMsg = msg;
      _showNotify = true;
    });
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _showNotify = false);
  }

  void _confirmDelete() async {
    if (_itemToDelete != null) {
      String id = _itemToDelete!;
      setState(() {
        _showConfirmDialog = false;
        _itemToDelete = null;
      });
      await _firestoreService.deleteReservation(id);
      if (!mounted) return;
      _triggerNotify('Fatura kaydı başarıyla silindi.');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Temiz kırık beyaz zemin
      body: Stack(
        children: [
          Column(
            children: [
              // ALAPROS KURUMSAL ÜST BAR YAPISI
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: const BoxDecoration(
                  color: Color(0xFFC61111),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Text(
                        'Faturalarım / Geçmiş',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // FATURA LİSTESİ
              Expanded(
                child: FutureBuilder<List<HotelReservation>>(
                  future: _firestoreService.getUserReservations(
                    widget.identityNumber,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFC61111),
                        ),
                      );
                    }

                    // Sadece Check-out yapılmış geçmiş konaklamaları listeleme mantığı (Aynı kaldı)
                    final pastRes = (snapshot.data ?? [])
                        .where((r) => r.isCheckedOut)
                        .toList();

                    if (pastRes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 60,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Geçmiş konaklama bulunamadı.',
                              style: TextStyle(
                                color: Color(0xFF1D1D1F),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: pastRes.length,
                      itemBuilder: (context, index) {
                        final res = pastRes[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFEBEBEB),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFC61111,
                                ).withOpacity(0.06),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_rounded,
                                color: Color(0xFFC61111),
                                size: 22,
                              ),
                            ),
                            title: Text(
                              'Oda ${res.roomNumber} - ${res.roomType}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D1D1F),
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Tarih: ${DateFormat('dd/MM/yyyy').format(res.checkInDate)}\nToplam: ${res.totalPrice.toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  color: Color(0xFF757575),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'ÖDENDİ',
                                  style: TextStyle(
                                    color: Color(0xFF00C853),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _itemToDelete = res.id;
                                      _showConfirmDialog = true;
                                    });
                                  },
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.grey[400],
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    InvoiceFormScreen(reservation: res),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // ONAY DIALOG PANELİ
          if (_showConfirmDialog)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Kaydı Sil',
                          style: TextStyle(
                            color: Color(0xFF1D1D1F),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Bu konaklama kaydını silmek istediğinizden emin misiniz?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  setState(() => _showConfirmDialog = false),
                              child: const Text(
                                'VAZGEÇ',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC61111),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _confirmDelete,
                              child: const Text(
                                'SİL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // TOAST BİLDİRİM PANELİ
          if (_showNotify)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _notifyMsg,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 10. PDF FATURA DETAY / BİLGİ GİRİŞ EKRANI (HİZALAMA HATALARI SIFIRLANMIŞ TAM SÜRÜM)
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen fatura adresi giriniz.'),
          backgroundColor: Color(0xFFC61111),
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    final pdf = pw.Document();

    final primaryColor = const PdfColor.fromInt(0xFF1D1D1F);
    final brandColor = const PdfColor.fromInt(0xFFC61111);
    final surfaceColor = const PdfColor.fromInt(0xFFF8FAFC);

    final List<Map<String, String>> tableItems = [];

    tableItems.add({
      'desc': '${widget.reservation.roomType} Konaklama',
      'detail': 'Oda ${widget.reservation.roomNumber}',
      'qty': '${widget.reservation.stayDays}',
      'unit': 'Gün',
      'price':
          '${(widget.reservation.totalPrice - _calculateRoomServiceTotal()).toStringAsFixed(2)} €',
    });

    for (var order in widget.reservation.roomServiceOrders) {
      tableItems.add({
        'desc': order['name'] ?? 'Oda Servisi',
        'detail': 'Servis',
        'qty': '${order['quantity'] ?? 1}',
        'unit': 'Adet',
        'price':
            '${((order['price'] ?? 0) * (order['quantity'] ?? 1)).toStringAsFixed(2)} €',
      });
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw
                    .MainAxisAlignment
                    .spaceBetween, // HATA BURADAYDI: pw. takısı eklendi
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(
                              text: 'Syntax Error ',
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 24,
                                color: primaryColor,
                              ),
                            ),
                            pw.TextSpan(
                              text: 'Hotel',
                              style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 24,
                                color: brandColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Merkez, Istanbul, Turkiye',
                        style: pw.TextStyle(font: font, fontSize: 10),
                      ),
                      pw.Text(
                        'info@syntaxhotel.com',
                        style: pw.TextStyle(font: font, fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'FATURA',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 28,
                          color: brandColor,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Tarih: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                        style: pw.TextStyle(font: font, fontSize: 10),
                      ),
                      pw.Text(
                        'Fatura No: INV-${widget.reservation.reservationCode}',
                        style: pw.TextStyle(font: font, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MÜŞTERİ BİLGİLERİ',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 11,
                        color: brandColor,
                      ),
                    ),
                    pw.Divider(color: brandColor, thickness: 1),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Ad Soyad: ${widget.reservation.name} ${widget.reservation.surname}',
                      style: pw.TextStyle(font: font, fontSize: 11),
                    ),
                    pw.Text(
                      'Kimlik/Pasaport: ${widget.reservation.identityNumber}',
                      style: pw.TextStyle(font: font, fontSize: 11),
                    ),
                    pw.Text(
                      'Adres: ${_addressController.text}',
                      style: pw.TextStyle(font: font, fontSize: 11),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: pw.BoxDecoration(
                  color: brandColor,
                  borderRadius: const pw.BorderRadius.vertical(
                    top: pw.Radius.circular(8),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'AÇIKLAMA',
                        style: pw.TextStyle(
                          font: boldFont,
                          color: PdfColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'ODA/DETAY',
                          style: pw.TextStyle(
                            font: boldFont,
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Align(
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'MİKTAR',
                          style: pw.TextStyle(
                            font: boldFont,
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Align(
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'BİRİM',
                          style: pw.TextStyle(
                            font: boldFont,
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'TUTAR',
                          style: pw.TextStyle(
                            font: boldFont,
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              ...tableItems.map(
                (item) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: PdfColors.grey200,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                          item['desc']!,
                          style: pw.TextStyle(font: font, fontSize: 10),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Align(
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            item['detail']!,
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Align(
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            item['qty']!,
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Align(
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            item['unit']!,
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Text(
                            item['price']!,
                            style: pw.TextStyle(font: boldFont, fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 24),
              pw.Row(
                mainAxisAlignment: pw
                    .MainAxisAlignment
                    .end, // HATA BURADAYDI: pw. takısı eklendi
                children: [
                  pw.SizedBox(
                    width: 180,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw
                              .MainAxisAlignment
                              .spaceBetween, // HATA BURADAYDI: pw. takısı eklendi
                          children: [
                            pw.Text(
                              'Ara Toplam:',
                              style: pw.TextStyle(font: font, fontSize: 11),
                            ),
                            pw.Text(
                              '${widget.reservation.totalPrice.toStringAsFixed(2)} €',
                              style: pw.TextStyle(font: font, fontSize: 11),
                            ),
                          ],
                        ),
                        pw.Divider(color: primaryColor),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          decoration: pw.BoxDecoration(
                            color: brandColor,
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(6),
                            ),
                          ),
                          child: pw.Row(
                            mainAxisAlignment: pw
                                .MainAxisAlignment
                                .spaceBetween, // HATA BURADAYDI: pw. takısı eklendi
                            children: [
                              pw.Text(
                                'GENEL TOPLAM',
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 11,
                                  color: PdfColors.white,
                                ),
                              ),
                              pw.Text(
                                '${widget.reservation.totalPrice.toStringAsFixed(2)} €',
                                style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 12,
                                  color: PdfColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Center(
                child: pw.Text(
                  'Bizi tercih ettiğiniz için teşekkür ederiz.',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
    setState(() => _isGenerating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFFC61111),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Text(
                    'Fatura Bilgilerini Girin',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSectionCard('Fatura Detayları', [
                    _buildFormInput(
                      hintText: 'Açık adresinizi yazınız',
                      labelText: 'Fatura Adresi (Zorunlu)',
                      controller: _addressController,
                    ),
                    const SizedBox(height: 16),
                    _buildFormInput(
                      hintText: 'Vergi Dairesi',
                      labelText: 'Vergi Dairesi (Opsiyonel)',
                      controller: _taxOfficeController,
                    ),
                    const SizedBox(height: 16),
                    _buildFormInput(
                      hintText: 'Vergi Numarası',
                      labelText: 'Vergi Numarası (Opsiyonel)',
                      controller: _taxNumberController,
                      type: TextInputType.number,
                    ),
                  ]),
                  const SizedBox(height: 30),
                  _isGenerating
                      ? const CircularProgressIndicator(
                          color: Color(0xFFC61111),
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _generateAndPrintPdf,
                            icon: const Icon(
                              Icons.picture_as_pdf_rounded,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'FATURA OLUŞTUR',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC61111),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  Text(
                    'Syntax Error Hotel',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBEBEB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1D1F),
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFormInput({
    required String hintText,
    required String labelText,
    required TextEditingController controller,
    TextInputType type = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Color(0xFF1D1D1F),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEBEBEB), width: 1.5),
          ),
          child: TextField(
            controller: controller,
            keyboardType: type,
            cursorColor: const Color(0xFFC61111),
            style: const TextStyle(
              color: Color(0xFF1D1D1F),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFFB0B0B0),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 15. KATEGORİ DETAY EKRANI (ALAPROS KURUMSAL TASARIM)
class RoomServiceCategoryScreen extends StatefulWidget {
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
  State<RoomServiceCategoryScreen> createState() =>
      _RoomServiceCategoryScreenState();
}

class _RoomServiceCategoryScreenState extends State<RoomServiceCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildAppBar(context, widget.category),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEBEBEB)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      item['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                    subtitle: Text(
                      '${item['price']} €',
                      style: const TextStyle(
                        color: Color(0xFFC61111),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC61111),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        widget.onAddToCart(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item['name']} sepete eklendi!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Text(
                        'EKLE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
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

// 16. ODA SERVİSİ SİPARİŞ SEPETİM EKRANI (ALAPROS KURUMSAL TASARIM)
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
  State<RoomServiceOrdersScreen> createState() =>
      _RoomServiceOrdersScreenState();
}

class _RoomServiceOrdersScreenState extends State<RoomServiceOrdersScreen> {
  double get _totalPrice => widget.cart.fold(
    0,
    (sum, item) =>
        sum + ((item['price'] as num).toDouble() * (item['quantity'] as int)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildAppBar(context, 'Sepetim'),
          Expanded(
            child: widget.cart.isEmpty
                ? const Center(
                    child: Text(
                      'Sepetiniz boş.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEBEBEB)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  '${item['price']} €',
                                  style: const TextStyle(
                                    color: Color(0xFFC61111),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => setState(
                                    () => widget.onUpdateQuantity(
                                      item['name'],
                                      -1,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${item['quantity']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: Color(0xFFC61111),
                                  ),
                                  onPressed: () => setState(
                                    () => widget.onUpdateQuantity(
                                      item['name'],
                                      1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (widget.cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEBEBEB))),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Toplam Tutar:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_totalPrice.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC61111),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC61111),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await FirestoreService().addRoomServiceOrder(
                            widget.reservationId,
                            _totalPrice,
                            widget.cart,
                          );
                          widget.onClearCart();
                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'SİPARİŞİ TAMAMLA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ORTAK APPBAR WIDGET'I (Tüm sayfalarda tasarım birliği için)
Widget _buildAppBar(BuildContext context, String title) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 18),
    decoration: const BoxDecoration(
      color: Color(0xFFC61111),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
    child: SafeArea(
      bottom: false,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

// 14. ODA SERVİSİ ANA EKRANI (ALAPROS KURUMSAL TASARIM)
class RoomServiceScreen extends StatefulWidget {
  final String roomNumber;
  final String reservationId;
  const RoomServiceScreen({
    super.key,
    required this.roomNumber,
    required this.reservationId,
  });

  @override
  State<RoomServiceScreen> createState() => _RoomServiceScreenState();
}

class _RoomServiceScreenState extends State<RoomServiceScreen> {
  final List<Map<String, dynamic>> _cart = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  int get _cartItemCount =>
      _cart.fold(0, (sum, item) => sum + (item['quantity'] as int));

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      final index = _cart.indexWhere(
        (element) => element['name'] == item['name'],
      );
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
        int newQty = (_cart[index]['quantity'] as int) + delta;
        if (newQty <= 0) {
          _cart.removeAt(index);
        } else {
          _cart[index]['quantity'] = newQty;
        }
      }
    });
  }

  List<Map<String, dynamic>> _getSearchResults(
    Map<String, List<Map<String, dynamic>>> menuData,
  ) {
    if (_searchQuery.isEmpty) return [];
    List<Map<String, dynamic>> results = [];
    for (var categoryItems in menuData.values) {
      for (var item in categoryItems) {
        if (item['name'].toString().toLowerCase().contains(
          _searchQuery.toLowerCase(),
        )) {
          results.add(item);
        }
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> menuData = {
      'Kahvaltı': [
        {
          'name': 'Kontinental Kahvaltı',
          'price': 15.0,
          'imageUrl':
              'https://st3.depositphotos.com/1027198/19437/i/450/depositphotos_194373632-stock-photo-continental-breakfast-coffee-tea-croissants.jpg',
        },
        {
          'name': 'Türk Kahvaltısı',
          'price': 20.0,
          'imageUrl':
              'https://cdn.shopify.com/s/files/1/1259/6441/files/kahvalti-tabagi.jpg?v=1645104466',
        },
        {
          'name': 'Omlet',
          'price': 8.0,
          'imageUrl':
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkL9Uxb-fECRSyb4I8XJXzIsK1yrsfCDJtXQ&s',
        },
        {
          'name': 'Menemen',
          'price': 10.0,
          'imageUrl':
              'https://i.tmgrup.com.tr/sfr/2026/04/16/menemen-1776333016435.jpg',
        },
      ],
      'Atıştırmalıklar ve Başlangıçlar': [
        {
          'name': 'Mercimek Çorbası',
          'price': 6.0,
          'imageUrl':
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRLvwsMnTe3X8DBGIIWw7M-rAlf19osq1CJOQ&sp',
        },
        {
          'name': 'Cheeseburger',
          'price': 14.0,
          'imageUrl':
              'https://images.themodernproper.com/production/posts/2016/ClassicCheeseBurger_8.jpg?w=960&h=960&q=82&fm=jpg&fit=crop&dm=1749310221&s=4c1a1c61f1babda90104ca8d7afed249',
        },
        {
          'name': 'Patates Kızartması',
          'price': 5.0,
          'imageUrl':
              'https://i.nefisyemektarifleri.com/2020/01/25/karbonatsiz-citir-citir-patates-kizartmasi-600x400.jpg',
        },
      ],
      'Ana Yemekler': [
        {
          'name': 'Izgara Antrikot',
          'price': 25.0,
          'imageUrl':
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTjbuhVUAislVKZQW7vcT0M3o_zPBmlJqlz9A&s',
        },
        {
          'name': 'Izgara Köfte',
          'price': 16.0,
          'imageUrl':
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTTlTyF4oUN9X2v1SAmG-yMrUodJ6uMy5tDlQ&s',
        },
      ],
      'Tatlılar ve Meyveler': [
        {
          'name': 'Sufle',
          'price': 8.0,
          'imageUrl':
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTvdsk54TV3sY8BZTWrULla0H3t68gNG0tzTg&s',
        },
        {
          'name': 'Cheesecake',
          'price': 9.0,
          'imageUrl':
              'https://assets.tmecosys.com/image/upload/t_web_rdp_recipe_584x480/img/recipe/ras/Assets/63437ceaaca08392d64a4f54abcbe225/Derivates/d34ad6dd998b08781eb1b5cebdb014f3673fcf81.jpg',
        },
      ],
      'İçecekler': [
        {
          'name': 'Türk Kahvesi',
          'price': 4.0,
          'imageUrl':
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmg_lywjJZbtnYKI6TnJwLD0b5FGUYXu3smg&s',
        },
        {
          'name': 'Ev Yapımı Limonata',
          'price': 6.5,
          'imageUrl':
              'https://i.lezzet.com.tr/images-xxlarge-recipe/ev-yapimi-konsantre-limonata-01e50b99-5890-411f-a4c2-997a71e8a5cc.jpg',
        },
      ],
    };

    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Kahvaltı',
        'icon': Icons.breakfast_dining_rounded,
        'imageUrl':
            'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?q=80&w=200',
        'items': menuData['Kahvaltı'],
      },
      {
        'title': 'Atıştırmalıklar',
        'icon': Icons.tapas_rounded,
        'imageUrl':
            'https://images.unsplash.com/photo-1541014741259-de529411b96a?q=80&w=200',
        'items': menuData['Atıştırmalıklar ve Başlangıçlar'],
      },
      {
        'title': 'Ana Yemekler',
        'icon': Icons.restaurant_rounded,
        'imageUrl':
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=200',
        'items': menuData['Ana Yemekler'],
      },
      {
        'title': 'Tatlılar',
        'icon': Icons.icecream_rounded,
        'imageUrl':
            'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?q=80&w=200',
        'items': menuData['Tatlılar ve Meyveler'],
      },
      {
        'title': 'İçecekler',
        'icon': Icons.local_bar_rounded,
        'imageUrl':
            'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?q=80&w=200',
        'items': menuData['İçecekler'],
      },
    ];

    final searchResults = _getSearchResults(menuData);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Kırık beyaz temiz zemin
      body: Column(
        children: [
          // APPBAR ALANI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFFC61111),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Text(
                    'Oda Servisi - ${widget.roomNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ARAMA INPUT ALANI
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEBEBEB), width: 1.5),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: Color(0xFF1D1D1F),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: const InputDecoration(
                  hintText: 'Yemek veya içecek arayın...',
                  hintStyle: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Color(0xFFC61111),
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // LİSTELEME ALANI (KATEGORİ VEYA ARAMA SONUCU)
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults(searchResults)
                : _buildCategoryList(categories),
          ),

          // SEPETE GİT AKSİYON ALANI (REFERANSTAKİ KIRMIZI BUTON)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomServiceOrdersScreen(
                          roomNumber: widget.roomNumber,
                          reservationId: widget.reservationId,
                          cart: _cart,
                          onUpdateQuantity: _updateQuantity,
                          onClearCart: () => setState(() => _cart.clear()),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC61111),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_basket_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'SİPARİŞE GİT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (_cartItemCount > 0) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$_cartItemCount',
                            style: const TextStyle(
                              color: Color(0xFFC61111),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<Map<String, dynamic>> categories) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Container(
          height: 85,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEBEBEB), width: 1.2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                cat['imageUrl'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: const Color(0xFFF8FAFC),
                  child: Icon(cat['icon'], color: const Color(0xFFC61111)),
                ),
              ),
            ),
            title: Text(
              cat['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D1D1F),
                fontSize: 15,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFC61111),
              size: 22,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomServiceCategoryScreen(
                    category: cat['title'],
                    roomNumber: widget.roomNumber,
                    reservationId: widget.reservationId,
                    items: cat['items'] ?? [],
                    onAddToCart: _addToCart,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text(
          'Ürün bulunamadı.',
          style: TextStyle(
            color: Color(0xFF888888),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEBEBEB)),
          ),
          child: ListTile(
            title: Text(
              item['name'],
              style: const TextStyle(
                color: Color(0xFF1D1D1F),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${item['price']} €',
              style: const TextStyle(
                color: Color(0xFFC61111),
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: Color(0xFF00C853),
                size: 24,
              ),
              onPressed: () {
                _addToCart(item);
              },
            ),
          ),
        );
      },
    );
  }
}

// IN HOUSE ROOM
// IN HOUSE ROOM - HATALARI SIFIRLANMIŞ KURUMSAL SÜRÜM
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Check-out Başlatılsın mı?',
          style: TextStyle(
            color: Color(0xFF1D1D1F),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Oda ${res.roomNumber} için toplam borcunuz: ${res.totalPrice.toStringAsFixed(2)} €\n\nÖdeme ekranına yönlendirileceksiniz.',
          style: const TextStyle(color: Color(0xFF555555), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('VAZGEÇ', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'ÖDEMEYE GİT',
              style: TextStyle(
                color: Color(0xFFC61111),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PaymentScreen(reservation: res, isCheckOut: true),
        ),
      );
    }
  }

  void _showQrPass(HotelReservation res) {
    final String qrData = jsonEncode({
      "rezervasyonKodu": res.reservationCode,
      "oda": res.roomNumber,
      "misafir": "${res.name} ${res.surname}",
      "giris": DateFormat('dd/MM/yyyy').format(res.checkInDate),
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              size: 44,
              color: Color(0xFFC61111),
            ),
            SizedBox(height: 10),
            Text(
              'Dijital Misafir Kartı',
              style: TextStyle(
                color: Color(0xFF1D1D1F),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEBEBEB)),
              ),
              child: SizedBox(
                width: 180,
                height: 180,
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Oda: ${res.roomNumber}',
              style: const TextStyle(
                color: Color(0xFFC61111),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'KAPAT',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFFC61111),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Text(
                    'Aktif Odalarım',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<HotelReservation>>(
              future: _firestoreService.getUserReservations(
                widget.identityNumber,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFC61111)),
                  );
                }

                // firstWhereOrNull hatasını düz Dart koduyla temizliyoruz:
                HotelReservation? activeRes;
                if (snapshot.hasData) {
                  for (var r in snapshot.data!) {
                    if (r.isCheckedIn && !r.isCheckedOut) {
                      activeRes = r;
                      break;
                    }
                  }
                }

                if (activeRes == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.meeting_room_outlined,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Şu an aktif bir odanız\nbulunmamaktadır.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF1D1D1F),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEBEBEB)),
                      ),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          iconColor: const Color(0xFFC61111),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC61111).withOpacity(0.06),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.meeting_room,
                              color: Color(0xFFC61111),
                              size: 22,
                            ),
                          ),
                          title: Text(
                            'Oda: ${activeRes.roomNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D1D1F),
                            ),
                          ),
                          subtitle: Text(
                            activeRes.roomType,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildActionItem(
                                    icon: Icons.qr_code_2,
                                    label: 'QR\nPass',
                                    color: const Color(0xFFE91E63),
                                    onTap: () => _showQrPass(activeRes!),
                                  ),
                                  _buildActionItem(
                                    icon: Icons.room_service,
                                    label: 'Room\nService',
                                    color: const Color(0xFFC61111),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RoomServiceScreen(
                                                roomNumber:
                                                    activeRes!.roomNumber,
                                                reservationId: activeRes.id,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildActionItem(
                                    icon: Icons.cleaning_services,
                                    label: 'House-\nkeeping',
                                    color: const Color(0xFF673AB7),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              HousekeepingScreen(
                                                roomNumber:
                                                    activeRes!.roomNumber,
                                                reservationId: activeRes.id,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  _buildActionItem(
                                    icon: Icons.exit_to_app,
                                    label: 'Check-\nout',
                                    color: const Color(0xFFFF9800),
                                    onTap: () => _checkOut(activeRes!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1D1F),
            ),
          ),
        ],
      ),
    );
  }
}

//Hizmet İkonları- butonlar
class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String imageUrl;
  final VoidCallback onTap;

  const _DashCard({
    super.key,
    required this.title,
    required this.icon,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: const Color(0xFF1E2732)),
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
                        Colors.black.withValues(alpha: 0.85),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: const Color(0xFFBFEFFF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

// REZERVASYON OLUŞTURMA EKRANI
// REZERVASYON OLUŞTURMA EKRANI (ALAPROS KURUMSAL TASARIM)
class CreateReservationScreen extends StatefulWidget {
  final Map<String, dynamic> guestData;
  const CreateReservationScreen({super.key, required this.guestData});

  @override
  State<CreateReservationScreen> createState() =>
      _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  DateTime _checkInDate = DateTime.now();
  final TextEditingController _stayDaysController = TextEditingController(
    text: '1',
  );
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

  void _updateAvailability() async {
    setState(() => _isSaving = true);
    Map<String, String> newStatus = {};
    int stayDays = int.tryParse(_stayDaysController.text) ?? 1;

    // Firebase'den oda durumlarını çekme mantığı (Aynı kaldı)
    for (int f = 1; f <= 3; f++) {
      for (int i = 1; i <= 10; i++) {
        String roomNum = "$f${i.toString().padLeft(2, '0')}";
        bool available = await FirestoreService().isRoomAvailable(
          roomNum,
          _checkInDate,
          stayDays,
        );
        newStatus[roomNum] = available ? 'BOŞ' : 'DOLU';
      }
    }

    if (mounted) {
      setState(() {
        _roomStatus = newStatus;
        _isSaving = false;
        if (_roomStatus[_selectedRoom] == 'DOLU') _selectedRoom = null;
      });
    }
  }

  String _getRoomType(String roomNum) {
    if (roomNum.endsWith('01') ||
        roomNum.endsWith('02') ||
        roomNum.endsWith('09') ||
        roomNum.endsWith('10'))
      return 'Köşe Oda';
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
      _showSuccessDialog(code);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: const Color(0xFFC61111),
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSuccessDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(
          Icons.check_circle,
          color: Color(0xFF00C853),
          size: 60,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Rezervasyon Başarılı!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text('Konfirmasyon Numaranız:'),
            Text(
              code,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC61111),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'TAMAM',
                style: TextStyle(
                  color: Color(0xFFC61111),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Hafif kırık beyaz zemin
      body: Column(
        children: [
          // ÜST BAŞLIK ALANI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFFC61111),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Text(
                    'Rezervasyon Yap',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // TARİH VE KİŞİ SEÇİMİ
                  _buildSectionCard('Konaklama Bilgileri', [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSimpleInput(
                            'Giriş Tarihi',
                            _dateController,
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSimpleInput(
                            'Gün Sayısı',
                            _stayDaysController,
                            type: TextInputType.number,
                            onChanged: (v) => _updateAvailability(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kişi Sayısı',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [1, 2, 3]
                          .map(
                            (n) => Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ChoiceChip(
                                label: Text('$n Kişi'),
                                selected: _personCount == n,
                                selectedColor: const Color(0xFFC61111),
                                labelStyle: TextStyle(
                                  color: _personCount == n
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (s) =>
                                    setState(() => _personCount = n),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ]),

                  // KAT KROKİSİ
                  _buildSectionCard('Kat Krokisi ve Oda Seçimi', [
                    if (_isSaving)
                      const Center(
                        child: LinearProgressIndicator(
                          color: Color(0xFFC61111),
                        ),
                      )
                    else
                      for (int floor = 1; floor <= 3; floor++) ...[
                        Text(
                          '$floor. Kat',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC61111),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildFloorLayout(floor),
                        const SizedBox(height: 20),
                      ],
                  ]),

                  // EKSTRA HİZMETLER VE ÖZET
                  if (_selectedRoom != null)
                    _buildSectionCard('Özet ve Onay', [
                      _buildSummaryRow(
                        'Seçili Oda:',
                        '$_selectedRoom (${_getRoomType(_selectedRoom!)})',
                        isRed: true,
                      ),
                      SwitchListTile(
                        title: const Text(
                          'Kahvaltı Dahil (+20€)',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: _includeBreakfast,
                        activeColor: const Color(0xFFC61111),
                        onChanged: (v) => setState(() => _includeBreakfast = v),
                      ),
                      SwitchListTile(
                        title: const Text(
                          'Akşam Yemeği Dahil (+40€)',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: _includeDinner,
                        activeColor: const Color(0xFFC61111),
                        onChanged: (v) => setState(() => _includeDinner = v),
                      ),
                      const Divider(),
                      _buildSummaryRow(
                        'GENEL TOPLAM:',
                        '${_calculateTotal().toStringAsFixed(2)} €',
                        isBold: true,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _confirmReservation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC61111),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'REZERVASYONU TAMAMLA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBEBEB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1D1F),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFloorLayout(int floor) {
    List<String> odds = [];
    List<String> evens = [];
    for (int i = 1; i <= 10; i++) {
      String roomNum = '$floor${i.toString().padLeft(2, '0')}';
      if (i % 2 != 0)
        odds.add(roomNum);
      else
        evens.add(roomNum);
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: odds.map((r) => _buildRoomTile(r)).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: evens.map((r) => _buildRoomTile(r)).toList(),
        ),
      ],
    );
  }

  Widget _buildRoomTile(String roomNum) {
    bool isOccupied = _roomStatus[roomNum] == 'DOLU';
    bool isSelected = _selectedRoom == roomNum;
    return Expanded(
      child: GestureDetector(
        onTap: isOccupied
            ? null
            : () => setState(() => _selectedRoom = roomNum),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 45,
          decoration: BoxDecoration(
            color: isOccupied
                ? Colors.grey[200]
                : (isSelected ? const Color(0xFFC61111) : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFC61111)
                  : (isOccupied
                        ? Colors.transparent
                        : Colors.green.withOpacity(0.5)),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            roomNum,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : (isOccupied ? Colors.grey : Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleInput(
    String label,
    TextEditingController ctrl, {
    bool readOnly = false,
    TextInputType type = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          readOnly: readOnly,
          keyboardType: type,
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isRed = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isRed ? const Color(0xFFC61111) : Colors.black,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
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
  bool _isPasswordVisible = false;

  bool _showNotify = false;
  String _notifyMsg = '';
  Color _notifyColor = const Color(0xFFC61111);

  void _triggerNotify(String msg, {bool isError = false}) async {
    setState(() {
      _notifyMsg = msg;
      _notifyColor = isError
          ? const Color(0xFFC61111)
          : const Color(0xFF00C853);
      _showNotify = true;
    });
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _showNotify = false);
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _triggerNotify('Lütfen alanları doldurun.', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      var guestData = await _firestoreService.loginGuest(
        _emailController.text,
        _passwordController.text,
      );
      if (guestData != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuestDashboardScreen(guestData: guestData),
          ),
        );
      } else {
        _triggerNotify('Hatalı e-posta veya şifre!', isError: true);
      }
    } catch (e) {
      _triggerNotify('Hata: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Column(
              children: [
                // Geri dönüş butonu içeren sade, şık üst alan
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFEBEBEB),
                              width: 1.2,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF1D1D1F),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form İçeriği
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.vpn_key_outlined,
                              size: 40,
                              color: Color(0xFFC61111),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Syntax Error Hotel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF888888),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Misafir Girişi',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1D1D1F),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Yeni Kurumsal Giriş Alanları (E-Posta)
                            _buildInputField(
                              hintText: 'Mail adresinizi giriniz',
                              labelText: 'E-Posta',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),

                            // Yeni Kurumsal Giriş Alanları (Şifre)
                            _buildInputField(
                              hintText: 'Şifrenizi giriniz',
                              labelText: 'Şifre',
                              controller: _passwordController,
                              isPassword: true,
                              obscureText: !_isPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: const Color(0xFFB0B0B0),
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () =>
                                      _isPasswordVisible = !_isPasswordVisible,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Referanstaki Kırmızı Buton
                            _isLoading
                                ? const CircularProgressIndicator(
                                    color: Color(0xFFC61111),
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFC61111,
                                        ),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Giriş Yap',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 32),

                            // Kayıt Ol Yönlendirmesi
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    color: Color(0xFF757575),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(text: 'Hesabın yok mu? '),
                                    TextSpan(
                                      text: 'Hemen Kayıt Ol',
                                      style: TextStyle(
                                        color: Color(0xFFC61111),
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bildirim (Toast/Snackbar) Tasarımı
          if (_showNotify)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _notifyColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _notifyColor == const Color(0xFFC61111)
                            ? Icons.error_outline_rounded
                            : Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _notifyMsg,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Bu sayfa için lokal kurumsal input builder'ı
  Widget _buildInputField({
    required String hintText,
    required String labelText,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 4),
          child: Text(
            labelText,
            style: const TextStyle(
              color: Color(0xFF1D1D1F),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEBEBEB), width: 1.5),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? obscureText : false,
            keyboardType: keyboardType,
            cursorColor: const Color(0xFFC61111),
            style: const TextStyle(
              color: Color(0xFF1D1D1F),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFFB0B0B0),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}

class _NeonTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onToggleVisibility;

  const _NeonTextField({
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2732).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,

        cursorColor: const Color(0xFF00E5FF),
        cursorWidth: 3,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),

        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }
}

class _NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _NeonButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF00838F), Color(0xFF006064)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// REZERVASYON SORGULAMA
// REZERVASYON SORGULAMA / LİSTELEME EKRANI (ALAPROS KURUMSAL TASARIM)
class ReservationSearchStepScreen extends StatefulWidget {
  final String identityNumber;
  const ReservationSearchStepScreen({super.key, required this.identityNumber});
  @override
  State<ReservationSearchStepScreen> createState() =>
      _ReservationSearchStepScreenState();
}

class _ReservationSearchStepScreenState
    extends State<ReservationSearchStepScreen> {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Temiz kırık beyaz arka plan
      body: Column(
        children: [
          // ALAPROS KURUMSAL ÜST BAR YAPISI
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFFC61111),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Text(
                    'Rezervasyonlarım',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // REZERVASYON LİSTESİ ALANI
          Expanded(
            child: FutureBuilder<List<HotelReservation>>(
              future: _firestoreService.getUserReservations(
                widget.identityNumber,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFC61111)),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Bir hata oluştu: ${snapshot.error}',
                      style: const TextStyle(
                        color: Color(0xFFC61111),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                // Sadece Check-in yapılmamış aktif rezervasyonları filtreleme mantığı (Aynı kaldı)
                final pendingReservations = (snapshot.data ?? [])
                    .where((res) => !res.isCheckedIn)
                    .toList();

                // Bekleyen Rezervasyon Yoksa Çıkacak Temiz Ekran
                if (pendingReservations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 70,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Bekleyen bir rezervasyonunuz\nbulunmamaktadır.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF1D1D1F),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Kurumsal Rezervasyon Kartları Listesi
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: pendingReservations.length,
                  itemBuilder: (context, index) {
                    final res = pendingReservations[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFEBEBEB),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        title: Text(
                          'Oda: ${res.roomNumber} - ${res.roomType}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D1D1F),
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Kod: ',
                                      style: TextStyle(
                                        color: Color(0xFF888888),
                                      ),
                                    ),
                                    TextSpan(
                                      text: res.reservationCode,
                                      style: const TextStyle(
                                        color: Color(0xFFC61111),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Giriş: ${DateFormat('dd/MM/yyyy').format(res.checkInDate)}',
                                style: const TextStyle(
                                  color: Color(0xFF888888),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC61111).withOpacity(0.06),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFFC61111),
                            size: 20,
                          ),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReservationDetailsScreen(reservation: res),
                          ),
                        ).then((_) => setState(() {})),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// REZERVASYON DETAYLARI VE CHECK-IN EKRANI
// REZERVASYON DETAYLARI VE CHECK-IN EKRANI (ALAPROS KURUMSAL TASARIM)
class ReservationDetailsScreen extends StatefulWidget {
  final HotelReservation reservation;
  const ReservationDetailsScreen({super.key, required this.reservation});
  @override
  State<ReservationDetailsScreen> createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  bool _isProcessing = false;
  final _firestoreService = FirestoreService();

  bool _showDeleteDialog = false;
  bool _showSuccessSnackBar = false;

  void _checkIn() async {
    setState(() => _isProcessing = true);
    try {
      await _firestoreService.completeHotelCheckIn(widget.reservation.id);
      if (!mounted) return;

      setState(() => _showSuccessSnackBar = true);

      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      setState(() => _showSuccessSnackBar = false);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: const Color(0xFFC61111),
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _delete() {
    setState(() => _showDeleteDialog = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Temiz kırık beyaz arka plan
      body: Stack(
        children: [
          Column(
            children: [
              // ALAPROS KURUMSAL ÜST BAR YAPISI
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: const BoxDecoration(
                  color: Color(0xFFC61111),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Text(
                        'Rezervasyon Detayı',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // DETAY İÇERİK ALANI
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFEBEBEB),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFC61111,
                                ).withOpacity(0.06),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.hotel_class_rounded,
                                size: 36,
                                color: Color(0xFFC61111),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.reservation.hotelName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D1D1F),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              child: Divider(
                                color: Colors.grey[200],
                                thickness: 1,
                              ),
                            ),
                            _buildDetailRow(
                              'Oda No:',
                              widget.reservation.roomNumber,
                              isHighlight: true,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Oda Tipi:',
                              widget.reservation.roomType,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Rezervasyon Kodu:',
                              widget.reservation.reservationCode,
                              isCode: true,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Giriş Tarihi:',
                              DateFormat(
                                'dd/MM/yyyy',
                              ).format(widget.reservation.checkInDate),
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Kişi Sayısı:',
                              '${widget.reservation.personCount} Kişi',
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              child: Divider(
                                color: Colors.grey[200],
                                thickness: 1,
                              ),
                            ),
                            _buildDetailRow(
                              'Toplam Tutar:',
                              '${widget.reservation.totalPrice.toStringAsFixed(2)} €',
                              isHighlight: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      // AKSİYON BUTONLARI (REFERANSTAKİ BUTON YAPILARI)
                      if (_isProcessing)
                        const CircularProgressIndicator(
                          color: Color(0xFFC61111),
                        )
                      else ...[
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC61111),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _checkIn,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login_rounded, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'CHECK-IN YAP',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFC61111),
                              side: BorderSide(
                                color: const Color(0xFFC61111).withOpacity(0.4),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            onPressed: _delete,
                            child: const Text(
                              'REZERVASYONU İPTAL ET',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // SADE, MODERN İPTAL ONAY PANELİ (DIALOG)
          if (_showDeleteDialog)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rezervasyonu İptal Et',
                          style: TextStyle(
                            color: Color(0xFF1D1D1F),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Bu rezervasyonu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
                          style: TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  setState(() => _showDeleteDialog = false),
                              child: const Text(
                                'VAZGEÇ',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC61111),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                setState(() {
                                  _showDeleteDialog = false;
                                  _isProcessing = true;
                                });
                                await _firestoreService.deleteReservation(
                                  widget.reservation.id,
                                );
                                if (!mounted) return;
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'İPTAL ET',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // BAŞARILI BİLDİRİM BARIPORTU
          if (_showSuccessSnackBar)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Check-in başarıyla tamamlandı!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
    bool isCode = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isCode
                ? const Color(0xFFC61111)
                : (isHighlight
                      ? const Color(0xFF1D1D1F)
                      : const Color(0xFF555555)),
            letterSpacing: isCode ? 1 : 0,
          ),
        ),
      ],
    );
  }
}

// 17. ÖDEME EKRANI (TAM KISITLAMALI VE KURUMSAL)
class PaymentScreen extends StatefulWidget {
  final HotelReservation reservation;
  final bool isCheckOut;

  const PaymentScreen({
    super.key,
    required this.reservation,
    this.isCheckOut = false,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cardNoController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isLoading = false;

  void _processPayment() async {
    // Sınır kontrolleri
    if (_cardNoController.text.length < 16 ||
        _expiryController.text.length < 4 ||
        _cvvController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları eksiksiz doldurun!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (widget.isCheckOut) {
        await FirestoreService().completeHotelCheckOut(widget.reservation.id);
      } else {
        await FirestoreService().completeHotelCheckIn(widget.reservation.id);
      }

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ödeme başarıyla alındı.'),
          backgroundColor: Color(0xFFC61111),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Kurumsal AppBar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFC61111),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Text(
                    'Ödeme İşlemi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEBEBEB)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Ödenecek Tutar',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.reservation.totalPrice.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC61111),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Kart No: Sadece rakam, max 16 karakter
                  _buildInput(
                    'Kart Numarası',
                    _cardNoController,
                    16,
                    '0000 0000 0000 0000',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Ay/Yıl: Sadece rakam, max 4 karakter
                      Expanded(
                        child: _buildInput(
                          'AA/YY',
                          _expiryController,
                          4,
                          '0526',
                        ),
                      ),
                      const SizedBox(width: 12),
                      // CVV: Sadece rakam, max 3 karakter
                      Expanded(
                        child: _buildInput('CVV', _cvvController, 3, '123'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC61111),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'ÖDEMEYİ TAMAMLA',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController ctrl,
    int limit,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          maxLength: limit, // Maksimum karakter sınırı
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ], // Sadece rakam
          decoration: InputDecoration(
            counterText: "", // Altındaki sayaç yazısını gizle
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// YÖNETİCİ GİRİŞ EKRANI (ALAPROS KURUMSAL TASARIM)
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _login() {
    if (_emailController.text == 'admin@admin.com' &&
        _passwordController.text == 'admin123') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hatalı e-posta veya şifre!'),
          backgroundColor: Color(0xFFC61111),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFFC61111),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Text(
                    'Yönetici Girişi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.security_rounded,
                        size: 44,
                        color: Color(0xFFC61111),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Syntax Error Hotel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildAdminField(
                        hintText: 'E-posta Adresiniz',
                        labelText: 'E-Posta',
                        controller: _emailController,
                      ),
                      const SizedBox(height: 20),
                      _buildAdminField(
                        hintText: 'Şifreniz',
                        labelText: 'Şifre',
                        isPassword: true,
                        obscureText: !_isPasswordVisible,
                        controller: _passwordController,
                        onToggleVisibility: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC61111),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'SİSTEME GİRİŞ YAP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminField({
    required String hintText,
    required String labelText,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 4),
          child: Text(
            labelText,
            style: const TextStyle(
              color: Color(0xFF1D1D1F),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEBEBEB), width: 1.5),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? obscureText : false,
            cursorColor: const Color(0xFFC61111),
            style: const TextStyle(
              color: Color(0xFF1D1D1F),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFFB0B0B0),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// Admin Girişi İçin Özel TextField Widget'ı
class _AdminTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final bool obscureText;
  final TextInputType keyboardType;
  final VoidCallback? onToggleVisibility;

  const _AdminTextField({
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2732).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        keyboardType: keyboardType,
        cursorColor: const Color(0xFF00E5FF),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }
}

// 12. HOUSEKEEPING EKRANI (GERİ BUTONLU VE BİLDİRİM TEYİTLİ)
class HousekeepingScreen extends StatefulWidget {
  final String roomNumber;
  final String reservationId;

  const HousekeepingScreen({
    super.key,
    required this.roomNumber,
    required this.reservationId,
  });

  @override
  State<HousekeepingScreen> createState() => _HousekeepingScreenState();
}

class _HousekeepingScreenState extends State<HousekeepingScreen> {
  // Geri bildirim mekanizması için metot
  void _sendRequest(String itemName) async {
    try {
      // İstek gönderimi
      await FirestoreService().addHousekeepingRequest(
        widget.reservationId,
        itemName,
      );

      // Başarılı bildirim
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$itemName talebiniz alındı, görevli arkadaşlarımıza iletildi.',
          ),
          backgroundColor: const Color(0xFFC61111),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Hata durumunda bildirim
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bir hata oluştu, lütfen tekrar deneyin.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, String>>> supplies = const {
      'Tekstil ve Uyku': [
        {
          'name': 'Ekstra Yastık',
          'img': 'https://www.idas.com.tr/Upload/Fluffy-yastik_n.jpg',
        },
        {
          'name': 'Battaniye',
          'img':
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSAwMEBq0K1RQZuFFEmFs0G0CHwF-N_UI-DnA&s',
        },
        {
          'name': 'Temiz Havlu',
          'img':
              'https://dantela.com.tr/cdn/shop/files/pamuk-50x90cm-6-li-karisik-el-havlu-seti-kod-9090-1982_800x.jpg?v=1715217879',
        },
      ],
      'Bakım ve Hijyen': [
        {
          'name': 'Şampuan & Sabun',
          'img':
              'https://img.kwcdn.com/product/Fancyalgo/VirtualModelMatting/098664a9e3848cbf009ed9c2c543840f.jpg?imageMogr2/auto-orient%7CimageView2/2/w/800/q/70/format/webp',
        },
        {
          'name': 'Diş Seti',
          'img':
              'https://cdn.dsmcdn.com/ty1560/product/media/images/ty1560/prod/QC/20240920/10/54715ae4-e735-3953-a3cd-99838601bb44/1_org_zoom.jpg',
        },
      ],
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Kurumsal AppBar (Geri Butonu Eklendi)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFC61111),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const Text(
                    'Temizlik & İhtiyaç',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: supplies.entries.map((category) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        category.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC61111),
                        ),
                      ),
                    ),
                    ...category.value.map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEBEBEB)),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item['img']!,
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            item['name']!,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFFC61111),
                            ),
                            onPressed: () => _sendRequest(item['name']!),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// 19. YÖNETİCİ PANELİ (ALAPROS KURUMSAL TASARIM)
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Resepsiyon Paneli',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFC61111),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Özet Kartları
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildStatCard('Doluluk', '78%', Icons.meeting_room_rounded),
                const SizedBox(width: 16),
                _buildStatCard('Talep', '12', Icons.assignment_late_rounded),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Canlı Oda Durum Haritası',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 20,
              itemBuilder: (context, index) {
                // Burada veritabanından gelen gerçek oda durumunu kullanmalısın
                bool isOccupied = index % 3 == 0;
                return Container(
                  decoration: BoxDecoration(
                    color: isOccupied ? const Color(0xFFC61111) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEBEBEB)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${101 + index}',
                    style: TextStyle(
                      color: isOccupied ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEBEBEB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFC61111)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
