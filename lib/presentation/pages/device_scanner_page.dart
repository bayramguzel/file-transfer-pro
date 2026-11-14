import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../data/services/device_discovery_service.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_widgets.dart';

class DeviceScannerPage extends StatefulWidget {
  const DeviceScannerPage({super.key});

  @override
  State<DeviceScannerPage> createState() => _DeviceScannerPageState();
}

class _DeviceScannerPageState extends State<DeviceScannerPage> {
  final DeviceDiscoveryService _discoveryService = DeviceDiscoveryService();
  bool _isScanning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  Future<void> _startScanning() async {
    setState(() {
      _isScanning = true;
      _error = null;
    });

    try {
      await _discoveryService.startDiscovery();
      // startDiscovery completes once sockets are set up; scanning continues in background
      if (mounted) {
        setState(() => _isScanning = _discoveryService.isDiscovering);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _restartScanning() async {
    await _discoveryService.stopDiscovery();
    _startScanning();
  }

  Future<void> _openDeviceUrl(DiscoveredDevice device) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final url = Uri.parse(device.url);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.inAppBrowserView,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.couldNotOpenUrl(device.url)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _discoveryService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nearbyDevices),
        actions: [
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          if (!_isScanning)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Yeniden Tara',
              onPressed: _restartScanning,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Icon(
                    Icons.radar,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isScanning ? l10n.scanningDevices : l10n.scanStopped,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.errorContainer,
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: StreamBuilder<List<DiscoveredDevice>>(
                stream: _discoveryService.devicesStream,
                initialData: const [],
                builder: (context, snapshot) {
                  final devices = snapshot.data ?? [];

                  if (devices.isEmpty && _isScanning) {
                    return const DeviceListSkeleton(itemCount: 4);
                  }

                  if (devices.isEmpty) {
                    return EmptyStateWidget(
                      title: l10n.noDevicesFound,
                      message: l10n.noDevicesFoundMessage,
                      icon: Icons.devices_other,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary,
                            child: const Icon(Icons.phone_android,
                                color: Colors.white),
                          ),
                          title: Text(
                            device.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${device.ipAddress}:${device.port}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.open_in_browser),
                            onPressed: () => _openDeviceUrl(device),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
