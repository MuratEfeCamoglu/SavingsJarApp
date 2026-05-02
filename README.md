🍯 SavingJar App
SavingJar, kullanıcıların finansal hedeflerine ulaşmalarını sağlayan, minimalist ve modern bir arayüze sahip akıllı bir birikim takip uygulamasıdır. Flutter ve Firebase teknolojileriyle geliştirilen bu uygulama, kullanıcıların "Kumbara" (Jar) mantığıyla para biriktirmesini ve harcamalarını yönetmesini sağlar.

✨ Özellikler
Dinamik Kumbara Yönetimi: Hedef tutarı, ikonu ve rengi kişiselleştirilebilir kumbaralar oluşturma.

Gelişmiş Finansal Hareketler: Sadece miktar değil; tarih, not ve kategori bazlı para ekleme (Add) ve çekme (Withdraw) işlemleri.

Gerçek Zamanlı Senkronizasyon: Firebase entegrasyonu sayesinde verileriniz anında buluta yedeklenir.

Profil Özelleştirme: İsim değişikliği ve galeri üzerinden profil fotoğrafı yükleme desteği.

Hedef Tamamlama Kilidi: Hedefine %100 ulaşan kumbaralara daha fazla para eklenmesini engelleyen akıllı kontrol sistemi.

Modern UI/UX: Responsive kart tasarımları, Dark Mode desteği ve cam (glassmorphic) efektli bileşenler.

Performans Odaklı: GPU dostu render alma ve düşük FPS kayıpları için optimize edilmiş widget yapısı.

🚀 Teknolojiler
Framework: Flutter (Dart)

Backend: Firebase (Cloud Firestore & Firebase Storage)

State Management: Provider

Yerel Depolama: Hive (Cache yönetimi için)

Mimari: Clean Architecture & Repository Pattern

🛠 Kurulum ve Çalıştırma
Uygulamayı yerel makinenizde çalıştırmak için aşağıdaki adımları izleyin:

Projeyi Klonlayın:

Bash
git clone https://github.com/kullaniciadi/savingsjar.git
cd savingsjar
Bağımlılıkları Yükleyin:

Bash
flutter pub get
Firebase Yapılandırması:

Firebase Console üzerinden yeni bir proje oluşturun.

Android ve iOS için google-services.json ve GoogleService-Info.plist dosyalarını ilgili klasörlere (android/app/ ve ios/Runner/) ekleyin.

Firestore ve Storage servislerini aktif edin.

Uygulamayı Çalıştırın:

Bash
flutter run
📁 Dosya Yapısı
Plaintext
lib/
├── core/            # Tema, sabitler ve global yardımcı sınıflar
├── data/
│   ├── models/      # Jar ve Transaction veri modelleri
│   └── repository/  # Firebase veri işlemleri
├── providers/       # Uygulama durum yönetimi (JarProvider vb.)
├── ui/
│   ├── screens/     # Home, New Jar, Settings ve Detail ekranları
│   └── widgets/     # Özel butonlar, kartlar ve form bileşenleri
└── main.dart        # Uygulama giriş noktası
📈 Kullanım İpuçları
Yeni Kumbara Oluşturma: Ana ekrandaki "+" butonuna basın. İsmini girin, rengini ve ikonunu seçin. Siyah ekran hatası almamak için tüm alanların dolu olduğundan emin olun.

Para Ekleme/Çekme: Kumbaranın içine girerek "Add" veya "Withdraw" butonlarını kullanın. İşleminize not düşerek harcamalarınızı daha sonra kolayca takip edebilirsiniz.

Profil Güncelleme: Ayarlar sekmesinden "Edit Profile" kısmına geçerek isminizi güncelleyebilir ve profil fotoğrafınızı değiştirebilirsiniz.

🚧 Yakında Gelecek Özellikler
[ ] Aylık ve haftalık birikim istatistikleri (Grafikler).

[ ] Ortak kumbara desteği (Ailecek biriktirme).

[ ] Biyometrik kilit (FaceID/Parmak İzi).