# 🎉 Doğum Günü Hatırlatma Uygulaması

Flutter ile geliştirilen bu mobil uygulama, kullanıcıların sevdiklerinin doğum günlerini kolayca kaydedip takip etmesini sağlar. Kullanıcı dostu arayüzü sayesinde yeni doğum günü eklemek, mevcut bilgileri görüntülemek veya silmek oldukça basittir.

---

## 📲 Özellikler

- 🔐 Firebase Authentication (E-posta/Şifre, Google ve GitHub ile giriş)
- 📝 Doğum günü ekleme, listeleme ve silme işlemleri
- 📂 Firebase Firestore ile bulut tabanlı veri saklama
- 🧾 Flutter Secure Storage ile güvenli kullanıcı girişi bilgisi saklama
- 📸 Drawer menüsünde API üzerinden logo görüntüleme
- 🧭 Sayfalar arası geçiş ve kullanıcı yönlendirmesi
- 📱 Modern ve duyarlı kullanıcı arayüzü (UI/UX)

---

## 📄 Uygulama Sayfaları ve Görevleri

### 🔑 Giriş Sayfası (Login Page)

- **Görev**: Kullanıcının uygulamaya giriş yapmasını sağlar.
- **İçerik**: Kullanıcıdan kullanıcı adı ve şifre girmesi istenir. Giriş başarılı olursa, kullanıcı ana sayfaya yönlendirilir. Başarısız girişte uyarı mesajı gösterilir.

### 🏠 Ana Sayfa (Home Page)

- **Görev**: Kayıtlı doğum günü verilerini listeleme.
- **İçerik**: Kullanıcıya ait tüm doğum günleri listelenir. Kullanıcı dilerse kayıtları silebilir.

### ➕ Doğum Günü Ekleme Sayfası (Add Birthday Page)

- **Görev**: Yeni doğum günü kaydı ekleme.
- **İçerik**: İsim - Soyisim ve doğum tarihi bilgileri girilerek sistemde saklanır. Kaydetmeden önce özet görüntülenir. İşlem başarılıysa onay mesajı gösterilir.

### 🚪 Çıkış Sayfası (Logout Page)

- **Görev**: Kullanıcının uygulamadan güvenli şekilde çıkış yapması.
- **İçerik**: Kullanıcı oturumu kapatılır ve giriş ekranına yönlendirilir.

---

## 🧭 Drawer Menüsündeki Logo API Bilgileri

- **Format**: WebP  
- **Boyut**: 128x128 piksel  
- **Yedek (Fallback)**: Monogram  
- **Retina Desteği**: Mevcut

---

## 🔒 Giriş Bilgilerinin Saklanması

Giriş bilgileri `flutter_secure_storage` kullanılarak cihazda şifreli şekilde saklanır. Bu sayede kullanıcı tekrar giriş yapmak zorunda kalmadan uygulamayı güvenli şekilde kullanabilir.

---

## 👨‍💻 Geliştirici Ekip ve Katkıları

### 👤 Abdullah Belli
- Uygulama mimarisi ve genel işleyişi tasarladı  
- Flutter ile tüm sayfaların kodlanmasını gerçekleştirdi  
- Sayfalar arası geçiş, yönlendirme ve login işlemlerini geliştirdi

### 👤 Furkan Kalay
- Uygulamanın kullanıcı arayüzünü (UI/UX) tasarladı  
- Doğum günü ekleme ve listeleme fonksiyonlarını geliştirdi  
- Drawer menüsünü oluşturdu  
- Uygulamanın testlerini gerçekleştirdi ve hataları giderdi

---

![Screenshot 2025-06-03 114458](https://github.com/user-attachments/assets/fbfad636-b9b3-4fd3-8ec2-c57eb8bca329)



