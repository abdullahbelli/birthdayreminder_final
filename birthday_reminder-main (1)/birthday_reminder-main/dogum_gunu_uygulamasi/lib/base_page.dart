import 'package:flutter/material.dart';
import 'custom_app_barr.dart';
import 'pages/Drawer.dart';

// Sayfa düzeni için temel bir şablon oluşturan StatelessWidget sınıfı
class BasePage extends StatelessWidget {
  final String title; // Sayfanın AppBar başlığı
  final Widget body; // Sayfanın içeriği (ana gövde)
  final Color? appBarColor; // AppBar'ın arka plan rengi (isteğe bağlı)

  const BasePage({
    super.key,
    required this.title,
    required this.body,
    this.appBarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Özel AppBar bileşeni kullanılıyor
      appBar: CustomAppBar(title: title, backgroundColor: appBarColor),
      // Sabit bir drawer menüsü tanımlanıyor (kullanıcı adı şimdilik boş)
      drawer: const AppDrawer(username: ""),
      // Sayfanın ana gövdesi olarak dışarıdan gelen widget yerleştiriliyor
      body: body,
    );
  }
}
