import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../core/utils/helpers.dart';
import '../../l10n/app_localizations.dart';

class FilePickerWidget extends StatefulWidget {
  final Function(List<File>) onFilesSelected;
  final List<File>? initialFiles;

  const FilePickerWidget({
    super.key,
    required this.onFilesSelected,
    this.initialFiles,
  });

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  List<File> _selectedFiles = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialFiles != null) {
      _selectedFiles = List.from(widget.initialFiles!);
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        final newFiles = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();

        setState(() {
          _selectedFiles.insertAll(0, newFiles);
        });

        widget.onFilesSelected(_selectedFiles);
      }
    } catch (e) {
      print('Error picking files: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .errorPickingFiles(e.toString()))),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    widget.onFilesSelected(_selectedFiles);
  }

  void _clearAll() {
    setState(() {
      _selectedFiles.clear();
      _searchQuery = '';
    });
    widget.onFilesSelected(_selectedFiles);
  }

  List<File> get _filteredFiles {
    if (_searchQuery.isEmpty) return _selectedFiles;
    return _selectedFiles
        .where((file) =>
            file.path.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  int get _totalSize {
    return _selectedFiles.fold(0, (sum, file) {
      try {
        return sum + file.lengthSync();
      } catch (e) {
        return sum;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredFiles = _filteredFiles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drop zone with drag and drop support
        DragTarget<List<File>>(
          onWillAcceptWithDetails: (data) => true,
          onAcceptWithDetails: (details) {
            setState(() {
              _selectedFiles.insertAll(0, details.data);
            });
            widget.onFilesSelected(_selectedFiles);
          },
          builder: (context, candidateData, rejectedData) {
            final isDragging = candidateData.isNotEmpty;
            return GestureDetector(
              onTap: _pickFiles,
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: isDragging ? Colors.green : theme.colorScheme.primary,
                  strokeWidth: isDragging ? 3 : 2,
                  dashPattern: const [8, 4],
                  radius: const Radius.circular(12),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                  decoration: BoxDecoration(
                    color: isDragging
                        ? Colors.green.withValues(alpha: 0.1)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        isDragging
                            ? Icons.file_download_outlined
                            : Icons.cloud_upload_outlined,
                        size: 64,
                        color: isDragging
                            ? Colors.green
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isDragging
                            ? AppLocalizations.of(context)!.dropFilesHere
                            : AppLocalizations.of(context)!.clickOrDragToUpload,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDragging ? Colors.green : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isDragging
                            ? AppLocalizations.of(context)!.releaseToDrop
                            : AppLocalizations.of(context)!
                                .canSelectMultipleFiles,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 24),

          // Header with count and clear button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!
                    .selectedFilesCount(_selectedFiles.length),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: _clearAll,
                icon: const Icon(Icons.clear_all),
                label: Text(AppLocalizations.of(context)!.clearAll),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Search bar
          if (_selectedFiles.length > 3)
            TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!
                    .searchInFiles(_selectedFiles.length),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),

          const SizedBox(height: 16),

          // Files list
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: filteredFiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.noMatchingFilesFound,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredFiles.length,
                    itemBuilder: (context, index) {
                      final file = filteredFiles[index];
                      final fileName =
                          file.path.split(Platform.pathSeparator).last;
                      final fileSize = file.existsSync()
                          ? Helpers.formatBytes(file.lengthSync())
                          : 'Unknown';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            _getFileIcon(fileName),
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(fileSize),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                _removeFile(_selectedFiles.indexOf(file)),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 16),

          // Total size and add more button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!
                    .totalSizeWithLabel(Helpers.formatBytes(_totalSize)),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.addMore),
              ),
            ],
          ),
        ],
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return Icons.image;
    } else if (['mp4', 'avi', 'mov', 'mkv'].contains(ext)) {
      return Icons.video_file;
    } else if (['mp3', 'wav', 'flac', 'aac'].contains(ext)) {
      return Icons.audio_file;
    } else if (['pdf'].contains(ext)) {
      return Icons.picture_as_pdf;
    } else if (['doc', 'docx', 'txt'].contains(ext)) {
      return Icons.description;
    } else if (['zip', 'rar', '7z', 'tar'].contains(ext)) {
      return Icons.folder_zip;
    }
    return Icons.insert_drive_file;
  }
}
