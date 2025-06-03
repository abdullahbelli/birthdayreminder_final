// Gerekli paketlerin içe aktarılması
import 'package:dogum_gunu_uygulamasi/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'Drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Ana sayfa widget'ı
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<String>
  _usernameFuture; // Kullanıcı adını tutacak gelecekteki değer
  List<kisi> dogumGunleri = []; // Doğum günü listesi
  final SupabaseClient _supabaseClient =
      Supabase.instance.client; // Supabase istemcisi
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Firebase kimlik doğrulama nesnesi
  String? _currentUserId; // Şu anki kullanıcı ID'si

  @override
  void initState() {
    super.initState();
    _usernameFuture = _loadUsername(); // Kullanıcı adını yükle
    _loadUserAndFetchBirthdays(); // Kullanıcıyı yükle ve doğum günlerini getir
  }

  // SharedPreferences'tan kullanıcı adını yükler
  Future<String> _loadUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? 'Misafir';
  }

  // Mevcut kullanıcıyı yükler ve doğum günlerini getirir
  Future<void> _loadUserAndFetchBirthdays() async {
    _currentUserId =
        _auth.currentUser?.uid; // Firebase üzerinden kullanıcı UID'si alınır
    if (_currentUserId != null) {
      await _fetchBirthdaysFromSupabase(); // Doğum günleri veritabanından çekilir
    } else {
      setState(() {
        dogumGunleri = []; // Kullanıcı yoksa liste temizlenir
      });
      _showErrorDialog("Oturum açmış bir kullanıcı bulunamadı.");
    }
  }

  // Supabase üzerinden kullanıcıya ait doğum günü kayıtlarını getirir
  Future<void> _fetchBirthdaysFromSupabase() async {
    if (_currentUserId == null) return;

    try {
      final List<Map<String, dynamic>> data = await _supabaseClient
          .from('birthdays')
          .select()
          .eq(
            'user_uid',
            _currentUserId!,
          ); // Sadece kullanıcıya ait verileri al

      setState(() {
        // Gelen veriyi kisi nesnelerine dönüştür ve listeye ata
        dogumGunleri =
            data
                .map((e) => kisi(isim: e['name'], dogumgunu: e['birthdate']))
                .toList();
      });
    } on PostgrestException catch (e) {
      print('Supabase PostgrestException: ${e.message}');
      _showErrorDialog("Veritabanı hatası: ${e.message}");
    } catch (e) {
      print('Doğum Günü Çekme Hatası: $e');
      _showErrorDialog(
        "Doğum günleri yüklenirken beklenmedik bir hata oluştu: $e",
      );
    }
  }

  // Supabase veritabanından doğum günü silme işlemi
  Future<void> _deleteBirthday(String birthdayName, String birthdayDate) async {
    if (_currentUserId == null) {
      _showErrorDialog("Silme işlemi için oturum açmış kullanıcı bulunamadı.");
      return;
    }

    try {
      await _supabaseClient
          .from('birthdays')
          .delete()
          .eq('user_uid', _currentUserId!)
          .eq('name', birthdayName)
          .eq('birthdate', birthdayDate); // Belirtilen veriyi sil

      print('Doğum günü başarıyla silindi.');
      await _fetchBirthdaysFromSupabase(); // Listeyi güncelle
      _showSuccessDialog(
        'Silme İşlemi Başarılı',
        '$birthdayName başarıyla silindi.',
      );
    } on PostgrestException catch (e) {
      print('Supabase PostgrestException (Silme): ${e.message}');
      _showErrorDialog(
        "Silme işlemi sırasında veritabanı hatası: ${e.message}",
      );
    } catch (e) {
      print('Silme Hatası: $e');
      _showErrorDialog(
        "Silme işlemi sırasında beklenmedik bir hata oluştu: $e",
      );
    }
  }

  // Hata gösteren alert dialog
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

  // Başarılı işlem sonrası gösterilen dialog
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
                  Navigator.pop(context);
                },
                child: const Text('Tamam'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: const Text('Doğum Günü Listesi'),
      ),
      drawer: FutureBuilder<String>(
        future: _usernameFuture,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Drawer(); // Yüklenirken boş drawer göster
          } else if (snapshot.hasError) {
            return Drawer(
              child: Center(child: Text('Hata: ${snapshot.error}')),
            );
          } else {
            return AppDrawer(
              username: snapshot.data ?? 'Misafir',
            ); // Drawer içinde kullanıcı adı göster
          }
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover, // Arka plan görseli
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<String>(
            future: _usernameFuture,
            builder: (
              BuildContext context,
              AsyncSnapshot<String> usernameSnapshot,
            ) {
              final String currentUsername = usernameSnapshot.data ?? 'Misafir';
              return dogumGunleri.isEmpty
                  ? Center(
                    // Doğum günü listesi boşsa gösterilen ekran
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24.0),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Görüntülenecek Bir Doğum Günü Yok.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                            ),
                            onPressed: () async {
                              // Doğum günü ekleme sayfasına yönlendirir
                              await Navigator.pushNamed(
                                context,
                                AppRoutes.ekle,
                                arguments: {'username': currentUsername},
                              );
                              _loadUserAndFetchBirthdays(); // Yeni verileri tekrar yükler
                            },
                            child: const Text(
                              'Doğum Günü Ekle',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: dogumGunleri.length,
                    itemBuilder: (context, index) {
                      final kisiItem = dogumGunleri[index];
                      return Card(
                        color: Colors.white.withOpacity(0.85),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 6,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(kisiItem.isim), // Kişi adı
                          subtitle: Text(kisiItem.dogumgunu), // Doğum tarihi
                          trailing: IconButton(
                            icon: const Icon(Icons.remove, color: Colors.red),
                            onPressed: () {
                              _deleteBirthday(
                                kisiItem.isim,
                                kisiItem.dogumgunu,
                              ); // Silme işlemi
                            },
                          ),
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

// Basit kişi sınıfı (isim ve doğum günü bilgisi tutar)
class kisi {
  final String isim;
  final String dogumgunu;

  kisi({required this.isim, required this.dogumgunu});
}
