import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/services/local_network_service.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/qr_code_widget.dart';

class ClipboardPage extends StatefulWidget {
  final String? initialText;

  const ClipboardPage({super.key, this.initialText});

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
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _textController.text = widget.initialText!;
      _networkService.clipboardContent = widget.initialText!;
      _networkService.setSharedText(widget.initialText!);
    } else {
      _loadClipboard();
    }
    _startServer();

    _textController.addListener(() {
      if (_networkService.clipboardContent != _textController.text) {
        _networkService.clipboardContent = _textController.text;
        _networkService.setSharedText(_textController.text);
      }
    });

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
        SnackBar(
            content: Text(AppLocalizations.of(context)!.copiedToClipboard)),
      );
    }
  }

  void _showConnectionInfo() {
    if (_serverUrl == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final ls = AppLocalizations.of(context)!;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  ls.connectionInfo,
                  style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                QrCodeWidget(data: _serverUrl!, size: 190),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B242C) : const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2E3E4E) : const Color(0xFFBAE6FD),
                    ),
                  ),
                  child: SelectableText(
                    _serverUrl!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  ls.orEnterAddress,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final s = AppLocalizations.of(context)!;

    // Pastel styling for cards
    final pastelCardBg = isDark ? const Color(0xFF1B242C) : const Color(0xFFF0F7FF);
    final pastelCardBorder = isDark ? const Color(0xFF2E3E4E) : const Color(0xFFBAE6FD);

    final inputBg = isDark ? const Color(0xFF161922) : const Color(0xFFF8FAFC);
    final inputBorder = isDark ? const Color(0xFF282D3D) : const Color(0xFFE2E8F0);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.clipboard),
        elevation: 0,
        actions: [
          if (_isServerRunning)
            IconButton(
              icon: const Icon(Icons.qr_code_rounded),
              onPressed: _showConnectionInfo,
              tooltip: s.showConnectionInfo,
            ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isServerRunning)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2E2218) : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF4C3626) : const Color(0xFFFED7AA),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFF97316), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s.serverStartErrorWifi,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? const Color(0xFFFDBA74) : const Color(0xFFC2410C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 1. Soft Pastel Info Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: pastelCardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: pastelCardBorder, width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.content_paste_rounded,
                        size: 28,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.clipboardSharing,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            s.clipboardSharingDescription,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. Text Input Area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: inputBorder),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                    decoration: InputDecoration(
                      hintText: s.clipboardHint,
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 3. Paste & Copy Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _loadClipboard,
                      icon: const Icon(Icons.paste_rounded, size: 18),
                      label: Text(s.paste),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF2E3E4E) : const Color(0xFFBAE6FD),
                        ),
                        backgroundColor: pastelCardBg,
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: Text(s.copy),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF2E3E4E) : const Color(0xFFBAE6FD),
                        ),
                        backgroundColor: pastelCardBg,
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),

              if (_isServerRunning) ...[
                const SizedBox(height: 10),
                // 4. Show Connection Info Button with proper bottom clearance
                ElevatedButton.icon(
                  onPressed: _showConnectionInfo,
                  icon: const Icon(Icons.qr_code_2_rounded, size: 20),
                  label: Text(
                    s.showConnectionInfo,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
