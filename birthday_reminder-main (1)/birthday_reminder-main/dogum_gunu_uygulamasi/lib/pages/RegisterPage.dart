import 'package:dogum_gunu_uygulamasi/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatlama işlemleri için
import 'package:firebase_auth/firebase_auth.dart'; // Firebase kimlik doğrulama işlemleri için
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore veritabanı işlemleri için
import 'package:shared_preferences/shared_preferences.dart'; // Yerel cihazda veri saklamak için
import 'package:supabase_flutter/supabase_flutter.dart'
    as supa; // Supabase'i kullanmak için

import '../custom_app_barr.dart'; // Özel app bar bileşeni

// Kayıt sayfası Stateful çünkü kullanıcı girişleri ve etkileşimler var
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Firebase ve Supabase istemcileri
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final supa.SupabaseClient _supabaseClient = supa.Supabase.instance.client;

  // Kullanıcı girişleri için controller'lar
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();

  DateTime? _selectedBirthdate; // Seçilen doğum tarihi

  // Takvim açarak doğum tarihi seçimi
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthdate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthdate) {
      setState(() {
        _selectedBirthdate = picked;
        _birthdateController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(picked); // Metin alanına yaz
      });
    }
  }

  // Kullanıcıyı kaydeden fonksiyon
  Future<void> _registerUser() async {
    // Gerekli alanların dolu olup olmadığını kontrol et
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _surnameController.text.isEmpty ||
        _birthPlaceController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _selectedBirthdate == null) {
      _showErrorDialog('Lütfen tüm alanları doldurun.');
      return;
    }

    try {
      // Firebase Authentication ile kullanıcı oluştur
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      final User? user = userCredential.user;

      if (user != null) {
        // Ek kullanıcı bilgilerini kaydet
        await _saveUserProfile(user.uid, user.email);

        // Kayıttan sonra anasayfaya yönlendir
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
          arguments: {'username': _nameController.text},
        );
      }
    } on FirebaseAuthException catch (e) {
      // Firebase kaynaklı hata
      print("Firebase Auth Kayıt Hatası: ${e.code} - ${e.message}");
      _showErrorDialog("Kayıt başarısız: ${e.message}");
    } catch (e) {
      // Diğer hatalar
      print("Beklenmedik Kayıt Hatası: $e");
      _showErrorDialog("Kayıt sırasında beklenmedik bir hata oluştu.");
    }
  }

  // Firestore, Supabase ve SharedPreferences'a kullanıcı bilgisini kaydeder
  Future<void> _saveUserProfile(String uid, String? email) async {
    try {
      // Firestore'a yaz
      await _firestore.collection('users').doc(uid).set({
        'name': _nameController.text,
        'surname': _surnameController.text,
        'email': email,
        'birthdate': _selectedBirthdate?.toIso8601String(),
        'birthPlace': _birthPlaceController.text,
        'city': _cityController.text,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Supabase'e yaz (profiles tablosuna)
      await _supabaseClient.from('profiles').insert({
        'uid': uid,
        'name': _nameController.text,
        'surname': _surnameController.text,
        'email': email,
        'birthdate': _selectedBirthdate?.toIso8601String(),
        'birth_place': _birthPlaceController.text,
        'city': _cityController.text,
      });

      // SharedPreferences ile cihazda sakla
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', uid);
      await prefs.setString('email', email ?? '');
      await prefs.setString('name', _nameController.text);
      await prefs.setString('surname', _surnameController.text);

      print("Kullanıcı bilgileri başarıyla kaydedildi.");
    } catch (e) {
      print("Kullanıcı bilgileri kaydetme hatası: $e");
      _showErrorDialog("Bilgiler kaydedilirken bir hata oluştu.");
    }
  }

  // Hata durumunda kullanıcıya gösterilen dialog
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // Arka planın appbar'ın arkasına uzanmasını sağlar
      appBar: const CustomAppBar(
        title: 'Kayıt Ol',
        backgroundColor: Colors.deepPurple,
      ),
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
                      'Yeni Hesap Oluştur',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Kullanıcı giriş alanları
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'E-posta'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Şifre'),
                      obscureText: true,
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'İsim'),
                    ),
                    TextField(
                      controller: _surnameController,
                      decoration: const InputDecoration(labelText: 'Soyisim'),
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
                    // Kayıt butonu
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
                      onPressed: _registerUser,
                      child: const Text(
                        'Kaydol',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Zaten hesabı olanlar için yönlendirme
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Zaten hesabın var mı? Giriş Yap',
                        style: TextStyle(color: Colors.deepPurple),
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

  // Sayfa kapatılırken controller'ları serbest bırak
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _birthPlaceController.dispose();
    _cityController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }
}
