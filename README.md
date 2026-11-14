# 📱 File Transfer Pro - Yerel Dosya Aktarım Uygulaması

File Transfer Pro, mobil cihazlar ve bilgisayarlar arasında **Wi-Fi** ve **Bluetooth** üzerinden güvenli ve hızlı dosya aktarımı sağlayan modern bir Flutter uygulamasıdır.

## ✨ Özellikler

### 🌐 Wi-Fi ile Paylaşım (En Hızlı)
- ⚡ Yüksek hızlı dosya aktarımı
- 📷 QR kod ile kolay bağlantı
- 🔍 Otomatik cihaz keşfetme
- 🌍 Tarayıcıdan dosya indirme
- 🔒 Yerel ağda güvenli paylaşım

### 📡 Bluetooth ile Paylaşım
- 🔵 Bluetooth cihaz tarama
- 🔗 Otomatik cihaz bağlantısı
- 📲 Mobil cihazlar arası aktarım
- 💻 Mobil-bilgisayar aktarımı

### 🎨 Modern Arayüz
- 🌓 Karanlık/Aydınlık tema
- 🎨 5 farklı accent renk seçeneği
- 🌍 Çoklu dil desteği (TR/EN/DE)
- 📱 Material Design 3

## 🚀 Nasıl Kullanılır?

### Wi-Fi ile Dosya Gönderme

1. **Gönderen Cihaz:**
   - Ana sayfadan "Gönder" butonuna tıklayın
   - Göndermek istediğiniz dosyaları seçin
   - QR kod ekrana gelecek

2. **Alıcı Cihaz:**
   - Ana sayfadan "Al" butonuna tıklayın
   - QR kodu tarayın veya IP adresini girin
   - Dosyalar otomatik indirilecek

### Bluetooth ile Dosya Gönderme

1. **Her İki Cihazda:**
   - Bluetooth'u açın
   - Konum izinlerini verin

2. **Gönderen Cihaz:**
   - "BT ile Gönder" butonuna tıklayın
   - Alıcı cihazı bulun ve bağlanın
   - Dosyaları seçip gönderin

3. **Alıcı Cihaz:**
   - Gelen bağlantı isteğini kabul edin
   - Dosyalar otomatik kaydedilecek

## 🔧 Kurulum

### Gereksinimler
- Flutter SDK 3.0.0+
- Android SDK (Android cihazlar için)
- Xcode (iOS cihazlar için)

### Adımlar

```bash
# Projeyi klonlayın
git clone <repository-url>
cd file_transfer

# Bağımlılıkları yükleyin
flutter pub get

# Uygulamayı çalıştırın
flutter run
```

## 📦 Bağımlılıklar

### Ana Bağımlılıklar
- **flutter_bloc** (^9.1.1) - State management
- **shelf** (^1.4.1) - HTTP server
- **flutter_blue_plus** (^1.32.12) - Bluetooth
- **file_picker** (^10.3.3) - Dosya seçimi
- **qr_flutter** (^4.1.0) - QR kod oluşturma
- **mobile_scanner** (^7.1.3) - QR kod okuma
- **drift** (^2.14.1) - Veritabanı
- **permission_handler** (^12.0.1) - İzin yönetimi

[Tüm bağımlılıklar için pubspec.yaml dosyasına bakın]

## 🏗️ Proje Yapısı

```
lib/
├── core/
│   ├── constants/     # Sabitler (portlar, timeout'lar)
│   ├── models/        # Enum'lar ve tip tanımları
│   ├── theme/         # Material Design 3 tema
│   └── utils/         # Yardımcı fonksiyonlar
├── data/
│   ├── datasources/   # Database (Drift/SQLite)
│   ├── models/        # Data modelleri
│   ├── repositories/  # Repository pattern
│   └── services/      # İş mantığı servisleri
│       ├── local_network_service.dart     # Wi-Fi paylaşımı
│       ├── bluetooth_service.dart          # Bluetooth paylaşımı
│       ├── device_discovery_service.dart   # Cihaz keşfetme
│       └── file_download_service.dart      # Dosya indirme
└── presentation/
    ├── blocs/         # BLoC state management
    ├── pages/         # Ekranlar
    │   ├── home_page.dart                  # Ana sayfa
    │   ├── local_send_page.dart            # Dosya seçimi
    │   ├── local_hosting_page.dart         # QR kod gösterimi
    │   ├── qr_scanner_page.dart            # QR tarama
    │   ├── device_scanner_page.dart        # Wi-Fi cihaz tarama
    │   ├── bluetooth_scanner_page.dart     # Bluetooth tarama
    │   └── transfer_history_page.dart      # Geçmiş
    └── widgets/       # Yeniden kullanılabilir bileşenler
```

## 🔐 İzinler

### Android Manifest
```xml
<!-- Network -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Bluetooth -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<!-- Storage -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Location (Bluetooth için gerekli) -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

## 🎯 Öne Çıkan Özellikler

### 🔒 Güvenlik
- Yerel ağ üzerinden direkt bağlantı
- İnternet gerektirmez
- Üçüncü parti sunucu yok
- Veriler cihazınızdan ayrılmaz

### ⚡ Performans
- Yüksek hızlı Wi-Fi aktarımı
- Streaming file transfer
- Hafıza dostu chunk-based transfer
- Real-time ilerleme göstergesi

### 🎨 Kullanıcı Deneyimi
- Sezgisel arayüz
- QR kod ile tek dokunuşta bağlantı
- Otomatik cihaz keşfetme
- Modern Material Design 3

## 🐛 Bilinen Sorunlar

- Bluetooth dosya aktarımı henüz tam test edilmemiştir
- Transfer pause/resume özelliği aktif değil
- Transfer geçmişi şu an simüle edilmiş veri kullanıyor

## 🚧 Geliştirme Durumu

- ✅ Wi-Fi paylaşımı - **Tamamlandı**
- ✅ Cihaz keşfetme - **Tamamlandı**
- ✅ QR kod paylaşımı - **Tamamlandı**
- 🟡 Bluetooth paylaşımı - **Geliştirme Aşamasında**
- ⏳ Transfer geçmişi - **Planlanan**
- ⏳ Pause/Resume - **Planlanan**

## 📝 Lisans

Bu proje özel bir projedir. Tüm hakları saklıdır.

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen şu adımları izleyin:

1. Projeyi fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'feat: Add amazing feature'`)
4. Branch'i push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📧 İletişim

Sorularınız veya önerileriniz için:
- Issue açın
- Pull request gönderin

---

**File Transfer Pro** - Hızlı, Güvenli, Yerel Dosya Aktarımı 🚀
