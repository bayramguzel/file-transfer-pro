// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get skip => 'Überspringen';

  @override
  String get filesAdded => 'Dateien hinzugefügt';

  @override
  String get about => 'Über';

  @override
  String get aboutApp => 'File Transfer v1.0.0';

  @override
  String get aboutDescription =>
      'Professionelle und sichere Dateiübertragungslösung.\n\nTeilen Sie Dateien schnell, einfach und sicher über WLAN und Bluetooth.';

  @override
  String get accentColor => 'Akzentfarbe';

  @override
  String get activeSharings => 'Aktive Freigaben';

  @override
  String get addMore => 'Mehr hinzufügen';

  @override
  String get allFileTypesSupported => 'Alle Dateitypen • Unbegrenzte Größe';

  @override
  String get allFiles => 'Alle Dateien';

  @override
  String get anErrorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get apkExtraction => 'APK-Extraktion';

  @override
  String get appSelection => 'App-Auswahl';

  @override
  String get appSubtitle => 'Professionelle Dateiübertragung';

  @override
  String get appTitle => 'File Transfer';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get archives => 'Archive';

  @override
  String get audio => 'Audio';

  @override
  String get automatic => 'Automatisch';

  @override
  String get batchSelection => 'Mehrfachauswahl';

  @override
  String get bluetoothDevices => 'Bluetooth-Geräte';

  @override
  String get bluetoothNoDevicesMessage =>
      'Starten Sie das Scannen, um Bluetooth-Geräte in der Nähe zu finden';

  @override
  String get bluetoothPermission => 'Bluetooth-Berechtigung erforderlich';

  @override
  String get bluetoothScanning => 'Bluetooth-Geräte werden gesucht...';

  @override
  String get bluetoothTransfer => 'Über Bluetooth';

  @override
  String get canSelectMultipleFiles => 'Sie können mehrere Dateien auswählen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get cancelTransfer => 'Übertragung abbrechen';

  @override
  String get cancelTransferConfirm =>
      'Möchten Sie diese Übertragung wirklich abbrechen und aus dem Verlauf löschen?';

  @override
  String get change => 'Ändern';

  @override
  String get changePath => 'Pfad ändern';

  @override
  String get changePhoto => 'Foto ändern';

  @override
  String get clear => 'Leeren';

  @override
  String get clearAll => 'Alles löschen';

  @override
  String get clipboard => 'Universelle Zwischenablage';

  @override
  String get clipboardHint => 'Text eingeben oder einfügen...';

  @override
  String get clipboardSharing => 'Textfreigabe';

  @override
  String get clipboardSharingDescription =>
      'Fügen Sie Text hier ein und teilen Sie ihn mit anderen Geräten im Netzwerk.';

  @override
  String get copy => 'Kopieren';

  @override
  String get paste => 'Einfügen';

  @override
  String get clickOrDragToUpload => 'Klicken oder ziehen zum Hochladen';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get connectSameNetwork => 'Mit demselben Netzwerk verbinden';

  @override
  String get connectSameNetworkMessage =>
      'Beide Geräte müssen mit demselben WLAN verbunden sein';

  @override
  String get connectWithQRCode => 'Mit QR-Code verbinden';

  @override
  String get connected => 'Verbunden';

  @override
  String get connectedToWifi => 'Mit WLAN verbunden';

  @override
  String get connecting => 'Verbindung wird hergestellt...';

  @override
  String get connectionFailed => 'Verbindung fehlgeschlagen';

  @override
  String get connectionInfo => 'Verbindungsinformationen';

  @override
  String get copiedToClipboard => 'In die Zwischenablage kopiert';

  @override
  String couldNotOpenUrl(Object url) {
    return 'URL konnte nicht geöffnet werden: $url';
  }

  @override
  String get date => 'Datum';

  @override
  String daysAgo(Object days) {
    return 'vor $days Tagen';
  }

  @override
  String get delete => 'Löschen';

  @override
  String deleteFailed(Object error) {
    return 'Löschen fehlgeschlagen: $error';
  }

  @override
  String get deleteTransfer => 'Übertragung löschen';

  @override
  String get deleteTransferConfirm =>
      'Möchten Sie diese Übertragung wirklich dauerhaft aus dem Verlauf löschen?';

  @override
  String get disconnected => 'Getrennt';

  @override
  String get displayNameNote =>
      'Dieser Name wird Empfängern beim Teilen angezeigt';

  @override
  String get documents => 'Dokumente';

  @override
  String get donate => 'Unterstützen';

  @override
  String get downloadDirectory => 'Download-Ordner';

  @override
  String get dropFilesHere => 'Dateien hier ablegen';

  @override
  String get easy => 'Einfach';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get english => 'English';

  @override
  String get enterName => 'Geben Sie Ihren Namen ein';

  @override
  String get error => 'Fehler';

  @override
  String errorLoadingApps(Object error) {
    return 'Fehler beim Laden der Apps: $error';
  }

  @override
  String errorLoadingHistory(Object error) {
    return 'Übertragungsverlauf konnte nicht geladen werden: $error';
  }

  @override
  String errorPickingFiles(Object error) {
    return 'Fehler beim Auswählen der Dateien: $error';
  }

  @override
  String get failed => 'Fehlgeschlagen';

  @override
  String get fast => 'Schnell';

  @override
  String get features => 'Funktionen';

  @override
  String get feedback => 'Feedback';

  @override
  String get fetching => 'Wird geladen...';

  @override
  String get fileCount => 'Dateianzahl';

  @override
  String get fileReceived => 'Datei empfangen';

  @override
  String fileReceivedFrom(Object filename) {
    return '$filename empfangen';
  }

  @override
  String get fileSelection => 'Dateiauswahl';

  @override
  String get files => 'Dateien';

  @override
  String filesCount(Object count) {
    return '$count Dateien';
  }

  @override
  String filesSelected(Object count) {
    return '$count Dateien ausgewählt';
  }

  @override
  String filesSharing(Object count) {
    return '$count Dateien werden freigegeben';
  }

  @override
  String get filterBy => 'Filtern nach';

  @override
  String get findDevices => 'Geräte suchen';

  @override
  String get followUs => 'Folgen Sie uns';

  @override
  String get generateNewPIN => 'Neuen PIN generieren';

  @override
  String get german => 'Deutsch';

  @override
  String get goBack => 'Zurück';

  @override
  String get grantPermission => 'Berechtigung erteilen';

  @override
  String get highSpeedTransfer => 'Hochgeschwindigkeitsübertragung';

  @override
  String get history => 'Übertragungsverlauf';

  @override
  String get home => 'Startseite';

  @override
  String hoursAgo(Object hours) {
    return 'vor $hours Stunden';
  }

  @override
  String get howItWorks => 'Wie es funktioniert?';

  @override
  String get images => 'Bilder';

  @override
  String get shareWithFriends => 'Mit Freunden teilen';

  @override
  String get shareAppText =>
      'Schauen Sie sich diese fantastische Dateiübertragungs-App an! Laden Sie sie von Google Play herunter: https://play.google.com/store/apps/details?id=com.filetransfer.pro';

  @override
  String get invalidQRCode =>
      'Ungültiger QR-Code. Bitte scannen Sie einen File Transfer Freigabecode.';

  @override
  String get ipAddress => 'IP-Adresse';

  @override
  String get ipAddressTakenError =>
      'IP-Adresse konnte nicht abgerufen werden. Stellen Sie sicher, dass Sie mit dem WLAN verbunden sind.';

  @override
  String get keepScreenOpenMessage =>
      'Die Freigabe bleibt aktiv, solange dieser Bildschirm geöffnet bleibt.';

  @override
  String get language => 'Sprache & Region';

  @override
  String get live => 'LIVE';

  @override
  String get loading => 'Wird geladen...';

  @override
  String get localNetworkSecurity => 'Lokale Netzwerksicherheit';

  @override
  String get locationPermission => 'Standortberechtigung erforderlich';

  @override
  String minutesAgo(Object minutes) {
    return 'vor $minutes Minuten';
  }

  @override
  String get multiFile => 'Mehrere Dateien';

  @override
  String get multiPlatform => 'Plattformübergreifend';

  @override
  String get nearbyDevices => 'Geräte in der Nähe';

  @override
  String get networkInfo => 'Netzwerkinformationen';

  @override
  String get networkOffline => 'Keine Netzwerkverbindung';

  @override
  String get networkOfflineMessage =>
      'Für die Geräteerkennung ist eine WLAN-Verbindung erforderlich. Bitte schalten Sie WLAN ein und versuchen Sie es erneut.';

  @override
  String get networkTransfer => 'Über WLAN-Netzwerk';

  @override
  String get no => 'Nein';

  @override
  String get noAppsFound => 'Keine Apps gefunden';

  @override
  String get noDevicesFound => 'Noch keine Geräte gefunden';

  @override
  String get noDevicesFoundMessage =>
      'Stellen Sie sicher, dass File Transfer auf anderen Geräten geöffnet ist und diese mit demselben WLAN-Netzwerk verbunden sind';

  @override
  String get noFilesSharedYet => 'Noch keine Dateien freigegeben';

  @override
  String get noMatchingFiles => 'Keine passenden Dateien gefunden';

  @override
  String get noMatchingFilesFound => 'Keine passenden Dateien gefunden';

  @override
  String get noReceivedFiles => 'Noch keine empfangenen Dateien';

  @override
  String get noResultsFound => 'Keine Ergebnisse gefunden';

  @override
  String get noResultsMessage =>
      'Keine Übertragungen gefunden, die Ihren Suchkriterien entsprechen. Versuchen Sie es mit einem anderen Suchbegriff.';

  @override
  String get noSentFiles => 'Noch keine gesendeten Dateien';

  @override
  String get noSizeLimit => 'Keine Größenbeschränkung';

  @override
  String get offline => 'Offline';

  @override
  String get offlineWlanNotConnected => 'Offline - Nicht mit WLAN verbunden';

  @override
  String get ok => 'OK';

  @override
  String get online => 'Online';

  @override
  String get onlineWlanConnected => 'Online - Mit WLAN verbunden';

  @override
  String get onlyUserApps => 'Nur Benutzer-Apps';

  @override
  String get openFolder => 'Ordner öffnen';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get openingConnection =>
      'Verbindung wird hergestellt, um Dateien zu empfangen...';

  @override
  String get orEnterAddress => 'Oder geben Sie diese Adresse im Browser ein:';

  @override
  String get other => 'Andere';

  @override
  String get pause => 'Pause';

  @override
  String get paused => 'Pausiert';

  @override
  String get permissionRequired => 'Berechtigung erforderlich';

  @override
  String get pinCode => 'PIN-Code';

  @override
  String get pinMessage =>
      'Das empfangende Gerät muss diesen PIN-Code eingeben, um auf die Dateien zuzugreifen.';

  @override
  String get pinProtection => 'PIN-Schutz';

  @override
  String get pleaseConnectToWifi =>
      'Bitte verbinden Sie sich in den WLAN-Einstellungen mit einem Netzwerk.';

  @override
  String get preparingSharing => 'Freigabe wird vorbereitet...';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get proUser => 'Pro-Benutzer';

  @override
  String get profile => 'Profil';

  @override
  String get profileName => 'Anzeigename';

  @override
  String get progress => 'Fortschritt';

  @override
  String get qrCodeFound => 'QR-Code gefunden';

  @override
  String get quickActions => 'Schnellaktionen';

  @override
  String get quickAndSecure => 'Schnelle und sichere Dateiübertragung';

  @override
  String get receiveFile => 'Datei empfangen';

  @override
  String get receiveFilesDescription => 'Sofort per QR-Code herunterladen';

  @override
  String receiverName(Object name) {
    return 'Empfänger: $name';
  }

  @override
  String get receiverScanQRMessage =>
      'Das empfangende Gerät kann diesen QR-Code scannen, um auf Dateien zuzugreifen';

  @override
  String get receiving => 'Wird empfangen';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get releaseToDrop => 'Loslassen zum Ablegen';

  @override
  String get removePhoto => 'Foto entfernen';

  @override
  String get resume => 'Fortsetzen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get scanQR => 'QR-Code scannen';

  @override
  String get scanQRCode => 'QR-Code scannen';

  @override
  String get scanQRCodeToDownload => 'QR-Code scannen';

  @override
  String get scanQrInstruction => 'Platzieren Sie den QR-Code im Kamerarahmen';

  @override
  String get scanQrSuccessMessage =>
      'Dateien werden automatisch geöffnet, wenn der Code gescannt wird';

  @override
  String get scanStopped => 'Suche gestoppt';

  @override
  String get scanningDevices => 'Suche nach Geräten im selben Netzwerk...';

  @override
  String get scanningStopped => 'Suche gestoppt';

  @override
  String get searchApps => 'Apps suchen...';

  @override
  String get searchByFileNameOrId => 'Nach Dateiname oder ID suchen...';

  @override
  String get searchFiles => 'Dateien suchen...';

  @override
  String searchInFiles(Object count) {
    return 'In $count Dateien suchen...';
  }

  @override
  String get secure => 'Sicher';

  @override
  String get selectApp => 'App auswählen';

  @override
  String get selectApps => 'Apps auswählen';

  @override
  String get selectAtLeastOneFile =>
      'Bitte wählen Sie mindestens eine Datei aus';

  @override
  String get selectFiles => 'Dateien auswählen';

  @override
  String get selectFilesMessage => 'Wählen Sie Dateien zum Teilen aus';

  @override
  String get selectFilesToShare => 'Dateien zum Teilen auswählen';

  @override
  String selectedFilesCount(Object count) {
    return 'Ausgewählte Dateien ($count)';
  }

  @override
  String get sendFile => 'Datei senden';

  @override
  String senderName(Object name) {
    return 'Absender: $name';
  }

  @override
  String get sending => 'Wird gesendet';

  @override
  String get serverActive => 'Server aktiv';

  @override
  String get serverPort => 'Server-Port';

  @override
  String get serverStartError => 'Server konnte nicht gestartet werden';

  @override
  String get serverStartErrorWifi =>
      'Server konnte nicht gestartet werden. Bitte WLAN-Verbindung prüfen.';

  @override
  String get settings => 'Einstellungen';

  @override
  String get shareApp => 'App teilen';

  @override
  String get shareAppDescription => 'Installierte Apps als APK senden';

  @override
  String shareAppsCount(Object count) {
    return '$count Apps teilen';
  }

  @override
  String get shareFilesSecurely => 'Dateien sicher teilen';

  @override
  String get shareSelected => 'Ausgewählte teilen';

  @override
  String get sharedFiles => 'Freigegebene Dateien';

  @override
  String get sharingActive => 'Freigabe aktiv!';

  @override
  String get sharingFailed => 'Freigabe konnte nicht gestartet werden';

  @override
  String get sharingInfo => 'Freigabeinformationen';

  @override
  String get showConnectionInfo => 'Verbindungsinformationen anzeigen';

  @override
  String get showSystemApps => 'System-Apps anzeigen';

  @override
  String get size => 'Größe';

  @override
  String get socialMedia => 'Soziale Medien';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get sortByDate => 'Nach Datum';

  @override
  String get sortByName => 'Nach Name';

  @override
  String get sortBySize => 'Nach Größe';

  @override
  String get sortByType => 'Nach Typ';

  @override
  String get startScanning => 'Suche starten';

  @override
  String get startSharing => 'Freigabe starten';

  @override
  String get startTime => 'Startzeit';

  @override
  String get startingServer => 'Server wird gestartet...';

  @override
  String get status => 'Status';

  @override
  String step(Object number) {
    return 'Schritt $number';
  }

  @override
  String get stopSharing => 'Freigabe beenden';

  @override
  String get storage => 'Speicher';

  @override
  String get storagePermission => 'Speicherberechtigung erforderlich';

  @override
  String get supportUs => 'Unterstützen Sie uns';

  @override
  String get supportedPlatforms => 'Android, Windows, Linux (iOS: IP-basiert)';

  @override
  String get theme => 'Design';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeLight => 'Hell';

  @override
  String get timeRemaining => 'Verbleibende Zeit';

  @override
  String get toggleOnlineStatus => 'Online-Status umschalten';

  @override
  String get totalSize => 'Gesamtgröße';

  @override
  String totalSizeWithLabel(Object size) {
    return 'Gesamtgröße: $size';
  }

  @override
  String get transferCode => 'Übertragungscode';

  @override
  String transferCodeWithLabel(Object code) {
    return 'Code: $code';
  }

  @override
  String get transferCompleted => 'Übertragung abgeschlossen!';

  @override
  String transferDeleteFailed(Object error) {
    return 'Übertragung konnte nicht gelöscht werden: $error';
  }

  @override
  String get transferDeleted => 'Übertragung gelöscht';

  @override
  String get transferDeletedSuccessfully => 'Übertragung erfolgreich gelöscht';

  @override
  String get transferDetails => 'Übertragungsdetails';

  @override
  String get transferFailed => 'Übertragung fehlgeschlagen';

  @override
  String get transferHistory => 'Übertragungsverlauf';

  @override
  String get transferHistoryEmpty => 'Übertragungsverlauf ist leer';

  @override
  String get transferHistoryEmptyMessage =>
      'Sie haben noch keine Dateiübertragungen vorgenommen. Kehren Sie zur Startseite zurück, um Ihre erste Übertragung durchzuführen.';

  @override
  String get transferInfo => 'Übertragungsinformationen';

  @override
  String get transferSpeed => 'Übertragungsgeschwindigkeit';

  @override
  String get transferViaBluetooth =>
      'Dateien über Bluetooth-Verbindung übertragen';

  @override
  String get transferViaNetwork => 'Dateien über WLAN-Netzwerk übertragen';

  @override
  String get transferred => 'Übertragen';

  @override
  String get turkish => 'Türkçe';

  @override
  String get ultraFast => 'Ultraschnell';

  @override
  String get unlimited => 'Unbegrenzt';

  @override
  String urlCannotOpen(Object url) {
    return 'URL kann nicht geöffnet werden: $url';
  }

  @override
  String get urlCopied => 'URL in die Zwischenablage kopiert';

  @override
  String get user => 'Benutzer';

  @override
  String get version => 'Version';

  @override
  String get videos => 'Videos';

  @override
  String get visitWebsite => 'Webseite besuchen';

  @override
  String get wifiRequired => 'WLAN erforderlich';

  @override
  String get wifiRequiredMessage =>
      'Für die Dateiübertragung müssen Sie mit einem WLAN-Netzwerk verbunden sein.';

  @override
  String get yes => 'Ja';

  @override
  String get completedFiles => 'Abgeschlossene Dateien';

  @override
  String get noTransfersYet => 'Noch keine Übertragungen';

  @override
  String get noSearchResults => 'Keine Ergebnisse gefunden';

  @override
  String get cameraPermissionRequired => 'Kameraberechtigung erforderlich';

  @override
  String get cameraPermissionMessage =>
      'Kamerazugriff wird benötigt, um QR-Codes zu scannen und Verbindungen herzustellen. Bitte erteilen Sie die Berechtigung.';

  @override
  String get storagePermissionRequired => 'Speicherberechtigung erforderlich';

  @override
  String get storagePermissionMessage =>
      'Speicherzugriff wird benötigt, um Dateien herunterzuladen und zu teilen.';

  @override
  String get notificationPermissionRequired =>
      'Benachrichtigungsberechtigung erforderlich';

  @override
  String get notificationPermissionMessage =>
      'Benachrichtigungsberechtigung wird benötigt, um Sie über abgeschlossene Übertragungen zu informieren.';

  @override
  String get permissionPermanentlyDenied =>
      'Berechtigung dauerhaft verweigert. Bitte erteilen Sie sie in den App-Einstellungen.';

  @override
  String get permissionDeniedTitle => 'Berechtigung verweigert';

  @override
  String get shareWithFriendsFull => 'Mit Freunden teilen';

  @override
  String get supportApp => 'App unterstützen';

  @override
  String get supportStatusActive => 'Unterstützungsstatus: Aktiv';

  @override
  String get supportStatusInactive => 'Unterstützungsstatus: Inaktiv';

  @override
  String supportRemainingTime(Object time) {
    return 'Verbleibende Unterstützungszeit: $time';
  }

  @override
  String get supportExtend => 'Werbung ansehen & unterstützen (+24 Std.)';

  @override
  String get supportDescription =>
      'Sie können unsere App unterstützen und bis zu 48 Stunden ein werbefreies Erlebnis durch das Ansehen eines kurzen Videos genießen.';

  @override
  String get supportMaxReached =>
      'Sie haben die maximale Unterstützungszeit von 48 Stunden erreicht. Vielen Dank!';

  @override
  String get supportThankYouTitle => 'Vielen Dank! ❤️';

  @override
  String get supportThankYouMessage =>
      'Vielen Dank für Ihre Unterstützung unserer App! Ihre Unterstützungszeit wurde erfolgreich verlängert.';

  @override
  String get adLoading => 'Werbung wird geladen, bitte warten...';

  @override
  String get adFailedToLoad =>
      'Werbung konnte derzeit nicht geladen werden. Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.';

  @override
  String hoursMinutesRemaining(Object hours, Object minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String minutesRemaining(Object minutes) {
    return '$minutes Min.';
  }

  @override
  String get notNow => 'Nicht jetzt';

  @override
  String get gallery => 'Galerie';

  @override
  String get camera => 'Kamera';

  @override
  String get fileNotFound => 'Datei nicht gefunden';

  @override
  String get open => 'Öffnen';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get rateAppTitle => 'Gefällt Ihnen File Transfer?';

  @override
  String get rateAppDescription =>
      'Ihr Feedback ist uns sehr wichtig! Unterstützen Sie uns mit 5 Sternen und einer Bewertung.';

  @override
  String get rateNow => 'Auf Google Play bewerten';

  @override
  String get remindMeLater => 'Später erinnern';

  @override
  String get dontAskAgain => 'Nicht mehr fragen';

  @override
  String get rateThankYou => 'Vielen Dank für Ihre Bewertung!';

  @override
  String get deviceName => 'Gerätename';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get chooseAvatar => 'Avatar wählen';

  @override
  String get appFolderNotice => 'Standardordner: file_transfer';

  @override
  String get recentTransfers => 'Letzte Übertragungen';

  @override
  String get noRecentTransfers => 'Noch keine Übertragungen';

  @override
  String get seeAll => 'Alle anzeigen';

  @override
  String get clipboardSync => 'Zwischenablage';

  @override
  String get connectedWifi => 'Verbunden';

  @override
  String get notConnected => 'Nicht verbunden';

  @override
  String get resuming => 'Übertragung wird fortgesetzt...';
}
