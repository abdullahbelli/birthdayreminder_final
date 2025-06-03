import 'package:dogum_gunu_uygulamasi/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için
import 'Drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Doğum günü ekleme sayfası - kullanıcı adı parametre olarak alınır
class DogumGunuEkle extends StatefulWidget {
  final String username;
  const DogumGunuEkle({super.key, required this.username});

  @override
  State<DogumGunuEkle> createState() => _DogumgunuekleState();
}

class _DogumgunuekleState extends State<DogumGunuEkle> {
  DateTime secilenTarih = DateTime.now(); // Varsayılan tarih bugünün tarihi
  final TextEditingController nameController =
      TextEditingController(); // İsim için controller
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentUserId; // Mevcut kullanıcının UID'si

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Kullanıcı UID'sini yükle
  }

  // Kullanıcı UID'sini yükle fonksiyonu
  Future<void> _loadUserId() async {
    _currentUserId = _auth.currentUser?.uid;
    if (_currentUserId == null) {
      _showErrorDialog(
        "Doğum günü eklemek için oturum açmış bir kullanıcı bulunamadı.",
      );
    }
  }

  // Tarih seçme fonksiyonu
  tarihSec() async {
    var secilen = await showDatePicker(
      context: context,
      initialDate: secilenTarih,
      firstDate: DateTime(1923), // En erken seçilebilir tarih
      lastDate: DateTime(2030), // En geç seçilebilir tarih
    );

    if (secilen != null) {
      setState(() {
        secilenTarih = secilen; // Seçilen tarih state'e atanır
      });
    }
  }

  Future<void> _ensureUserProfileExists() async {
    final existing =
        await _supabaseClient
            .from('profiles')
            .select()
            .eq('uid', _currentUserId!)
            .maybeSingle();

    if (existing == null) {
      await _supabaseClient.from('profiles').insert({
        'uid': _currentUserId,
        'email': _supabaseClient.auth.currentUser?.email ?? '',
        'name': '', // Varsa ad-soyad verisi buraya
      });
    }
  }

  // Doğum gününü Supabase'e kaydetme fonksiyonu
  Future<void> _saveBirthdayToSupabase() async {
    if (_currentUserId == null) {
      _showErrorDialog(
        "Doğum günü eklemek için oturum açmış bir kullanıcı bulunamadı.",
      );
      return;
    }
    if (nameController.text.isEmpty) {
      _showErrorDialog("Lütfen isim - soyisim giriniz.");
      return;
    }

    try {
      await _ensureUserProfileExists();

      await _supabaseClient.from('birthdays').insert([
        {
          'user_uid': _currentUserId,
          'name': nameController.text,
          'birthdate': DateFormat('yyyy-MM-dd').format(secilenTarih),
        },
      ]);

      _showSuccessDialog(
        'Kayıt Başarılı',
        '${nameController.text} başarıyla kaydedildi.',
      );
    } on PostgrestException catch (e) {
      print('Supabase PostgrestException: ${e.message}');
      _showErrorDialog("Veritabanı hatası: ${e.message}");
    } catch (e) {
      print('Doğum Günü Kaydetme Hatası: $e');
      _showErrorDialog("Kaydetme sırasında beklenmedik bir hata oluştu: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hata'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tamam'),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Uyarıyı kapat
                  // Doğum günü eklendikten sonra ana sayfaya geri dön
                  Navigator.pushNamed(
                    context,
                    AppRoutes.home,
                    arguments: {'username': widget.username},
                  );
                },
                child: const Text('Tamam'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Seçilen tarih Türkçe formatlanır
    var formatlanmisTarih = DateFormat('dd/MM/yyyy', 'tr').format(secilenTarih);

    return Scaffold(
      extendBodyBehindAppBar: true, // Arka plan AppBar'ın arkasına uzar
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: const Text('Doğum Günü Ekle'),
      ),
      drawer: AppDrawer(
        username: widget.username, // widget.username kullanın
      ), // Drawer'a kullanıcı adı gönderilir
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"), // Arka plan görseli
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              // İçerik kaydırılabilir
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // İsim soyisim giriş alanı
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'İsim - Soyisim',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Seçilen tarihi gösteren metin
                    Text(formatlanmisTarih),

                    // Tarih seç butonu
                    ElevatedButton(
                      onPressed: tarihSec,
                      child: const Text('Tarih Seç'),
                    ),
                    const SizedBox(height: 10),

                    // Kaydet butonu
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      onPressed:
                          _saveBirthdayToSupabase, // Supabase'e kaydetme fonksiyonunu çağır
                      child: const Text(
                        'Kaydet',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
