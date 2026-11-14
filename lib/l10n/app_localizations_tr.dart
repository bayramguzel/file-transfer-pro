// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get skip => 'Atla';

  @override
  String get filesAdded => 'dosya eklendi';

  @override
  String get about => 'Hakkında';

  @override
  String get aboutApp => 'File Transfer v1.0.0';

  @override
  String get aboutDescription =>
      'Profesyonel ve güvenli dosya aktarım çözümü.\n\nWi-Fi ve Bluetooth üzerinden hızlı, kolay ve güvenli dosya paylaşımı yapın.';

  @override
  String get accentColor => 'Vurgu Rengi';

  @override
  String get activeSharings => 'Aktif Paylaşımlar';

  @override
  String get addMore => 'Daha Fazla Ekle';

  @override
  String get allFileTypesSupported => 'Her türlü dosya • Sınırsız boyut';

  @override
  String get allFiles => 'Tüm Dosyalar';

  @override
  String get anErrorOccurred => 'Bir Hata Oluştu';

  @override
  String get apkExtraction => 'APK Çıkarma';

  @override
  String get appSelection => 'Uygulama Seçimi';

  @override
  String get appSubtitle => 'Profesyonel Dosya Aktarımı';

  @override
  String get appTitle => 'File Transfer';

  @override
  String get appearance => 'Görünüm';

  @override
  String get archives => 'Arşivler';

  @override
  String get audio => 'Sesler';

  @override
  String get automatic => 'Otomatik';

  @override
  String get batchSelection => 'Toplu Seçim';

  @override
  String get bluetoothDevices => 'Bluetooth Cihazları';

  @override
  String get bluetoothNoDevicesMessage =>
      'Yakınınızdaki Bluetooth cihazlarını görmek için taramayı başlatın';

  @override
  String get bluetoothPermission => 'Bluetooth izni gerekli';

  @override
  String get bluetoothScanning => 'Bluetooth cihazları taranıyor...';

  @override
  String get bluetoothTransfer => 'Bluetooth ile';

  @override
  String get canSelectMultipleFiles => 'Birden fazla dosya seçebilirsiniz';

  @override
  String get cancel => 'İptal';

  @override
  String get cancelTransfer => 'Transferi İptal Et';

  @override
  String get cancelTransferConfirm =>
      'Bu transferi iptal etmek ve geçmişten silmek istediğinizden emin misiniz?';

  @override
  String get change => 'Değiştir';

  @override
  String get changePath => 'Yolu Değiştir';

  @override
  String get changePhoto => 'Fotoğrafı Değiştir';

  @override
  String get clear => 'Temizle';

  @override
  String get clearAll => 'Hepsini Temizle';

  @override
  String get clipboard => 'Evrensel Pano';

  @override
  String get clipboardHint => 'Metin yazın veya yapıştırın...';

  @override
  String get clipboardSharing => 'Metin Paylaşımı';

  @override
  String get clipboardSharingDescription =>
      'Metni buraya yapıştırın ve ağdaki diğer cihazlarla paylaşın.';

  @override
  String get copy => 'Kopyala';

  @override
  String get paste => 'Yapıştır';

  @override
  String get clickOrDragToUpload => 'Yüklemek için tıklayın veya sürükleyin';

  @override
  String get completed => 'Tamamlandı';

  @override
  String get connectSameNetwork => 'Aynı Ağa Bağlanın';

  @override
  String get connectSameNetworkMessage =>
      'Her iki cihaz aynı Wi-Fi ağında olmalı';

  @override
  String get connectWithQRCode => 'QR Kodu ile Bağlan';

  @override
  String get connected => 'Bağlandı';

  @override
  String get connectedToWifi => 'Wi-Fi ağına bağlısınız';

  @override
  String get connecting => 'Bağlanıyor...';

  @override
  String get connectionFailed => 'Bağlantı Başarısız';

  @override
  String get connectionInfo => 'Bağlantı Bilgileri';

  @override
  String get copiedToClipboard => 'Panoya kopyalandı';

  @override
  String couldNotOpenUrl(Object url) {
    return 'Bağlantı açılamadı: $url';
  }

  @override
  String get date => 'Tarih';

  @override
  String daysAgo(Object days) {
    return '$days gün önce';
  }

  @override
  String get delete => 'Sil';

  @override
  String deleteFailed(Object error) {
    return 'Silme başarısız: $error';
  }

  @override
  String get deleteTransfer => 'Transferi Sil';

  @override
  String get deleteTransferConfirm =>
      'Bu transferi geçmişten kalıcı olarak silmek istediğinizden emin misiniz?';

  @override
  String get disconnected => 'Bağlantı Kesildi';

  @override
  String get displayNameNote =>
      'Bu isim dosya paylaşırken alıcılara gösterilir';

  @override
  String get documents => 'Belgeler';

  @override
  String get donate => 'Destek Ol';

  @override
  String get downloadDirectory => 'İndirme Klasörü';

  @override
  String get dropFilesHere => 'Dosyaları buraya bırakın';

  @override
  String get easy => 'Kolay';

  @override
  String get edit => 'Düzenle';

  @override
  String get english => 'English';

  @override
  String get enterName => 'Adınızı girin';

  @override
  String get error => 'Hata';

  @override
  String errorLoadingApps(Object error) {
    return 'Uygulamalar yüklenirken hata: $error';
  }

  @override
  String errorLoadingHistory(Object error) {
    return 'Aktarım geçmişi yüklenemedi: $error';
  }

  @override
  String errorPickingFiles(Object error) {
    return 'Dosya seçilirken hata oluştu: $error';
  }

  @override
  String get failed => 'Başarısız';

  @override
  String get fast => 'Hızlı';

  @override
  String get features => 'Özellikler';

  @override
  String get feedback => 'Geri Bildirim';

  @override
  String get fetching => 'Alınıyor...';

  @override
  String get fileCount => 'Dosya Sayısı';

  @override
  String get fileReceived => 'Dosya Alındı';

  @override
  String fileReceivedFrom(Object filename) {
    return '$filename dosyası alındı';
  }

  @override
  String get fileSelection => 'Dosya Seçimi';

  @override
  String get files => 'Dosyalar';

  @override
  String filesCount(Object count) {
    return '$count dosya';
  }

  @override
  String filesSelected(Object count) {
    return '$count dosya seçildi';
  }

  @override
  String filesSharing(Object count) {
    return '$count dosya paylaşılıyor';
  }

  @override
  String get filterBy => 'Filtrele';

  @override
  String get findDevices => 'Cihaz Bul';

  @override
  String get followUs => 'Bizi Takip Edin';

  @override
  String get generateNewPIN => 'Yeni PIN Oluştur';

  @override
  String get german => 'Deutsch';

  @override
  String get goBack => 'Geri Dön';

  @override
  String get grantPermission => 'İzin Ver';

  @override
  String get highSpeedTransfer => 'Yüksek hızlı aktarım';

  @override
  String get history => 'Aktarım Geçmişi';

  @override
  String get home => 'Ana Sayfa';

  @override
  String hoursAgo(Object hours) {
    return '$hours saat önce';
  }

  @override
  String get howItWorks => 'Nasıl Çalışır?';

  @override
  String get images => 'Resimler';

  @override
  String get shareWithFriends => 'Arkadaşlarınızla Paylaşın';

  @override
  String get shareAppText =>
      'Bu harika dosya aktarım uygulamasına göz atın! Google Play\'den indirin: https://play.google.com/store/apps/details?id=com.filetransfer.pro';

  @override
  String get invalidQRCode =>
      'Geçersiz QR kod. Lütfen bir File Transfer paylaşım kodu tarayın.';

  @override
  String get ipAddress => 'IP Adresi';

  @override
  String get ipAddressTakenError =>
      'IP adresi alınamadı. Wi-Fi\'ye bağlı olduğunuzdan emin olun.';

  @override
  String get keepScreenOpenMessage =>
      'Bu ekranı açık tuttuğunuz sürece paylaşım aktif kalacaktır.';

  @override
  String get language => 'Dil & Bölge';

  @override
  String get live => 'CANLI';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get localNetworkSecurity => 'Yerel ağ güvenliği';

  @override
  String get locationPermission => 'Konum izni gerekli';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes dakika önce';
  }

  @override
  String get multiFile => 'Çoklu Dosya';

  @override
  String get multiPlatform => 'Çoklu Platform';

  @override
  String get nearbyDevices => 'Yakındaki Cihazlar';

  @override
  String get networkInfo => 'Ağ Bilgileri';

  @override
  String get networkOffline => 'İnternet Bağlantısı Yok';

  @override
  String get networkOfflineMessage =>
      'Cihaz keşfi için Wi-Fi bağlantısına ihtiyaç var. Lütfen Wi-Fi\'yi açıp tekrar deneyin.';

  @override
  String get networkTransfer => 'Ağ Üzerinden';

  @override
  String get no => 'Hayır';

  @override
  String get noAppsFound => 'Uygulama bulunamadı';

  @override
  String get noDevicesFound => 'Henüz Cihaz Bulunamadı';

  @override
  String get noDevicesFoundMessage =>
      'Diğer cihazlarda File Transfer açık olduğundan ve aynı Wi-Fi ağına bağlı olduklarından emin olun';

  @override
  String get noFilesSharedYet => 'Henüz dosya paylaşılmadı';

  @override
  String get noMatchingFiles => 'Aramanızla eşleşen dosya bulunamadı';

  @override
  String get noMatchingFilesFound => 'Eşleşen dosya bulunamadı';

  @override
  String get noReceivedFiles => 'Henüz alınan dosya yok';

  @override
  String get noResultsFound => 'Sonuç Bulunamadı';

  @override
  String get noResultsMessage =>
      'Arama kriterlerinize uygun aktarım bulunamadı. Farklı bir arama terimi deneyin.';

  @override
  String get noSentFiles => 'Henüz gönderilen dosya yok';

  @override
  String get noSizeLimit => 'Boyut limiti yok';

  @override
  String get offline => 'Çevrimdışı';

  @override
  String get offlineWlanNotConnected => 'Çevrimdışı - Wi-Fi\'ye bağlı değil';

  @override
  String get ok => 'Tamam';

  @override
  String get online => 'Çevrimiçi';

  @override
  String get onlineWlanConnected => 'Çevrimiçi - Wi-Fi\'ye bağlı';

  @override
  String get onlyUserApps => 'Sadece Kullanıcı Uygulamaları';

  @override
  String get openFolder => 'Klasörü Aç';

  @override
  String get openSettings => 'Ayarları Aç';

  @override
  String get openingConnection => 'Dosyaları almak için bağlantı açılıyor...';

  @override
  String get orEnterAddress => 'Veya tarayıcıya şu adresi yazın:';

  @override
  String get other => 'Diğer';

  @override
  String get pause => 'Duraklat';

  @override
  String get paused => 'Duraklatıldı';

  @override
  String get permissionRequired => 'İzin Gerekli';

  @override
  String get pinCode => 'PIN Kodu';

  @override
  String get pinMessage =>
      'Alıcı cihazın dosyalara erişmek için bu PIN kodunu girmesi gerekir.';

  @override
  String get pinProtection => 'PIN Koruması';

  @override
  String get pleaseConnectToWifi =>
      'Lütfen Wi-Fi ayarlarınızdan bir kablosuz ağa bağlanın.';

  @override
  String get preparingSharing => 'Paylaşım Hazırlanıyor...';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get proUser => 'Pro Kullanıcı';

  @override
  String get profile => 'Profil';

  @override
  String get profileName => 'Görünen Ad';

  @override
  String get progress => 'İlerleme';

  @override
  String get qrCodeFound => 'QR Kod Bulundu';

  @override
  String get quickActions => 'Hızlı İşlemler';

  @override
  String get quickAndSecure => 'Hızlı ve Güvenli Dosya Aktarımı';

  @override
  String get receiveFile => 'Dosya Al';

  @override
  String get receiveFilesDescription => 'QR kod ile anında indirin';

  @override
  String receiverName(Object name) {
    return 'Alıcı: $name';
  }

  @override
  String get receiverScanQRMessage =>
      'Alıcı cihaz bu QR kodu taratarak dosyalara erişebilir';

  @override
  String get receiving => 'Alınıyor';

  @override
  String get refresh => 'Yenile';

  @override
  String get releaseToDrop => 'Bırakmak için parmağınızı/farenizi bırakın';

  @override
  String get removePhoto => 'Fotoğrafı Kaldır';

  @override
  String get resume => 'Devam Et';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get scanQR => 'QR Kod Tara';

  @override
  String get scanQRCode => 'QR Kodu Tarayın';

  @override
  String get scanQRCodeToDownload => 'QR Kodu Tarayın';

  @override
  String get scanQrInstruction => 'QR kodu kamera çerçevesine getirin';

  @override
  String get scanQrSuccessMessage =>
      'Kod tarandığında dosyalar otomatik açılacak';

  @override
  String get scanStopped => 'Tarama durduruldu';

  @override
  String get scanningDevices => 'Aynı ağdaki cihazlar taranıyor...';

  @override
  String get scanningStopped => 'Tarama durduruldu';

  @override
  String get searchApps => 'Uygulama ara...';

  @override
  String get searchByFileNameOrId => 'Dosya adı veya ID ile ara...';

  @override
  String get searchFiles => 'Dosya ara...';

  @override
  String searchInFiles(Object count) {
    return '$count dosya içinde ara...';
  }

  @override
  String get secure => 'Güvenli';

  @override
  String get selectApp => 'Uygulama Seç';

  @override
  String get selectApps => 'Uygulama Seçin';

  @override
  String get selectAtLeastOneFile => 'Lütfen en az bir dosya seçin';

  @override
  String get selectFiles => 'Dosyalarınızı seçin';

  @override
  String get selectFilesMessage => 'Paylaşmak için dosyalarınızı seçin';

  @override
  String get selectFilesToShare => 'Paylaşmak için dosya seçin';

  @override
  String selectedFilesCount(Object count) {
    return 'Seçilen Dosyalar ($count)';
  }

  @override
  String get sendFile => 'Dosya Gönder';

  @override
  String senderName(Object name) {
    return 'Gönderen: $name';
  }

  @override
  String get sending => 'Gönderiliyor';

  @override
  String get serverActive => 'Sunucu Aktif';

  @override
  String get serverPort => 'Sunucu Portu';

  @override
  String get serverStartError => 'Sunucu başlatılamadı';

  @override
  String get serverStartErrorWifi =>
      'Sunucu başlatılamadı. Wi-Fi bağlantısını kontrol edin.';

  @override
  String get settings => 'Ayarlar';

  @override
  String get shareApp => 'Uygulama Paylaş';

  @override
  String get shareAppDescription => 'Yüklü uygulamaları APK olarak gönder';

  @override
  String shareAppsCount(Object count) {
    return '$count Uygulamayı Paylaş';
  }

  @override
  String get shareFilesSecurely => 'Dosyalarınızı güvenle paylaşın';

  @override
  String get shareSelected => 'Seçilenleri Paylaş';

  @override
  String get sharedFiles => 'Paylaşılan Dosyalar';

  @override
  String get sharingActive => 'Paylaşım Aktif!';

  @override
  String get sharingFailed => 'Paylaşım Başlatılamadı';

  @override
  String get sharingInfo => 'Paylaşım Bilgileri';

  @override
  String get showConnectionInfo => 'Bağlantı Bilgisini Göster';

  @override
  String get showSystemApps => 'Sistem uygulamalarını göster';

  @override
  String get size => 'Boyut';

  @override
  String get socialMedia => 'Sosyal Medya';

  @override
  String get sortBy => 'Sırala';

  @override
  String get sortByDate => 'Tarihe Göre';

  @override
  String get sortByName => 'İsme Göre';

  @override
  String get sortBySize => 'Boyuta Göre';

  @override
  String get sortByType => 'Türe Göre';

  @override
  String get startScanning => 'Taramayı Başlat';

  @override
  String get startSharing => 'Paylaşımı Başlat';

  @override
  String get startTime => 'Başlangıç';

  @override
  String get startingServer => 'Sunucu başlatılıyor...';

  @override
  String get status => 'Durum';

  @override
  String step(Object number) {
    return 'Adım $number';
  }

  @override
  String get stopSharing => 'Paylaşımı Durdur';

  @override
  String get storage => 'Depolama';

  @override
  String get storagePermission => 'Depolama izni gerekli';

  @override
  String get supportUs => 'Destek Olun';

  @override
  String get supportedPlatforms => 'Android, Windows, Linux (iOS: IP Tabanlı)';

  @override
  String get theme => 'Tema';

  @override
  String get themeDark => 'Koyu';

  @override
  String get themeLight => 'Açık';

  @override
  String get timeRemaining => 'Kalan Süre';

  @override
  String get toggleOnlineStatus => 'Çevrimiçi Durumunu Değiştir';

  @override
  String get totalSize => 'Toplam Boyut';

  @override
  String totalSizeWithLabel(Object size) {
    return 'Toplam Boyut: $size';
  }

  @override
  String get transferCode => 'Transfer Kodu';

  @override
  String transferCodeWithLabel(Object code) {
    return 'Kod: $code';
  }

  @override
  String get transferCompleted => 'Aktarım Tamamlandı!';

  @override
  String transferDeleteFailed(Object error) {
    return 'Transfer silinemedi: $error';
  }

  @override
  String get transferDeleted => 'Transfer silindi';

  @override
  String get transferDeletedSuccessfully => 'Transfer başarıyla silindi';

  @override
  String get transferDetails => 'Aktarım Detayları';

  @override
  String get transferFailed => 'Aktarım Başarısız';

  @override
  String get transferHistory => 'Aktarım Geçmişi';

  @override
  String get transferHistoryEmpty => 'Aktarım Geçmişi Boş';

  @override
  String get transferHistoryEmptyMessage =>
      'Henüz hiç dosya aktarımı yapmadınız. İlk aktarımınızı yapmak için ana sayfaya dönün.';

  @override
  String get transferInfo => 'Transfer Bilgileri';

  @override
  String get transferSpeed => 'Transfer Hızı';

  @override
  String get transferViaBluetooth => 'Bluetooth bağlantısı ile dosya aktarımı';

  @override
  String get transferViaNetwork => 'Wi-Fi ağı üzerinden dosya aktarımı';

  @override
  String get transferred => 'Aktarılan';

  @override
  String get turkish => 'Türkçe';

  @override
  String get ultraFast => 'Ultra Hızlı';

  @override
  String get unlimited => 'Sınırsız';

  @override
  String urlCannotOpen(Object url) {
    return 'URL açılamıyor: $url';
  }

  @override
  String get urlCopied => 'URL panoya kopyalandı';

  @override
  String get user => 'Kullanıcı';

  @override
  String get version => 'Sürüm';

  @override
  String get videos => 'Videolar';

  @override
  String get visitWebsite => 'Web Sitesini Ziyaret Et';

  @override
  String get wifiRequired => 'Wi-Fi Gerekli';

  @override
  String get wifiRequiredMessage =>
      'Dosya aktarımı için bir Wi-Fi ağına bağlı olmanız gerekir.';

  @override
  String get yes => 'Evet';

  @override
  String get completedFiles => 'Tamamlanan Dosyalar';

  @override
  String get noTransfersYet => 'Henüz aktarım yok';

  @override
  String get noSearchResults => 'Sonuç bulunamadı';

  @override
  String get cameraPermissionRequired => 'Kamera İzni Gerekli';

  @override
  String get cameraPermissionMessage =>
      'QR kodu tarayarak bağlanmak için kamera erişimine ihtiyaç var. Lütfen aşağıdan izin verin.';

  @override
  String get storagePermissionRequired => 'Depolama İzni Gerekli';

  @override
  String get storagePermissionMessage =>
      'Dosya indirip paylaşabilmek için depolama erişimi gerekiyor.';

  @override
  String get notificationPermissionRequired => 'Bildirim İzni Gerekli';

  @override
  String get notificationPermissionMessage =>
      'Transfer tamamlandığında sizi bilgilendirmek için bildirim iznine ihtiyaç var.';

  @override
  String get permissionPermanentlyDenied =>
      'İzin kalıcı olarak reddedildi. Lütfen uygulama ayarlarından izin verin.';

  @override
  String get permissionDeniedTitle => 'İzin Reddedildi';

  @override
  String get shareWithFriendsFull => 'Arkadaşlarınızla Paylaşın';

  @override
  String get supportApp => 'Destek Ol';

  @override
  String get supportStatusActive => 'Destek Durumu: Aktif';

  @override
  String get supportStatusInactive => 'Destek Durumu: Pasif';

  @override
  String supportRemainingTime(Object time) {
    return 'Kalan Destek Süresi: $time';
  }

  @override
  String get supportExtend => 'Reklam İzle & Destek Ol (+24 Saat)';

  @override
  String get supportDescription =>
      'Kısa bir reklam izleyerek bize destek olabilir ve 48 saate kadar reklamsız destekçi ayrıcalığı kazanabilirsiniz.';

  @override
  String get supportMaxReached =>
      'Maksimum 48 saatlik destek süresine ulaştınız. Harikasınız!';

  @override
  String get supportThankYouTitle => 'Teşekkür Ederiz! ❤️';

  @override
  String get supportThankYouMessage =>
      'Uygulamamızı desteklediğiniz için çok teşekkürler! Destek süreniz başarıyla uzatıldı.';

  @override
  String get adLoading => 'Reklam yükleniyor, lütfen bekleyin...';

  @override
  String get adFailedToLoad =>
      'Reklam şu anda yüklenemedi. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String hoursMinutesRemaining(Object hours, Object minutes) {
    return '$hours saat $minutes dakika';
  }

  @override
  String minutesRemaining(Object minutes) {
    return '$minutes dakika';
  }

  @override
  String get notNow => 'Şimdi Değil';

  @override
  String get gallery => 'Galeri';

  @override
  String get camera => 'Kamera';

  @override
  String get fileNotFound => 'Dosya bulunamadı';

  @override
  String get open => 'Aç';

  @override
  String get unknown => 'Bilinmiyor';

  @override
  String get rateAppTitle => 'File Transfer\'ı Beğendiniz mi?';

  @override
  String get rateAppDescription =>
      'Görüşleriniz bizim için çok değerli! 5 yıldız ve yorum bırakarak bize destek olabilirsiniz.';

  @override
  String get rateNow => 'Google Play\'de Değerlendir';

  @override
  String get remindMeLater => 'Daha Sonra Hatırlat';

  @override
  String get dontAskAgain => 'Bir Daha Sorma';

  @override
  String get rateThankYou => 'Değerlendirmeniz için teşekkürler!';

  @override
  String get deviceName => 'Cihaz Adı';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get save => 'Kaydet';

  @override
  String get chooseAvatar => 'Avatar Seç';

  @override
  String get appFolderNotice => 'Varsayılan Klasör: file_transfer';

  @override
  String get recentTransfers => 'Son Aktarımlar';

  @override
  String get noRecentTransfers => 'Henüz aktarım geçmişi yok';

  @override
  String get seeAll => 'Tümünü Gör';

  @override
  String get clipboardSync => 'Pano Paylaşımı';

  @override
  String get connectedWifi => 'Bağlı';

  @override
  String get notConnected => 'Bağlı Değil';

  @override
  String get resuming => 'Aktarım devam ettiriliyor...';

  @override
  String get iosLocalNetworkHint =>
      'Diğer cihaz bağlanamıyorsa: Ayarlar > Gizlilik ve Güvenlik > Yerel Ağ bölümünden File Transfer Pro\'ya izin verin.';

  @override
  String get serverRestarted => 'Paylaşım sunucusu yeniden başlatıldı.';
}
