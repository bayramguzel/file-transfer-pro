# Evrensel Pano (Universal Clipboard)

Bu dosya, File Transfer Pro uygulamasından ayrılan Evrensel Pano özelliğinin kodlarını ve mantığını içermektedir.

## Özellikler
- Cihazlar arası metin paylaşımı.
- Yerel ağ (Wi-Fi) üzerinden senkronizasyon.
- Web arayüzü desteği.
- QR Kod ile kolay bağlantı.

## Kullanılan Servisler
- `LocalNetworkService`: HTTP sunucusu ve mDNS reklamı için kullanılır.
- `Clipboard`: Flutter'ın yerel pano erişimi için kullanılır.

## Mevcut Kodlar

### 1. UI Sayfası (presentation/pages/clipboard_page.dart)
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../data/services/local_network_service.dart';
import '../widgets/qr_code_widget.dart';

class ClipboardPage extends StatefulWidget {
  const ClipboardPage({super.key});

  @override
  State<ClipboardPage> createState() => _ClipboardPageState();
}

class _ClipboardPageState extends State<ClipboardPage> {
  final TextEditingController _textController = TextEditingController();
  final LocalNetworkService _networkService = LocalNetworkService();
  String? _serverUrl;
  bool _isServerRunning = false;

  @override
  void initState() {
    super.initState();
    _loadClipboard();
    _startServer();

    // Listen to text changes to update server clipboard
    _textController.addListener(() {
      if (_networkService.clipboardContent != _textController.text) {
        _networkService.clipboardContent = _textController.text;
      }
    });

    // Listen to server clipboard changes (from web)
    _networkService.onClipboardChanged = (text) {
      if (mounted && _textController.text != text) {
        setState(() {
          _textController.text = text;
        });
      }
    };
  }

  Future<void> _startServer() async {
    final ip = await _networkService.getLocalIpAddress();
    if (ip != null) {
      // Start server with empty file list, just for clipboard
      await _networkService.startServer([]);
      if (mounted) {
        setState(() {
          _serverUrl = _networkService.getServerUrl(ip);
          _isServerRunning = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _networkService.stopServer();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _textController.text = data!.text!;
        _networkService.clipboardContent = data.text!;
      });
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _textController.text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.clipboardCopied)),
      );
    }
  }

  void _showConnectionInfo() {
    if (_serverUrl == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.connectionInfo,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              QrCodeWidget(data: _serverUrl!, size: 200),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _serverUrl!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.clipboardConnectionMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.universalClipboardTitle),
        elevation: 0,
        actions: [
          if (_isServerRunning)
            IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: _showConnectionInfo,
              tooltip: AppLocalizations.of(context)!.connectionInfo,
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isServerRunning)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(AppLocalizations.of(context)!
                              .serverStartErrorWifi)),
                    ],
                  ),
                ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.paste_rounded,
                          size: 48, color: Colors.blue),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.textSharingTitle,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.textSharingDescription,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.clipboardHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loadClipboard,
                      icon: const Icon(Icons.paste),
                      label: Text(AppLocalizations.of(context)!.paste),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy),
                      label: Text(AppLocalizations.of(context)!.copy),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isServerRunning)
                ElevatedButton.icon(
                  onPressed: _showConnectionInfo,
                  icon: const Icon(Icons.share),
                  label: Text(AppLocalizations.of(context)!.showConnectionInfo),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

```

### 2. Ağ Mantığı (LocalNetworkService içindeki clipboard kısımları)
`LocalNetworkService` sınıfı içerisinde aşağıdaki değişkenler ve handler'lar bulunmaktaydı:

- `_clipboardContent`: Paylaşılan metni tutar.
- `onClipboardChanged`: Metin değiştiğinde tetiklenen callback.
- `/clipboard` endpoint'i (GET ve POST): Web arayüzünden metin okuma ve yazma.

## Web Arayüzü Entegrasyonu
Web arayüzünde `textarea` ve `fetch` API'leri kullanılarak `/clipboard` endpoint'ine istek atılmaktadır.

## Yeni Uygulama İçin Öneriler
- Ayrı bir paket olarak geliştirilmelidir.
- Sadece pano senkronizasyonu üzerine odaklanmalıdır.
- Arka plan servisleri (background services) eklenerek uygulama kapalıyken de çalışması sağlanabilir.
