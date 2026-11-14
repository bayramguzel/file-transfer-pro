import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/services/permission_service.dart';
import '../../l10n/app_localizations.dart';
import 'local_hosting_page.dart';
import '../widgets/smooth_animations.dart';
import '../widgets/banner_ad_widget.dart';

class AppSelectionPage extends StatefulWidget {
  const AppSelectionPage({super.key});

  @override
  State<AppSelectionPage> createState() => _AppSelectionPageState();
}

class _AppSelectionPageState extends State<AppSelectionPage> {
  List<Application> _apps = [];
  List<Application> _filteredApps = [];
  final List<Application> _selectedApps = [];
  bool _isLoading = true;
  bool _showSystemApps = false;
  String _searchQuery = '';
  final PermissionService _permissionService = PermissionService();

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    // Yüklü uygulama listesi yalnızca Android'de okunabilir.
    if (!Platform.isAndroid) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Request storage permission via centralized service
      if (Platform.isAndroid) {
        await _permissionService.requestStoragePermission(
          context: mounted ? context : null,
        );
      }

      // Tüm uygulamaları al, limit yok
      final apps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: _showSystemApps,
        onlyAppsWithLaunchIntent: false, // Tüm uygulamaları dahil et
      );

      setState(() {
        _apps = apps;
        _filterApps();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .errorLoadingApps(e.toString()))),
        );
      }
    }
  }

  void _filterApps() {
    if (_searchQuery.isEmpty) {
      _filteredApps = List.from(_apps);
    } else {
      _filteredApps = _apps.where((app) {
        return app.appName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            app.packageName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    // Sort: Selected first, then alphabetical
    _filteredApps.sort((a, b) {
      final aSelected = _selectedApps.contains(a);
      final bSelected = _selectedApps.contains(b);
      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;
      return a.appName.toLowerCase().compareTo(b.appName.toLowerCase());
    });
  }

  void _toggleAppSelection(Application app) {
    setState(() {
      if (_selectedApps.contains(app)) {
        _selectedApps.remove(app);
      } else {
        _selectedApps.add(app);
      }
    });
  }

  Future<void> _startSharing() async {
    if (_selectedApps.isEmpty) return;

    // Show a loading dialog while preparing APK files with clean names
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    AppLocalizations.of(context)?.loading ?? 'Hazırlanıyor...',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final tempDir = await getTemporaryDirectory();
      final apkDir = Directory('${tempDir.path}/shared_apks');
      if (!apkDir.existsSync()) {
        await apkDir.create(recursive: true);
      }

      final List<File> files = [];
      for (final app in _selectedApps) {
        final originalFile = File(app.apkFilePath);
        if (!originalFile.existsSync()) continue;

        // Clean app name for filename (AppName.apk instead of base.apk)
        String safeName = app.appName
            .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
            .trim();
        if (safeName.isEmpty) {
          safeName = app.packageName.replaceAll('.', '_');
        }

        final targetFile = File('${apkDir.path}/$safeName.apk');
        // Copy if not already cached with same size
        if (!targetFile.existsSync() || targetFile.lengthSync() != originalFile.lengthSync()) {
          await originalFile.copy(targetFile.path);
        }
        files.add(targetFile);
      }

      if (mounted) {
        Navigator.of(context).pop(); // dismiss loading dialog
        if (files.isNotEmpty) {
          Navigator.of(context).pushReplacement(
            SmoothPageRoute(
              page: LocalHostingPage(files: files),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selectApp),
        actions: [
          PopupMenuButton<bool>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _showSystemApps = value;
                _loadApps();
              });
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                checked: !_showSystemApps,
                value: false,
                child: Text(AppLocalizations.of(context)!.onlyUserApps),
              ),
              CheckedPopupMenuItem(
                checked: _showSystemApps,
                value: true,
                child: Text(AppLocalizations.of(context)!.showSystemApps),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchApps,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterApps();
                });
              },
            ),
          ),

          // App List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredApps.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.apps_outage,
                                size: 64,
                                color: Colors.grey.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text(AppLocalizations.of(context)!.noAppsFound),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredApps.length,
                        itemBuilder: (context, index) {
                          final app = _filteredApps[index];
                          final isSelected = _selectedApps.contains(app);

                          // Curated pastel palettes for light and dark themes
                          final pastelBgList = isDark
                              ? const [
                                  Color(0xFF1B242C), // Pastel Slate/Blue
                                  Color(0xFF192B21), // Pastel Mint
                                  Color(0xFF281E2E), // Pastel Lavender
                                  Color(0xFF2D221A), // Pastel Peach
                                  Color(0xFF2D1B22), // Pastel Rose
                                  Color(0xFF1A2A2B), // Pastel Teal
                                  Color(0xFF1E2034), // Pastel Indigo
                                  Color(0xFF2B2618), // Pastel Amber
                                ]
                              : const [
                                  Color(0xFFF0F7FF), // Soft Blue
                                  Color(0xFFF0FDF4), // Soft Mint
                                  Color(0xFFFAF5FF), // Soft Lavender
                                  Color(0xFFFFF7ED), // Soft Peach
                                  Color(0xFFFFF1F2), // Soft Rose
                                  Color(0xFFF0FDFA), // Soft Teal
                                  Color(0xFFEEF2FF), // Soft Indigo
                                  Color(0xFFFEFCE8), // Soft Amber
                                ];

                          final pastelBorderList = isDark
                              ? const [
                                  Color(0xFF2E3E4E),
                                  Color(0xFF2A4A38),
                                  Color(0xFF483354),
                                  Color(0xFF4C3828),
                                  Color(0xFF4E2B38),
                                  Color(0xFF2B4648),
                                  Color(0xFF333758),
                                  Color(0xFF483F25),
                                ]
                              : const [
                                  Color(0xFFBAE6FD),
                                  Color(0xFFBBF7D0),
                                  Color(0xFFE9D5FF),
                                  Color(0xFFFED7AA),
                                  Color(0xFFFECDD3),
                                  Color(0xFF99F6E4),
                                  Color(0xFFC7D2FE),
                                  Color(0xFFFEF08A),
                                ];

                          final colorIndex =
                              (app.packageName.hashCode.abs()) % pastelBgList.length;

                          final cardBg = isSelected
                              ? theme.colorScheme.primary
                                  .withValues(alpha: isDark ? 0.35 : 0.18)
                              : pastelBgList[colorIndex];

                          final cardBorder = isSelected
                              ? theme.colorScheme.primary
                              : pastelBorderList[colorIndex];

                          String fileSizeMb = '0';
                          try {
                            final f = File(app.apkFilePath);
                            if (f.existsSync()) {
                              fileSizeMb =
                                  (f.lengthSync() / (1024 * 1024)).toStringAsFixed(1);
                            }
                          } catch (_) {}

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: cardBorder,
                                width: isSelected ? 2 : 1.2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: app is ApplicationWithIcon
                                    ? Image.memory(app.icon,
                                        width: 36, height: 36)
                                    : const Icon(Icons.android_rounded, size: 36),
                              ),
                              title: Text(
                                app.appName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 3),
                                  // App ID (package name) badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (isDark
                                              ? Colors.white
                                              : Colors.black)
                                          .withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: (isDark
                                                ? Colors.white
                                                : Colors.black)
                                            .withValues(alpha: 0.08),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      app.packageName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                        letterSpacing: -0.2,
                                        color: isDark
                                            ? const Color(0xFF93C5FD)
                                            : const Color(0xFF2563EB),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${app.versionName ?? ""} • $fileSizeMb MB',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 11.5,
                                      color: (isDark
                                              ? Colors.white
                                              : Colors.black87)
                                          .withValues(alpha: 0.65),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Checkbox(
                                value: isSelected,
                                activeColor: theme.colorScheme.primary,
                                onChanged: (value) => _toggleAppSelection(app),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onTap: () => _toggleAppSelection(app),
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 16),
          const Center(child: BannerAdWidget()),
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _selectedApps.isEmpty ? null : _startSharing,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.withValues(alpha: 0.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.share_rounded),
                const SizedBox(width: 8),
                Text(
                  _selectedApps.isEmpty
                      ? AppLocalizations.of(context)!.selectApps
                      : AppLocalizations.of(context)!
                          .shareAppsCount(_selectedApps.length),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
