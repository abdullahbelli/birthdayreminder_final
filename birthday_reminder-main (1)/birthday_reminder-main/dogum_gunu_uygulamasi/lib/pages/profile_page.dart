import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih biçimlendirme için
import 'package:firebase_auth/firebase_auth.dart'; // Firebase kimlik doğrulama
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore veritabanı
import 'package:supabase_flutter/supabase_flutter.dart'
    as supa; // Supabase entegrasyonu
import '../custom_app_barr.dart'; // Özelleştirilmiş AppBar

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Firebase ve Supabase servisleri
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final supa.SupabaseClient _supabaseClient = supa.Supabase.instance.client;

  // Form alanları için kontrolörler
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  // Doğum tarihi için DateTime nesnesi
  DateTime? _selectedBirthdate;

  // Sayfanın yüklenip yüklenmediğini takip etmek için
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Sayfa açıldığında kullanıcı profilini yükle
  }

  /// Firestore'dan kullanıcı bilgilerini çek
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    User? user = _auth.currentUser;
    if (user == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _surnameController.text = data['surname'] ?? '';
        _emailController.text = data['email'] ?? '';
        _birthPlaceController.text = data['birthPlace'] ?? '';
        _cityController.text = data['city'] ?? '';

        if (data['birthdate'] != null) {
          _selectedBirthdate = DateTime.tryParse(data['birthdate']);
          if (_selectedBirthdate != null) {
            _birthdateController.text = DateFormat(
              'dd/MM/yyyy',
            ).format(_selectedBirthdate!);
          }
        }
      }
    } catch (e, st) {
      debugPrint('Profil yüklenirken hata: $e\n$st');
      _showErrorDialog('Profil bilgileri yüklenirken hata oluştu.');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Tarih seçici açar ve seçilen tarihi gösterir
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthdate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthdate) {
      setState(() {
        _selectedBirthdate = picked;
        _birthdateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  /// Kullanıcı profilini hem Firestore hem de Supabase'te günceller
  Future<void> _updateUserProfile() async {
    if (_nameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _birthPlaceController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _selectedBirthdate == null) {
      _showErrorDialog('Lütfen tüm alanları doldurun.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showErrorDialog('Kullanıcı bulunamadı.');
        return;
      }

      // Firestore'da güncelle
      await _firestore.collection('users').doc(user.uid).update({
        'name': _nameController.text,
        'surname': _surnameController.text,
        'email': _emailController.text,
        'birthPlace': _birthPlaceController.text,
        'city': _cityController.text,
        'birthdate': _selectedBirthdate!.toIso8601String(),
      });

      // Supabase'te güncelle (uid sütununa göre eşleşen kayıt)
      final supabaseResponse = await _supabaseClient
          .from('profiles')
          .update({
            'name': _nameController.text,
            'surname': _surnameController.text,
            'email': _emailController.text,
            'birth_place': _birthPlaceController.text,
            'city': _cityController.text,
            'birthdate': _selectedBirthdate!.toIso8601String(),
          })
          .eq('uid', user.uid);

      if (supabaseResponse == null) {
        debugPrint('Supabase update returned null');
      }

      _showInfoDialog('Profil başarıyla güncellendi.');
    } catch (e, st) {
      debugPrint('Profil güncellenirken hata: $e\n$st');
      _showErrorDialog('Profil güncellenirken hata oluştu.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Hata mesajı gösterir
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

  /// Bilgilendirme mesajı gösterir
  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Bilgi'),
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

  /// Kontrolörleri temizle
  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _birthPlaceController.dispose();
    _cityController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  /// Arayüz
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        title: 'Profilim',
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                    child: SingleChildScrollView(
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
                            const Text(
                              'Profil Bilgilerin',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // E-posta alanı (readonly)
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'E-posta',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              readOnly: true,
                            ),
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'İsim',
                              ),
                            ),
                            TextField(
                              controller: _surnameController,
                              decoration: const InputDecoration(
                                labelText: 'Soyisim',
                              ),
                            ),
                            TextField(
                              controller: _birthPlaceController,
                              decoration: const InputDecoration(
                                labelText: 'Doğum Yeri',
                              ),
                            ),
                            TextField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'Yaşadığı İl',
                              ),
                            ),
                            // Doğum tarihi alanı (datepicker açılır)
                            TextField(
                              controller: _birthdateController,
                              decoration: const InputDecoration(
                                labelText: 'Doğum Tarihi',
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _updateUserProfile,
                              child: const Text(
                                'Güncelle',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
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
