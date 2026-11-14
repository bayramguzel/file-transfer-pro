import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/transfer.dart';
import '../../data/repositories/transfer_repository.dart';
import '../../core/utils/helpers.dart';
import '../../core/models/enums.dart';
import 'transfer_detail_page.dart';
import '../widgets/error_widgets.dart';
import '../widgets/loading_shimmer.dart';

class TransferHistoryPage extends StatefulWidget {
  final TransferRepository transferRepository;

  const TransferHistoryPage({
    super.key,
    required this.transferRepository,
  });

  @override
  State<TransferHistoryPage> createState() => _TransferHistoryPageState();
}

class _TransferHistoryPageState extends State<TransferHistoryPage> {
  List<Transfer> _transfers = [];
  List<Transfer> _filteredTransfers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTransfers();
  }

  Future<void> _loadTransfers() async {
    setState(() => _isLoading = true);

    try {
      // Load real transfers from database
      _transfers = await widget.transferRepository.getAllTransfers();
      // Sort by timestamp descending (newest first)
      _transfers.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _filteredTransfers = _transfers;
    } catch (e) {
      print('Error loading transfers: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!
                .errorLoadingHistory(e.toString())),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterTransfers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTransfers = _transfers;
      } else {
        _filteredTransfers = _transfers.where((transfer) {
          final id = transfer.id.toLowerCase();
          final fileNames =
              transfer.files.map((f) => f.name.toLowerCase()).join(' ');
          final searchLower = query.toLowerCase();
          return id.contains(searchLower) || fileNames.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _deleteTransfer(Transfer transfer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteTransfer),
        content: Text(AppLocalizations.of(context)!.deleteTransferConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Delete from database
        await widget.transferRepository.deleteTransfer(transfer.id);

        setState(() {
          _transfers.remove(transfer);
          _filteredTransfers.remove(transfer);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!.transferDeleted)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.deleteFailed(e.toString())),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transferHistory),
        actions: [
          if (_transfers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadTransfers,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (_transfers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.searchByFileNameOrId,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onChanged: _filterTransfers,
              ),
            ),

          // Content
          Expanded(
            child: _isLoading
                ? const TransferHistoryShimmer(itemCount: 5)
                : _filteredTransfers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTransfers.length,
                        itemBuilder: (context, index) {
                          final transfer = _filteredTransfers[index];
                          return _TransferCard(
                            transfer: transfer,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransferDetailPage(
                                    transfer: transfer,
                                  ),
                                ),
                              );
                            },
                            onDelete: () => _deleteTransfer(transfer),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return EmptyStateWidget(
      title: _searchQuery.isEmpty
          ? l10n.transferHistoryEmpty
          : l10n.noResultsFound,
      message:
          _searchQuery.isEmpty ? l10n.noTransfersYet : l10n.noSearchResults,
      icon: _searchQuery.isEmpty ? Icons.folder_open : Icons.search_off,
    );
  }
}

class _TransferCard extends StatelessWidget {
  final Transfer transfer;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TransferCard({
    required this.transfer,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _getStatusColor(transfer.status);
    final statusText = _getStatusText(transfer.status, context);

    final isDark = theme.brightness == Brightness.dark;
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

    final colorIndex = (transfer.id.hashCode.abs()) % pastelBgList.length;
    final cardBg = pastelBgList[colorIndex];
    final cardBorder = pastelBorderList[colorIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Transfer ID
              Row(
                children: [
                  const Icon(Icons.tag, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    l10n.transferCodeWithLabel(transfer.id),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Files count and size
              Row(
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.filesCount(transfer.files.length),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.data_usage,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    Helpers.formatBytes(transfer.totalSize),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Timestamp
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTimestamp(transfer.timestamp, context),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),

              // Progress bar (if in progress)
              if (transfer.status == TransferStatus.sending ||
                  transfer.status == TransferStatus.receiving)
                Column(
                  children: [
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: transfer.progress / 100,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transfer.progress.toInt()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Color _getStatusColor(TransferStatus status) {
    switch (status) {
      case TransferStatus.sending:
      case TransferStatus.receiving:
        return Colors.blue;
      case TransferStatus.paused:
        return Colors.orange;
      case TransferStatus.completed:
        return Colors.green;
      case TransferStatus.failed:
        return Colors.red;
    }
  }

  String _getStatusText(TransferStatus status, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case TransferStatus.sending:
        return l10n.sending;
      case TransferStatus.receiving:
        return l10n.receiving;
      case TransferStatus.paused:
        return l10n.paused;
      case TransferStatus.completed:
        return l10n.completed;
      case TransferStatus.failed:
        return l10n.failed;
    }
  }

  String _formatTimestamp(DateTime timestamp, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
