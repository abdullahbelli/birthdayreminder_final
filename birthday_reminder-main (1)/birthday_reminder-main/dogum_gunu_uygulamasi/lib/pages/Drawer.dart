import 'package:dogum_gunu_uygulamasi/routes/app_routes.dart';
import 'package:flutter/material.dart';

// Drawer bileşeni, kullanıcı adını parametre olarak alır
class AppDrawer extends StatefulWidget {
  final String username;
  const AppDrawer({super.key, required this.username});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // Uygulama için kullanılacak logo URL’si
  final String imageURL = 'https://img.logo.dev/birthdate.co';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // Drawer’ın üst kısmında gösterilen başlık kısmı
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ), // Arka plan rengi
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kullanıcıya ait profil resmi olarak logo gösteriliyor
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.username.isNotEmpty
                          ? widget.username[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  // Kullanıcıya özel karşılama mesajı
                  Text(
                    widget.username.isNotEmpty
                        ? 'Hoşgeldiniz ${widget.username}' // Eğer kullanıcı adı boş değilse
                        : 'Hoşgeldiniz', // Boşsa sadece Hoşgeldiniz
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          ListTile(
            title: const Text('Profil Bilgileri'),
            onTap: () {
              // Ana sayfaya yönlendirir
              Navigator.pushNamed(
                context,
                AppRoutes.profil,
                arguments: {
                  'username': widget.username,
                }, // Kullanıcı adı aktarılır
              );
            },
          ),

          // Drawer menüsünde "Doğum Günü Listesi" seçeneği
          ListTile(
            title: const Text('Doğum Günü Listesi'),
            onTap: () {
              // Ana sayfaya yönlendirir
              Navigator.pushNamed(
                context,
                AppRoutes.home,
                arguments: {
                  'username': widget.username,
                }, // Kullanıcı adı aktarılır
              );
            },
          ),

          // Drawer menüsünde "Doğum Günü Ekle" seçeneği
          ListTile(
            title: const Text('Doğum Günü Ekle'),
            onTap: () {
              // Doğum günü ekleme sayfasına yönlendirir
              Navigator.pushNamed(
                context,
                AppRoutes.ekle,
                arguments: {
                  'username': widget.username,
                }, // Kullanıcı adı aktarılır
              );
            },
          ),

          // Drawer menüsünde "Çıkış Yap" seçeneği
          ListTile(
            title: const Text("Çıkış Yap"),
            onTap: () {
              // Kullanıcı çıkış yaptığında login sayfasına yönlendirilir
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                arguments: {
                  'username': widget.username,
                }, // Kullanıcı adı tekrar aktarılır
                (Route<dynamic> route) =>
                    false, // Önceki sayfalar tamamen temizlenir
              );
            },
          ),
        ],
      ),
    );
  }
}
