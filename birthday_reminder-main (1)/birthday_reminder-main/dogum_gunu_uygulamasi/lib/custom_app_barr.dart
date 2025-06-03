import 'package:flutter/material.dart';

/// Özel bir AppBar widget'ı tanımlayan sınıf.

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // AppBar başlığı
  final List<Widget>?
  actions; // AppBar'da sağ tarafta yer alacak widget listesi
  final Color? backgroundColor; // AppBar arka plan rengi

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.backgroundColor,
  });

  /// AppBar yüksekliği belirlenir.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// AppBar widget'ı oluşturuluyor.
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: actions, // Sağ taraftaki aksiyon ikonları
      backgroundColor: backgroundColor, // Arka plan rengi
      iconTheme: const IconThemeData(
        color: Colors.white,
      ), // Menü ikonlarının rengi
      titleTextStyle: const TextStyle(
        color: Colors.white, // Başlık metni rengi
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
