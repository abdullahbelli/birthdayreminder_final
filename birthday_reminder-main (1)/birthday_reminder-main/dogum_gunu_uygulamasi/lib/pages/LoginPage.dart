// Gerekli paketlerin içe aktarılması
import 'package:dogum_gunu_uygulamasi/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../custom_app_barr.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Giriş sayfası Stateful widget
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Firebase, Google ve Firestore servisleri tanımlanıyor
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // E-posta ve şifre input kontrolcüleri
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Kullanıcı bilgilerini SharedPreferences ve Firestore'a kaydeder
  Future<void> _saveUserInfo(User user, {bool savePassword = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Temel kullanıcı bilgilerini local olarak kaydet
    await prefs.setString('uid', user.uid);
    await prefs.setString('email', user.email ?? '');
    await prefs.setString('name', user.displayName ?? '');
    await prefs.setString('surname', '');

    // Şifre saklanacaksa secure storage'a yaz
    if (savePassword) {
      await _secureStorage.write(
        key: 'password',
        value: _passwordController.text,
      );
    }

    // Kullanıcı Firestore'da yoksa, yeni belge oluştur
    final docRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      await docRef.set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'surname': '',
        'birthdate': null,
        'birthPlace': '',
        'city': '',
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  // Hata durumunda kullanıcıya gösterilecek diyalog kutusu
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
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

  // Google ile giriş işlemleri
  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;

      if (googleAuth == null) throw Exception("Google yetkilendirme başarısız");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await _saveUserInfo(user);
        _navigateToHome(user);
      }
    } catch (e) {
      _showErrorDialog("Google ile giriş başarısız: $e");
    }
  }

  // GitHub ile giriş işlemleri (sadece web desteği var)
  Future<void> _signInWithGitHub() async {
    if (!kIsWeb) {
      _showErrorDialog("GitHub ile giriş sadece web üzerinde destekleniyor.");
      return;
    }

    try {
      final githubProvider = GithubAuthProvider();
      final userCredential = await _auth.signInWithPopup(githubProvider);
      final user = userCredential.user;

      if (user != null) {
        await _saveUserInfo(user);
        _navigateToHome(user);
      }
    } catch (e) {
      _showErrorDialog("GitHub ile giriş başarısız: $e");
    }
  }

  // E-posta ve şifre ile giriş işlemleri
  Future<void> _signInWithEmailAndPassword() async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final user = userCredential.user;

      if (user != null) {
        await _saveUserInfo(user, savePassword: true);
        _navigateToHome(user);
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog("Giriş başarısız: ${e.message}");
    } catch (e) {
      _showErrorDialog("Giriş sırasında beklenmedik bir hata oluştu.");
    }
  }

  // Giriş başarılıysa anasayfaya yönlendirme
  void _navigateToHome(User user) {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
      arguments: {'username': user.displayName ?? user.email ?? 'User'},
    );
  }

  // Bellek sızıntılarını önlemek için controller'ları temizle
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Arayüz (UI) bileşenleri
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        title: 'Giriş Yap',
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
                      'Hesabına Giriş Yap',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // E-posta girişi
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'E-posta'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    // Şifre girişi
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Şifre'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    // E-posta/şifre ile giriş butonu
                    ElevatedButton(
                      onPressed: _signInWithEmailAndPassword,
                      style: _buttonStyle(Colors.deepPurple),
                      child: const Text(
                        'Giriş Yap',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // GitHub ile giriş butonu
                    ElevatedButton.icon(
                      onPressed: _signInWithGitHub,
                      style: _buttonStyle(Colors.blue),
                      icon: const FaIcon(
                        FontAwesomeIcons.github,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'GitHub ile Giriş Yap',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Google ile giriş butonu
                    ElevatedButton.icon(
                      onPressed: _signInWithGoogle,
                      style: _buttonStyle(Colors.redAccent),
                      icon: const FaIcon(
                        FontAwesomeIcons.google,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Google ile Giriş Yap',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Kayıt sayfasına yönlendirme linki
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: const Text(
                        'Hesabın yok mu? Kayıt Ol',
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

  // Buton stilini özelleştiren yardımcı fonksiyon
  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
