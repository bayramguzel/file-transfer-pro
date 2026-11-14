import 'package:equatable/equatable.dart';
import '../../core/models/enums.dart';
import 'transfer_file.dart';

class Transfer extends Equatable {
  final String id;
  final TransferStatus status;
  final List<TransferFile> files;
  final double progress;
  final DateTime timestamp;
  final TransferDirection direction;
  final String? senderName;
  final String? receiverName;

  const Transfer({
    required this.id,
    required this.status,
    required this.files,
    this.progress = 0.0,
    required this.timestamp,
    required this.direction,
    this.senderName,
    this.receiverName,
  });

  Transfer copyWith({
    String? id,
    TransferStatus? status,
    List<TransferFile>? files,
    double? progress,
    DateTime? timestamp,
    TransferDirection? direction,
    String? senderName,
    String? receiverName,
  }) {
    return Transfer(
      id: id ?? this.id,
      status: status ?? this.status,
      files: files ?? this.files,
      progress: progress ?? this.progress,
      timestamp: timestamp ?? this.timestamp,
      direction: direction ?? this.direction,
      senderName: senderName ?? this.senderName,
      receiverName: receiverName ?? this.receiverName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'files': files.map((f) => f.toJson()).toList(),
      'progress': progress,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'direction': direction.index,
      'senderName': senderName,
      'receiverName': receiverName,
    };
  }

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['id'] as String,
      status: TransferStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransferStatus.sending,
      ),
      files: (json['files'] as List<dynamic>)
          .map((f) => TransferFile.fromJson(f as Map<String, dynamic>))
          .toList(),
      progress: (json['progress'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      direction: TransferDirection.values[json['direction'] as int? ?? 0],
      senderName: json['senderName'] as String?,
      receiverName: json['receiverName'] as String?,
    );
  }

  int get totalSize => files.fold(0, (sum, file) => sum + file.size);

  int get completedFiles =>
      files.where((f) => f.status == FileStatus.completed).length;

  @override
  List<Object?> get props => [
        id,
        status,
        files,
        progress,
        timestamp,
        direction,
        senderName,
        receiverName
      ];
}
