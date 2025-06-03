import 'package:flutter/material.dart';
import 'package:dogum_gunu_uygulamasi/routes/app_routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase başlatma - Manuel yapılandırma ile
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDRXJuzedXWhYWnkmrqRWLDOr7kKyFAbAw",
        appId: "1:1022239079076:android:6faa2cfde4165a0ce74431",
        messagingSenderId: "1022239079076",
        projectId: "dogum-gunu-uygulamasi-df9c4",
        authDomain: "dogum-gunu-uygulamasi-df9c4.firebaseapp.com",
        storageBucket: "dogum-gunu-uygulamasi-df9c4.appspot.com",
      ),
    );
  } catch (e) {
    if (e.toString().contains('A Firebase App named')) {
    } else {
      rethrow;
    }
  }

  // Supabase başlatma
  await Supabase.initialize(
    url: 'https://krrbkyloxzkmlltkrpao.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtycmJreWxveHprbWxsdGtycGFvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg4NjI3MzQsImV4cCI6MjA2NDQzODczNH0.hV_gSYqIPzVKKvPdnqtr3Y7lloOQq3bO98NL16rD2XE', // KENDİ Supabase ANON KEY'iniz
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale(
        'tr',
        'TR',
      ), // Uygulama dilini Türkçe olarak ayarladık.
      // Lokalizasyon desteği için gerekli delegeler eklendi.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ], // Desteklenen dilleri Türkçe ve İngilizce yaptık.

      debugShowCheckedModeBanner: false, // Debug banner gizlendi.
      // Uygulamanın başlığı teması belirlendi.
      title: 'Doğum Günü Hatırlatıcı',

      theme: ThemeData(primarySwatch: Colors.deepPurple),

      // İlk açılışta kullanılacak olan rota.
      initialRoute: AppRoutes.login,

      // Uygulama rotaları AppRoutes'tan yönlendiriliyor.
      routes: AppRoutes.routes,
    );
  }
}
