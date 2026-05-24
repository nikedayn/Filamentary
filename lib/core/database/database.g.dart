// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PrintersTable extends Printers with TableInfo<$PrintersTable, Printer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrintersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ipAddressMeta = const VerificationMeta(
    'ipAddress',
  );
  @override
  late final GeneratedColumn<String> ipAddress = GeneratedColumn<String>(
    'ip_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(80),
  );
  static const VerificationMeta _apiKeyMeta = const VerificationMeta('apiKey');
  @override
  late final GeneratedColumn<String> apiKey = GeneratedColumn<String>(
    'api_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeSlotsJsonMeta = const VerificationMeta(
    'activeSlotsJson',
  );
  @override
  late final GeneratedColumn<String> activeSlotsJson = GeneratedColumn<String>(
    'active_slots_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotsCountMeta = const VerificationMeta(
    'slotsCount',
  );
  @override
  late final GeneratedColumn<int> slotsCount = GeneratedColumn<int>(
    'slots_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    ipAddress,
    manufacturer,
    model,
    port,
    apiKey,
    activeSlotsJson,
    slotsCount,
    version,
    timestamp,
    isDeleted,
    imageUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'printers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Printer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('ip_address')) {
      context.handle(
        _ipAddressMeta,
        ipAddress.isAcceptableOrUnknown(data['ip_address']!, _ipAddressMeta),
      );
    } else if (isInserting) {
      context.missing(_ipAddressMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manufacturerMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    }
    if (data.containsKey('api_key')) {
      context.handle(
        _apiKeyMeta,
        apiKey.isAcceptableOrUnknown(data['api_key']!, _apiKeyMeta),
      );
    }
    if (data.containsKey('active_slots_json')) {
      context.handle(
        _activeSlotsJsonMeta,
        activeSlotsJson.isAcceptableOrUnknown(
          data['active_slots_json']!,
          _activeSlotsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activeSlotsJsonMeta);
    }
    if (data.containsKey('slots_count')) {
      context.handle(
        _slotsCountMeta,
        slotsCount.isAcceptableOrUnknown(data['slots_count']!, _slotsCountMeta),
      );
    } else if (isInserting) {
      context.missing(_slotsCountMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Printer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Printer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      ipAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ip_address'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}port'],
      )!,
      apiKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_key'],
      ),
      activeSlotsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_slots_json'],
      )!,
      slotsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slots_count'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
    );
  }

  @override
  $PrintersTable createAlias(String alias) {
    return $PrintersTable(attachedDatabase, alias);
  }
}

class Printer extends DataClass implements Insertable<Printer> {
  final String id;
  final String name;
  final String ipAddress;
  final String manufacturer;
  final String model;
  final int port;
  final String? apiKey;
  final String activeSlotsJson;
  final int slotsCount;
  final int version;
  final DateTime timestamp;
  final bool isDeleted;
  final String? imageUrl;
  const Printer({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.manufacturer,
    required this.model,
    required this.port,
    this.apiKey,
    required this.activeSlotsJson,
    required this.slotsCount,
    required this.version,
    required this.timestamp,
    required this.isDeleted,
    this.imageUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['ip_address'] = Variable<String>(ipAddress);
    map['manufacturer'] = Variable<String>(manufacturer);
    map['model'] = Variable<String>(model);
    map['port'] = Variable<int>(port);
    if (!nullToAbsent || apiKey != null) {
      map['api_key'] = Variable<String>(apiKey);
    }
    map['active_slots_json'] = Variable<String>(activeSlotsJson);
    map['slots_count'] = Variable<int>(slotsCount);
    map['version'] = Variable<int>(version);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    return map;
  }

  PrintersCompanion toCompanion(bool nullToAbsent) {
    return PrintersCompanion(
      id: Value(id),
      name: Value(name),
      ipAddress: Value(ipAddress),
      manufacturer: Value(manufacturer),
      model: Value(model),
      port: Value(port),
      apiKey: apiKey == null && nullToAbsent
          ? const Value.absent()
          : Value(apiKey),
      activeSlotsJson: Value(activeSlotsJson),
      slotsCount: Value(slotsCount),
      version: Value(version),
      timestamp: Value(timestamp),
      isDeleted: Value(isDeleted),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
    );
  }

  factory Printer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Printer(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      ipAddress: serializer.fromJson<String>(json['ipAddress']),
      manufacturer: serializer.fromJson<String>(json['manufacturer']),
      model: serializer.fromJson<String>(json['model']),
      port: serializer.fromJson<int>(json['port']),
      apiKey: serializer.fromJson<String?>(json['apiKey']),
      activeSlotsJson: serializer.fromJson<String>(json['activeSlotsJson']),
      slotsCount: serializer.fromJson<int>(json['slotsCount']),
      version: serializer.fromJson<int>(json['version']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'ipAddress': serializer.toJson<String>(ipAddress),
      'manufacturer': serializer.toJson<String>(manufacturer),
      'model': serializer.toJson<String>(model),
      'port': serializer.toJson<int>(port),
      'apiKey': serializer.toJson<String?>(apiKey),
      'activeSlotsJson': serializer.toJson<String>(activeSlotsJson),
      'slotsCount': serializer.toJson<int>(slotsCount),
      'version': serializer.toJson<int>(version),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'imageUrl': serializer.toJson<String?>(imageUrl),
    };
  }

  Printer copyWith({
    String? id,
    String? name,
    String? ipAddress,
    String? manufacturer,
    String? model,
    int? port,
    Value<String?> apiKey = const Value.absent(),
    String? activeSlotsJson,
    int? slotsCount,
    int? version,
    DateTime? timestamp,
    bool? isDeleted,
    Value<String?> imageUrl = const Value.absent(),
  }) => Printer(
    id: id ?? this.id,
    name: name ?? this.name,
    ipAddress: ipAddress ?? this.ipAddress,
    manufacturer: manufacturer ?? this.manufacturer,
    model: model ?? this.model,
    port: port ?? this.port,
    apiKey: apiKey.present ? apiKey.value : this.apiKey,
    activeSlotsJson: activeSlotsJson ?? this.activeSlotsJson,
    slotsCount: slotsCount ?? this.slotsCount,
    version: version ?? this.version,
    timestamp: timestamp ?? this.timestamp,
    isDeleted: isDeleted ?? this.isDeleted,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
  );
  Printer copyWithCompanion(PrintersCompanion data) {
    return Printer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      ipAddress: data.ipAddress.present ? data.ipAddress.value : this.ipAddress,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      model: data.model.present ? data.model.value : this.model,
      port: data.port.present ? data.port.value : this.port,
      apiKey: data.apiKey.present ? data.apiKey.value : this.apiKey,
      activeSlotsJson: data.activeSlotsJson.present
          ? data.activeSlotsJson.value
          : this.activeSlotsJson,
      slotsCount: data.slotsCount.present
          ? data.slotsCount.value
          : this.slotsCount,
      version: data.version.present ? data.version.value : this.version,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Printer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('port: $port, ')
          ..write('apiKey: $apiKey, ')
          ..write('activeSlotsJson: $activeSlotsJson, ')
          ..write('slotsCount: $slotsCount, ')
          ..write('version: $version, ')
          ..write('timestamp: $timestamp, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('imageUrl: $imageUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    ipAddress,
    manufacturer,
    model,
    port,
    apiKey,
    activeSlotsJson,
    slotsCount,
    version,
    timestamp,
    isDeleted,
    imageUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Printer &&
          other.id == this.id &&
          other.name == this.name &&
          other.ipAddress == this.ipAddress &&
          other.manufacturer == this.manufacturer &&
          other.model == this.model &&
          other.port == this.port &&
          other.apiKey == this.apiKey &&
          other.activeSlotsJson == this.activeSlotsJson &&
          other.slotsCount == this.slotsCount &&
          other.version == this.version &&
          other.timestamp == this.timestamp &&
          other.isDeleted == this.isDeleted &&
          other.imageUrl == this.imageUrl);
}

class PrintersCompanion extends UpdateCompanion<Printer> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> ipAddress;
  final Value<String> manufacturer;
  final Value<String> model;
  final Value<int> port;
  final Value<String?> apiKey;
  final Value<String> activeSlotsJson;
  final Value<int> slotsCount;
  final Value<int> version;
  final Value<DateTime> timestamp;
  final Value<bool> isDeleted;
  final Value<String?> imageUrl;
  final Value<int> rowid;
  const PrintersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.ipAddress = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    this.port = const Value.absent(),
    this.apiKey = const Value.absent(),
    this.activeSlotsJson = const Value.absent(),
    this.slotsCount = const Value.absent(),
    this.version = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrintersCompanion.insert({
    required String id,
    required String name,
    required String ipAddress,
    required String manufacturer,
    required String model,
    this.port = const Value.absent(),
    this.apiKey = const Value.absent(),
    required String activeSlotsJson,
    required int slotsCount,
    this.version = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       ipAddress = Value(ipAddress),
       manufacturer = Value(manufacturer),
       model = Value(model),
       activeSlotsJson = Value(activeSlotsJson),
       slotsCount = Value(slotsCount);
  static Insertable<Printer> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? ipAddress,
    Expression<String>? manufacturer,
    Expression<String>? model,
    Expression<int>? port,
    Expression<String>? apiKey,
    Expression<String>? activeSlotsJson,
    Expression<int>? slotsCount,
    Expression<int>? version,
    Expression<DateTime>? timestamp,
    Expression<bool>? isDeleted,
    Expression<String>? imageUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (ipAddress != null) 'ip_address': ipAddress,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (model != null) 'model': model,
      if (port != null) 'port': port,
      if (apiKey != null) 'api_key': apiKey,
      if (activeSlotsJson != null) 'active_slots_json': activeSlotsJson,
      if (slotsCount != null) 'slots_count': slotsCount,
      if (version != null) 'version': version,
      if (timestamp != null) 'timestamp': timestamp,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (imageUrl != null) 'image_url': imageUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrintersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? ipAddress,
    Value<String>? manufacturer,
    Value<String>? model,
    Value<int>? port,
    Value<String?>? apiKey,
    Value<String>? activeSlotsJson,
    Value<int>? slotsCount,
    Value<int>? version,
    Value<DateTime>? timestamp,
    Value<bool>? isDeleted,
    Value<String?>? imageUrl,
    Value<int>? rowid,
  }) {
    return PrintersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      port: port ?? this.port,
      apiKey: apiKey ?? this.apiKey,
      activeSlotsJson: activeSlotsJson ?? this.activeSlotsJson,
      slotsCount: slotsCount ?? this.slotsCount,
      version: version ?? this.version,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      imageUrl: imageUrl ?? this.imageUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (ipAddress.present) {
      map['ip_address'] = Variable<String>(ipAddress.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (apiKey.present) {
      map['api_key'] = Variable<String>(apiKey.value);
    }
    if (activeSlotsJson.present) {
      map['active_slots_json'] = Variable<String>(activeSlotsJson.value);
    }
    if (slotsCount.present) {
      map['slots_count'] = Variable<int>(slotsCount.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrintersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('ipAddress: $ipAddress, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('port: $port, ')
          ..write('apiKey: $apiKey, ')
          ..write('activeSlotsJson: $activeSlotsJson, ')
          ..write('slotsCount: $slotsCount, ')
          ..write('version: $version, ')
          ..write('timestamp: $timestamp, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MaterialsTable extends Materials
    with TableInfo<$MaterialsTable, Material> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaterialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diameterMeta = const VerificationMeta(
    'diameter',
  );
  @override
  late final GeneratedColumn<String> diameter = GeneratedColumn<String>(
    'diameter',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('1.75mm'),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _initialWeightMeta = const VerificationMeta(
    'initialWeight',
  );
  @override
  late final GeneratedColumn<double> initialWeight = GeneratedColumn<double>(
    'initial_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usedWeightMeta = const VerificationMeta(
    'usedWeight',
  );
  @override
  late final GeneratedColumn<double> usedWeight = GeneratedColumn<double>(
    'used_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    manufacturer,
    type,
    color,
    diameter,
    imageUrl,
    initialWeight,
    usedWeight,
    version,
    timestamp,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'materials';
  @override
  VerificationContext validateIntegrity(
    Insertable<Material> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_manufacturerMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('diameter')) {
      context.handle(
        _diameterMeta,
        diameter.isAcceptableOrUnknown(data['diameter']!, _diameterMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('initial_weight')) {
      context.handle(
        _initialWeightMeta,
        initialWeight.isAcceptableOrUnknown(
          data['initial_weight']!,
          _initialWeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialWeightMeta);
    }
    if (data.containsKey('used_weight')) {
      context.handle(
        _usedWeightMeta,
        usedWeight.isAcceptableOrUnknown(data['used_weight']!, _usedWeightMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Material map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Material(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      diameter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diameter'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      initialWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}initial_weight'],
      )!,
      usedWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}used_weight'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $MaterialsTable createAlias(String alias) {
    return $MaterialsTable(attachedDatabase, alias);
  }
}

class Material extends DataClass implements Insertable<Material> {
  final String id;
  final String manufacturer;
  final String type;
  final String color;
  final String diameter;
  final String? imageUrl;
  final double initialWeight;
  final double usedWeight;
  final int version;
  final DateTime timestamp;
  final bool isDeleted;
  const Material({
    required this.id,
    required this.manufacturer,
    required this.type,
    required this.color,
    required this.diameter,
    this.imageUrl,
    required this.initialWeight,
    required this.usedWeight,
    required this.version,
    required this.timestamp,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['manufacturer'] = Variable<String>(manufacturer);
    map['type'] = Variable<String>(type);
    map['color'] = Variable<String>(color);
    map['diameter'] = Variable<String>(diameter);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['initial_weight'] = Variable<double>(initialWeight);
    map['used_weight'] = Variable<double>(usedWeight);
    map['version'] = Variable<int>(version);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  MaterialsCompanion toCompanion(bool nullToAbsent) {
    return MaterialsCompanion(
      id: Value(id),
      manufacturer: Value(manufacturer),
      type: Value(type),
      color: Value(color),
      diameter: Value(diameter),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      initialWeight: Value(initialWeight),
      usedWeight: Value(usedWeight),
      version: Value(version),
      timestamp: Value(timestamp),
      isDeleted: Value(isDeleted),
    );
  }

  factory Material.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Material(
      id: serializer.fromJson<String>(json['id']),
      manufacturer: serializer.fromJson<String>(json['manufacturer']),
      type: serializer.fromJson<String>(json['type']),
      color: serializer.fromJson<String>(json['color']),
      diameter: serializer.fromJson<String>(json['diameter']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      initialWeight: serializer.fromJson<double>(json['initialWeight']),
      usedWeight: serializer.fromJson<double>(json['usedWeight']),
      version: serializer.fromJson<int>(json['version']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'manufacturer': serializer.toJson<String>(manufacturer),
      'type': serializer.toJson<String>(type),
      'color': serializer.toJson<String>(color),
      'diameter': serializer.toJson<String>(diameter),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'initialWeight': serializer.toJson<double>(initialWeight),
      'usedWeight': serializer.toJson<double>(usedWeight),
      'version': serializer.toJson<int>(version),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Material copyWith({
    String? id,
    String? manufacturer,
    String? type,
    String? color,
    String? diameter,
    Value<String?> imageUrl = const Value.absent(),
    double? initialWeight,
    double? usedWeight,
    int? version,
    DateTime? timestamp,
    bool? isDeleted,
  }) => Material(
    id: id ?? this.id,
    manufacturer: manufacturer ?? this.manufacturer,
    type: type ?? this.type,
    color: color ?? this.color,
    diameter: diameter ?? this.diameter,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    initialWeight: initialWeight ?? this.initialWeight,
    usedWeight: usedWeight ?? this.usedWeight,
    version: version ?? this.version,
    timestamp: timestamp ?? this.timestamp,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Material copyWithCompanion(MaterialsCompanion data) {
    return Material(
      id: data.id.present ? data.id.value : this.id,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      type: data.type.present ? data.type.value : this.type,
      color: data.color.present ? data.color.value : this.color,
      diameter: data.diameter.present ? data.diameter.value : this.diameter,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      initialWeight: data.initialWeight.present
          ? data.initialWeight.value
          : this.initialWeight,
      usedWeight: data.usedWeight.present
          ? data.usedWeight.value
          : this.usedWeight,
      version: data.version.present ? data.version.value : this.version,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Material(')
          ..write('id: $id, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('diameter: $diameter, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('initialWeight: $initialWeight, ')
          ..write('usedWeight: $usedWeight, ')
          ..write('version: $version, ')
          ..write('timestamp: $timestamp, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    manufacturer,
    type,
    color,
    diameter,
    imageUrl,
    initialWeight,
    usedWeight,
    version,
    timestamp,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Material &&
          other.id == this.id &&
          other.manufacturer == this.manufacturer &&
          other.type == this.type &&
          other.color == this.color &&
          other.diameter == this.diameter &&
          other.imageUrl == this.imageUrl &&
          other.initialWeight == this.initialWeight &&
          other.usedWeight == this.usedWeight &&
          other.version == this.version &&
          other.timestamp == this.timestamp &&
          other.isDeleted == this.isDeleted);
}

class MaterialsCompanion extends UpdateCompanion<Material> {
  final Value<String> id;
  final Value<String> manufacturer;
  final Value<String> type;
  final Value<String> color;
  final Value<String> diameter;
  final Value<String?> imageUrl;
  final Value<double> initialWeight;
  final Value<double> usedWeight;
  final Value<int> version;
  final Value<DateTime> timestamp;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const MaterialsCompanion({
    this.id = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.type = const Value.absent(),
    this.color = const Value.absent(),
    this.diameter = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.initialWeight = const Value.absent(),
    this.usedWeight = const Value.absent(),
    this.version = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MaterialsCompanion.insert({
    required String id,
    required String manufacturer,
    required String type,
    required String color,
    this.diameter = const Value.absent(),
    this.imageUrl = const Value.absent(),
    required double initialWeight,
    this.usedWeight = const Value.absent(),
    this.version = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       manufacturer = Value(manufacturer),
       type = Value(type),
       color = Value(color),
       initialWeight = Value(initialWeight);
  static Insertable<Material> custom({
    Expression<String>? id,
    Expression<String>? manufacturer,
    Expression<String>? type,
    Expression<String>? color,
    Expression<String>? diameter,
    Expression<String>? imageUrl,
    Expression<double>? initialWeight,
    Expression<double>? usedWeight,
    Expression<int>? version,
    Expression<DateTime>? timestamp,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (type != null) 'type': type,
      if (color != null) 'color': color,
      if (diameter != null) 'diameter': diameter,
      if (imageUrl != null) 'image_url': imageUrl,
      if (initialWeight != null) 'initial_weight': initialWeight,
      if (usedWeight != null) 'used_weight': usedWeight,
      if (version != null) 'version': version,
      if (timestamp != null) 'timestamp': timestamp,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MaterialsCompanion copyWith({
    Value<String>? id,
    Value<String>? manufacturer,
    Value<String>? type,
    Value<String>? color,
    Value<String>? diameter,
    Value<String?>? imageUrl,
    Value<double>? initialWeight,
    Value<double>? usedWeight,
    Value<int>? version,
    Value<DateTime>? timestamp,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return MaterialsCompanion(
      id: id ?? this.id,
      manufacturer: manufacturer ?? this.manufacturer,
      type: type ?? this.type,
      color: color ?? this.color,
      diameter: diameter ?? this.diameter,
      imageUrl: imageUrl ?? this.imageUrl,
      initialWeight: initialWeight ?? this.initialWeight,
      usedWeight: usedWeight ?? this.usedWeight,
      version: version ?? this.version,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (diameter.present) {
      map['diameter'] = Variable<String>(diameter.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (initialWeight.present) {
      map['initial_weight'] = Variable<double>(initialWeight.value);
    }
    if (usedWeight.present) {
      map['used_weight'] = Variable<double>(usedWeight.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaterialsCompanion(')
          ..write('id: $id, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('diameter: $diameter, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('initialWeight: $initialWeight, ')
          ..write('usedWeight: $usedWeight, ')
          ..write('version: $version, ')
          ..write('timestamp: $timestamp, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrintJobsTable extends PrintJobs
    with TableInfo<$PrintJobsTable, PrintJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrintJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _printerIdMeta = const VerificationMeta(
    'printerId',
  );
  @override
  late final GeneratedColumn<String> printerId = GeneratedColumn<String>(
    'printer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES printers (id)',
    ),
  );
  static const VerificationMeta _modelNameMeta = const VerificationMeta(
    'modelName',
  );
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
    'model_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spentWeightMeta = const VerificationMeta(
    'spentWeight',
  );
  @override
  late final GeneratedColumn<double> spentWeight = GeneratedColumn<double>(
    'spent_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usedMaterialsLogJsonMeta =
      const VerificationMeta('usedMaterialsLogJson');
  @override
  late final GeneratedColumn<String> usedMaterialsLogJson =
      GeneratedColumn<String>(
        'used_materials_log_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    printerId,
    modelName,
    status,
    spentWeight,
    usedMaterialsLogJson,
    startTime,
    duration,
    version,
    timestamp,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'print_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrintJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('printer_id')) {
      context.handle(
        _printerIdMeta,
        printerId.isAcceptableOrUnknown(data['printer_id']!, _printerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_printerIdMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(
        _modelNameMeta,
        modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta),
      );
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('spent_weight')) {
      context.handle(
        _spentWeightMeta,
        spentWeight.isAcceptableOrUnknown(
          data['spent_weight']!,
          _spentWeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_spentWeightMeta);
    }
    if (data.containsKey('used_materials_log_json')) {
      context.handle(
        _usedMaterialsLogJsonMeta,
        usedMaterialsLogJson.isAcceptableOrUnknown(
          data['used_materials_log_json']!,
          _usedMaterialsLogJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_usedMaterialsLogJsonMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrintJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrintJob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      printerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printer_id'],
      )!,
      modelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      spentWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}spent_weight'],
      )!,
      usedMaterialsLogJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}used_materials_log_json'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $PrintJobsTable createAlias(String alias) {
    return $PrintJobsTable(attachedDatabase, alias);
  }
}

class PrintJob extends DataClass implements Insertable<PrintJob> {
  final String id;
  final String printerId;
  final String modelName;
  final String status;
  final double spentWeight;
  final String usedMaterialsLogJson;
  final DateTime startTime;
  final int duration;
  final int version;
  final DateTime timestamp;
  final bool isDeleted;
  const PrintJob({
    required this.id,
    required this.printerId,
    required this.modelName,
    required this.status,
    required this.spentWeight,
    required this.usedMaterialsLogJson,
    required this.startTime,
    required this.duration,
    required this.version,
    required this.timestamp,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['printer_id'] = Variable<String>(printerId);
    map['model_name'] = Variable<String>(modelName);
    map['status'] = Variable<String>(status);
    map['spent_weight'] = Variable<double>(spentWeight);
    map['used_materials_log_json'] = Variable<String>(usedMaterialsLogJson);
    map['start_time'] = Variable<DateTime>(startTime);
    map['duration'] = Variable<int>(duration);
    map['version'] = Variable<int>(version);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  PrintJobsCompanion toCompanion(bool nullToAbsent) {
    return PrintJobsCompanion(
      id: Value(id),
      printerId: Value(printerId),
      modelName: Value(modelName),
      status: Value(status),
      spentWeight: Value(spentWeight),
      usedMaterialsLogJson: Value(usedMaterialsLogJson),
      startTime: Value(startTime),
      duration: Value(duration),
      version: Value(version),
      timestamp: Value(timestamp),
      isDeleted: Value(isDeleted),
    );
  }

  factory PrintJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrintJob(
      id: serializer.fromJson<String>(json['id']),
      printerId: serializer.fromJson<String>(json['printerId']),
      modelName: serializer.fromJson<String>(json['modelName']),
      status: serializer.fromJson<String>(json['status']),
      spentWeight: serializer.fromJson<double>(json['spentWeight']),
      usedMaterialsLogJson: serializer.fromJson<String>(
        json['usedMaterialsLogJson'],
      ),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      duration: serializer.fromJson<int>(json['duration']),
      version: serializer.fromJson<int>(json['version']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'printerId': serializer.toJson<String>(printerId),
      'modelName': serializer.toJson<String>(modelName),
      'status': serializer.toJson<String>(status),
      'spentWeight': serializer.toJson<double>(spentWeight),
      'usedMaterialsLogJson': serializer.toJson<String>(usedMaterialsLogJson),
      'startTime': serializer.toJson<DateTime>(startTime),
      'duration': serializer.toJson<int>(duration),
      'version': serializer.toJson<int>(version),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  PrintJob copyWith({
    String? id,
    String? printerId,
    String? modelName,
    String? status,
    double? spentWeight,
    String? usedMaterialsLogJson,
    DateTime? startTime,
    int? duration,
    int? version,
    DateTime? timestamp,
    bool? isDeleted,
  }) => PrintJob(
    id: id ?? this.id,
    printerId: printerId ?? this.printerId,
    modelName: modelName ?? this.modelName,
    status: status ?? this.status,
    spentWeight: spentWeight ?? this.spentWeight,
    usedMaterialsLogJson: usedMaterialsLogJson ?? this.usedMaterialsLogJson,
    startTime: startTime ?? this.startTime,
    duration: duration ?? this.duration,
    version: version ?? this.version,
    timestamp: timestamp ?? this.timestamp,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  PrintJob copyWithCompanion(PrintJobsCompanion data) {
    return PrintJob(
      id: data.id.present ? data.id.value : this.id,
      printerId: data.printerId.present ? data.printerId.value : this.printerId,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      status: data.status.present ? data.status.value : this.status,
      spentWeight: data.spentWeight.present
          ? data.spentWeight.value
          : this.spentWeight,
      usedMaterialsLogJson: data.usedMaterialsLogJson.present
          ? data.usedMaterialsLogJson.value
          : this.usedMaterialsLogJson,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      duration: data.duration.present ? data.duration.value : this.duration,
      version: data.version.present ? data.version.value : this.version,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrintJob(')
          ..write('id: $id, ')
          ..write('printerId: $printerId, ')
          ..write('modelName: $modelName, ')
          ..write('status: $status, ')
          ..write('spentWeight: $spentWeight, ')
          ..write('usedMaterialsLogJson: $usedMaterialsLogJson, ')
          ..write('startTime: $startTime, ')
          ..write('duration: $duration, ')
          ..write('version: $version, ')
          ..write('timestamp: $timestamp, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    printerId,
    modelName,
    status,
    spentWeight,
    usedMaterialsLogJson,
    startTime,
    duration,
    version,
    timestamp,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrintJob &&
          other.id == this.id &&
          other.printerId == this.printerId &&
          other.modelName == this.modelName &&
          other.status == this.status &&
          other.spentWeight == this.spentWeight &&
          other.usedMaterialsLogJson == this.usedMaterialsLogJson &&
          other.startTime == this.startTime &&
          other.duration == this.duration &&
          other.version == this.version &&
          other.timestamp == this.timestamp &&
          other.isDeleted == this.isDeleted);
}

class PrintJobsCompanion extends UpdateCompanion<PrintJob> {
  final Value<String> id;
  final Value<String> printerId;
  final Value<String> modelName;
  final Value<String> status;
  final Value<double> spentWeight;
  final Value<String> usedMaterialsLogJson;
  final Value<DateTime> startTime;
  final Value<int> duration;
  final Value<int> version;
  final Value<DateTime> timestamp;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const PrintJobsCompanion({
    this.id = const Value.absent(),
    this.printerId = const Value.absent(),
    this.modelName = const Value.absent(),
    this.status = const Value.absent(),
    this.spentWeight = const Value.absent(),
    this.usedMaterialsLogJson = const Value.absent(),
    this.startTime = const Value.absent(),
    this.duration = const Value.absent(),
    this.version = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrintJobsCompanion.insert({
    required String id,
    required String printerId,
    required String modelName,
    required String status,
    required double spentWeight,
    required String usedMaterialsLogJson,
    required DateTime startTime,
    required int duration,
    this.version = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       printerId = Value(printerId),
       modelName = Value(modelName),
       status = Value(status),
       spentWeight = Value(spentWeight),
       usedMaterialsLogJson = Value(usedMaterialsLogJson),
       startTime = Value(startTime),
       duration = Value(duration);
  static Insertable<PrintJob> custom({
    Expression<String>? id,
    Expression<String>? printerId,
    Expression<String>? modelName,
    Expression<String>? status,
    Expression<double>? spentWeight,
    Expression<String>? usedMaterialsLogJson,
    Expression<DateTime>? startTime,
    Expression<int>? duration,
    Expression<int>? version,
    Expression<DateTime>? timestamp,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (printerId != null) 'printer_id': printerId,
      if (modelName != null) 'model_name': modelName,
      if (status != null) 'status': status,
      if (spentWeight != null) 'spent_weight': spentWeight,
      if (usedMaterialsLogJson != null)
        'used_materials_log_json': usedMaterialsLogJson,
      if (startTime != null) 'start_time': startTime,
      if (duration != null) 'duration': duration,
      if (version != null) 'version': version,
      if (timestamp != null) 'timestamp': timestamp,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrintJobsCompanion copyWith({
    Value<String>? id,
    Value<String>? printerId,
    Value<String>? modelName,
    Value<String>? status,
    Value<double>? spentWeight,
    Value<String>? usedMaterialsLogJson,
    Value<DateTime>? startTime,
    Value<int>? duration,
    Value<int>? version,
    Value<DateTime>? timestamp,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return PrintJobsCompanion(
      id: id ?? this.id,
      printerId: printerId ?? this.printerId,
      modelName: modelName ?? this.modelName,
      status: status ?? this.status,
      spentWeight: spentWeight ?? this.spentWeight,
      usedMaterialsLogJson: usedMaterialsLogJson ?? this.usedMaterialsLogJson,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      version: version ?? this.version,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (printerId.present) {
      map['printer_id'] = Variable<String>(printerId.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (spentWeight.present) {
      map['spent_weight'] = Variable<double>(spentWeight.value);
    }
    if (usedMaterialsLogJson.present) {
      map['used_materials_log_json'] = Variable<String>(
        usedMaterialsLogJson.value,
      );
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrintJobsCompanion(')
          ..write('id: $id, ')
          ..write('printerId: $printerId, ')
          ..write('modelName: $modelName, ')
          ..write('status: $status, ')
          ..write('spentWeight: $spentWeight, ')
          ..write('usedMaterialsLogJson: $usedMaterialsLogJson, ')
          ..write('startTime: $startTime, ')
          ..write('duration: $duration, ')
          ..write('version: $version, ')
          ..write('timestamp: $timestamp, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeValueMeta = const VerificationMeta(
    'changeValue',
  );
  @override
  late final GeneratedColumn<double> changeValue = GeneratedColumn<double>(
    'change_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityId,
    changeValue,
    type,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('change_value')) {
      context.handle(
        _changeValueMeta,
        changeValue.isAcceptableOrUnknown(
          data['change_value']!,
          _changeValueMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      changeValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}change_value'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final String entityId;
  final double? changeValue;
  final String type;
  final DateTime timestamp;
  const Transaction({
    required this.id,
    required this.entityId,
    this.changeValue,
    required this.type,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || changeValue != null) {
      map['change_value'] = Variable<double>(changeValue);
    }
    map['type'] = Variable<String>(type);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      entityId: Value(entityId),
      changeValue: changeValue == null && nullToAbsent
          ? const Value.absent()
          : Value(changeValue),
      type: Value(type),
      timestamp: Value(timestamp),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      entityId: serializer.fromJson<String>(json['entityId']),
      changeValue: serializer.fromJson<double?>(json['changeValue']),
      type: serializer.fromJson<String>(json['type']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityId': serializer.toJson<String>(entityId),
      'changeValue': serializer.toJson<double?>(changeValue),
      'type': serializer.toJson<String>(type),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  Transaction copyWith({
    String? id,
    String? entityId,
    Value<double?> changeValue = const Value.absent(),
    String? type,
    DateTime? timestamp,
  }) => Transaction(
    id: id ?? this.id,
    entityId: entityId ?? this.entityId,
    changeValue: changeValue.present ? changeValue.value : this.changeValue,
    type: type ?? this.type,
    timestamp: timestamp ?? this.timestamp,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      changeValue: data.changeValue.present
          ? data.changeValue.value
          : this.changeValue,
      type: data.type.present ? data.type.value : this.type,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('changeValue: $changeValue, ')
          ..write('type: $type, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityId, changeValue, type, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.entityId == this.entityId &&
          other.changeValue == this.changeValue &&
          other.type == this.type &&
          other.timestamp == this.timestamp);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> entityId;
  final Value<double?> changeValue;
  final Value<String> type;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.entityId = const Value.absent(),
    this.changeValue = const Value.absent(),
    this.type = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String entityId,
    this.changeValue = const Value.absent(),
    required String type,
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityId = Value(entityId),
       type = Value(type);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? entityId,
    Expression<double>? changeValue,
    Expression<String>? type,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityId != null) 'entity_id': entityId,
      if (changeValue != null) 'change_value': changeValue,
      if (type != null) 'type': type,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityId,
    Value<double?>? changeValue,
    Value<String>? type,
    Value<DateTime>? timestamp,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      changeValue: changeValue ?? this.changeValue,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (changeValue.present) {
      map['change_value'] = Variable<double>(changeValue.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('entityId: $entityId, ')
          ..write('changeValue: $changeValue, ')
          ..write('type: $type, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PrintersTable printers = $PrintersTable(this);
  late final $MaterialsTable materials = $MaterialsTable(this);
  late final $PrintJobsTable printJobs = $PrintJobsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    printers,
    materials,
    printJobs,
    transactions,
  ];
}

typedef $$PrintersTableCreateCompanionBuilder =
    PrintersCompanion Function({
      required String id,
      required String name,
      required String ipAddress,
      required String manufacturer,
      required String model,
      Value<int> port,
      Value<String?> apiKey,
      required String activeSlotsJson,
      required int slotsCount,
      Value<int> version,
      Value<DateTime> timestamp,
      Value<bool> isDeleted,
      Value<String?> imageUrl,
      Value<int> rowid,
    });
typedef $$PrintersTableUpdateCompanionBuilder =
    PrintersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> ipAddress,
      Value<String> manufacturer,
      Value<String> model,
      Value<int> port,
      Value<String?> apiKey,
      Value<String> activeSlotsJson,
      Value<int> slotsCount,
      Value<int> version,
      Value<DateTime> timestamp,
      Value<bool> isDeleted,
      Value<String?> imageUrl,
      Value<int> rowid,
    });

final class $$PrintersTableReferences
    extends BaseReferences<_$AppDatabase, $PrintersTable, Printer> {
  $$PrintersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PrintJobsTable, List<PrintJob>>
  _printJobsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.printJobs,
    aliasName: $_aliasNameGenerator(db.printers.id, db.printJobs.printerId),
  );

  $$PrintJobsTableProcessedTableManager get printJobsRefs {
    final manager = $$PrintJobsTableTableManager(
      $_db,
      $_db.printJobs,
    ).filter((f) => f.printerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_printJobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PrintersTableFilterComposer
    extends Composer<_$AppDatabase, $PrintersTable> {
  $$PrintersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ipAddress => $composableBuilder(
    column: $table.ipAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apiKey => $composableBuilder(
    column: $table.apiKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeSlotsJson => $composableBuilder(
    column: $table.activeSlotsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slotsCount => $composableBuilder(
    column: $table.slotsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> printJobsRefs(
    Expression<bool> Function($$PrintJobsTableFilterComposer f) f,
  ) {
    final $$PrintJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.printJobs,
      getReferencedColumn: (t) => t.printerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrintJobsTableFilterComposer(
            $db: $db,
            $table: $db.printJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PrintersTableOrderingComposer
    extends Composer<_$AppDatabase, $PrintersTable> {
  $$PrintersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ipAddress => $composableBuilder(
    column: $table.ipAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiKey => $composableBuilder(
    column: $table.apiKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeSlotsJson => $composableBuilder(
    column: $table.activeSlotsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slotsCount => $composableBuilder(
    column: $table.slotsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrintersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrintersTable> {
  $$PrintersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get ipAddress =>
      $composableBuilder(column: $table.ipAddress, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get apiKey =>
      $composableBuilder(column: $table.apiKey, builder: (column) => column);

  GeneratedColumn<String> get activeSlotsJson => $composableBuilder(
    column: $table.activeSlotsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get slotsCount => $composableBuilder(
    column: $table.slotsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  Expression<T> printJobsRefs<T extends Object>(
    Expression<T> Function($$PrintJobsTableAnnotationComposer a) f,
  ) {
    final $$PrintJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.printJobs,
      getReferencedColumn: (t) => t.printerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrintJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.printJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PrintersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrintersTable,
          Printer,
          $$PrintersTableFilterComposer,
          $$PrintersTableOrderingComposer,
          $$PrintersTableAnnotationComposer,
          $$PrintersTableCreateCompanionBuilder,
          $$PrintersTableUpdateCompanionBuilder,
          (Printer, $$PrintersTableReferences),
          Printer,
          PrefetchHooks Function({bool printJobsRefs})
        > {
  $$PrintersTableTableManager(_$AppDatabase db, $PrintersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrintersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrintersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrintersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> ipAddress = const Value.absent(),
                Value<String> manufacturer = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<String?> apiKey = const Value.absent(),
                Value<String> activeSlotsJson = const Value.absent(),
                Value<int> slotsCount = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrintersCompanion(
                id: id,
                name: name,
                ipAddress: ipAddress,
                manufacturer: manufacturer,
                model: model,
                port: port,
                apiKey: apiKey,
                activeSlotsJson: activeSlotsJson,
                slotsCount: slotsCount,
                version: version,
                timestamp: timestamp,
                isDeleted: isDeleted,
                imageUrl: imageUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String ipAddress,
                required String manufacturer,
                required String model,
                Value<int> port = const Value.absent(),
                Value<String?> apiKey = const Value.absent(),
                required String activeSlotsJson,
                required int slotsCount,
                Value<int> version = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrintersCompanion.insert(
                id: id,
                name: name,
                ipAddress: ipAddress,
                manufacturer: manufacturer,
                model: model,
                port: port,
                apiKey: apiKey,
                activeSlotsJson: activeSlotsJson,
                slotsCount: slotsCount,
                version: version,
                timestamp: timestamp,
                isDeleted: isDeleted,
                imageUrl: imageUrl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PrintersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({printJobsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (printJobsRefs) db.printJobs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (printJobsRefs)
                    await $_getPrefetchedData<
                      Printer,
                      $PrintersTable,
                      PrintJob
                    >(
                      currentTable: table,
                      referencedTable: $$PrintersTableReferences
                          ._printJobsRefsTable(db),
                      managerFromTypedResult: (p0) => $$PrintersTableReferences(
                        db,
                        table,
                        p0,
                      ).printJobsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.printerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PrintersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrintersTable,
      Printer,
      $$PrintersTableFilterComposer,
      $$PrintersTableOrderingComposer,
      $$PrintersTableAnnotationComposer,
      $$PrintersTableCreateCompanionBuilder,
      $$PrintersTableUpdateCompanionBuilder,
      (Printer, $$PrintersTableReferences),
      Printer,
      PrefetchHooks Function({bool printJobsRefs})
    >;
typedef $$MaterialsTableCreateCompanionBuilder =
    MaterialsCompanion Function({
      required String id,
      required String manufacturer,
      required String type,
      required String color,
      Value<String> diameter,
      Value<String?> imageUrl,
      required double initialWeight,
      Value<double> usedWeight,
      Value<int> version,
      Value<DateTime> timestamp,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$MaterialsTableUpdateCompanionBuilder =
    MaterialsCompanion Function({
      Value<String> id,
      Value<String> manufacturer,
      Value<String> type,
      Value<String> color,
      Value<String> diameter,
      Value<String?> imageUrl,
      Value<double> initialWeight,
      Value<double> usedWeight,
      Value<int> version,
      Value<DateTime> timestamp,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$MaterialsTableFilterComposer
    extends Composer<_$AppDatabase, $MaterialsTable> {
  $$MaterialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diameter => $composableBuilder(
    column: $table.diameter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get initialWeight => $composableBuilder(
    column: $table.initialWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get usedWeight => $composableBuilder(
    column: $table.usedWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MaterialsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaterialsTable> {
  $$MaterialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diameter => $composableBuilder(
    column: $table.diameter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get initialWeight => $composableBuilder(
    column: $table.initialWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get usedWeight => $composableBuilder(
    column: $table.usedWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MaterialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaterialsTable> {
  $$MaterialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get diameter =>
      $composableBuilder(column: $table.diameter, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<double> get initialWeight => $composableBuilder(
    column: $table.initialWeight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get usedWeight => $composableBuilder(
    column: $table.usedWeight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$MaterialsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaterialsTable,
          Material,
          $$MaterialsTableFilterComposer,
          $$MaterialsTableOrderingComposer,
          $$MaterialsTableAnnotationComposer,
          $$MaterialsTableCreateCompanionBuilder,
          $$MaterialsTableUpdateCompanionBuilder,
          (Material, BaseReferences<_$AppDatabase, $MaterialsTable, Material>),
          Material,
          PrefetchHooks Function()
        > {
  $$MaterialsTableTableManager(_$AppDatabase db, $MaterialsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaterialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaterialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaterialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> manufacturer = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> diameter = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<double> initialWeight = const Value.absent(),
                Value<double> usedWeight = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaterialsCompanion(
                id: id,
                manufacturer: manufacturer,
                type: type,
                color: color,
                diameter: diameter,
                imageUrl: imageUrl,
                initialWeight: initialWeight,
                usedWeight: usedWeight,
                version: version,
                timestamp: timestamp,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String manufacturer,
                required String type,
                required String color,
                Value<String> diameter = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                required double initialWeight,
                Value<double> usedWeight = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaterialsCompanion.insert(
                id: id,
                manufacturer: manufacturer,
                type: type,
                color: color,
                diameter: diameter,
                imageUrl: imageUrl,
                initialWeight: initialWeight,
                usedWeight: usedWeight,
                version: version,
                timestamp: timestamp,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MaterialsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaterialsTable,
      Material,
      $$MaterialsTableFilterComposer,
      $$MaterialsTableOrderingComposer,
      $$MaterialsTableAnnotationComposer,
      $$MaterialsTableCreateCompanionBuilder,
      $$MaterialsTableUpdateCompanionBuilder,
      (Material, BaseReferences<_$AppDatabase, $MaterialsTable, Material>),
      Material,
      PrefetchHooks Function()
    >;
typedef $$PrintJobsTableCreateCompanionBuilder =
    PrintJobsCompanion Function({
      required String id,
      required String printerId,
      required String modelName,
      required String status,
      required double spentWeight,
      required String usedMaterialsLogJson,
      required DateTime startTime,
      required int duration,
      Value<int> version,
      Value<DateTime> timestamp,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$PrintJobsTableUpdateCompanionBuilder =
    PrintJobsCompanion Function({
      Value<String> id,
      Value<String> printerId,
      Value<String> modelName,
      Value<String> status,
      Value<double> spentWeight,
      Value<String> usedMaterialsLogJson,
      Value<DateTime> startTime,
      Value<int> duration,
      Value<int> version,
      Value<DateTime> timestamp,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

final class $$PrintJobsTableReferences
    extends BaseReferences<_$AppDatabase, $PrintJobsTable, PrintJob> {
  $$PrintJobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PrintersTable _printerIdTable(_$AppDatabase db) =>
      db.printers.createAlias(
        $_aliasNameGenerator(db.printJobs.printerId, db.printers.id),
      );

  $$PrintersTableProcessedTableManager get printerId {
    final $_column = $_itemColumn<String>('printer_id')!;

    final manager = $$PrintersTableTableManager(
      $_db,
      $_db.printers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_printerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PrintJobsTableFilterComposer
    extends Composer<_$AppDatabase, $PrintJobsTable> {
  $$PrintJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get spentWeight => $composableBuilder(
    column: $table.spentWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usedMaterialsLogJson => $composableBuilder(
    column: $table.usedMaterialsLogJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  $$PrintersTableFilterComposer get printerId {
    final $$PrintersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.printerId,
      referencedTable: $db.printers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrintersTableFilterComposer(
            $db: $db,
            $table: $db.printers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrintJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrintJobsTable> {
  $$PrintJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelName => $composableBuilder(
    column: $table.modelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get spentWeight => $composableBuilder(
    column: $table.spentWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usedMaterialsLogJson => $composableBuilder(
    column: $table.usedMaterialsLogJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$PrintersTableOrderingComposer get printerId {
    final $$PrintersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.printerId,
      referencedTable: $db.printers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrintersTableOrderingComposer(
            $db: $db,
            $table: $db.printers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrintJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrintJobsTable> {
  $$PrintJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get spentWeight => $composableBuilder(
    column: $table.spentWeight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get usedMaterialsLogJson => $composableBuilder(
    column: $table.usedMaterialsLogJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$PrintersTableAnnotationComposer get printerId {
    final $$PrintersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.printerId,
      referencedTable: $db.printers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrintersTableAnnotationComposer(
            $db: $db,
            $table: $db.printers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrintJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrintJobsTable,
          PrintJob,
          $$PrintJobsTableFilterComposer,
          $$PrintJobsTableOrderingComposer,
          $$PrintJobsTableAnnotationComposer,
          $$PrintJobsTableCreateCompanionBuilder,
          $$PrintJobsTableUpdateCompanionBuilder,
          (PrintJob, $$PrintJobsTableReferences),
          PrintJob,
          PrefetchHooks Function({bool printerId})
        > {
  $$PrintJobsTableTableManager(_$AppDatabase db, $PrintJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrintJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrintJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrintJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> printerId = const Value.absent(),
                Value<String> modelName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> spentWeight = const Value.absent(),
                Value<String> usedMaterialsLogJson = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrintJobsCompanion(
                id: id,
                printerId: printerId,
                modelName: modelName,
                status: status,
                spentWeight: spentWeight,
                usedMaterialsLogJson: usedMaterialsLogJson,
                startTime: startTime,
                duration: duration,
                version: version,
                timestamp: timestamp,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String printerId,
                required String modelName,
                required String status,
                required double spentWeight,
                required String usedMaterialsLogJson,
                required DateTime startTime,
                required int duration,
                Value<int> version = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrintJobsCompanion.insert(
                id: id,
                printerId: printerId,
                modelName: modelName,
                status: status,
                spentWeight: spentWeight,
                usedMaterialsLogJson: usedMaterialsLogJson,
                startTime: startTime,
                duration: duration,
                version: version,
                timestamp: timestamp,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PrintJobsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({printerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (printerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.printerId,
                                referencedTable: $$PrintJobsTableReferences
                                    ._printerIdTable(db),
                                referencedColumn: $$PrintJobsTableReferences
                                    ._printerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PrintJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrintJobsTable,
      PrintJob,
      $$PrintJobsTableFilterComposer,
      $$PrintJobsTableOrderingComposer,
      $$PrintJobsTableAnnotationComposer,
      $$PrintJobsTableCreateCompanionBuilder,
      $$PrintJobsTableUpdateCompanionBuilder,
      (PrintJob, $$PrintJobsTableReferences),
      PrintJob,
      PrefetchHooks Function({bool printerId})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String entityId,
      Value<double?> changeValue,
      required String type,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> entityId,
      Value<double?> changeValue,
      Value<String> type,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get changeValue => $composableBuilder(
    column: $table.changeValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get changeValue => $composableBuilder(
    column: $table.changeValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<double> get changeValue => $composableBuilder(
    column: $table.changeValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<double?> changeValue = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                entityId: entityId,
                changeValue: changeValue,
                type: type,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityId,
                Value<double?> changeValue = const Value.absent(),
                required String type,
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                entityId: entityId,
                changeValue: changeValue,
                type: type,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        Transaction,
        BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
      ),
      Transaction,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PrintersTableTableManager get printers =>
      $$PrintersTableTableManager(_db, _db.printers);
  $$MaterialsTableTableManager get materials =>
      $$MaterialsTableTableManager(_db, _db.materials);
  $$PrintJobsTableTableManager get printJobs =>
      $$PrintJobsTableTableManager(_db, _db.printJobs);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
}
