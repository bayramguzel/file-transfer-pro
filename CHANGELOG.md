# FlowShare - Değişiklik Günlüğü

## v1.0.0 - Yerel Ağ ve Bluetooth Odaklı Versiyon

### ✨ Yeni Özellikler
- **Bluetooth Desteği Eklendi**
  - Bluetooth cihaz tarama ve keşfetme
  - Bluetooth üzerinden dosya aktarımı altyapısı
  - Cihaz bağlantı yönetimi

### 🔄 Değişiklikler
- **İnternet Paylaşımı Kaldırıldı**
  - "Kod ile Gönder/Al" özellikleri kaldırıldı
  - Uygulama artık tamamen yerel ağ (WLAN) ve Bluetooth odaklı
  - İnternet bağlantısı gerektirmez

- **Ana Menü Yeniden Tasarlandı**
  - Wi-Fi paylaşımı bölümü vurgulandı
  - Bluetooth seçenekleri eklendi
  - Daha net ve kullanıcı dostu arayüz

### 🐛 Düzeltilen Hatalar
- ✅ Eksik bağımlılıklar eklendi (`dio`, `url_launcher`, `flutter_blue_plus`)
- ✅ `Helpers.formatBytes` fonksiyonu düzeltildi - artık dosya boyutları doğru gösteriliyor
- ✅ Confetti widget referansları temizlendi
- ✅ Android izinleri eklendi:
  - Bluetooth izinleri (scan, connect, advertise)
  - Ağ izinleri (WiFi, internet)
  - Depolama izinleri (dosya okuma/yazma)
  - Konum izinleri (Bluetooth için gerekli)

### 🎨 Arayüz İyileştirmeleri
- Uygulama açıklaması güncellendi: "Yerel Dosya Aktarımı"
- Kullanım kılavuzu Bluetooth bölümü ile güncellendi
- Hakkında dialog'u güncellendi
- Drawer menüsü modernize edildi

### 📱 Ana Özellikler
1. **Wi-Fi ile Hızlı Paylaşım**
   - QR kod ile kolay bağlantı
   - HTTP server üzerinden direkt dosya aktarımı
   - Cihaz keşfetme (UDP broadcast)

2. **Bluetooth Paylaşım**
   - Yakındaki Bluetooth cihazları tarama
   - Cihazlara bağlanma
   - Bluetooth üzerinden dosya gönderme/alma

3. **Modern Arayüz**
   - Material Design 3
   - Karanlık/Aydınlık tema
   - 5 farklı accent rengi
   - Türkçe/İngilizce/Almanca dil desteği

### 🔧 Teknik İyileştirmeler
- Flutter pub dependencies güncellendi
- Code analysis uyarıları azaltıldı
- Unused imports temizlendi
- Theme constant hataları düzeltildi

### 📋 Bilinen Sınırlamalar
- Bluetooth dosya aktarımı UI'ı oluşturuldu ancak tam test edilmedi
- Transfer geçmişi şu an dummy data kullanıyor
- Pause/Resume özelliği henüz implement edilmedi

### 🚀 Gelecek Özellikler
- Bluetooth dosya aktarımının tam implementasyonu ve testi
- Transfer geçmişi database entegrasyonu
- Pause/Resume transfer özelliği
- Çoklu cihaza aynı anda gönderim
- Dosya sıkıştırma seçeneği
