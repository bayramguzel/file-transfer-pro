import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import '../../core/constants/app_constants.dart';
import '../../core/models/enums.dart';
import '../models/transfer.dart' as model;
import '../models/transfer_file.dart' as model;

part 'database.g.dart';

class Transfers extends Table {
  TextColumn get id => text()();
  IntColumn get status => integer()();
  TextColumn get filesJson => text()();
  RealColumn get progress => real()();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get direction => integer()(); // 0=sent, 1=received
  TextColumn get senderName => text().withDefault(const Constant('Unknown'))();
  TextColumn get receiverName =>
      text().withDefault(const Constant('Unknown'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Transfers])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => AppConstants.dbVersion;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          // Add new columns for direction tracking
          await migrator.addColumn(transfers, transfers.direction);
          await migrator.addColumn(transfers, transfers.senderName);
          await migrator.addColumn(transfers, transfers.receiverName);
        }
      },
    );
  }

  // CRUD Operations
  Future<List<model.Transfer>> getAllTransfers() async {
    final query = select(transfers)
      ..orderBy([
        (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
      ]);
    final rows = await query.get();
    return rows.map(_transferFromRow).toList();
  }

  Future<List<model.Transfer>> getTransfersByDirection(
      TransferDirection direction) async {
    final rows = await (select(transfers)
          ..where((t) => t.direction.equals(direction.index))
          ..orderBy([
            (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
          ]))
        .get();
    return rows.map(_transferFromRow).toList();
  }

  Future<model.Transfer?> getTransferById(String id) async {
    final row = await (select(transfers)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _transferFromRow(row);
  }

  Future<void> addTransfer(model.Transfer transfer) async {
    await into(transfers).insert(
      TransfersCompanion.insert(
        id: transfer.id,
        status: transfer.status.index,
        filesJson: json.encode(transfer.files.map((f) => f.toJson()).toList()),
        progress: transfer.progress,
        timestamp: transfer.timestamp,
        direction: transfer.direction.index,
        senderName: Value(transfer.senderName ?? ''),
        receiverName: Value(transfer.receiverName ?? ''),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> updateTransfer(model.Transfer transfer) async {
    await (update(transfers)..where((t) => t.id.equals(transfer.id))).write(
      TransfersCompanion(
        status: Value(transfer.status.index),
        filesJson:
            Value(json.encode(transfer.files.map((f) => f.toJson()).toList())),
        progress: Value(transfer.progress),
        timestamp: Value(transfer.timestamp),
      ),
    );
  }

  Future<void> deleteTransfer(String id) async {
    await (delete(transfers)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearAllTransfers() async {
    await delete(transfers).go();
  }

  // Watch for changes (newest first)
  Stream<List<model.Transfer>> watchAllTransfers() {
    final query = select(transfers)
      ..orderBy([
        (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
      ]);
    return query.watch().map((rows) {
      return rows.map(_transferFromRow).toList();
    });
  }

  // Helper to convert database row to Transfer model
  model.Transfer _transferFromRow(Transfer row) {
    final filesList = (json.decode(row.filesJson) as List<dynamic>)
        .map((f) => model.TransferFile.fromJson(f as Map<String, dynamic>))
        .toList();

    return model.Transfer(
      id: row.id,
      status: TransferStatus.values[row.status],
      files: filesList,
      progress: row.progress,
      timestamp: row.timestamp,
      direction: TransferDirection.values[row.direction],
      senderName: row.senderName,
      receiverName: row.receiverName,
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.dbName));
    return NativeDatabase(file);
  });
}
