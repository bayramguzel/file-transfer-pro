import 'dart:async';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';

class DiscoveredDevice {
  final String name;
  final String ipAddress;
  final int port;
  final DateTime discoveredAt;

  DiscoveredDevice({
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.discoveredAt,
  });

  String get url => 'http://$ipAddress:$port';
}

class DeviceDiscoveryService {
  // Singleton pattern
  static final DeviceDiscoveryService _instance =
      DeviceDiscoveryService._internal();
  factory DeviceDiscoveryService() => _instance;
  DeviceDiscoveryService._internal();

  final int port = 8080;
  final int discoveryPort = 8081;

  // App-specific multicast group for discovery (avoids AP isolation on many routers)
  static const String _multicastGroup = '239.255.42.98';

  RawDatagramSocket? _broadcastSocket;
  RawDatagramSocket? _listenSocket;

  // Singleton: StreamController must never be closed so re-entry works
  final StreamController<List<DiscoveredDevice>> _devicesController =
      StreamController<List<DiscoveredDevice>>.broadcast();

  final Map<String, DiscoveredDevice> _discoveredDevices = {};
  Timer? _cleanupTimer;
  Timer? _broadcastTimer;
  bool _isDiscovering = false;

  // Cached local IP — avoid async race conditions in message handler
  String? _localIp;

  Stream<List<DiscoveredDevice>> get devicesStream => _devicesController.stream;
  List<DiscoveredDevice> get devices => _discoveredDevices.values.toList();
  bool get isDiscovering => _isDiscovering;

  Future<void> startDiscovery() async {
    if (_isDiscovering) {
      // Already running — just push current list to any new listeners
      if (!_devicesController.isClosed) {
        _devicesController.add(devices);
      }
      return;
    }
    _isDiscovering = true;

    try {
      final info = NetworkInfo();
      _localIp = await info.getWifiIP();
      if (_localIp == null) {
        throw Exception('Wi-Fi\'ye bağlı değilsiniz');
      }

      await _setupBroadcastSocket();
      await _setupListenSocket();

      _cleanupTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        _cleanupOldDevices();
      });

      // Broadcast every 3 seconds for faster discovery
      _broadcastTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        _sendDiscovery();
      });

      _sendDiscovery();
    } catch (e) {
      print('Discovery error: $e');
      _isDiscovering = false;
      rethrow;
    }
  }

  Future<void> _setupBroadcastSocket() async {
    try {
      _broadcastSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _broadcastSocket!.broadcastEnabled = true;
    } catch (e) {
      print('Broadcast socket error: $e');
    }
  }

  Future<void> _setupListenSocket() async {
    // reusePort is not supported on all Android versions (errno=92).
    // Try with it first, fall back to without.
    bool bound = false;
    try {
      _listenSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        discoveryPort,
        reuseAddress: true,
        reusePort: true,
      );
      bound = true;
    } catch (_) {
      // reusePort not available on this platform/version
    }

    if (!bound) {
      try {
        _listenSocket = await RawDatagramSocket.bind(
          InternetAddress.anyIPv4,
          discoveryPort,
          reuseAddress: true,
          reusePort: false,
        );
        bound = true;
      } catch (e) {
        print('Listen socket bind failed: $e');
        return;
      }
    }

    // Join multicast group so we also receive multicast discovery packets
    try {
      _listenSocket!.joinMulticast(InternetAddress(_multicastGroup));
      print('Multicast group joined: $_multicastGroup');
    } catch (e) {
      print('Multicast join failed (non-critical): $e');
    }

    _listenSocket!.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = _listenSocket!.receive();
        if (datagram != null) {
          _handleDiscoveryMessage(datagram);
        }
      }
    });
  }

  String _getDeviceName() {
    if (Platform.isWindows) {
      return Platform.environment['COMPUTERNAME'] ?? 'Windows PC';
    } else if (Platform.isMacOS) {
      return Platform.environment['HOSTNAME']?.split('.').first ?? 'Mac';
    } else if (Platform.isLinux) {
      return Platform.environment['HOSTNAME'] ?? 'Linux PC';
    } else {
      // Android / iOS: use the system hostname which is device-specific
      final hostname = Platform.localHostname;
      if (hostname.isNotEmpty && hostname != 'localhost') {
        return hostname;
      }
      return Platform.isIOS ? 'iPhone' : 'Android Device';
    }
  }

  void _sendDiscovery() {
    if (_broadcastSocket == null) return;

    try {
      final deviceName = _getDeviceName();
      final message = 'FILETRANSFER_DISCOVERY:$deviceName:$port';
      final data = message.codeUnits;

      // 1. Limited broadcast (255.255.255.255) — standard, may be blocked by AP isolation
      try {
        _broadcastSocket!
            .send(data, InternetAddress('255.255.255.255'), discoveryPort);
      } catch (e) {
        print('Limited broadcast failed: $e');
      }

      // 2. Subnet-directed broadcast (e.g. 192.168.1.255) — bypasses some AP isolation setups
      if (_localIp != null) {
        final subnetBcast = _subnetBroadcast(_localIp!);
        if (subnetBcast != null) {
          try {
            _broadcastSocket!
                .send(data, InternetAddress(subnetBcast), discoveryPort);
          } catch (e) {
            print('Subnet broadcast failed: $e');
          }
        }
      }

      // 3. Multicast — works even when AP isolation blocks broadcast
      try {
        _broadcastSocket!
            .send(data, InternetAddress(_multicastGroup), discoveryPort);
      } catch (e) {
        print('Multicast send failed: $e');
      }

      print('📡 Broadcasting: $deviceName on port $port');
    } catch (e) {
      print('Discovery send error: $e');
    }
  }

  /// Returns subnet-directed broadcast for a /24 network.
  /// e.g. '192.168.1.42' → '192.168.1.255'
  String? _subnetBroadcast(String ip) {
    try {
      final parts = ip.split('.');
      if (parts.length == 4) {
        return '${parts[0]}.${parts[1]}.${parts[2]}.255';
      }
    } catch (_) {}
    return null;
  }

  void _handleDiscoveryMessage(Datagram datagram) {
    try {
      final message = String.fromCharCodes(datagram.data);

      if (message.startsWith('FILETRANSFER_DISCOVERY:')) {
        final parts = message.substring(23).split(':');
        if (parts.length >= 2) {
          final deviceName = parts[0];
          final devicePort = int.tryParse(parts[1]) ?? port;
          final ipAddress = datagram.address.address;

          // Use cached IP — synchronous, no race condition
          if (_localIp != null && ipAddress == _localIp) return;

          final device = DiscoveredDevice(
            name: deviceName,
            ipAddress: ipAddress,
            port: devicePort,
            discoveredAt: DateTime.now(),
          );

          _discoveredDevices[ipAddress] = device;
          if (!_devicesController.isClosed) {
            _devicesController.add(devices);
          }
        }
      }
    } catch (e) {
      print('Message handling error: $e');
    }
  }

  void _cleanupOldDevices() {
    final now = DateTime.now();
    final toRemove = <String>[];

    for (final entry in _discoveredDevices.entries) {
      // Remove devices not seen for >30 s (broadcast interval is 3 s, so 10 misses)
      if (now.difference(entry.value.discoveredAt).inSeconds > 30) {
        toRemove.add(entry.key);
      }
    }

    for (final key in toRemove) {
      _discoveredDevices.remove(key);
    }

    if (toRemove.isNotEmpty && !_devicesController.isClosed) {
      _devicesController.add(devices);
    }
  }

  Future<void> stopDiscovery() async {
    _isDiscovering = false;
    _cleanupTimer?.cancel();
    _broadcastTimer?.cancel();
    _listenSocket?.close();
    _listenSocket = null;
    _broadcastSocket?.close();
    _broadcastSocket = null;
    _discoveredDevices.clear();
    _localIp = null;
    if (!_devicesController.isClosed) {
      _devicesController.add([]);
    }
  }

  // dispose() is called by pages — do NOT close the StreamController since
  // this is a singleton and must be reusable across navigation events.
  void dispose() {
    stopDiscovery();
  }
}
