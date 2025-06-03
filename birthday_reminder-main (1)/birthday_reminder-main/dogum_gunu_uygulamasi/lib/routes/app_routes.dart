import 'package:dogum_gunu_uygulamasi/pages/DogumGunuEkle.dart';
import 'package:dogum_gunu_uygulamasi/pages/HomePage.dart';
import 'package:dogum_gunu_uygulamasi/pages/LoginPage.dart';
import 'package:dogum_gunu_uygulamasi/pages/profile_page.dart';
import 'package:flutter/widgets.dart';
import 'package:dogum_gunu_uygulamasi/pages/RegisterPage.dart';

class AppRoutes {
  // Rota isimleri
  static const String login = '/';
  static const String home = '/home';
  static const String ekle = '/add';
  static const String profil = '/profil';
  static const String register = '/register';

  // Rotaları bir Map olarak döndürüyoruz
  static Map<String, Widget Function(BuildContext)> get routes => {
    login: (context) => const LoginPage(), // Giriş sayfasına yönlendirme
    home: (context) => const HomePage(), // Ana sayfaya yönlendirme
    profil: (context) => const ProfilePage(),
    register: (context) => const RegisterPage(), // Kayıt sayfasına yönlendirme
    ekle: (context) {
      // Rota argümanlarını alıyoruz
      final args = ModalRoute.of(context)?.settings.arguments as Map?;

      final String username = args?['username'] ?? 'Misafir';

      // Kullanıcı adıyla birlikte DoğumGünüEkle sayfasına yönlendiriyoruz
      return DogumGunuEkle(username: username);
    },
  };
}
