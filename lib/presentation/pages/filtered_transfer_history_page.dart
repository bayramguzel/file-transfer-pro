import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../data/models/transfer.dart';
import '../../data/repositories/transfer_repository.dart';
import '../../core/models/enums.dart';
import '../../core/utils/helpers.dart';
import 'transfer_detail_page.dart';

class FilteredTransferHistoryPage extends StatefulWidget {
  final TransferRepository transferRepository;
  final TransferDirection direction;
  final String title;

  const FilteredTransferHistoryPage({
    super.key,
    required this.transferRepository,
    required this.direction,
    required this.title,
  });

  @override
  State<FilteredTransferHistoryPage> createState() =>
      _FilteredTransferHistoryPageState();
}

class _FilteredTransferHistoryPageState
    extends State<FilteredTransferHistoryPage> {
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
      // Load filtered transfers from database
      _transfers = await widget.transferRepository
          .getTransfersByDirection(widget.direction);
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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTransfer),
        content: Text(l10n.deleteTransferConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.transferRepository.deleteTransfer(transfer.id);
        await _loadTransfers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.transferDeletedSuccessfully)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.transferDeleteFailed(e.toString()))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterTransfers,
              decoration: InputDecoration(
                hintText: l10n.searchFiles,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
          ),

          // Transfer list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTransfers.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadTransfers,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredTransfers.length,
                          itemBuilder: (context, index) {
                            final transfer = _filteredTransfers[index];
                            return _TransferCard(
                              transfer: transfer,
                              onTap: () => _navigateToDetail(transfer),
                              onDelete: () => _deleteTransfer(transfer),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.direction == TransferDirection.received
                ? Icons.file_download_rounded
                : Icons.file_upload_rounded,
                size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? (widget.direction == TransferDirection.received
                    ? l10n.noReceivedFiles
                    : l10n.noSentFiles)
                : l10n.noMatchingFiles,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(Transfer transfer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransferDetailPage(
          transfer: transfer,
        ),
      ),
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
            padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(transfer.status),
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // File info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transfer.files.length == 1
                              ? transfer.files.first.name
                              : l10n.filesCount(transfer.files.length),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              Helpers.formatBytes(transfer.totalSize),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDateTime(transfer.timestamp),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: theme.colorScheme.error,
                    onPressed: onDelete,
                  ),
                ],
              ),

              // Names (if available)
              if (transfer.senderName != null ||
                  transfer.receiverName != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      if (transfer.senderName != null &&
                          transfer.senderName!.isNotEmpty) ...[
                        const Icon(Icons.person_outline, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          l10n.senderName(transfer.senderName!),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      if (transfer.senderName != null &&
                          transfer.senderName!.isNotEmpty &&
                          transfer.receiverName != null &&
                          transfer.receiverName!.isNotEmpty)
                        const SizedBox(width: 12),
                      if (transfer.receiverName != null &&
                          transfer.receiverName!.isNotEmpty) ...[
                        const Icon(Icons.person_outline, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          l10n.receiverName(transfer.receiverName!),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
      case TransferStatus.completed:
        return Colors.green;
      case TransferStatus.failed:
        return Colors.red;
      case TransferStatus.paused:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(TransferStatus status) {
    switch (status) {
      case TransferStatus.sending:
        return Icons.upload_rounded;
      case TransferStatus.receiving:
        return Icons.download_rounded;
      case TransferStatus.completed:
        return Icons.check_circle_rounded;
      case TransferStatus.failed:
        return Icons.error_rounded;
      case TransferStatus.paused:
        return Icons.pause_circle_rounded;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
