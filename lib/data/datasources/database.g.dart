// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TransfersTable extends Transfers
    with TableInfo<$TransfersTable, Transfer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransfersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _filesJsonMeta =
      const VerificationMeta('filesJson');
  @override
  late final GeneratedColumn<String> filesJson = GeneratedColumn<String>(
      'files_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _progressMeta =
      const VerificationMeta('progress');
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
      'progress', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _directionMeta =
      const VerificationMeta('direction');
  @override
  late final GeneratedColumn<int> direction = GeneratedColumn<int>(
      'direction', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _senderNameMeta =
      const VerificationMeta('senderName');
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
      'sender_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Unknown'));
  static const VerificationMeta _receiverNameMeta =
      const VerificationMeta('receiverName');
  @override
  late final GeneratedColumn<String> receiverName = GeneratedColumn<String>(
      'receiver_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Unknown'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        status,
        filesJson,
        progress,
        timestamp,
        direction,
        senderName,
        receiverName
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transfers';
  @override
  VerificationContext validateIntegrity(Insertable<Transfer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('files_json')) {
      context.handle(_filesJsonMeta,
          filesJson.isAcceptableOrUnknown(data['files_json']!, _filesJsonMeta));
    } else if (isInserting) {
      context.missing(_filesJsonMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta,
          progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    } else if (isInserting) {
      context.missing(_progressMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(_directionMeta,
          direction.isAcceptableOrUnknown(data['direction']!, _directionMeta));
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('sender_name')) {
      context.handle(
          _senderNameMeta,
          senderName.isAcceptableOrUnknown(
              data['sender_name']!, _senderNameMeta));
    }
    if (data.containsKey('receiver_name')) {
      context.handle(
          _receiverNameMeta,
          receiverName.isAcceptableOrUnknown(
              data['receiver_name']!, _receiverNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transfer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transfer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      filesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}files_json'])!,
      progress: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}progress'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      direction: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}direction'])!,
      senderName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_name'])!,
      receiverName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receiver_name'])!,
    );
  }

  @override
  $TransfersTable createAlias(String alias) {
    return $TransfersTable(attachedDatabase, alias);
  }
}

class Transfer extends DataClass implements Insertable<Transfer> {
  final String id;
  final int status;
  final String filesJson;
  final double progress;
  final DateTime timestamp;
  final int direction;
  final String senderName;
  final String receiverName;
  const Transfer(
      {required this.id,
      required this.status,
      required this.filesJson,
      required this.progress,
      required this.timestamp,
      required this.direction,
      required this.senderName,
      required this.receiverName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['status'] = Variable<int>(status);
    map['files_json'] = Variable<String>(filesJson);
    map['progress'] = Variable<double>(progress);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['direction'] = Variable<int>(direction);
    map['sender_name'] = Variable<String>(senderName);
    map['receiver_name'] = Variable<String>(receiverName);
    return map;
  }

  TransfersCompanion toCompanion(bool nullToAbsent) {
    return TransfersCompanion(
      id: Value(id),
      status: Value(status),
      filesJson: Value(filesJson),
      progress: Value(progress),
      timestamp: Value(timestamp),
      direction: Value(direction),
      senderName: Value(senderName),
      receiverName: Value(receiverName),
    );
  }

  factory Transfer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transfer(
      id: serializer.fromJson<String>(json['id']),
      status: serializer.fromJson<int>(json['status']),
      filesJson: serializer.fromJson<String>(json['filesJson']),
      progress: serializer.fromJson<double>(json['progress']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      direction: serializer.fromJson<int>(json['direction']),
      senderName: serializer.fromJson<String>(json['senderName']),
      receiverName: serializer.fromJson<String>(json['receiverName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'status': serializer.toJson<int>(status),
      'filesJson': serializer.toJson<String>(filesJson),
      'progress': serializer.toJson<double>(progress),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'direction': serializer.toJson<int>(direction),
      'senderName': serializer.toJson<String>(senderName),
      'receiverName': serializer.toJson<String>(receiverName),
    };
  }

  Transfer copyWith(
          {String? id,
          int? status,
          String? filesJson,
          double? progress,
          DateTime? timestamp,
          int? direction,
          String? senderName,
          String? receiverName}) =>
      Transfer(
        id: id ?? this.id,
        status: status ?? this.status,
        filesJson: filesJson ?? this.filesJson,
        progress: progress ?? this.progress,
        timestamp: timestamp ?? this.timestamp,
        direction: direction ?? this.direction,
        senderName: senderName ?? this.senderName,
        receiverName: receiverName ?? this.receiverName,
      );
  Transfer copyWithCompanion(TransfersCompanion data) {
    return Transfer(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      filesJson: data.filesJson.present ? data.filesJson.value : this.filesJson,
      progress: data.progress.present ? data.progress.value : this.progress,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      direction: data.direction.present ? data.direction.value : this.direction,
      senderName:
          data.senderName.present ? data.senderName.value : this.senderName,
      receiverName: data.receiverName.present
          ? data.receiverName.value
          : this.receiverName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transfer(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('filesJson: $filesJson, ')
          ..write('progress: $progress, ')
          ..write('timestamp: $timestamp, ')
          ..write('direction: $direction, ')
          ..write('senderName: $senderName, ')
          ..write('receiverName: $receiverName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, status, filesJson, progress, timestamp,
      direction, senderName, receiverName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transfer &&
          other.id == this.id &&
          other.status == this.status &&
          other.filesJson == this.filesJson &&
          other.progress == this.progress &&
          other.timestamp == this.timestamp &&
          other.direction == this.direction &&
          other.senderName == this.senderName &&
          other.receiverName == this.receiverName);
}

class TransfersCompanion extends UpdateCompanion<Transfer> {
  final Value<String> id;
  final Value<int> status;
  final Value<String> filesJson;
  final Value<double> progress;
  final Value<DateTime> timestamp;
  final Value<int> direction;
  final Value<String> senderName;
  final Value<String> receiverName;
  final Value<int> rowid;
  const TransfersCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.filesJson = const Value.absent(),
    this.progress = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.direction = const Value.absent(),
    this.senderName = const Value.absent(),
    this.receiverName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransfersCompanion.insert({
    required String id,
    required int status,
    required String filesJson,
    required double progress,
    required DateTime timestamp,
    required int direction,
    this.senderName = const Value.absent(),
    this.receiverName = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        status = Value(status),
        filesJson = Value(filesJson),
        progress = Value(progress),
        timestamp = Value(timestamp),
        direction = Value(direction);
  static Insertable<Transfer> custom({
    Expression<String>? id,
    Expression<int>? status,
    Expression<String>? filesJson,
    Expression<double>? progress,
    Expression<DateTime>? timestamp,
    Expression<int>? direction,
    Expression<String>? senderName,
    Expression<String>? receiverName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (filesJson != null) 'files_json': filesJson,
      if (progress != null) 'progress': progress,
      if (timestamp != null) 'timestamp': timestamp,
      if (direction != null) 'direction': direction,
      if (senderName != null) 'sender_name': senderName,
      if (receiverName != null) 'receiver_name': receiverName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransfersCompanion copyWith(
      {Value<String>? id,
      Value<int>? status,
      Value<String>? filesJson,
      Value<double>? progress,
      Value<DateTime>? timestamp,
      Value<int>? direction,
      Value<String>? senderName,
      Value<String>? receiverName,
      Value<int>? rowid}) {
    return TransfersCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      filesJson: filesJson ?? this.filesJson,
      progress: progress ?? this.progress,
      timestamp: timestamp ?? this.timestamp,
      direction: direction ?? this.direction,
      senderName: senderName ?? this.senderName,
      receiverName: receiverName ?? this.receiverName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (filesJson.present) {
      map['files_json'] = Variable<String>(filesJson.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (direction.present) {
      map['direction'] = Variable<int>(direction.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (receiverName.present) {
      map['receiver_name'] = Variable<String>(receiverName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransfersCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('filesJson: $filesJson, ')
          ..write('progress: $progress, ')
          ..write('timestamp: $timestamp, ')
          ..write('direction: $direction, ')
          ..write('senderName: $senderName, ')
          ..write('receiverName: $receiverName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransfersTable transfers = $TransfersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [transfers];
}

typedef $$TransfersTableCreateCompanionBuilder = TransfersCompanion Function({
  required String id,
  required int status,
  required String filesJson,
  required double progress,
  required DateTime timestamp,
  required int direction,
  Value<String> senderName,
  Value<String> receiverName,
  Value<int> rowid,
});
typedef $$TransfersTableUpdateCompanionBuilder = TransfersCompanion Function({
  Value<String> id,
  Value<int> status,
  Value<String> filesJson,
  Value<double> progress,
  Value<DateTime> timestamp,
  Value<int> direction,
  Value<String> senderName,
  Value<String> receiverName,
  Value<int> rowid,
});

class $$TransfersTableFilterComposer
    extends Composer<_$AppDatabase, $TransfersTable> {
  $$TransfersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filesJson => $composableBuilder(
      column: $table.filesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderName => $composableBuilder(
      column: $table.senderName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiverName => $composableBuilder(
      column: $table.receiverName, builder: (column) => ColumnFilters(column));
}

class $$TransfersTableOrderingComposer
    extends Composer<_$AppDatabase, $TransfersTable> {
  $$TransfersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filesJson => $composableBuilder(
      column: $table.filesJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderName => $composableBuilder(
      column: $table.senderName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiverName => $composableBuilder(
      column: $table.receiverName,
      builder: (column) => ColumnOrderings(column));
}

class $$TransfersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransfersTable> {
  $$TransfersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get filesJson =>
      $composableBuilder(column: $table.filesJson, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get senderName => $composableBuilder(
      column: $table.senderName, builder: (column) => column);

  GeneratedColumn<String> get receiverName => $composableBuilder(
      column: $table.receiverName, builder: (column) => column);
}

class $$TransfersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransfersTable,
    Transfer,
    $$TransfersTableFilterComposer,
    $$TransfersTableOrderingComposer,
    $$TransfersTableAnnotationComposer,
    $$TransfersTableCreateCompanionBuilder,
    $$TransfersTableUpdateCompanionBuilder,
    (Transfer, BaseReferences<_$AppDatabase, $TransfersTable, Transfer>),
    Transfer,
    PrefetchHooks Function()> {
  $$TransfersTableTableManager(_$AppDatabase db, $TransfersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransfersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<String> filesJson = const Value.absent(),
            Value<double> progress = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> direction = const Value.absent(),
            Value<String> senderName = const Value.absent(),
            Value<String> receiverName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransfersCompanion(
            id: id,
            status: status,
            filesJson: filesJson,
            progress: progress,
            timestamp: timestamp,
            direction: direction,
            senderName: senderName,
            receiverName: receiverName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int status,
            required String filesJson,
            required double progress,
            required DateTime timestamp,
            required int direction,
            Value<String> senderName = const Value.absent(),
            Value<String> receiverName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransfersCompanion.insert(
            id: id,
            status: status,
            filesJson: filesJson,
            progress: progress,
            timestamp: timestamp,
            direction: direction,
            senderName: senderName,
            receiverName: receiverName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransfersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransfersTable,
    Transfer,
    $$TransfersTableFilterComposer,
    $$TransfersTableOrderingComposer,
    $$TransfersTableAnnotationComposer,
    $$TransfersTableCreateCompanionBuilder,
    $$TransfersTableUpdateCompanionBuilder,
    (Transfer, BaseReferences<_$AppDatabase, $TransfersTable, Transfer>),
    Transfer,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransfersTableTableManager get transfers =>
      $$TransfersTableTableManager(_db, _db.transfers);
}
