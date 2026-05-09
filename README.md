# SavingsJarApp 🏺

Bu proje, kişisel finans yönetimini ve birikim takibini kolaylaştırmak için geliştirilmiş, **Firebase** destekli bir Flutter uygulamasıdır.

## 🚀 Öne Çıkan Özellikler
- **Hedef Odaklı Birikim:** Belirli amaçlar için sanal "kavanozlar" oluşturun.
- **Gerçek Zamanlı Veri:** Firebase Firestore ile verileriniz tüm cihazlarınızda anlık güncellenir.
- **Oturum Yönetimi:** Google ile hızlı ve güvenli giriş desteği.
- **Kullanıcı Dostu Arayüz:** Provider tabanlı hızlı durum yönetimi ve dinamik tema desteği.

## 🛠️ Teknik Özellikler
- **SDK:** Flutter
- **Bağımlılıklar:** `firebase_core`, `cloud_firestore`, `firebase_auth`, `provider`.
- **Yönetim:** `JarProvider` ve `ThemeProvider` ile merkezi kontrol.

## ⚙️ Hızlı Başlangıç
1. `google-services.json` (Android) veya `GoogleService-Info.plist` (iOS) dosyalarınızı ekleyin.
2. `flutter pub get` komutunu çalıştırın.
3. Uygulamayı çalıştırın.

## 📁 Dosya Yapısı
- `lib/ui/screens/`: Giriş, Anasayfa, Kavanoz Detayı ve Ayarlar ekranları.
- `lib/data/models/`: Veri yapıları.
- `lib/providers/`: İş mantığı ve state yönetimi.
