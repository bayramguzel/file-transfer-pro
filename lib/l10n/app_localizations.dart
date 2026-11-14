import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @filesAdded.
  ///
  /// In en, this message translates to:
  /// **'files added'**
  String get filesAdded;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'File Transfer v1.0.0'**
  String get aboutApp;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Professional and secure file transfer solution.\n\nShare files quickly, easily and securely over Wi-Fi and Bluetooth.'**
  String get aboutDescription;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get accentColor;

  /// No description provided for @activeSharings.
  ///
  /// In en, this message translates to:
  /// **'Active Sharings'**
  String get activeSharings;

  /// No description provided for @addMore.
  ///
  /// In en, this message translates to:
  /// **'Add More'**
  String get addMore;

  /// No description provided for @allFileTypesSupported.
  ///
  /// In en, this message translates to:
  /// **'All file types • Unlimited size'**
  String get allFileTypesSupported;

  /// No description provided for @allFiles.
  ///
  /// In en, this message translates to:
  /// **'All Files'**
  String get allFiles;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An Error Occurred'**
  String get anErrorOccurred;

  /// No description provided for @apkExtraction.
  ///
  /// In en, this message translates to:
  /// **'APK Extraction'**
  String get apkExtraction;

  /// No description provided for @appSelection.
  ///
  /// In en, this message translates to:
  /// **'App Selection'**
  String get appSelection;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Professional File Transfer'**
  String get appSubtitle;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'File Transfer'**
  String get appTitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @archives.
  ///
  /// In en, this message translates to:
  /// **'Archives'**
  String get archives;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// No description provided for @batchSelection.
  ///
  /// In en, this message translates to:
  /// **'Batch Selection'**
  String get batchSelection;

  /// No description provided for @bluetoothDevices.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Devices'**
  String get bluetoothDevices;

  /// No description provided for @bluetoothNoDevicesMessage.
  ///
  /// In en, this message translates to:
  /// **'Start scanning to see nearby Bluetooth devices'**
  String get bluetoothNoDevicesMessage;

  /// No description provided for @bluetoothPermission.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permission required'**
  String get bluetoothPermission;

  /// No description provided for @bluetoothScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning for Bluetooth devices...'**
  String get bluetoothScanning;

  /// No description provided for @bluetoothTransfer.
  ///
  /// In en, this message translates to:
  /// **'Via Bluetooth'**
  String get bluetoothTransfer;

  /// No description provided for @canSelectMultipleFiles.
  ///
  /// In en, this message translates to:
  /// **'You can select multiple files'**
  String get canSelectMultipleFiles;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancelTransfer.
  ///
  /// In en, this message translates to:
  /// **'Cancel Transfer'**
  String get cancelTransfer;

  /// No description provided for @cancelTransferConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this transfer and delete it from history?'**
  String get cancelTransferConfirm;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @changePath.
  ///
  /// In en, this message translates to:
  /// **'Change Path'**
  String get changePath;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @clipboard.
  ///
  /// In en, this message translates to:
  /// **'Universal Clipboard'**
  String get clipboard;

  /// No description provided for @clipboardHint.
  ///
  /// In en, this message translates to:
  /// **'Type or paste text here...'**
  String get clipboardHint;

  /// No description provided for @clipboardSharing.
  ///
  /// In en, this message translates to:
  /// **'Text Sharing'**
  String get clipboardSharing;

  /// No description provided for @clipboardSharingDescription.
  ///
  /// In en, this message translates to:
  /// **'Paste text here and share it with other devices on the network.'**
  String get clipboardSharingDescription;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @clickOrDragToUpload.
  ///
  /// In en, this message translates to:
  /// **'Click or drag to upload'**
  String get clickOrDragToUpload;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @connectSameNetwork.
  ///
  /// In en, this message translates to:
  /// **'Connect to Same Network'**
  String get connectSameNetwork;

  /// No description provided for @connectSameNetworkMessage.
  ///
  /// In en, this message translates to:
  /// **'Both devices must be on the same Wi-Fi'**
  String get connectSameNetworkMessage;

  /// No description provided for @connectWithQRCode.
  ///
  /// In en, this message translates to:
  /// **'Connect with QR Code'**
  String get connectWithQRCode;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @connectedToWifi.
  ///
  /// In en, this message translates to:
  /// **'Connected to Wi-Fi'**
  String get connectedToWifi;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get connectionFailed;

  /// No description provided for @connectionInfo.
  ///
  /// In en, this message translates to:
  /// **'Connection Information'**
  String get connectionInfo;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @couldNotOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not open URL: {url}'**
  String couldNotOpenUrl(Object url);

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(Object days);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String deleteFailed(Object error);

  /// No description provided for @deleteTransfer.
  ///
  /// In en, this message translates to:
  /// **'Delete Transfer'**
  String get deleteTransfer;

  /// No description provided for @deleteTransferConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this transfer from history?'**
  String get deleteTransferConfirm;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @displayNameNote.
  ///
  /// In en, this message translates to:
  /// **'This name is shown to recipients when sharing files'**
  String get displayNameNote;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @downloadDirectory.
  ///
  /// In en, this message translates to:
  /// **'Download Directory'**
  String get downloadDirectory;

  /// No description provided for @dropFilesHere.
  ///
  /// In en, this message translates to:
  /// **'Drop files here'**
  String get dropFilesHere;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorLoadingApps.
  ///
  /// In en, this message translates to:
  /// **'Error loading apps: {error}'**
  String errorLoadingApps(Object error);

  /// No description provided for @errorLoadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Failed to load transfer history: {error}'**
  String errorLoadingHistory(Object error);

  /// No description provided for @errorPickingFiles.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while picking files: {error}'**
  String errorPickingFiles(Object error);

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @fetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching...'**
  String get fetching;

  /// No description provided for @fileCount.
  ///
  /// In en, this message translates to:
  /// **'File Count'**
  String get fileCount;

  /// No description provided for @fileReceived.
  ///
  /// In en, this message translates to:
  /// **'File Received'**
  String get fileReceived;

  /// No description provided for @fileReceivedFrom.
  ///
  /// In en, this message translates to:
  /// **'Received {filename}'**
  String fileReceivedFrom(Object filename);

  /// No description provided for @fileSelection.
  ///
  /// In en, this message translates to:
  /// **'File Selection'**
  String get fileSelection;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @filesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} files'**
  String filesCount(Object count);

  /// No description provided for @filesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} files selected'**
  String filesSelected(Object count);

  /// No description provided for @filesSharing.
  ///
  /// In en, this message translates to:
  /// **'{count} files sharing'**
  String filesSharing(Object count);

  /// No description provided for @filterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter By'**
  String get filterBy;

  /// No description provided for @findDevices.
  ///
  /// In en, this message translates to:
  /// **'Find Devices'**
  String get findDevices;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get followUs;

  /// No description provided for @generateNewPIN.
  ///
  /// In en, this message translates to:
  /// **'Generate New PIN'**
  String get generateNewPIN;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @highSpeedTransfer.
  ///
  /// In en, this message translates to:
  /// **'High speed transfer'**
  String get highSpeedTransfer;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'Transfer History'**
  String get history;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(Object hours);

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it Works?'**
  String get howItWorks;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @shareWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Share with Friends'**
  String get shareWithFriends;

  /// No description provided for @shareAppText.
  ///
  /// In en, this message translates to:
  /// **'Check out this amazing file transfer app! Download it from Google Play: https://play.google.com/store/apps/details?id=com.filetransfer.pro'**
  String get shareAppText;

  /// No description provided for @invalidQRCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code. Please scan a File Transfer sharing code.'**
  String get invalidQRCode;

  /// No description provided for @ipAddress.
  ///
  /// In en, this message translates to:
  /// **'IP Address'**
  String get ipAddress;

  /// No description provided for @ipAddressTakenError.
  ///
  /// In en, this message translates to:
  /// **'IP address could not be obtained. Make sure you are connected to Wi-Fi.'**
  String get ipAddressTakenError;

  /// No description provided for @keepScreenOpenMessage.
  ///
  /// In en, this message translates to:
  /// **'Sharing will remain active as long as you keep this screen open.'**
  String get keepScreenOpenMessage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language & Region'**
  String get language;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @localNetworkSecurity.
  ///
  /// In en, this message translates to:
  /// **'Local network security'**
  String get localNetworkSecurity;

  /// No description provided for @locationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location permission required'**
  String get locationPermission;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @multiFile.
  ///
  /// In en, this message translates to:
  /// **'Multi File'**
  String get multiFile;

  /// No description provided for @multiPlatform.
  ///
  /// In en, this message translates to:
  /// **'Multi-Platform'**
  String get multiPlatform;

  /// No description provided for @nearbyDevices.
  ///
  /// In en, this message translates to:
  /// **'Nearby Devices'**
  String get nearbyDevices;

  /// No description provided for @networkInfo.
  ///
  /// In en, this message translates to:
  /// **'Network Info'**
  String get networkInfo;

  /// No description provided for @networkOffline.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get networkOffline;

  /// No description provided for @networkOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi connection is required for device discovery. Please turn on Wi-Fi and try again.'**
  String get networkOfflineMessage;

  /// No description provided for @networkTransfer.
  ///
  /// In en, this message translates to:
  /// **'Via Network'**
  String get networkTransfer;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noAppsFound.
  ///
  /// In en, this message translates to:
  /// **'No apps found'**
  String get noAppsFound;

  /// No description provided for @noDevicesFound.
  ///
  /// In en, this message translates to:
  /// **'No Devices Found Yet'**
  String get noDevicesFound;

  /// No description provided for @noDevicesFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Make sure File Transfer is open on other devices and they are connected to the same Wi-Fi network'**
  String get noDevicesFoundMessage;

  /// No description provided for @noFilesSharedYet.
  ///
  /// In en, this message translates to:
  /// **'No files shared yet'**
  String get noFilesSharedYet;

  /// No description provided for @noMatchingFiles.
  ///
  /// In en, this message translates to:
  /// **'No files found matching your search'**
  String get noMatchingFiles;

  /// No description provided for @noMatchingFilesFound.
  ///
  /// In en, this message translates to:
  /// **'No matching files found'**
  String get noMatchingFilesFound;

  /// No description provided for @noReceivedFiles.
  ///
  /// In en, this message translates to:
  /// **'No received files yet'**
  String get noReceivedFiles;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get noResultsFound;

  /// No description provided for @noResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'No transfers found matching your search criteria. Try a different search term.'**
  String get noResultsMessage;

  /// No description provided for @noSentFiles.
  ///
  /// In en, this message translates to:
  /// **'No sent files yet'**
  String get noSentFiles;

  /// No description provided for @noSizeLimit.
  ///
  /// In en, this message translates to:
  /// **'No size limit'**
  String get noSizeLimit;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @offlineWlanNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Offline - Not connected to WLAN'**
  String get offlineWlanNotConnected;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @onlineWlanConnected.
  ///
  /// In en, this message translates to:
  /// **'Online - Connected to WLAN'**
  String get onlineWlanConnected;

  /// No description provided for @onlyUserApps.
  ///
  /// In en, this message translates to:
  /// **'Only User Apps'**
  String get onlyUserApps;

  /// No description provided for @openFolder.
  ///
  /// In en, this message translates to:
  /// **'Open Folder'**
  String get openFolder;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @openingConnection.
  ///
  /// In en, this message translates to:
  /// **'Opening connection to receive files...'**
  String get openingConnection;

  /// No description provided for @orEnterAddress.
  ///
  /// In en, this message translates to:
  /// **'Or enter this address in browser:'**
  String get orEnterAddress;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @pinCode.
  ///
  /// In en, this message translates to:
  /// **'PIN Code'**
  String get pinCode;

  /// No description provided for @pinMessage.
  ///
  /// In en, this message translates to:
  /// **'The receiving device must enter this PIN code to access the files.'**
  String get pinMessage;

  /// No description provided for @pinProtection.
  ///
  /// In en, this message translates to:
  /// **'PIN Protection'**
  String get pinProtection;

  /// No description provided for @pleaseConnectToWifi.
  ///
  /// In en, this message translates to:
  /// **'Please connect to a wireless network from your Wi-Fi settings.'**
  String get pleaseConnectToWifi;

  /// No description provided for @preparingSharing.
  ///
  /// In en, this message translates to:
  /// **'Preparing Sharing...'**
  String get preparingSharing;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @proUser.
  ///
  /// In en, this message translates to:
  /// **'Pro User'**
  String get proUser;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profileName;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @qrCodeFound.
  ///
  /// In en, this message translates to:
  /// **'QR Code Found'**
  String get qrCodeFound;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @quickAndSecure.
  ///
  /// In en, this message translates to:
  /// **'Quick and Secure File Transfer'**
  String get quickAndSecure;

  /// No description provided for @receiveFile.
  ///
  /// In en, this message translates to:
  /// **'Receive File'**
  String get receiveFile;

  /// No description provided for @receiveFilesDescription.
  ///
  /// In en, this message translates to:
  /// **'Download instantly with QR code'**
  String get receiveFilesDescription;

  /// No description provided for @receiverName.
  ///
  /// In en, this message translates to:
  /// **'Receiver: {name}'**
  String receiverName(Object name);

  /// No description provided for @receiverScanQRMessage.
  ///
  /// In en, this message translates to:
  /// **'The receiving device can access files by scanning this QR code'**
  String get receiverScanQRMessage;

  /// No description provided for @receiving.
  ///
  /// In en, this message translates to:
  /// **'Receiving'**
  String get receiving;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @releaseToDrop.
  ///
  /// In en, this message translates to:
  /// **'Release to drop'**
  String get releaseToDrop;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @scanQR.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get scanQR;

  /// No description provided for @scanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCode;

  /// No description provided for @scanQRCodeToDownload.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQRCodeToDownload;

  /// No description provided for @scanQrInstruction.
  ///
  /// In en, this message translates to:
  /// **'Place the QR code within the camera frame'**
  String get scanQrInstruction;

  /// No description provided for @scanQrSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Files will open automatically when the code is scanned'**
  String get scanQrSuccessMessage;

  /// No description provided for @scanStopped.
  ///
  /// In en, this message translates to:
  /// **'Scan stopped'**
  String get scanStopped;

  /// No description provided for @scanningDevices.
  ///
  /// In en, this message translates to:
  /// **'Scanning for devices on the same network...'**
  String get scanningDevices;

  /// No description provided for @scanningStopped.
  ///
  /// In en, this message translates to:
  /// **'Scanning stopped'**
  String get scanningStopped;

  /// No description provided for @searchApps.
  ///
  /// In en, this message translates to:
  /// **'Search apps...'**
  String get searchApps;

  /// No description provided for @searchByFileNameOrId.
  ///
  /// In en, this message translates to:
  /// **'Search by file name or ID...'**
  String get searchByFileNameOrId;

  /// No description provided for @searchFiles.
  ///
  /// In en, this message translates to:
  /// **'Search files...'**
  String get searchFiles;

  /// No description provided for @searchInFiles.
  ///
  /// In en, this message translates to:
  /// **'Search in {count} files...'**
  String searchInFiles(Object count);

  /// No description provided for @secure.
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get secure;

  /// No description provided for @selectApp.
  ///
  /// In en, this message translates to:
  /// **'Select App'**
  String get selectApp;

  /// No description provided for @selectApps.
  ///
  /// In en, this message translates to:
  /// **'Select Apps'**
  String get selectApps;

  /// No description provided for @selectAtLeastOneFile.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one file'**
  String get selectAtLeastOneFile;

  /// No description provided for @selectFiles.
  ///
  /// In en, this message translates to:
  /// **'Select Your Files'**
  String get selectFiles;

  /// No description provided for @selectFilesMessage.
  ///
  /// In en, this message translates to:
  /// **'Select files to share'**
  String get selectFilesMessage;

  /// No description provided for @selectFilesToShare.
  ///
  /// In en, this message translates to:
  /// **'Select files to share'**
  String get selectFilesToShare;

  /// No description provided for @selectedFilesCount.
  ///
  /// In en, this message translates to:
  /// **'Selected Files ({count})'**
  String selectedFilesCount(Object count);

  /// No description provided for @sendFile.
  ///
  /// In en, this message translates to:
  /// **'Send File'**
  String get sendFile;

  /// No description provided for @senderName.
  ///
  /// In en, this message translates to:
  /// **'Sender: {name}'**
  String senderName(Object name);

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get sending;

  /// No description provided for @serverActive.
  ///
  /// In en, this message translates to:
  /// **'Server Active'**
  String get serverActive;

  /// No description provided for @serverPort.
  ///
  /// In en, this message translates to:
  /// **'Server Port'**
  String get serverPort;

  /// No description provided for @serverStartError.
  ///
  /// In en, this message translates to:
  /// **'Server could not be started'**
  String get serverStartError;

  /// No description provided for @serverStartErrorWifi.
  ///
  /// In en, this message translates to:
  /// **'Server could not be started. Check Wi-Fi connection.'**
  String get serverStartErrorWifi;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @shareAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Send installed apps as APK'**
  String get shareAppDescription;

  /// No description provided for @shareAppsCount.
  ///
  /// In en, this message translates to:
  /// **'Share {count} Apps'**
  String shareAppsCount(Object count);

  /// No description provided for @shareFilesSecurely.
  ///
  /// In en, this message translates to:
  /// **'Share your files securely'**
  String get shareFilesSecurely;

  /// No description provided for @shareSelected.
  ///
  /// In en, this message translates to:
  /// **'Share Selected'**
  String get shareSelected;

  /// No description provided for @sharedFiles.
  ///
  /// In en, this message translates to:
  /// **'Shared Files'**
  String get sharedFiles;

  /// No description provided for @sharingActive.
  ///
  /// In en, this message translates to:
  /// **'Sharing Active!'**
  String get sharingActive;

  /// No description provided for @sharingFailed.
  ///
  /// In en, this message translates to:
  /// **'Sharing Could Not Be Started'**
  String get sharingFailed;

  /// No description provided for @sharingInfo.
  ///
  /// In en, this message translates to:
  /// **'Sharing Information'**
  String get sharingInfo;

  /// No description provided for @showConnectionInfo.
  ///
  /// In en, this message translates to:
  /// **'Show Connection Info'**
  String get showConnectionInfo;

  /// No description provided for @showSystemApps.
  ///
  /// In en, this message translates to:
  /// **'Show system apps'**
  String get showSystemApps;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @socialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get socialMedia;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'By Date'**
  String get sortByDate;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'By Name'**
  String get sortByName;

  /// No description provided for @sortBySize.
  ///
  /// In en, this message translates to:
  /// **'By Size'**
  String get sortBySize;

  /// No description provided for @sortByType.
  ///
  /// In en, this message translates to:
  /// **'By Type'**
  String get sortByType;

  /// No description provided for @startScanning.
  ///
  /// In en, this message translates to:
  /// **'Start Scanning'**
  String get startScanning;

  /// No description provided for @startSharing.
  ///
  /// In en, this message translates to:
  /// **'Start Sharing'**
  String get startSharing;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @startingServer.
  ///
  /// In en, this message translates to:
  /// **'Starting server...'**
  String get startingServer;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String step(Object number);

  /// No description provided for @stopSharing.
  ///
  /// In en, this message translates to:
  /// **'Stop Sharing'**
  String get stopSharing;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @storagePermission.
  ///
  /// In en, this message translates to:
  /// **'Storage permission required'**
  String get storagePermission;

  /// No description provided for @supportUs.
  ///
  /// In en, this message translates to:
  /// **'Support Us'**
  String get supportUs;

  /// No description provided for @supportedPlatforms.
  ///
  /// In en, this message translates to:
  /// **'Android, Windows, Linux (iOS: IP Based)'**
  String get supportedPlatforms;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get timeRemaining;

  /// No description provided for @toggleOnlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Toggle Online Status'**
  String get toggleOnlineStatus;

  /// No description provided for @totalSize.
  ///
  /// In en, this message translates to:
  /// **'Total Size'**
  String get totalSize;

  /// No description provided for @totalSizeWithLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Size: {size}'**
  String totalSizeWithLabel(Object size);

  /// No description provided for @transferCode.
  ///
  /// In en, this message translates to:
  /// **'Transfer Code'**
  String get transferCode;

  /// No description provided for @transferCodeWithLabel.
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String transferCodeWithLabel(Object code);

  /// No description provided for @transferCompleted.
  ///
  /// In en, this message translates to:
  /// **'Transfer Completed!'**
  String get transferCompleted;

  /// No description provided for @transferDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete transfer: {error}'**
  String transferDeleteFailed(Object error);

  /// No description provided for @transferDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transfer deleted'**
  String get transferDeleted;

  /// No description provided for @transferDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transfer deleted successfully'**
  String get transferDeletedSuccessfully;

  /// No description provided for @transferDetails.
  ///
  /// In en, this message translates to:
  /// **'Transfer Details'**
  String get transferDetails;

  /// No description provided for @transferFailed.
  ///
  /// In en, this message translates to:
  /// **'Transfer Failed'**
  String get transferFailed;

  /// No description provided for @transferHistory.
  ///
  /// In en, this message translates to:
  /// **'Transfer History'**
  String get transferHistory;

  /// No description provided for @transferHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Transfer History is Empty'**
  String get transferHistoryEmpty;

  /// No description provided for @transferHistoryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t made any file transfers yet. Return to the home page to make your first transfer.'**
  String get transferHistoryEmptyMessage;

  /// No description provided for @transferInfo.
  ///
  /// In en, this message translates to:
  /// **'Transfer Information'**
  String get transferInfo;

  /// No description provided for @transferSpeed.
  ///
  /// In en, this message translates to:
  /// **'Transfer Speed'**
  String get transferSpeed;

  /// No description provided for @transferViaBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Transfer files via Bluetooth connection'**
  String get transferViaBluetooth;

  /// No description provided for @transferViaNetwork.
  ///
  /// In en, this message translates to:
  /// **'Transfer files over Wi-Fi network'**
  String get transferViaNetwork;

  /// No description provided for @transferred.
  ///
  /// In en, this message translates to:
  /// **'Transferred'**
  String get transferred;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @ultraFast.
  ///
  /// In en, this message translates to:
  /// **'Ultra Fast'**
  String get ultraFast;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @urlCannotOpen.
  ///
  /// In en, this message translates to:
  /// **'Cannot open URL: {url}'**
  String urlCannotOpen(Object url);

  /// No description provided for @urlCopied.
  ///
  /// In en, this message translates to:
  /// **'URL copied to clipboard'**
  String get urlCopied;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @visitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit Website'**
  String get visitWebsite;

  /// No description provided for @wifiRequired.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Required'**
  String get wifiRequired;

  /// No description provided for @wifiRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'You must be connected to a Wi-Fi network for file transfer.'**
  String get wifiRequiredMessage;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @completedFiles.
  ///
  /// In en, this message translates to:
  /// **'Completed Files'**
  String get completedFiles;

  /// No description provided for @noTransfersYet.
  ///
  /// In en, this message translates to:
  /// **'No transfers yet'**
  String get noTransfersYet;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noSearchResults;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission Required'**
  String get cameraPermissionRequired;

  /// No description provided for @cameraPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Camera access is needed to scan QR codes and connect. Please grant permission below.'**
  String get cameraPermissionMessage;

  /// No description provided for @storagePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Storage Permission Required'**
  String get storagePermissionRequired;

  /// No description provided for @storagePermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Storage access is required to download and share files.'**
  String get storagePermissionMessage;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission Required'**
  String get notificationPermissionRequired;

  /// No description provided for @notificationPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is needed to inform you when a transfer completes.'**
  String get notificationPermissionMessage;

  /// No description provided for @permissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission permanently denied. Please grant it from app settings.'**
  String get permissionPermanentlyDenied;

  /// No description provided for @permissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDeniedTitle;

  /// No description provided for @shareWithFriendsFull.
  ///
  /// In en, this message translates to:
  /// **'Share with Friends'**
  String get shareWithFriendsFull;

  /// No description provided for @supportApp.
  ///
  /// In en, this message translates to:
  /// **'Support Us'**
  String get supportApp;

  /// No description provided for @supportStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Support Status: Active'**
  String get supportStatusActive;

  /// No description provided for @supportStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Support Status: Inactive'**
  String get supportStatusInactive;

  /// No description provided for @supportRemainingTime.
  ///
  /// In en, this message translates to:
  /// **'Remaining Support Time: {time}'**
  String supportRemainingTime(Object time);

  /// No description provided for @supportExtend.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad & Support (+24 Hours)'**
  String get supportExtend;

  /// No description provided for @supportDescription.
  ///
  /// In en, this message translates to:
  /// **'You can support our app and enjoy up to 48 hours of ad-free supporter privileges by watching a short video ad.'**
  String get supportDescription;

  /// No description provided for @supportMaxReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached the maximum 48-hour support limit. You\'re amazing!'**
  String get supportMaxReached;

  /// No description provided for @supportThankYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank You! ❤️'**
  String get supportThankYouTitle;

  /// No description provided for @supportThankYouMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you so much for supporting our app! Your support duration has been extended successfully.'**
  String get supportThankYouMessage;

  /// No description provided for @adLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading ad, please wait...'**
  String get adLoading;

  /// No description provided for @adFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load ad at this moment. Please check your internet connection and try again.'**
  String get adFailedToLoad;

  /// No description provided for @hoursMinutesRemaining.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours {minutes} minutes'**
  String hoursMinutesRemaining(Object hours, Object minutes);

  /// No description provided for @minutesRemaining.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String minutesRemaining(Object minutes);

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get fileNotFound;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @rateAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoying File Transfer?'**
  String get rateAppTitle;

  /// No description provided for @rateAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Your feedback is very valuable to us! Support us by leaving 5 stars and a review.'**
  String get rateAppDescription;

  /// No description provided for @rateNow.
  ///
  /// In en, this message translates to:
  /// **'Rate on Google Play'**
  String get rateNow;

  /// No description provided for @remindMeLater.
  ///
  /// In en, this message translates to:
  /// **'Remind Me Later'**
  String get remindMeLater;

  /// No description provided for @dontAskAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Ask Again'**
  String get dontAskAgain;

  /// No description provided for @rateThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your rating!'**
  String get rateThankYou;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get deviceName;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @chooseAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose Avatar'**
  String get chooseAvatar;

  /// No description provided for @appFolderNotice.
  ///
  /// In en, this message translates to:
  /// **'Default Folder: file_transfer'**
  String get appFolderNotice;

  /// No description provided for @recentTransfers.
  ///
  /// In en, this message translates to:
  /// **'Recent Transfers'**
  String get recentTransfers;

  /// No description provided for @noRecentTransfers.
  ///
  /// In en, this message translates to:
  /// **'No recent transfers yet'**
  String get noRecentTransfers;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @clipboardSync.
  ///
  /// In en, this message translates to:
  /// **'Clipboard Sync'**
  String get clipboardSync;

  /// No description provided for @connectedWifi.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connectedWifi;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not Connected'**
  String get notConnected;

  /// No description provided for @resuming.
  ///
  /// In en, this message translates to:
  /// **'Resuming transfer...'**
  String get resuming;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
