import 'package:equatable/equatable.dart';
import '../../core/models/enums.dart';

class TransferFile extends Equatable {
  final String name;
  final int size;
  final String type;
  final double progress;
  final FileStatus status;
  final String? errorMessage;

  const TransferFile({
    required this.name,
    required this.size,
    required this.type,
    this.progress = 0.0,
    this.status = FileStatus.pending,
    this.errorMessage,
  });

  TransferFile copyWith({
    String? name,
    int? size,
    String? type,
    double? progress,
    FileStatus? status,
    String? errorMessage,
  }) {
    return TransferFile(
      name: name ?? this.name,
      size: size ?? this.size,
      type: type ?? this.type,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'size': size,
      'type': type,
      'progress': progress,
      'status': status.name,
      'errorMessage': errorMessage,
    };
  }

  factory TransferFile.fromJson(Map<String, dynamic> json) {
    return TransferFile(
      name: json['name'] as String,
      size: json['size'] as int,
      type: json['type'] as String,
      progress: (json['progress'] as num).toDouble(),
      status: FileStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FileStatus.pending,
      ),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  @override
  List<Object?> get props => [name, size, type, progress, status, errorMessage];
}
