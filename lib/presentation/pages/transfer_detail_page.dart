import 'package:flutter/material.dart';
// Confetti removed
import '../../l10n/app_localizations.dart';
import '../../data/models/transfer.dart';
import '../../data/models/transfer_file.dart';
import '../../core/utils/helpers.dart';
import '../../core/models/enums.dart';

class TransferDetailPage extends StatefulWidget {
  final Transfer transfer;

  const TransferDetailPage({
    super.key,
    required this.transfer,
  });

  @override
  State<TransferDetailPage> createState() => _TransferDetailPageState();
}

class _TransferDetailPageState extends State<TransferDetailPage> {
  late Transfer _transfer;

  @override
  void initState() {
    super.initState();
    _transfer = widget.transfer;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.transferDetails),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            _buildStatusCard(theme),
            const SizedBox(height: 16),

            // Transfer Info
            _buildInfoCard(theme),
            const SizedBox(height: 16),

            // Files List
            _buildFilesCard(theme),
            const SizedBox(height: 16),

            // Actions
            if (_transfer.status != TransferStatus.completed &&
                _transfer.status != TransferStatus.failed)
              _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    final statusColor = _getStatusColor(_transfer.status);
    final statusText = _getStatusText(_transfer.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              _getStatusIcon(_transfer.status),
              size: 64,
              color: statusColor,
            ),
            const SizedBox(height: 12),
            Text(
              statusText,
              style: theme.textTheme.titleLarge?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_transfer.status == TransferStatus.sending ||
                _transfer.status == TransferStatus.receiving)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _transfer.progress / 100,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_transfer.progress.toInt()}% ${AppLocalizations.of(context)!.completed.toLowerCase()}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.transferInfo,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow(Icons.tag, AppLocalizations.of(context)!.transferCode,
                _transfer.id),
            _buildInfoRow(
              Icons.insert_drive_file,
              AppLocalizations.of(context)!.fileCount,
              '${_transfer.files.length} ${AppLocalizations.of(context)!.files.toLowerCase()}',
            ),
            _buildInfoRow(
              Icons.data_usage,
              AppLocalizations.of(context)!.totalSize,
              Helpers.formatBytes(_transfer.totalSize),
            ),
            _buildInfoRow(
              Icons.access_time,
              AppLocalizations.of(context)!.startTime,
              _formatDateTime(_transfer.timestamp),
            ),
            if (_transfer.status == TransferStatus.completed)
              _buildInfoRow(
                Icons.check_circle,
                AppLocalizations.of(context)!.completedFiles,
                '${_transfer.completedFiles}/${_transfer.files.length} ${AppLocalizations.of(context)!.files.toLowerCase()}',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.files,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ..._transfer.files.map((file) => _buildFileItem(file, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(TransferFile file, ThemeData theme) {
    final statusColor = _getFileStatusColor(file.status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getFileIcon(file.name), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      Helpers.formatBytes(file.size),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _getFileStatusIcon(file.status),
                color: statusColor,
                size: 20,
              ),
            ],
          ),
          if (file.status == FileStatus.transferring)
            Column(
              children: [
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: file.progress / 100,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(height: 4),
                Text(
                  '${file.progress.toInt()}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          if (file.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                file.errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement pause/resume
          },
          icon: Icon(_transfer.status == TransferStatus.paused
              ? Icons.play_arrow
              : Icons.pause),
          label: Text(_transfer.status == TransferStatus.paused
              ? AppLocalizations.of(context)!.resume
              : AppLocalizations.of(context)!.pause),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.cancelTransfer),
                content: Text(
                  AppLocalizations.of(context)!.cancelTransferConfirm,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(AppLocalizations.of(context)!.no),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(AppLocalizations.of(context)!.cancelTransfer),
                  ),
                ],
              ),
            );

            if (confirmed == true && mounted) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.cancel),
          label: Text(AppLocalizations.of(context)!.cancelTransfer),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            foregroundColor: Colors.red,
          ),
        ),
      ],
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

  IconData _getStatusIcon(TransferStatus status) {
    switch (status) {
      case TransferStatus.sending:
        return Icons.upload;
      case TransferStatus.receiving:
        return Icons.download;
      case TransferStatus.paused:
        return Icons.pause_circle;
      case TransferStatus.completed:
        return Icons.check_circle;
      case TransferStatus.failed:
        return Icons.error;
    }
  }

  String _getStatusText(TransferStatus status) {
    switch (status) {
      case TransferStatus.sending:
        return AppLocalizations.of(context)!.sending;
      case TransferStatus.receiving:
        return AppLocalizations.of(context)!.receiving;
      case TransferStatus.paused:
        return AppLocalizations.of(context)!.paused;
      case TransferStatus.completed:
        return AppLocalizations.of(context)!.transferCompleted;
      case TransferStatus.failed:
        return AppLocalizations.of(context)!.transferFailed;
    }
  }

  Color _getFileStatusColor(FileStatus status) {
    switch (status) {
      case FileStatus.pending:
        return Colors.grey;
      case FileStatus.transferring:
        return Colors.blue;
      case FileStatus.completed:
        return Colors.green;
      case FileStatus.failed:
        return Colors.red;
    }
  }

  IconData _getFileStatusIcon(FileStatus status) {
    switch (status) {
      case FileStatus.pending:
        return Icons.schedule;
      case FileStatus.transferring:
        return Icons.sync;
      case FileStatus.completed:
        return Icons.check_circle;
      case FileStatus.failed:
        return Icons.error;
    }
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) return Icons.image;
    if (['mp4', 'avi', 'mov'].contains(ext)) return Icons.video_file;
    if (['mp3', 'wav'].contains(ext)) return Icons.audio_file;
    if (['pdf'].contains(ext)) return Icons.picture_as_pdf;
    if (['zip', 'rar'].contains(ext)) return Icons.folder_zip;
    return Icons.insert_drive_file;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
