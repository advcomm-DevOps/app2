// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChannelsTable extends Channels with TableInfo<$ChannelsTable, Channel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChannelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mtdsClientTsMeta = const VerificationMeta(
    'mtdsClientTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsClientTs = GeneratedColumn<BigInt>(
    'mtds_client_ts',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
    defaultValue: Constant(BigInt.from(0)),
  );
  static const VerificationMeta _mtdsServerTsMeta = const VerificationMeta(
    'mtdsServerTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsServerTs = GeneratedColumn<BigInt>(
    'mtds_server_ts',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mtdsDeviceIdMeta = const VerificationMeta(
    'mtdsDeviceId',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsDeviceId = GeneratedColumn<BigInt>(
    'mtds_device_id',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
    defaultValue: Constant(BigInt.from(0)),
  );
  static const VerificationMeta _mtdsDeleteTsMeta = const VerificationMeta(
    'mtdsDeleteTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsDeleteTs = GeneratedColumn<BigInt>(
    'mtds_delete_ts',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<int> channelId = GeneratedColumn<int>(
    'channel_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _channelNameMeta = const VerificationMeta(
    'channelName',
  );
  @override
  late final GeneratedColumn<String> channelName = GeneratedColumn<String>(
    'channel_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 63,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelDescriptionMeta =
      const VerificationMeta('channelDescription');
  @override
  late final GeneratedColumn<String> channelDescription =
      GeneratedColumn<String>(
        'channel_description',
        aliasedName,
        false,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 63,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _entityRolesMeta = const VerificationMeta(
    'entityRoles',
  );
  @override
  late final GeneratedColumn<String> entityRoles = GeneratedColumn<String>(
    'entity_roles',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 63,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('all'),
  );
  static const VerificationMeta _actorSequenceMeta = const VerificationMeta(
    'actorSequence',
  );
  @override
  late final GeneratedColumn<BigInt> actorSequence = GeneratedColumn<BigInt>(
    'actor_sequence',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialActorIdMeta = const VerificationMeta(
    'initialActorId',
  );
  @override
  late final GeneratedColumn<BigInt> initialActorId = GeneratedColumn<BigInt>(
    'initial_actor_id',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _otherActorIdMeta = const VerificationMeta(
    'otherActorId',
  );
  @override
  late final GeneratedColumn<BigInt> otherActorId = GeneratedColumn<BigInt>(
    'other_actor_id',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contextTemplateMeta = const VerificationMeta(
    'contextTemplate',
  );
  @override
  late final GeneratedColumn<String> contextTemplate = GeneratedColumn<String>(
    'context_template',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isTagRequiredMeta = const VerificationMeta(
    'isTagRequired',
  );
  @override
  late final GeneratedColumn<bool> isTagRequired = GeneratedColumn<bool>(
    'is_tag_required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_tag_required" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    mtdsClientTs,
    mtdsServerTs,
    mtdsDeviceId,
    mtdsDeleteTs,
    channelId,
    channelName,
    channelDescription,
    entityRoles,
    actorSequence,
    initialActorId,
    otherActorId,
    contextTemplate,
    isTagRequired,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'channels';
  @override
  VerificationContext validateIntegrity(
    Insertable<Channel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mtds_client_ts')) {
      context.handle(
        _mtdsClientTsMeta,
        mtdsClientTs.isAcceptableOrUnknown(
          data['mtds_client_ts']!,
          _mtdsClientTsMeta,
        ),
      );
    }
    if (data.containsKey('mtds_server_ts')) {
      context.handle(
        _mtdsServerTsMeta,
        mtdsServerTs.isAcceptableOrUnknown(
          data['mtds_server_ts']!,
          _mtdsServerTsMeta,
        ),
      );
    }
    if (data.containsKey('mtds_device_id')) {
      context.handle(
        _mtdsDeviceIdMeta,
        mtdsDeviceId.isAcceptableOrUnknown(
          data['mtds_device_id']!,
          _mtdsDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('mtds_delete_ts')) {
      context.handle(
        _mtdsDeleteTsMeta,
        mtdsDeleteTs.isAcceptableOrUnknown(
          data['mtds_delete_ts']!,
          _mtdsDeleteTsMeta,
        ),
      );
    }
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    }
    if (data.containsKey('channel_name')) {
      context.handle(
        _channelNameMeta,
        channelName.isAcceptableOrUnknown(
          data['channel_name']!,
          _channelNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_channelNameMeta);
    }
    if (data.containsKey('channel_description')) {
      context.handle(
        _channelDescriptionMeta,
        channelDescription.isAcceptableOrUnknown(
          data['channel_description']!,
          _channelDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_channelDescriptionMeta);
    }
    if (data.containsKey('entity_roles')) {
      context.handle(
        _entityRolesMeta,
        entityRoles.isAcceptableOrUnknown(
          data['entity_roles']!,
          _entityRolesMeta,
        ),
      );
    }
    if (data.containsKey('actor_sequence')) {
      context.handle(
        _actorSequenceMeta,
        actorSequence.isAcceptableOrUnknown(
          data['actor_sequence']!,
          _actorSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actorSequenceMeta);
    }
    if (data.containsKey('initial_actor_id')) {
      context.handle(
        _initialActorIdMeta,
        initialActorId.isAcceptableOrUnknown(
          data['initial_actor_id']!,
          _initialActorIdMeta,
        ),
      );
    }
    if (data.containsKey('other_actor_id')) {
      context.handle(
        _otherActorIdMeta,
        otherActorId.isAcceptableOrUnknown(
          data['other_actor_id']!,
          _otherActorIdMeta,
        ),
      );
    }
    if (data.containsKey('context_template')) {
      context.handle(
        _contextTemplateMeta,
        contextTemplate.isAcceptableOrUnknown(
          data['context_template']!,
          _contextTemplateMeta,
        ),
      );
    }
    if (data.containsKey('is_tag_required')) {
      context.handle(
        _isTagRequiredMeta,
        isTagRequired.isAcceptableOrUnknown(
          data['is_tag_required']!,
          _isTagRequiredMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {channelId};
  @override
  Channel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Channel(
      mtdsClientTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_client_ts'],
      )!,
      mtdsServerTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_server_ts'],
      ),
      mtdsDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_device_id'],
      )!,
      mtdsDeleteTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_delete_ts'],
      ),
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}channel_id'],
      )!,
      channelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_name'],
      )!,
      channelDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_description'],
      )!,
      entityRoles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_roles'],
      )!,
      actorSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}actor_sequence'],
      )!,
      initialActorId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}initial_actor_id'],
      ),
      otherActorId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}other_actor_id'],
      ),
      contextTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_template'],
      ),
      isTagRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_tag_required'],
      )!,
    );
  }

  @override
  $ChannelsTable createAlias(String alias) {
    return $ChannelsTable(attachedDatabase, alias);
  }
}

class Channel extends DataClass implements Insertable<Channel> {
  /// Client-generated timestamp in milliseconds since client epoch.
  /// Always present with a default of 0 so change detection never hits NULL.
  final BigInt mtdsClientTs;

  /// Server-assigned authoritative timestamp in nanoseconds since epoch (NodeJS HR based).
  /// NULL until the record is synced to server.
  final BigInt? mtdsServerTs;

  /// 64-bit device identifier used for replication guardrails.
  /// Always present with a default of 0; SDK overwrites it on each write.
  final BigInt mtdsDeviceId;

  /// Soft-delete marker (NULL = active, non-null = deleted at timestamp in milliseconds since client epoch)
  final BigInt? mtdsDeleteTs;
  final int channelId;
  final String channelName;
  final String channelDescription;
  final String entityRoles;
  final BigInt actorSequence;
  final BigInt? initialActorId;
  final BigInt? otherActorId;
  final String? contextTemplate;
  final bool isTagRequired;
  const Channel({
    required this.mtdsClientTs,
    this.mtdsServerTs,
    required this.mtdsDeviceId,
    this.mtdsDeleteTs,
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    required this.entityRoles,
    required this.actorSequence,
    this.initialActorId,
    this.otherActorId,
    this.contextTemplate,
    required this.isTagRequired,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['mtds_client_ts'] = Variable<BigInt>(mtdsClientTs);
    if (!nullToAbsent || mtdsServerTs != null) {
      map['mtds_server_ts'] = Variable<BigInt>(mtdsServerTs);
    }
    map['mtds_device_id'] = Variable<BigInt>(mtdsDeviceId);
    if (!nullToAbsent || mtdsDeleteTs != null) {
      map['mtds_delete_ts'] = Variable<BigInt>(mtdsDeleteTs);
    }
    map['channel_id'] = Variable<int>(channelId);
    map['channel_name'] = Variable<String>(channelName);
    map['channel_description'] = Variable<String>(channelDescription);
    map['entity_roles'] = Variable<String>(entityRoles);
    map['actor_sequence'] = Variable<BigInt>(actorSequence);
    if (!nullToAbsent || initialActorId != null) {
      map['initial_actor_id'] = Variable<BigInt>(initialActorId);
    }
    if (!nullToAbsent || otherActorId != null) {
      map['other_actor_id'] = Variable<BigInt>(otherActorId);
    }
    if (!nullToAbsent || contextTemplate != null) {
      map['context_template'] = Variable<String>(contextTemplate);
    }
    map['is_tag_required'] = Variable<bool>(isTagRequired);
    return map;
  }

  ChannelsCompanion toCompanion(bool nullToAbsent) {
    return ChannelsCompanion(
      mtdsClientTs: Value(mtdsClientTs),
      mtdsServerTs: mtdsServerTs == null && nullToAbsent
          ? const Value.absent()
          : Value(mtdsServerTs),
      mtdsDeviceId: Value(mtdsDeviceId),
      mtdsDeleteTs: mtdsDeleteTs == null && nullToAbsent
          ? const Value.absent()
          : Value(mtdsDeleteTs),
      channelId: Value(channelId),
      channelName: Value(channelName),
      channelDescription: Value(channelDescription),
      entityRoles: Value(entityRoles),
      actorSequence: Value(actorSequence),
      initialActorId: initialActorId == null && nullToAbsent
          ? const Value.absent()
          : Value(initialActorId),
      otherActorId: otherActorId == null && nullToAbsent
          ? const Value.absent()
          : Value(otherActorId),
      contextTemplate: contextTemplate == null && nullToAbsent
          ? const Value.absent()
          : Value(contextTemplate),
      isTagRequired: Value(isTagRequired),
    );
  }

  factory Channel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Channel(
      mtdsClientTs: serializer.fromJson<BigInt>(json['mtdsClientTs']),
      mtdsServerTs: serializer.fromJson<BigInt?>(json['mtdsServerTs']),
      mtdsDeviceId: serializer.fromJson<BigInt>(json['mtdsDeviceId']),
      mtdsDeleteTs: serializer.fromJson<BigInt?>(json['mtdsDeleteTs']),
      channelId: serializer.fromJson<int>(json['channelId']),
      channelName: serializer.fromJson<String>(json['channelName']),
      channelDescription: serializer.fromJson<String>(
        json['channelDescription'],
      ),
      entityRoles: serializer.fromJson<String>(json['entityRoles']),
      actorSequence: serializer.fromJson<BigInt>(json['actorSequence']),
      initialActorId: serializer.fromJson<BigInt?>(json['initialActorId']),
      otherActorId: serializer.fromJson<BigInt?>(json['otherActorId']),
      contextTemplate: serializer.fromJson<String?>(json['contextTemplate']),
      isTagRequired: serializer.fromJson<bool>(json['isTagRequired']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mtdsClientTs': serializer.toJson<BigInt>(mtdsClientTs),
      'mtdsServerTs': serializer.toJson<BigInt?>(mtdsServerTs),
      'mtdsDeviceId': serializer.toJson<BigInt>(mtdsDeviceId),
      'mtdsDeleteTs': serializer.toJson<BigInt?>(mtdsDeleteTs),
      'channelId': serializer.toJson<int>(channelId),
      'channelName': serializer.toJson<String>(channelName),
      'channelDescription': serializer.toJson<String>(channelDescription),
      'entityRoles': serializer.toJson<String>(entityRoles),
      'actorSequence': serializer.toJson<BigInt>(actorSequence),
      'initialActorId': serializer.toJson<BigInt?>(initialActorId),
      'otherActorId': serializer.toJson<BigInt?>(otherActorId),
      'contextTemplate': serializer.toJson<String?>(contextTemplate),
      'isTagRequired': serializer.toJson<bool>(isTagRequired),
    };
  }

  Channel copyWith({
    BigInt? mtdsClientTs,
    Value<BigInt?> mtdsServerTs = const Value.absent(),
    BigInt? mtdsDeviceId,
    Value<BigInt?> mtdsDeleteTs = const Value.absent(),
    int? channelId,
    String? channelName,
    String? channelDescription,
    String? entityRoles,
    BigInt? actorSequence,
    Value<BigInt?> initialActorId = const Value.absent(),
    Value<BigInt?> otherActorId = const Value.absent(),
    Value<String?> contextTemplate = const Value.absent(),
    bool? isTagRequired,
  }) => Channel(
    mtdsClientTs: mtdsClientTs ?? this.mtdsClientTs,
    mtdsServerTs: mtdsServerTs.present ? mtdsServerTs.value : this.mtdsServerTs,
    mtdsDeviceId: mtdsDeviceId ?? this.mtdsDeviceId,
    mtdsDeleteTs: mtdsDeleteTs.present ? mtdsDeleteTs.value : this.mtdsDeleteTs,
    channelId: channelId ?? this.channelId,
    channelName: channelName ?? this.channelName,
    channelDescription: channelDescription ?? this.channelDescription,
    entityRoles: entityRoles ?? this.entityRoles,
    actorSequence: actorSequence ?? this.actorSequence,
    initialActorId: initialActorId.present
        ? initialActorId.value
        : this.initialActorId,
    otherActorId: otherActorId.present ? otherActorId.value : this.otherActorId,
    contextTemplate: contextTemplate.present
        ? contextTemplate.value
        : this.contextTemplate,
    isTagRequired: isTagRequired ?? this.isTagRequired,
  );
  Channel copyWithCompanion(ChannelsCompanion data) {
    return Channel(
      mtdsClientTs: data.mtdsClientTs.present
          ? data.mtdsClientTs.value
          : this.mtdsClientTs,
      mtdsServerTs: data.mtdsServerTs.present
          ? data.mtdsServerTs.value
          : this.mtdsServerTs,
      mtdsDeviceId: data.mtdsDeviceId.present
          ? data.mtdsDeviceId.value
          : this.mtdsDeviceId,
      mtdsDeleteTs: data.mtdsDeleteTs.present
          ? data.mtdsDeleteTs.value
          : this.mtdsDeleteTs,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      channelName: data.channelName.present
          ? data.channelName.value
          : this.channelName,
      channelDescription: data.channelDescription.present
          ? data.channelDescription.value
          : this.channelDescription,
      entityRoles: data.entityRoles.present
          ? data.entityRoles.value
          : this.entityRoles,
      actorSequence: data.actorSequence.present
          ? data.actorSequence.value
          : this.actorSequence,
      initialActorId: data.initialActorId.present
          ? data.initialActorId.value
          : this.initialActorId,
      otherActorId: data.otherActorId.present
          ? data.otherActorId.value
          : this.otherActorId,
      contextTemplate: data.contextTemplate.present
          ? data.contextTemplate.value
          : this.contextTemplate,
      isTagRequired: data.isTagRequired.present
          ? data.isTagRequired.value
          : this.isTagRequired,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Channel(')
          ..write('mtdsClientTs: $mtdsClientTs, ')
          ..write('mtdsServerTs: $mtdsServerTs, ')
          ..write('mtdsDeviceId: $mtdsDeviceId, ')
          ..write('mtdsDeleteTs: $mtdsDeleteTs, ')
          ..write('channelId: $channelId, ')
          ..write('channelName: $channelName, ')
          ..write('channelDescription: $channelDescription, ')
          ..write('entityRoles: $entityRoles, ')
          ..write('actorSequence: $actorSequence, ')
          ..write('initialActorId: $initialActorId, ')
          ..write('otherActorId: $otherActorId, ')
          ..write('contextTemplate: $contextTemplate, ')
          ..write('isTagRequired: $isTagRequired')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mtdsClientTs,
    mtdsServerTs,
    mtdsDeviceId,
    mtdsDeleteTs,
    channelId,
    channelName,
    channelDescription,
    entityRoles,
    actorSequence,
    initialActorId,
    otherActorId,
    contextTemplate,
    isTagRequired,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Channel &&
          other.mtdsClientTs == this.mtdsClientTs &&
          other.mtdsServerTs == this.mtdsServerTs &&
          other.mtdsDeviceId == this.mtdsDeviceId &&
          other.mtdsDeleteTs == this.mtdsDeleteTs &&
          other.channelId == this.channelId &&
          other.channelName == this.channelName &&
          other.channelDescription == this.channelDescription &&
          other.entityRoles == this.entityRoles &&
          other.actorSequence == this.actorSequence &&
          other.initialActorId == this.initialActorId &&
          other.otherActorId == this.otherActorId &&
          other.contextTemplate == this.contextTemplate &&
          other.isTagRequired == this.isTagRequired);
}

class ChannelsCompanion extends UpdateCompanion<Channel> {
  final Value<BigInt> mtdsClientTs;
  final Value<BigInt?> mtdsServerTs;
  final Value<BigInt> mtdsDeviceId;
  final Value<BigInt?> mtdsDeleteTs;
  final Value<int> channelId;
  final Value<String> channelName;
  final Value<String> channelDescription;
  final Value<String> entityRoles;
  final Value<BigInt> actorSequence;
  final Value<BigInt?> initialActorId;
  final Value<BigInt?> otherActorId;
  final Value<String?> contextTemplate;
  final Value<bool> isTagRequired;
  const ChannelsCompanion({
    this.mtdsClientTs = const Value.absent(),
    this.mtdsServerTs = const Value.absent(),
    this.mtdsDeviceId = const Value.absent(),
    this.mtdsDeleteTs = const Value.absent(),
    this.channelId = const Value.absent(),
    this.channelName = const Value.absent(),
    this.channelDescription = const Value.absent(),
    this.entityRoles = const Value.absent(),
    this.actorSequence = const Value.absent(),
    this.initialActorId = const Value.absent(),
    this.otherActorId = const Value.absent(),
    this.contextTemplate = const Value.absent(),
    this.isTagRequired = const Value.absent(),
  });
  ChannelsCompanion.insert({
    this.mtdsClientTs = const Value.absent(),
    this.mtdsServerTs = const Value.absent(),
    this.mtdsDeviceId = const Value.absent(),
    this.mtdsDeleteTs = const Value.absent(),
    this.channelId = const Value.absent(),
    required String channelName,
    required String channelDescription,
    this.entityRoles = const Value.absent(),
    required BigInt actorSequence,
    this.initialActorId = const Value.absent(),
    this.otherActorId = const Value.absent(),
    this.contextTemplate = const Value.absent(),
    this.isTagRequired = const Value.absent(),
  }) : channelName = Value(channelName),
       channelDescription = Value(channelDescription),
       actorSequence = Value(actorSequence);
  static Insertable<Channel> custom({
    Expression<BigInt>? mtdsClientTs,
    Expression<BigInt>? mtdsServerTs,
    Expression<BigInt>? mtdsDeviceId,
    Expression<BigInt>? mtdsDeleteTs,
    Expression<int>? channelId,
    Expression<String>? channelName,
    Expression<String>? channelDescription,
    Expression<String>? entityRoles,
    Expression<BigInt>? actorSequence,
    Expression<BigInt>? initialActorId,
    Expression<BigInt>? otherActorId,
    Expression<String>? contextTemplate,
    Expression<bool>? isTagRequired,
  }) {
    return RawValuesInsertable({
      if (mtdsClientTs != null) 'mtds_client_ts': mtdsClientTs,
      if (mtdsServerTs != null) 'mtds_server_ts': mtdsServerTs,
      if (mtdsDeviceId != null) 'mtds_device_id': mtdsDeviceId,
      if (mtdsDeleteTs != null) 'mtds_delete_ts': mtdsDeleteTs,
      if (channelId != null) 'channel_id': channelId,
      if (channelName != null) 'channel_name': channelName,
      if (channelDescription != null) 'channel_description': channelDescription,
      if (entityRoles != null) 'entity_roles': entityRoles,
      if (actorSequence != null) 'actor_sequence': actorSequence,
      if (initialActorId != null) 'initial_actor_id': initialActorId,
      if (otherActorId != null) 'other_actor_id': otherActorId,
      if (contextTemplate != null) 'context_template': contextTemplate,
      if (isTagRequired != null) 'is_tag_required': isTagRequired,
    });
  }

  ChannelsCompanion copyWith({
    Value<BigInt>? mtdsClientTs,
    Value<BigInt?>? mtdsServerTs,
    Value<BigInt>? mtdsDeviceId,
    Value<BigInt?>? mtdsDeleteTs,
    Value<int>? channelId,
    Value<String>? channelName,
    Value<String>? channelDescription,
    Value<String>? entityRoles,
    Value<BigInt>? actorSequence,
    Value<BigInt?>? initialActorId,
    Value<BigInt?>? otherActorId,
    Value<String?>? contextTemplate,
    Value<bool>? isTagRequired,
  }) {
    return ChannelsCompanion(
      mtdsClientTs: mtdsClientTs ?? this.mtdsClientTs,
      mtdsServerTs: mtdsServerTs ?? this.mtdsServerTs,
      mtdsDeviceId: mtdsDeviceId ?? this.mtdsDeviceId,
      mtdsDeleteTs: mtdsDeleteTs ?? this.mtdsDeleteTs,
      channelId: channelId ?? this.channelId,
      channelName: channelName ?? this.channelName,
      channelDescription: channelDescription ?? this.channelDescription,
      entityRoles: entityRoles ?? this.entityRoles,
      actorSequence: actorSequence ?? this.actorSequence,
      initialActorId: initialActorId ?? this.initialActorId,
      otherActorId: otherActorId ?? this.otherActorId,
      contextTemplate: contextTemplate ?? this.contextTemplate,
      isTagRequired: isTagRequired ?? this.isTagRequired,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mtdsClientTs.present) {
      map['mtds_client_ts'] = Variable<BigInt>(mtdsClientTs.value);
    }
    if (mtdsServerTs.present) {
      map['mtds_server_ts'] = Variable<BigInt>(mtdsServerTs.value);
    }
    if (mtdsDeviceId.present) {
      map['mtds_device_id'] = Variable<BigInt>(mtdsDeviceId.value);
    }
    if (mtdsDeleteTs.present) {
      map['mtds_delete_ts'] = Variable<BigInt>(mtdsDeleteTs.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<int>(channelId.value);
    }
    if (channelName.present) {
      map['channel_name'] = Variable<String>(channelName.value);
    }
    if (channelDescription.present) {
      map['channel_description'] = Variable<String>(channelDescription.value);
    }
    if (entityRoles.present) {
      map['entity_roles'] = Variable<String>(entityRoles.value);
    }
    if (actorSequence.present) {
      map['actor_sequence'] = Variable<BigInt>(actorSequence.value);
    }
    if (initialActorId.present) {
      map['initial_actor_id'] = Variable<BigInt>(initialActorId.value);
    }
    if (otherActorId.present) {
      map['other_actor_id'] = Variable<BigInt>(otherActorId.value);
    }
    if (contextTemplate.present) {
      map['context_template'] = Variable<String>(contextTemplate.value);
    }
    if (isTagRequired.present) {
      map['is_tag_required'] = Variable<bool>(isTagRequired.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChannelsCompanion(')
          ..write('mtdsClientTs: $mtdsClientTs, ')
          ..write('mtdsServerTs: $mtdsServerTs, ')
          ..write('mtdsDeviceId: $mtdsDeviceId, ')
          ..write('mtdsDeleteTs: $mtdsDeleteTs, ')
          ..write('channelId: $channelId, ')
          ..write('channelName: $channelName, ')
          ..write('channelDescription: $channelDescription, ')
          ..write('entityRoles: $entityRoles, ')
          ..write('actorSequence: $actorSequence, ')
          ..write('initialActorId: $initialActorId, ')
          ..write('otherActorId: $otherActorId, ')
          ..write('contextTemplate: $contextTemplate, ')
          ..write('isTagRequired: $isTagRequired')
          ..write(')'))
        .toString();
  }
}

class $ChannelTagsTable extends ChannelTags
    with TableInfo<$ChannelTagsTable, ChannelTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChannelTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mtdsClientTsMeta = const VerificationMeta(
    'mtdsClientTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsClientTs = GeneratedColumn<BigInt>(
    'mtds_client_ts',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
    defaultValue: Constant(BigInt.from(0)),
  );
  static const VerificationMeta _mtdsServerTsMeta = const VerificationMeta(
    'mtdsServerTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsServerTs = GeneratedColumn<BigInt>(
    'mtds_server_ts',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mtdsDeviceIdMeta = const VerificationMeta(
    'mtdsDeviceId',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsDeviceId = GeneratedColumn<BigInt>(
    'mtds_device_id',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
    defaultValue: Constant(BigInt.from(0)),
  );
  static const VerificationMeta _mtdsDeleteTsMeta = const VerificationMeta(
    'mtdsDeleteTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsDeleteTs = GeneratedColumn<BigInt>(
    'mtds_delete_ts',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _channelTagIdMeta = const VerificationMeta(
    'channelTagId',
  );
  @override
  late final GeneratedColumn<BigInt> channelTagId = GeneratedColumn<BigInt>(
    'channel_tag_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<BigInt> channelId = GeneratedColumn<BigInt>(
    'channel_id',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 63,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagDescriptionMeta = const VerificationMeta(
    'tagDescription',
  );
  @override
  late final GeneratedColumn<String> tagDescription = GeneratedColumn<String>(
    'tag_description',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 255),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expireAtMeta = const VerificationMeta(
    'expireAt',
  );
  @override
  late final GeneratedColumn<DateTime> expireAt = GeneratedColumn<DateTime>(
    'expire_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    mtdsClientTs,
    mtdsServerTs,
    mtdsDeviceId,
    mtdsDeleteTs,
    channelTagId,
    channelId,
    tag,
    tagDescription,
    expireAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'channel_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChannelTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mtds_client_ts')) {
      context.handle(
        _mtdsClientTsMeta,
        mtdsClientTs.isAcceptableOrUnknown(
          data['mtds_client_ts']!,
          _mtdsClientTsMeta,
        ),
      );
    }
    if (data.containsKey('mtds_server_ts')) {
      context.handle(
        _mtdsServerTsMeta,
        mtdsServerTs.isAcceptableOrUnknown(
          data['mtds_server_ts']!,
          _mtdsServerTsMeta,
        ),
      );
    }
    if (data.containsKey('mtds_device_id')) {
      context.handle(
        _mtdsDeviceIdMeta,
        mtdsDeviceId.isAcceptableOrUnknown(
          data['mtds_device_id']!,
          _mtdsDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('mtds_delete_ts')) {
      context.handle(
        _mtdsDeleteTsMeta,
        mtdsDeleteTs.isAcceptableOrUnknown(
          data['mtds_delete_ts']!,
          _mtdsDeleteTsMeta,
        ),
      );
    }
    if (data.containsKey('channel_tag_id')) {
      context.handle(
        _channelTagIdMeta,
        channelTagId.isAcceptableOrUnknown(
          data['channel_tag_id']!,
          _channelTagIdMeta,
        ),
      );
    }
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('tag_description')) {
      context.handle(
        _tagDescriptionMeta,
        tagDescription.isAcceptableOrUnknown(
          data['tag_description']!,
          _tagDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('expire_at')) {
      context.handle(
        _expireAtMeta,
        expireAt.isAcceptableOrUnknown(data['expire_at']!, _expireAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {channelTagId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {channelId, tag},
  ];
  @override
  ChannelTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChannelTag(
      mtdsClientTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_client_ts'],
      )!,
      mtdsServerTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_server_ts'],
      ),
      mtdsDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_device_id'],
      )!,
      mtdsDeleteTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_delete_ts'],
      ),
      channelTagId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}channel_tag_id'],
      )!,
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}channel_id'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
      tagDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_description'],
      ),
      expireAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expire_at'],
      ),
    );
  }

  @override
  $ChannelTagsTable createAlias(String alias) {
    return $ChannelTagsTable(attachedDatabase, alias);
  }
}

class ChannelTag extends DataClass implements Insertable<ChannelTag> {
  /// Client-generated timestamp in milliseconds since client epoch.
  /// Always present with a default of 0 so change detection never hits NULL.
  final BigInt mtdsClientTs;

  /// Server-assigned authoritative timestamp in nanoseconds since epoch (NodeJS HR based).
  /// NULL until the record is synced to server.
  final BigInt? mtdsServerTs;

  /// 64-bit device identifier used for replication guardrails.
  /// Always present with a default of 0; SDK overwrites it on each write.
  final BigInt mtdsDeviceId;

  /// Soft-delete marker (NULL = active, non-null = deleted at timestamp in milliseconds since client epoch)
  final BigInt? mtdsDeleteTs;
  final BigInt channelTagId;
  final BigInt channelId;
  final String tag;
  final String? tagDescription;
  final DateTime? expireAt;
  const ChannelTag({
    required this.mtdsClientTs,
    this.mtdsServerTs,
    required this.mtdsDeviceId,
    this.mtdsDeleteTs,
    required this.channelTagId,
    required this.channelId,
    required this.tag,
    this.tagDescription,
    this.expireAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['mtds_client_ts'] = Variable<BigInt>(mtdsClientTs);
    if (!nullToAbsent || mtdsServerTs != null) {
      map['mtds_server_ts'] = Variable<BigInt>(mtdsServerTs);
    }
    map['mtds_device_id'] = Variable<BigInt>(mtdsDeviceId);
    if (!nullToAbsent || mtdsDeleteTs != null) {
      map['mtds_delete_ts'] = Variable<BigInt>(mtdsDeleteTs);
    }
    map['channel_tag_id'] = Variable<BigInt>(channelTagId);
    map['channel_id'] = Variable<BigInt>(channelId);
    map['tag'] = Variable<String>(tag);
    if (!nullToAbsent || tagDescription != null) {
      map['tag_description'] = Variable<String>(tagDescription);
    }
    if (!nullToAbsent || expireAt != null) {
      map['expire_at'] = Variable<DateTime>(expireAt);
    }
    return map;
  }

  ChannelTagsCompanion toCompanion(bool nullToAbsent) {
    return ChannelTagsCompanion(
      mtdsClientTs: Value(mtdsClientTs),
      mtdsServerTs: mtdsServerTs == null && nullToAbsent
          ? const Value.absent()
          : Value(mtdsServerTs),
      mtdsDeviceId: Value(mtdsDeviceId),
      mtdsDeleteTs: mtdsDeleteTs == null && nullToAbsent
          ? const Value.absent()
          : Value(mtdsDeleteTs),
      channelTagId: Value(channelTagId),
      channelId: Value(channelId),
      tag: Value(tag),
      tagDescription: tagDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(tagDescription),
      expireAt: expireAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expireAt),
    );
  }

  factory ChannelTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChannelTag(
      mtdsClientTs: serializer.fromJson<BigInt>(json['mtdsClientTs']),
      mtdsServerTs: serializer.fromJson<BigInt?>(json['mtdsServerTs']),
      mtdsDeviceId: serializer.fromJson<BigInt>(json['mtdsDeviceId']),
      mtdsDeleteTs: serializer.fromJson<BigInt?>(json['mtdsDeleteTs']),
      channelTagId: serializer.fromJson<BigInt>(json['channelTagId']),
      channelId: serializer.fromJson<BigInt>(json['channelId']),
      tag: serializer.fromJson<String>(json['tag']),
      tagDescription: serializer.fromJson<String?>(json['tagDescription']),
      expireAt: serializer.fromJson<DateTime?>(json['expireAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mtdsClientTs': serializer.toJson<BigInt>(mtdsClientTs),
      'mtdsServerTs': serializer.toJson<BigInt?>(mtdsServerTs),
      'mtdsDeviceId': serializer.toJson<BigInt>(mtdsDeviceId),
      'mtdsDeleteTs': serializer.toJson<BigInt?>(mtdsDeleteTs),
      'channelTagId': serializer.toJson<BigInt>(channelTagId),
      'channelId': serializer.toJson<BigInt>(channelId),
      'tag': serializer.toJson<String>(tag),
      'tagDescription': serializer.toJson<String?>(tagDescription),
      'expireAt': serializer.toJson<DateTime?>(expireAt),
    };
  }

  ChannelTag copyWith({
    BigInt? mtdsClientTs,
    Value<BigInt?> mtdsServerTs = const Value.absent(),
    BigInt? mtdsDeviceId,
    Value<BigInt?> mtdsDeleteTs = const Value.absent(),
    BigInt? channelTagId,
    BigInt? channelId,
    String? tag,
    Value<String?> tagDescription = const Value.absent(),
    Value<DateTime?> expireAt = const Value.absent(),
  }) => ChannelTag(
    mtdsClientTs: mtdsClientTs ?? this.mtdsClientTs,
    mtdsServerTs: mtdsServerTs.present ? mtdsServerTs.value : this.mtdsServerTs,
    mtdsDeviceId: mtdsDeviceId ?? this.mtdsDeviceId,
    mtdsDeleteTs: mtdsDeleteTs.present ? mtdsDeleteTs.value : this.mtdsDeleteTs,
    channelTagId: channelTagId ?? this.channelTagId,
    channelId: channelId ?? this.channelId,
    tag: tag ?? this.tag,
    tagDescription: tagDescription.present
        ? tagDescription.value
        : this.tagDescription,
    expireAt: expireAt.present ? expireAt.value : this.expireAt,
  );
  ChannelTag copyWithCompanion(ChannelTagsCompanion data) {
    return ChannelTag(
      mtdsClientTs: data.mtdsClientTs.present
          ? data.mtdsClientTs.value
          : this.mtdsClientTs,
      mtdsServerTs: data.mtdsServerTs.present
          ? data.mtdsServerTs.value
          : this.mtdsServerTs,
      mtdsDeviceId: data.mtdsDeviceId.present
          ? data.mtdsDeviceId.value
          : this.mtdsDeviceId,
      mtdsDeleteTs: data.mtdsDeleteTs.present
          ? data.mtdsDeleteTs.value
          : this.mtdsDeleteTs,
      channelTagId: data.channelTagId.present
          ? data.channelTagId.value
          : this.channelTagId,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      tag: data.tag.present ? data.tag.value : this.tag,
      tagDescription: data.tagDescription.present
          ? data.tagDescription.value
          : this.tagDescription,
      expireAt: data.expireAt.present ? data.expireAt.value : this.expireAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChannelTag(')
          ..write('mtdsClientTs: $mtdsClientTs, ')
          ..write('mtdsServerTs: $mtdsServerTs, ')
          ..write('mtdsDeviceId: $mtdsDeviceId, ')
          ..write('mtdsDeleteTs: $mtdsDeleteTs, ')
          ..write('channelTagId: $channelTagId, ')
          ..write('channelId: $channelId, ')
          ..write('tag: $tag, ')
          ..write('tagDescription: $tagDescription, ')
          ..write('expireAt: $expireAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mtdsClientTs,
    mtdsServerTs,
    mtdsDeviceId,
    mtdsDeleteTs,
    channelTagId,
    channelId,
    tag,
    tagDescription,
    expireAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChannelTag &&
          other.mtdsClientTs == this.mtdsClientTs &&
          other.mtdsServerTs == this.mtdsServerTs &&
          other.mtdsDeviceId == this.mtdsDeviceId &&
          other.mtdsDeleteTs == this.mtdsDeleteTs &&
          other.channelTagId == this.channelTagId &&
          other.channelId == this.channelId &&
          other.tag == this.tag &&
          other.tagDescription == this.tagDescription &&
          other.expireAt == this.expireAt);
}

class ChannelTagsCompanion extends UpdateCompanion<ChannelTag> {
  final Value<BigInt> mtdsClientTs;
  final Value<BigInt?> mtdsServerTs;
  final Value<BigInt> mtdsDeviceId;
  final Value<BigInt?> mtdsDeleteTs;
  final Value<BigInt> channelTagId;
  final Value<BigInt> channelId;
  final Value<String> tag;
  final Value<String?> tagDescription;
  final Value<DateTime?> expireAt;
  const ChannelTagsCompanion({
    this.mtdsClientTs = const Value.absent(),
    this.mtdsServerTs = const Value.absent(),
    this.mtdsDeviceId = const Value.absent(),
    this.mtdsDeleteTs = const Value.absent(),
    this.channelTagId = const Value.absent(),
    this.channelId = const Value.absent(),
    this.tag = const Value.absent(),
    this.tagDescription = const Value.absent(),
    this.expireAt = const Value.absent(),
  });
  ChannelTagsCompanion.insert({
    this.mtdsClientTs = const Value.absent(),
    this.mtdsServerTs = const Value.absent(),
    this.mtdsDeviceId = const Value.absent(),
    this.mtdsDeleteTs = const Value.absent(),
    this.channelTagId = const Value.absent(),
    required BigInt channelId,
    required String tag,
    this.tagDescription = const Value.absent(),
    this.expireAt = const Value.absent(),
  }) : channelId = Value(channelId),
       tag = Value(tag);
  static Insertable<ChannelTag> custom({
    Expression<BigInt>? mtdsClientTs,
    Expression<BigInt>? mtdsServerTs,
    Expression<BigInt>? mtdsDeviceId,
    Expression<BigInt>? mtdsDeleteTs,
    Expression<BigInt>? channelTagId,
    Expression<BigInt>? channelId,
    Expression<String>? tag,
    Expression<String>? tagDescription,
    Expression<DateTime>? expireAt,
  }) {
    return RawValuesInsertable({
      if (mtdsClientTs != null) 'mtds_client_ts': mtdsClientTs,
      if (mtdsServerTs != null) 'mtds_server_ts': mtdsServerTs,
      if (mtdsDeviceId != null) 'mtds_device_id': mtdsDeviceId,
      if (mtdsDeleteTs != null) 'mtds_delete_ts': mtdsDeleteTs,
      if (channelTagId != null) 'channel_tag_id': channelTagId,
      if (channelId != null) 'channel_id': channelId,
      if (tag != null) 'tag': tag,
      if (tagDescription != null) 'tag_description': tagDescription,
      if (expireAt != null) 'expire_at': expireAt,
    });
  }

  ChannelTagsCompanion copyWith({
    Value<BigInt>? mtdsClientTs,
    Value<BigInt?>? mtdsServerTs,
    Value<BigInt>? mtdsDeviceId,
    Value<BigInt?>? mtdsDeleteTs,
    Value<BigInt>? channelTagId,
    Value<BigInt>? channelId,
    Value<String>? tag,
    Value<String?>? tagDescription,
    Value<DateTime?>? expireAt,
  }) {
    return ChannelTagsCompanion(
      mtdsClientTs: mtdsClientTs ?? this.mtdsClientTs,
      mtdsServerTs: mtdsServerTs ?? this.mtdsServerTs,
      mtdsDeviceId: mtdsDeviceId ?? this.mtdsDeviceId,
      mtdsDeleteTs: mtdsDeleteTs ?? this.mtdsDeleteTs,
      channelTagId: channelTagId ?? this.channelTagId,
      channelId: channelId ?? this.channelId,
      tag: tag ?? this.tag,
      tagDescription: tagDescription ?? this.tagDescription,
      expireAt: expireAt ?? this.expireAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mtdsClientTs.present) {
      map['mtds_client_ts'] = Variable<BigInt>(mtdsClientTs.value);
    }
    if (mtdsServerTs.present) {
      map['mtds_server_ts'] = Variable<BigInt>(mtdsServerTs.value);
    }
    if (mtdsDeviceId.present) {
      map['mtds_device_id'] = Variable<BigInt>(mtdsDeviceId.value);
    }
    if (mtdsDeleteTs.present) {
      map['mtds_delete_ts'] = Variable<BigInt>(mtdsDeleteTs.value);
    }
    if (channelTagId.present) {
      map['channel_tag_id'] = Variable<BigInt>(channelTagId.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<BigInt>(channelId.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (tagDescription.present) {
      map['tag_description'] = Variable<String>(tagDescription.value);
    }
    if (expireAt.present) {
      map['expire_at'] = Variable<DateTime>(expireAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChannelTagsCompanion(')
          ..write('mtdsClientTs: $mtdsClientTs, ')
          ..write('mtdsServerTs: $mtdsServerTs, ')
          ..write('mtdsDeviceId: $mtdsDeviceId, ')
          ..write('mtdsDeleteTs: $mtdsDeleteTs, ')
          ..write('channelTagId: $channelTagId, ')
          ..write('channelId: $channelId, ')
          ..write('tag: $tag, ')
          ..write('tagDescription: $tagDescription, ')
          ..write('expireAt: $expireAt')
          ..write(')'))
        .toString();
  }
}

class $XDocActorsTable extends XDocActors
    with TableInfo<$XDocActorsTable, XDocActor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XDocActorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mtdsClientTsMeta = const VerificationMeta(
    'mtdsClientTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsClientTs = GeneratedColumn<BigInt>(
    'mtds_client_ts',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
    defaultValue: Constant(BigInt.from(0)),
  );
  static const VerificationMeta _mtdsServerTsMeta = const VerificationMeta(
    'mtdsServerTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsServerTs = GeneratedColumn<BigInt>(
    'mtds_server_ts',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mtdsDeviceIdMeta = const VerificationMeta(
    'mtdsDeviceId',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsDeviceId = GeneratedColumn<BigInt>(
    'mtds_device_id',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
    defaultValue: Constant(BigInt.from(0)),
  );
  static const VerificationMeta _mtdsDeleteTsMeta = const VerificationMeta(
    'mtdsDeleteTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsDeleteTs = GeneratedColumn<BigInt>(
    'mtds_delete_ts',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xDocActorIdMeta = const VerificationMeta(
    'xDocActorId',
  );
  @override
  late final GeneratedColumn<BigInt> xDocActorId = GeneratedColumn<BigInt>(
    'x_doc_actor_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _xDocIdMeta = const VerificationMeta('xDocId');
  @override
  late final GeneratedColumn<BigInt> xDocId = GeneratedColumn<BigInt>(
    'x_doc_id',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<BigInt> actorId = GeneratedColumn<BigInt>(
    'actor_id',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<BigInt> channelId = GeneratedColumn<BigInt>(
    'channel_id',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedSymmetricKeyMeta =
      const VerificationMeta('encryptedSymmetricKey');
  @override
  late final GeneratedColumn<Uint8List> encryptedSymmetricKey =
      GeneratedColumn<Uint8List>(
        'encrypted_symmetric_key',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _interconnectIdMeta = const VerificationMeta(
    'interconnectId',
  );
  @override
  late final GeneratedColumn<BigInt> interconnectId = GeneratedColumn<BigInt>(
    'interconnect_id',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _docNameMeta = const VerificationMeta(
    'docName',
  );
  @override
  late final GeneratedColumn<String> docName = GeneratedColumn<String>(
    'doc_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 63,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextDataMeta = const VerificationMeta(
    'contextData',
  );
  @override
  late final GeneratedColumn<String> contextData = GeneratedColumn<String>(
    'context_data',
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
  static const VerificationMeta _completionTimeMeta = const VerificationMeta(
    'completionTime',
  );
  @override
  late final GeneratedColumn<DateTime> completionTime =
      GeneratedColumn<DateTime>(
        'completion_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    mtdsClientTs,
    mtdsServerTs,
    mtdsDeviceId,
    mtdsDeleteTs,
    xDocActorId,
    xDocId,
    actorId,
    channelId,
    encryptedSymmetricKey,
    interconnectId,
    docName,
    contextData,
    startTime,
    completionTime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'x_doc_actors';
  @override
  VerificationContext validateIntegrity(
    Insertable<XDocActor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mtds_client_ts')) {
      context.handle(
        _mtdsClientTsMeta,
        mtdsClientTs.isAcceptableOrUnknown(
          data['mtds_client_ts']!,
          _mtdsClientTsMeta,
        ),
      );
    }
    if (data.containsKey('mtds_server_ts')) {
      context.handle(
        _mtdsServerTsMeta,
        mtdsServerTs.isAcceptableOrUnknown(
          data['mtds_server_ts']!,
          _mtdsServerTsMeta,
        ),
      );
    }
    if (data.containsKey('mtds_device_id')) {
      context.handle(
        _mtdsDeviceIdMeta,
        mtdsDeviceId.isAcceptableOrUnknown(
          data['mtds_device_id']!,
          _mtdsDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('mtds_delete_ts')) {
      context.handle(
        _mtdsDeleteTsMeta,
        mtdsDeleteTs.isAcceptableOrUnknown(
          data['mtds_delete_ts']!,
          _mtdsDeleteTsMeta,
        ),
      );
    }
    if (data.containsKey('x_doc_actor_id')) {
      context.handle(
        _xDocActorIdMeta,
        xDocActorId.isAcceptableOrUnknown(
          data['x_doc_actor_id']!,
          _xDocActorIdMeta,
        ),
      );
    }
    if (data.containsKey('x_doc_id')) {
      context.handle(
        _xDocIdMeta,
        xDocId.isAcceptableOrUnknown(data['x_doc_id']!, _xDocIdMeta),
      );
    } else if (isInserting) {
      context.missing(_xDocIdMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('encrypted_symmetric_key')) {
      context.handle(
        _encryptedSymmetricKeyMeta,
        encryptedSymmetricKey.isAcceptableOrUnknown(
          data['encrypted_symmetric_key']!,
          _encryptedSymmetricKeyMeta,
        ),
      );
    }
    if (data.containsKey('interconnect_id')) {
      context.handle(
        _interconnectIdMeta,
        interconnectId.isAcceptableOrUnknown(
          data['interconnect_id']!,
          _interconnectIdMeta,
        ),
      );
    }
    if (data.containsKey('doc_name')) {
      context.handle(
        _docNameMeta,
        docName.isAcceptableOrUnknown(data['doc_name']!, _docNameMeta),
      );
    } else if (isInserting) {
      context.missing(_docNameMeta);
    }
    if (data.containsKey('context_data')) {
      context.handle(
        _contextDataMeta,
        contextData.isAcceptableOrUnknown(
          data['context_data']!,
          _contextDataMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contextDataMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('completion_time')) {
      context.handle(
        _completionTimeMeta,
        completionTime.isAcceptableOrUnknown(
          data['completion_time']!,
          _completionTimeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {xDocActorId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {xDocId, actorId},
  ];
  @override
  XDocActor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XDocActor(
      mtdsClientTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_client_ts'],
      )!,
      mtdsServerTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_server_ts'],
      ),
      mtdsDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_device_id'],
      )!,
      mtdsDeleteTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_delete_ts'],
      ),
      xDocActorId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}x_doc_actor_id'],
      )!,
      xDocId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}x_doc_id'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}actor_id'],
      )!,
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}channel_id'],
      )!,
      encryptedSymmetricKey: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}encrypted_symmetric_key'],
      ),
      interconnectId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}interconnect_id'],
      ),
      docName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_name'],
      )!,
      contextData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_data'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      completionTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completion_time'],
      ),
    );
  }

  @override
  $XDocActorsTable createAlias(String alias) {
    return $XDocActorsTable(attachedDatabase, alias);
  }
}

class XDocActor extends DataClass implements Insertable<XDocActor> {
  /// Client-generated timestamp in milliseconds since client epoch.
  /// Always present with a default of 0 so change detection never hits NULL.
  final BigInt mtdsClientTs;

  /// Server-assigned authoritative timestamp in nanoseconds since epoch (NodeJS HR based).
  /// NULL until the record is synced to server.
  final BigInt? mtdsServerTs;

  /// 64-bit device identifier used for replication guardrails.
  /// Always present with a default of 0; SDK overwrites it on each write.
  final BigInt mtdsDeviceId;

  /// Soft-delete marker (NULL = active, non-null = deleted at timestamp in milliseconds since client epoch)
  final BigInt? mtdsDeleteTs;
  final BigInt xDocActorId;
  final BigInt xDocId;
  final BigInt actorId;
  final BigInt channelId;
  final Uint8List? encryptedSymmetricKey;
  final BigInt? interconnectId;
  final String docName;
  final String contextData;
  final DateTime startTime;
  final DateTime? completionTime;
  const XDocActor({
    required this.mtdsClientTs,
    this.mtdsServerTs,
    required this.mtdsDeviceId,
    this.mtdsDeleteTs,
    required this.xDocActorId,
    required this.xDocId,
    required this.actorId,
    required this.channelId,
    this.encryptedSymmetricKey,
    this.interconnectId,
    required this.docName,
    required this.contextData,
    required this.startTime,
    this.completionTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['mtds_client_ts'] = Variable<BigInt>(mtdsClientTs);
    if (!nullToAbsent || mtdsServerTs != null) {
      map['mtds_server_ts'] = Variable<BigInt>(mtdsServerTs);
    }
    map['mtds_device_id'] = Variable<BigInt>(mtdsDeviceId);
    if (!nullToAbsent || mtdsDeleteTs != null) {
      map['mtds_delete_ts'] = Variable<BigInt>(mtdsDeleteTs);
    }
    map['x_doc_actor_id'] = Variable<BigInt>(xDocActorId);
    map['x_doc_id'] = Variable<BigInt>(xDocId);
    map['actor_id'] = Variable<BigInt>(actorId);
    map['channel_id'] = Variable<BigInt>(channelId);
    if (!nullToAbsent || encryptedSymmetricKey != null) {
      map['encrypted_symmetric_key'] = Variable<Uint8List>(
        encryptedSymmetricKey,
      );
    }
    if (!nullToAbsent || interconnectId != null) {
      map['interconnect_id'] = Variable<BigInt>(interconnectId);
    }
    map['doc_name'] = Variable<String>(docName);
    map['context_data'] = Variable<String>(contextData);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || completionTime != null) {
      map['completion_time'] = Variable<DateTime>(completionTime);
    }
    return map;
  }

  XDocActorsCompanion toCompanion(bool nullToAbsent) {
    return XDocActorsCompanion(
      mtdsClientTs: Value(mtdsClientTs),
      mtdsServerTs: mtdsServerTs == null && nullToAbsent
          ? const Value.absent()
          : Value(mtdsServerTs),
      mtdsDeviceId: Value(mtdsDeviceId),
      mtdsDeleteTs: mtdsDeleteTs == null && nullToAbsent
          ? const Value.absent()
          : Value(mtdsDeleteTs),
      xDocActorId: Value(xDocActorId),
      xDocId: Value(xDocId),
      actorId: Value(actorId),
      channelId: Value(channelId),
      encryptedSymmetricKey: encryptedSymmetricKey == null && nullToAbsent
          ? const Value.absent()
          : Value(encryptedSymmetricKey),
      interconnectId: interconnectId == null && nullToAbsent
          ? const Value.absent()
          : Value(interconnectId),
      docName: Value(docName),
      contextData: Value(contextData),
      startTime: Value(startTime),
      completionTime: completionTime == null && nullToAbsent
          ? const Value.absent()
          : Value(completionTime),
    );
  }

  factory XDocActor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XDocActor(
      mtdsClientTs: serializer.fromJson<BigInt>(json['mtdsClientTs']),
      mtdsServerTs: serializer.fromJson<BigInt?>(json['mtdsServerTs']),
      mtdsDeviceId: serializer.fromJson<BigInt>(json['mtdsDeviceId']),
      mtdsDeleteTs: serializer.fromJson<BigInt?>(json['mtdsDeleteTs']),
      xDocActorId: serializer.fromJson<BigInt>(json['xDocActorId']),
      xDocId: serializer.fromJson<BigInt>(json['xDocId']),
      actorId: serializer.fromJson<BigInt>(json['actorId']),
      channelId: serializer.fromJson<BigInt>(json['channelId']),
      encryptedSymmetricKey: serializer.fromJson<Uint8List?>(
        json['encryptedSymmetricKey'],
      ),
      interconnectId: serializer.fromJson<BigInt?>(json['interconnectId']),
      docName: serializer.fromJson<String>(json['docName']),
      contextData: serializer.fromJson<String>(json['contextData']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      completionTime: serializer.fromJson<DateTime?>(json['completionTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mtdsClientTs': serializer.toJson<BigInt>(mtdsClientTs),
      'mtdsServerTs': serializer.toJson<BigInt?>(mtdsServerTs),
      'mtdsDeviceId': serializer.toJson<BigInt>(mtdsDeviceId),
      'mtdsDeleteTs': serializer.toJson<BigInt?>(mtdsDeleteTs),
      'xDocActorId': serializer.toJson<BigInt>(xDocActorId),
      'xDocId': serializer.toJson<BigInt>(xDocId),
      'actorId': serializer.toJson<BigInt>(actorId),
      'channelId': serializer.toJson<BigInt>(channelId),
      'encryptedSymmetricKey': serializer.toJson<Uint8List?>(
        encryptedSymmetricKey,
      ),
      'interconnectId': serializer.toJson<BigInt?>(interconnectId),
      'docName': serializer.toJson<String>(docName),
      'contextData': serializer.toJson<String>(contextData),
      'startTime': serializer.toJson<DateTime>(startTime),
      'completionTime': serializer.toJson<DateTime?>(completionTime),
    };
  }

  XDocActor copyWith({
    BigInt? mtdsClientTs,
    Value<BigInt?> mtdsServerTs = const Value.absent(),
    BigInt? mtdsDeviceId,
    Value<BigInt?> mtdsDeleteTs = const Value.absent(),
    BigInt? xDocActorId,
    BigInt? xDocId,
    BigInt? actorId,
    BigInt? channelId,
    Value<Uint8List?> encryptedSymmetricKey = const Value.absent(),
    Value<BigInt?> interconnectId = const Value.absent(),
    String? docName,
    String? contextData,
    DateTime? startTime,
    Value<DateTime?> completionTime = const Value.absent(),
  }) => XDocActor(
    mtdsClientTs: mtdsClientTs ?? this.mtdsClientTs,
    mtdsServerTs: mtdsServerTs.present ? mtdsServerTs.value : this.mtdsServerTs,
    mtdsDeviceId: mtdsDeviceId ?? this.mtdsDeviceId,
    mtdsDeleteTs: mtdsDeleteTs.present ? mtdsDeleteTs.value : this.mtdsDeleteTs,
    xDocActorId: xDocActorId ?? this.xDocActorId,
    xDocId: xDocId ?? this.xDocId,
    actorId: actorId ?? this.actorId,
    channelId: channelId ?? this.channelId,
    encryptedSymmetricKey: encryptedSymmetricKey.present
        ? encryptedSymmetricKey.value
        : this.encryptedSymmetricKey,
    interconnectId: interconnectId.present
        ? interconnectId.value
        : this.interconnectId,
    docName: docName ?? this.docName,
    contextData: contextData ?? this.contextData,
    startTime: startTime ?? this.startTime,
    completionTime: completionTime.present
        ? completionTime.value
        : this.completionTime,
  );
  XDocActor copyWithCompanion(XDocActorsCompanion data) {
    return XDocActor(
      mtdsClientTs: data.mtdsClientTs.present
          ? data.mtdsClientTs.value
          : this.mtdsClientTs,
      mtdsServerTs: data.mtdsServerTs.present
          ? data.mtdsServerTs.value
          : this.mtdsServerTs,
      mtdsDeviceId: data.mtdsDeviceId.present
          ? data.mtdsDeviceId.value
          : this.mtdsDeviceId,
      mtdsDeleteTs: data.mtdsDeleteTs.present
          ? data.mtdsDeleteTs.value
          : this.mtdsDeleteTs,
      xDocActorId: data.xDocActorId.present
          ? data.xDocActorId.value
          : this.xDocActorId,
      xDocId: data.xDocId.present ? data.xDocId.value : this.xDocId,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      encryptedSymmetricKey: data.encryptedSymmetricKey.present
          ? data.encryptedSymmetricKey.value
          : this.encryptedSymmetricKey,
      interconnectId: data.interconnectId.present
          ? data.interconnectId.value
          : this.interconnectId,
      docName: data.docName.present ? data.docName.value : this.docName,
      contextData: data.contextData.present
          ? data.contextData.value
          : this.contextData,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      completionTime: data.completionTime.present
          ? data.completionTime.value
          : this.completionTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XDocActor(')
          ..write('mtdsClientTs: $mtdsClientTs, ')
          ..write('mtdsServerTs: $mtdsServerTs, ')
          ..write('mtdsDeviceId: $mtdsDeviceId, ')
          ..write('mtdsDeleteTs: $mtdsDeleteTs, ')
          ..write('xDocActorId: $xDocActorId, ')
          ..write('xDocId: $xDocId, ')
          ..write('actorId: $actorId, ')
          ..write('channelId: $channelId, ')
          ..write('encryptedSymmetricKey: $encryptedSymmetricKey, ')
          ..write('interconnectId: $interconnectId, ')
          ..write('docName: $docName, ')
          ..write('contextData: $contextData, ')
          ..write('startTime: $startTime, ')
          ..write('completionTime: $completionTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mtdsClientTs,
    mtdsServerTs,
    mtdsDeviceId,
    mtdsDeleteTs,
    xDocActorId,
    xDocId,
    actorId,
    channelId,
    $driftBlobEquality.hash(encryptedSymmetricKey),
    interconnectId,
    docName,
    contextData,
    startTime,
    completionTime,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XDocActor &&
          other.mtdsClientTs == this.mtdsClientTs &&
          other.mtdsServerTs == this.mtdsServerTs &&
          other.mtdsDeviceId == this.mtdsDeviceId &&
          other.mtdsDeleteTs == this.mtdsDeleteTs &&
          other.xDocActorId == this.xDocActorId &&
          other.xDocId == this.xDocId &&
          other.actorId == this.actorId &&
          other.channelId == this.channelId &&
          $driftBlobEquality.equals(
            other.encryptedSymmetricKey,
            this.encryptedSymmetricKey,
          ) &&
          other.interconnectId == this.interconnectId &&
          other.docName == this.docName &&
          other.contextData == this.contextData &&
          other.startTime == this.startTime &&
          other.completionTime == this.completionTime);
}

class XDocActorsCompanion extends UpdateCompanion<XDocActor> {
  final Value<BigInt> mtdsClientTs;
  final Value<BigInt?> mtdsServerTs;
  final Value<BigInt> mtdsDeviceId;
  final Value<BigInt?> mtdsDeleteTs;
  final Value<BigInt> xDocActorId;
  final Value<BigInt> xDocId;
  final Value<BigInt> actorId;
  final Value<BigInt> channelId;
  final Value<Uint8List?> encryptedSymmetricKey;
  final Value<BigInt?> interconnectId;
  final Value<String> docName;
  final Value<String> contextData;
  final Value<DateTime> startTime;
  final Value<DateTime?> completionTime;
  const XDocActorsCompanion({
    this.mtdsClientTs = const Value.absent(),
    this.mtdsServerTs = const Value.absent(),
    this.mtdsDeviceId = const Value.absent(),
    this.mtdsDeleteTs = const Value.absent(),
    this.xDocActorId = const Value.absent(),
    this.xDocId = const Value.absent(),
    this.actorId = const Value.absent(),
    this.channelId = const Value.absent(),
    this.encryptedSymmetricKey = const Value.absent(),
    this.interconnectId = const Value.absent(),
    this.docName = const Value.absent(),
    this.contextData = const Value.absent(),
    this.startTime = const Value.absent(),
    this.completionTime = const Value.absent(),
  });
  XDocActorsCompanion.insert({
    this.mtdsClientTs = const Value.absent(),
    this.mtdsServerTs = const Value.absent(),
    this.mtdsDeviceId = const Value.absent(),
    this.mtdsDeleteTs = const Value.absent(),
    this.xDocActorId = const Value.absent(),
    required BigInt xDocId,
    required BigInt actorId,
    required BigInt channelId,
    this.encryptedSymmetricKey = const Value.absent(),
    this.interconnectId = const Value.absent(),
    required String docName,
    required String contextData,
    required DateTime startTime,
    this.completionTime = const Value.absent(),
  }) : xDocId = Value(xDocId),
       actorId = Value(actorId),
       channelId = Value(channelId),
       docName = Value(docName),
       contextData = Value(contextData),
       startTime = Value(startTime);
  static Insertable<XDocActor> custom({
    Expression<BigInt>? mtdsClientTs,
    Expression<BigInt>? mtdsServerTs,
    Expression<BigInt>? mtdsDeviceId,
    Expression<BigInt>? mtdsDeleteTs,
    Expression<BigInt>? xDocActorId,
    Expression<BigInt>? xDocId,
    Expression<BigInt>? actorId,
    Expression<BigInt>? channelId,
    Expression<Uint8List>? encryptedSymmetricKey,
    Expression<BigInt>? interconnectId,
    Expression<String>? docName,
    Expression<String>? contextData,
    Expression<DateTime>? startTime,
    Expression<DateTime>? completionTime,
  }) {
    return RawValuesInsertable({
      if (mtdsClientTs != null) 'mtds_client_ts': mtdsClientTs,
      if (mtdsServerTs != null) 'mtds_server_ts': mtdsServerTs,
      if (mtdsDeviceId != null) 'mtds_device_id': mtdsDeviceId,
      if (mtdsDeleteTs != null) 'mtds_delete_ts': mtdsDeleteTs,
      if (xDocActorId != null) 'x_doc_actor_id': xDocActorId,
      if (xDocId != null) 'x_doc_id': xDocId,
      if (actorId != null) 'actor_id': actorId,
      if (channelId != null) 'channel_id': channelId,
      if (encryptedSymmetricKey != null)
        'encrypted_symmetric_key': encryptedSymmetricKey,
      if (interconnectId != null) 'interconnect_id': interconnectId,
      if (docName != null) 'doc_name': docName,
      if (contextData != null) 'context_data': contextData,
      if (startTime != null) 'start_time': startTime,
      if (completionTime != null) 'completion_time': completionTime,
    });
  }

  XDocActorsCompanion copyWith({
    Value<BigInt>? mtdsClientTs,
    Value<BigInt?>? mtdsServerTs,
    Value<BigInt>? mtdsDeviceId,
    Value<BigInt?>? mtdsDeleteTs,
    Value<BigInt>? xDocActorId,
    Value<BigInt>? xDocId,
    Value<BigInt>? actorId,
    Value<BigInt>? channelId,
    Value<Uint8List?>? encryptedSymmetricKey,
    Value<BigInt?>? interconnectId,
    Value<String>? docName,
    Value<String>? contextData,
    Value<DateTime>? startTime,
    Value<DateTime?>? completionTime,
  }) {
    return XDocActorsCompanion(
      mtdsClientTs: mtdsClientTs ?? this.mtdsClientTs,
      mtdsServerTs: mtdsServerTs ?? this.mtdsServerTs,
      mtdsDeviceId: mtdsDeviceId ?? this.mtdsDeviceId,
      mtdsDeleteTs: mtdsDeleteTs ?? this.mtdsDeleteTs,
      xDocActorId: xDocActorId ?? this.xDocActorId,
      xDocId: xDocId ?? this.xDocId,
      actorId: actorId ?? this.actorId,
      channelId: channelId ?? this.channelId,
      encryptedSymmetricKey:
          encryptedSymmetricKey ?? this.encryptedSymmetricKey,
      interconnectId: interconnectId ?? this.interconnectId,
      docName: docName ?? this.docName,
      contextData: contextData ?? this.contextData,
      startTime: startTime ?? this.startTime,
      completionTime: completionTime ?? this.completionTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mtdsClientTs.present) {
      map['mtds_client_ts'] = Variable<BigInt>(mtdsClientTs.value);
    }
    if (mtdsServerTs.present) {
      map['mtds_server_ts'] = Variable<BigInt>(mtdsServerTs.value);
    }
    if (mtdsDeviceId.present) {
      map['mtds_device_id'] = Variable<BigInt>(mtdsDeviceId.value);
    }
    if (mtdsDeleteTs.present) {
      map['mtds_delete_ts'] = Variable<BigInt>(mtdsDeleteTs.value);
    }
    if (xDocActorId.present) {
      map['x_doc_actor_id'] = Variable<BigInt>(xDocActorId.value);
    }
    if (xDocId.present) {
      map['x_doc_id'] = Variable<BigInt>(xDocId.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<BigInt>(actorId.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<BigInt>(channelId.value);
    }
    if (encryptedSymmetricKey.present) {
      map['encrypted_symmetric_key'] = Variable<Uint8List>(
        encryptedSymmetricKey.value,
      );
    }
    if (interconnectId.present) {
      map['interconnect_id'] = Variable<BigInt>(interconnectId.value);
    }
    if (docName.present) {
      map['doc_name'] = Variable<String>(docName.value);
    }
    if (contextData.present) {
      map['context_data'] = Variable<String>(contextData.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (completionTime.present) {
      map['completion_time'] = Variable<DateTime>(completionTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XDocActorsCompanion(')
          ..write('mtdsClientTs: $mtdsClientTs, ')
          ..write('mtdsServerTs: $mtdsServerTs, ')
          ..write('mtdsDeviceId: $mtdsDeviceId, ')
          ..write('mtdsDeleteTs: $mtdsDeleteTs, ')
          ..write('xDocActorId: $xDocActorId, ')
          ..write('xDocId: $xDocId, ')
          ..write('actorId: $actorId, ')
          ..write('channelId: $channelId, ')
          ..write('encryptedSymmetricKey: $encryptedSymmetricKey, ')
          ..write('interconnectId: $interconnectId, ')
          ..write('docName: $docName, ')
          ..write('contextData: $contextData, ')
          ..write('startTime: $startTime, ')
          ..write('completionTime: $completionTime')
          ..write(')'))
        .toString();
  }
}

class $XDocEventsTable extends XDocEvents
    with TableInfo<$XDocEventsTable, XDocEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XDocEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mtdsClientTsMeta = const VerificationMeta(
    'mtdsClientTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsClientTs = GeneratedColumn<BigInt>(
    'mtds_client_ts',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
    defaultValue: Constant(BigInt.from(0)),
  );
  static const VerificationMeta _mtdsServerTsMeta = const VerificationMeta(
    'mtdsServerTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsServerTs = GeneratedColumn<BigInt>(
    'mtds_server_ts',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mtdsDeviceIdMeta = const VerificationMeta(
    'mtdsDeviceId',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsDeviceId = GeneratedColumn<BigInt>(
    'mtds_device_id',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
    defaultValue: Constant(BigInt.from(0)),
  );
  static const VerificationMeta _mtdsDeleteTsMeta = const VerificationMeta(
    'mtdsDeleteTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsDeleteTs = GeneratedColumn<BigInt>(
    'mtds_delete_ts',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xDocEventIdMeta = const VerificationMeta(
    'xDocEventId',
  );
  @override
  late final GeneratedColumn<BigInt> xDocEventId = GeneratedColumn<BigInt>(
    'x_doc_event_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _xDocActorIdMeta = const VerificationMeta(
    'xDocActorId',
  );
  @override
  late final GeneratedColumn<BigInt> xDocActorId = GeneratedColumn<BigInt>(
    'x_doc_actor_id',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xDocIdMeta = const VerificationMeta('xDocId');
  @override
  late final GeneratedColumn<BigInt> xDocId = GeneratedColumn<BigInt>(
    'x_doc_id',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<BigInt> actorId = GeneratedColumn<BigInt>(
    'actor_id',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventPayloadMeta = const VerificationMeta(
    'eventPayload',
  );
  @override
  late final GeneratedColumn<String> eventPayload = GeneratedColumn<String>(
    'event_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextDataMeta = const VerificationMeta(
    'contextData',
  );
  @override
  late final GeneratedColumn<String> contextData = GeneratedColumn<String>(
    'context_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _entityRolesMeta = const VerificationMeta(
    'entityRoles',
  );
  @override
  late final GeneratedColumn<String> entityRoles = GeneratedColumn<String>(
    'entity_roles',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 63,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    mtdsClientTs,
    mtdsServerTs,
    mtdsDeviceId,
    mtdsDeleteTs,
    xDocEventId,
    xDocActorId,
    xDocId,
    actorId,
    eventPayload,
    contextData,
    entityRoles,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'x_doc_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<XDocEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mtds_client_ts')) {
      context.handle(
        _mtdsClientTsMeta,
        mtdsClientTs.isAcceptableOrUnknown(
          data['mtds_client_ts']!,
          _mtdsClientTsMeta,
        ),
      );
    }
    if (data.containsKey('mtds_server_ts')) {
      context.handle(
        _mtdsServerTsMeta,
        mtdsServerTs.isAcceptableOrUnknown(
          data['mtds_server_ts']!,
          _mtdsServerTsMeta,
        ),
      );
    }
    if (data.containsKey('mtds_device_id')) {
      context.handle(
        _mtdsDeviceIdMeta,
        mtdsDeviceId.isAcceptableOrUnknown(
          data['mtds_device_id']!,
          _mtdsDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('mtds_delete_ts')) {
      context.handle(
        _mtdsDeleteTsMeta,
        mtdsDeleteTs.isAcceptableOrUnknown(
          data['mtds_delete_ts']!,
          _mtdsDeleteTsMeta,
        ),
      );
    }
    if (data.containsKey('x_doc_event_id')) {
      context.handle(
        _xDocEventIdMeta,
        xDocEventId.isAcceptableOrUnknown(
          data['x_doc_event_id']!,
          _xDocEventIdMeta,
        ),
      );
    }
    if (data.containsKey('x_doc_actor_id')) {
      context.handle(
        _xDocActorIdMeta,
        xDocActorId.isAcceptableOrUnknown(
          data['x_doc_actor_id']!,
          _xDocActorIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_xDocActorIdMeta);
    }
    if (data.containsKey('x_doc_id')) {
      context.handle(
        _xDocIdMeta,
        xDocId.isAcceptableOrUnknown(data['x_doc_id']!, _xDocIdMeta),
      );
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    }
    if (data.containsKey('event_payload')) {
      context.handle(
        _eventPayloadMeta,
        eventPayload.isAcceptableOrUnknown(
          data['event_payload']!,
          _eventPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventPayloadMeta);
    }
    if (data.containsKey('context_data')) {
      context.handle(
        _contextDataMeta,
        contextData.isAcceptableOrUnknown(
          data['context_data']!,
          _contextDataMeta,
        ),
      );
    }
    if (data.containsKey('entity_roles')) {
      context.handle(
        _entityRolesMeta,
        entityRoles.isAcceptableOrUnknown(
          data['entity_roles']!,
          _entityRolesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityRolesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {xDocEventId};
  @override
  XDocEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XDocEvent(
      mtdsClientTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_client_ts'],
      )!,
      mtdsServerTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_server_ts'],
      ),
      mtdsDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_device_id'],
      )!,
      mtdsDeleteTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_delete_ts'],
      ),
      xDocEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}x_doc_event_id'],
      )!,
      xDocActorId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}x_doc_actor_id'],
      )!,
      xDocId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}x_doc_id'],
      ),
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}actor_id'],
      ),
      eventPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_payload'],
      )!,
      contextData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_data'],
      )!,
      entityRoles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_roles'],
      )!,
    );
  }

  @override
  $XDocEventsTable createAlias(String alias) {
    return $XDocEventsTable(attachedDatabase, alias);
  }
}

class XDocEvent extends DataClass implements Insertable<XDocEvent> {
  /// Client-generated timestamp in milliseconds since client epoch.
  /// Always present with a default of 0 so change detection never hits NULL.
  final BigInt mtdsClientTs;

  /// Server-assigned authoritative timestamp in nanoseconds since epoch (NodeJS HR based).
  /// NULL until the record is synced to server.
  final BigInt? mtdsServerTs;

  /// 64-bit device identifier used for replication guardrails.
  /// Always present with a default of 0; SDK overwrites it on each write.
  final BigInt mtdsDeviceId;

  /// Soft-delete marker (NULL = active, non-null = deleted at timestamp in milliseconds since client epoch)
  final BigInt? mtdsDeleteTs;
  final BigInt xDocEventId;
  final BigInt xDocActorId;
  final BigInt? xDocId;
  final BigInt? actorId;
  final String eventPayload;
  final String contextData;
  final String entityRoles;
  const XDocEvent({
    required this.mtdsClientTs,
    this.mtdsServerTs,
    required this.mtdsDeviceId,
    this.mtdsDeleteTs,
    required this.xDocEventId,
    required this.xDocActorId,
    this.xDocId,
    this.actorId,
    required this.eventPayload,
    required this.contextData,
    required this.entityRoles,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['mtds_client_ts'] = Variable<BigInt>(mtdsClientTs);
    if (!nullToAbsent || mtdsServerTs != null) {
      map['mtds_server_ts'] = Variable<BigInt>(mtdsServerTs);
    }
    map['mtds_device_id'] = Variable<BigInt>(mtdsDeviceId);
    if (!nullToAbsent || mtdsDeleteTs != null) {
      map['mtds_delete_ts'] = Variable<BigInt>(mtdsDeleteTs);
    }
    map['x_doc_event_id'] = Variable<BigInt>(xDocEventId);
    map['x_doc_actor_id'] = Variable<BigInt>(xDocActorId);
    if (!nullToAbsent || xDocId != null) {
      map['x_doc_id'] = Variable<BigInt>(xDocId);
    }
    if (!nullToAbsent || actorId != null) {
      map['actor_id'] = Variable<BigInt>(actorId);
    }
    map['event_payload'] = Variable<String>(eventPayload);
    map['context_data'] = Variable<String>(contextData);
    map['entity_roles'] = Variable<String>(entityRoles);
    return map;
  }

  XDocEventsCompanion toCompanion(bool nullToAbsent) {
    return XDocEventsCompanion(
      mtdsClientTs: Value(mtdsClientTs),
      mtdsServerTs: mtdsServerTs == null && nullToAbsent
          ? const Value.absent()
          : Value(mtdsServerTs),
      mtdsDeviceId: Value(mtdsDeviceId),
      mtdsDeleteTs: mtdsDeleteTs == null && nullToAbsent
          ? const Value.absent()
          : Value(mtdsDeleteTs),
      xDocEventId: Value(xDocEventId),
      xDocActorId: Value(xDocActorId),
      xDocId: xDocId == null && nullToAbsent
          ? const Value.absent()
          : Value(xDocId),
      actorId: actorId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorId),
      eventPayload: Value(eventPayload),
      contextData: Value(contextData),
      entityRoles: Value(entityRoles),
    );
  }

  factory XDocEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XDocEvent(
      mtdsClientTs: serializer.fromJson<BigInt>(json['mtdsClientTs']),
      mtdsServerTs: serializer.fromJson<BigInt?>(json['mtdsServerTs']),
      mtdsDeviceId: serializer.fromJson<BigInt>(json['mtdsDeviceId']),
      mtdsDeleteTs: serializer.fromJson<BigInt?>(json['mtdsDeleteTs']),
      xDocEventId: serializer.fromJson<BigInt>(json['xDocEventId']),
      xDocActorId: serializer.fromJson<BigInt>(json['xDocActorId']),
      xDocId: serializer.fromJson<BigInt?>(json['xDocId']),
      actorId: serializer.fromJson<BigInt?>(json['actorId']),
      eventPayload: serializer.fromJson<String>(json['eventPayload']),
      contextData: serializer.fromJson<String>(json['contextData']),
      entityRoles: serializer.fromJson<String>(json['entityRoles']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mtdsClientTs': serializer.toJson<BigInt>(mtdsClientTs),
      'mtdsServerTs': serializer.toJson<BigInt?>(mtdsServerTs),
      'mtdsDeviceId': serializer.toJson<BigInt>(mtdsDeviceId),
      'mtdsDeleteTs': serializer.toJson<BigInt?>(mtdsDeleteTs),
      'xDocEventId': serializer.toJson<BigInt>(xDocEventId),
      'xDocActorId': serializer.toJson<BigInt>(xDocActorId),
      'xDocId': serializer.toJson<BigInt?>(xDocId),
      'actorId': serializer.toJson<BigInt?>(actorId),
      'eventPayload': serializer.toJson<String>(eventPayload),
      'contextData': serializer.toJson<String>(contextData),
      'entityRoles': serializer.toJson<String>(entityRoles),
    };
  }

  XDocEvent copyWith({
    BigInt? mtdsClientTs,
    Value<BigInt?> mtdsServerTs = const Value.absent(),
    BigInt? mtdsDeviceId,
    Value<BigInt?> mtdsDeleteTs = const Value.absent(),
    BigInt? xDocEventId,
    BigInt? xDocActorId,
    Value<BigInt?> xDocId = const Value.absent(),
    Value<BigInt?> actorId = const Value.absent(),
    String? eventPayload,
    String? contextData,
    String? entityRoles,
  }) => XDocEvent(
    mtdsClientTs: mtdsClientTs ?? this.mtdsClientTs,
    mtdsServerTs: mtdsServerTs.present ? mtdsServerTs.value : this.mtdsServerTs,
    mtdsDeviceId: mtdsDeviceId ?? this.mtdsDeviceId,
    mtdsDeleteTs: mtdsDeleteTs.present ? mtdsDeleteTs.value : this.mtdsDeleteTs,
    xDocEventId: xDocEventId ?? this.xDocEventId,
    xDocActorId: xDocActorId ?? this.xDocActorId,
    xDocId: xDocId.present ? xDocId.value : this.xDocId,
    actorId: actorId.present ? actorId.value : this.actorId,
    eventPayload: eventPayload ?? this.eventPayload,
    contextData: contextData ?? this.contextData,
    entityRoles: entityRoles ?? this.entityRoles,
  );
  XDocEvent copyWithCompanion(XDocEventsCompanion data) {
    return XDocEvent(
      mtdsClientTs: data.mtdsClientTs.present
          ? data.mtdsClientTs.value
          : this.mtdsClientTs,
      mtdsServerTs: data.mtdsServerTs.present
          ? data.mtdsServerTs.value
          : this.mtdsServerTs,
      mtdsDeviceId: data.mtdsDeviceId.present
          ? data.mtdsDeviceId.value
          : this.mtdsDeviceId,
      mtdsDeleteTs: data.mtdsDeleteTs.present
          ? data.mtdsDeleteTs.value
          : this.mtdsDeleteTs,
      xDocEventId: data.xDocEventId.present
          ? data.xDocEventId.value
          : this.xDocEventId,
      xDocActorId: data.xDocActorId.present
          ? data.xDocActorId.value
          : this.xDocActorId,
      xDocId: data.xDocId.present ? data.xDocId.value : this.xDocId,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      eventPayload: data.eventPayload.present
          ? data.eventPayload.value
          : this.eventPayload,
      contextData: data.contextData.present
          ? data.contextData.value
          : this.contextData,
      entityRoles: data.entityRoles.present
          ? data.entityRoles.value
          : this.entityRoles,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XDocEvent(')
          ..write('mtdsClientTs: $mtdsClientTs, ')
          ..write('mtdsServerTs: $mtdsServerTs, ')
          ..write('mtdsDeviceId: $mtdsDeviceId, ')
          ..write('mtdsDeleteTs: $mtdsDeleteTs, ')
          ..write('xDocEventId: $xDocEventId, ')
          ..write('xDocActorId: $xDocActorId, ')
          ..write('xDocId: $xDocId, ')
          ..write('actorId: $actorId, ')
          ..write('eventPayload: $eventPayload, ')
          ..write('contextData: $contextData, ')
          ..write('entityRoles: $entityRoles')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mtdsClientTs,
    mtdsServerTs,
    mtdsDeviceId,
    mtdsDeleteTs,
    xDocEventId,
    xDocActorId,
    xDocId,
    actorId,
    eventPayload,
    contextData,
    entityRoles,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XDocEvent &&
          other.mtdsClientTs == this.mtdsClientTs &&
          other.mtdsServerTs == this.mtdsServerTs &&
          other.mtdsDeviceId == this.mtdsDeviceId &&
          other.mtdsDeleteTs == this.mtdsDeleteTs &&
          other.xDocEventId == this.xDocEventId &&
          other.xDocActorId == this.xDocActorId &&
          other.xDocId == this.xDocId &&
          other.actorId == this.actorId &&
          other.eventPayload == this.eventPayload &&
          other.contextData == this.contextData &&
          other.entityRoles == this.entityRoles);
}

class XDocEventsCompanion extends UpdateCompanion<XDocEvent> {
  final Value<BigInt> mtdsClientTs;
  final Value<BigInt?> mtdsServerTs;
  final Value<BigInt> mtdsDeviceId;
  final Value<BigInt?> mtdsDeleteTs;
  final Value<BigInt> xDocEventId;
  final Value<BigInt> xDocActorId;
  final Value<BigInt?> xDocId;
  final Value<BigInt?> actorId;
  final Value<String> eventPayload;
  final Value<String> contextData;
  final Value<String> entityRoles;
  const XDocEventsCompanion({
    this.mtdsClientTs = const Value.absent(),
    this.mtdsServerTs = const Value.absent(),
    this.mtdsDeviceId = const Value.absent(),
    this.mtdsDeleteTs = const Value.absent(),
    this.xDocEventId = const Value.absent(),
    this.xDocActorId = const Value.absent(),
    this.xDocId = const Value.absent(),
    this.actorId = const Value.absent(),
    this.eventPayload = const Value.absent(),
    this.contextData = const Value.absent(),
    this.entityRoles = const Value.absent(),
  });
  XDocEventsCompanion.insert({
    this.mtdsClientTs = const Value.absent(),
    this.mtdsServerTs = const Value.absent(),
    this.mtdsDeviceId = const Value.absent(),
    this.mtdsDeleteTs = const Value.absent(),
    this.xDocEventId = const Value.absent(),
    required BigInt xDocActorId,
    this.xDocId = const Value.absent(),
    this.actorId = const Value.absent(),
    required String eventPayload,
    this.contextData = const Value.absent(),
    required String entityRoles,
  }) : xDocActorId = Value(xDocActorId),
       eventPayload = Value(eventPayload),
       entityRoles = Value(entityRoles);
  static Insertable<XDocEvent> custom({
    Expression<BigInt>? mtdsClientTs,
    Expression<BigInt>? mtdsServerTs,
    Expression<BigInt>? mtdsDeviceId,
    Expression<BigInt>? mtdsDeleteTs,
    Expression<BigInt>? xDocEventId,
    Expression<BigInt>? xDocActorId,
    Expression<BigInt>? xDocId,
    Expression<BigInt>? actorId,
    Expression<String>? eventPayload,
    Expression<String>? contextData,
    Expression<String>? entityRoles,
  }) {
    return RawValuesInsertable({
      if (mtdsClientTs != null) 'mtds_client_ts': mtdsClientTs,
      if (mtdsServerTs != null) 'mtds_server_ts': mtdsServerTs,
      if (mtdsDeviceId != null) 'mtds_device_id': mtdsDeviceId,
      if (mtdsDeleteTs != null) 'mtds_delete_ts': mtdsDeleteTs,
      if (xDocEventId != null) 'x_doc_event_id': xDocEventId,
      if (xDocActorId != null) 'x_doc_actor_id': xDocActorId,
      if (xDocId != null) 'x_doc_id': xDocId,
      if (actorId != null) 'actor_id': actorId,
      if (eventPayload != null) 'event_payload': eventPayload,
      if (contextData != null) 'context_data': contextData,
      if (entityRoles != null) 'entity_roles': entityRoles,
    });
  }

  XDocEventsCompanion copyWith({
    Value<BigInt>? mtdsClientTs,
    Value<BigInt?>? mtdsServerTs,
    Value<BigInt>? mtdsDeviceId,
    Value<BigInt?>? mtdsDeleteTs,
    Value<BigInt>? xDocEventId,
    Value<BigInt>? xDocActorId,
    Value<BigInt?>? xDocId,
    Value<BigInt?>? actorId,
    Value<String>? eventPayload,
    Value<String>? contextData,
    Value<String>? entityRoles,
  }) {
    return XDocEventsCompanion(
      mtdsClientTs: mtdsClientTs ?? this.mtdsClientTs,
      mtdsServerTs: mtdsServerTs ?? this.mtdsServerTs,
      mtdsDeviceId: mtdsDeviceId ?? this.mtdsDeviceId,
      mtdsDeleteTs: mtdsDeleteTs ?? this.mtdsDeleteTs,
      xDocEventId: xDocEventId ?? this.xDocEventId,
      xDocActorId: xDocActorId ?? this.xDocActorId,
      xDocId: xDocId ?? this.xDocId,
      actorId: actorId ?? this.actorId,
      eventPayload: eventPayload ?? this.eventPayload,
      contextData: contextData ?? this.contextData,
      entityRoles: entityRoles ?? this.entityRoles,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mtdsClientTs.present) {
      map['mtds_client_ts'] = Variable<BigInt>(mtdsClientTs.value);
    }
    if (mtdsServerTs.present) {
      map['mtds_server_ts'] = Variable<BigInt>(mtdsServerTs.value);
    }
    if (mtdsDeviceId.present) {
      map['mtds_device_id'] = Variable<BigInt>(mtdsDeviceId.value);
    }
    if (mtdsDeleteTs.present) {
      map['mtds_delete_ts'] = Variable<BigInt>(mtdsDeleteTs.value);
    }
    if (xDocEventId.present) {
      map['x_doc_event_id'] = Variable<BigInt>(xDocEventId.value);
    }
    if (xDocActorId.present) {
      map['x_doc_actor_id'] = Variable<BigInt>(xDocActorId.value);
    }
    if (xDocId.present) {
      map['x_doc_id'] = Variable<BigInt>(xDocId.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<BigInt>(actorId.value);
    }
    if (eventPayload.present) {
      map['event_payload'] = Variable<String>(eventPayload.value);
    }
    if (contextData.present) {
      map['context_data'] = Variable<String>(contextData.value);
    }
    if (entityRoles.present) {
      map['entity_roles'] = Variable<String>(entityRoles.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XDocEventsCompanion(')
          ..write('mtdsClientTs: $mtdsClientTs, ')
          ..write('mtdsServerTs: $mtdsServerTs, ')
          ..write('mtdsDeviceId: $mtdsDeviceId, ')
          ..write('mtdsDeleteTs: $mtdsDeleteTs, ')
          ..write('xDocEventId: $xDocEventId, ')
          ..write('xDocActorId: $xDocActorId, ')
          ..write('xDocId: $xDocId, ')
          ..write('actorId: $actorId, ')
          ..write('eventPayload: $eventPayload, ')
          ..write('contextData: $contextData, ')
          ..write('entityRoles: $entityRoles')
          ..write(')'))
        .toString();
  }
}

class $XDocStateTransitionsTable extends XDocStateTransitions
    with TableInfo<$XDocStateTransitionsTable, XDocStateTransition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XDocStateTransitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mtdsClientTsMeta = const VerificationMeta(
    'mtdsClientTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsClientTs = GeneratedColumn<BigInt>(
    'mtds_client_ts',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
    defaultValue: Constant(BigInt.from(0)),
  );
  static const VerificationMeta _mtdsServerTsMeta = const VerificationMeta(
    'mtdsServerTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsServerTs = GeneratedColumn<BigInt>(
    'mtds_server_ts',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mtdsDeviceIdMeta = const VerificationMeta(
    'mtdsDeviceId',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsDeviceId = GeneratedColumn<BigInt>(
    'mtds_device_id',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
    defaultValue: Constant(BigInt.from(0)),
  );
  static const VerificationMeta _mtdsDeleteTsMeta = const VerificationMeta(
    'mtdsDeleteTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsDeleteTs = GeneratedColumn<BigInt>(
    'mtds_delete_ts',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xDocStateTransitionIdMeta =
      const VerificationMeta('xDocStateTransitionId');
  @override
  late final GeneratedColumn<BigInt> xDocStateTransitionId =
      GeneratedColumn<BigInt>(
        'x_doc_state_transition_id',
        aliasedName,
        false,
        hasAutoIncrement: true,
        type: DriftSqlType.bigInt,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'PRIMARY KEY AUTOINCREMENT',
        ),
      );
  static const VerificationMeta _channelStateNameMeta = const VerificationMeta(
    'channelStateName',
  );
  @override
  late final GeneratedColumn<String> channelStateName = GeneratedColumn<String>(
    'channel_state_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 63,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xDocActorIdMeta = const VerificationMeta(
    'xDocActorId',
  );
  @override
  late final GeneratedColumn<BigInt> xDocActorId = GeneratedColumn<BigInt>(
    'x_doc_actor_id',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelStateIdMeta = const VerificationMeta(
    'channelStateId',
  );
  @override
  late final GeneratedColumn<BigInt> channelStateId = GeneratedColumn<BigInt>(
    'channel_state_id',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryTimeMeta = const VerificationMeta(
    'entryTime',
  );
  @override
  late final GeneratedColumn<DateTime> entryTime = GeneratedColumn<DateTime>(
    'entry_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exitTimeMeta = const VerificationMeta(
    'exitTime',
  );
  @override
  late final GeneratedColumn<DateTime> exitTime = GeneratedColumn<DateTime>(
    'exit_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    mtdsClientTs,
    mtdsServerTs,
    mtdsDeviceId,
    mtdsDeleteTs,
    xDocStateTransitionId,
    channelStateName,
    xDocActorId,
    channelStateId,
    entryTime,
    exitTime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'x_doc_state_transitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<XDocStateTransition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mtds_client_ts')) {
      context.handle(
        _mtdsClientTsMeta,
        mtdsClientTs.isAcceptableOrUnknown(
          data['mtds_client_ts']!,
          _mtdsClientTsMeta,
        ),
      );
    }
    if (data.containsKey('mtds_server_ts')) {
      context.handle(
        _mtdsServerTsMeta,
        mtdsServerTs.isAcceptableOrUnknown(
          data['mtds_server_ts']!,
          _mtdsServerTsMeta,
        ),
      );
    }
    if (data.containsKey('mtds_device_id')) {
      context.handle(
        _mtdsDeviceIdMeta,
        mtdsDeviceId.isAcceptableOrUnknown(
          data['mtds_device_id']!,
          _mtdsDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('mtds_delete_ts')) {
      context.handle(
        _mtdsDeleteTsMeta,
        mtdsDeleteTs.isAcceptableOrUnknown(
          data['mtds_delete_ts']!,
          _mtdsDeleteTsMeta,
        ),
      );
    }
    if (data.containsKey('x_doc_state_transition_id')) {
      context.handle(
        _xDocStateTransitionIdMeta,
        xDocStateTransitionId.isAcceptableOrUnknown(
          data['x_doc_state_transition_id']!,
          _xDocStateTransitionIdMeta,
        ),
      );
    }
    if (data.containsKey('channel_state_name')) {
      context.handle(
        _channelStateNameMeta,
        channelStateName.isAcceptableOrUnknown(
          data['channel_state_name']!,
          _channelStateNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_channelStateNameMeta);
    }
    if (data.containsKey('x_doc_actor_id')) {
      context.handle(
        _xDocActorIdMeta,
        xDocActorId.isAcceptableOrUnknown(
          data['x_doc_actor_id']!,
          _xDocActorIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_xDocActorIdMeta);
    }
    if (data.containsKey('channel_state_id')) {
      context.handle(
        _channelStateIdMeta,
        channelStateId.isAcceptableOrUnknown(
          data['channel_state_id']!,
          _channelStateIdMeta,
        ),
      );
    }
    if (data.containsKey('entry_time')) {
      context.handle(
        _entryTimeMeta,
        entryTime.isAcceptableOrUnknown(data['entry_time']!, _entryTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTimeMeta);
    }
    if (data.containsKey('exit_time')) {
      context.handle(
        _exitTimeMeta,
        exitTime.isAcceptableOrUnknown(data['exit_time']!, _exitTimeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {xDocStateTransitionId};
  @override
  XDocStateTransition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XDocStateTransition(
      mtdsClientTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_client_ts'],
      )!,
      mtdsServerTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_server_ts'],
      ),
      mtdsDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_device_id'],
      )!,
      mtdsDeleteTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_delete_ts'],
      ),
      xDocStateTransitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}x_doc_state_transition_id'],
      )!,
      channelStateName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_state_name'],
      )!,
      xDocActorId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}x_doc_actor_id'],
      )!,
      channelStateId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}channel_state_id'],
      ),
      entryTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entry_time'],
      )!,
      exitTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}exit_time'],
      ),
    );
  }

  @override
  $XDocStateTransitionsTable createAlias(String alias) {
    return $XDocStateTransitionsTable(attachedDatabase, alias);
  }
}

class XDocStateTransition extends DataClass
    implements Insertable<XDocStateTransition> {
  /// Client-generated timestamp in milliseconds since client epoch.
  /// Always present with a default of 0 so change detection never hits NULL.
  final BigInt mtdsClientTs;

  /// Server-assigned authoritative timestamp in nanoseconds since epoch (NodeJS HR based).
  /// NULL until the record is synced to server.
  final BigInt? mtdsServerTs;

  /// 64-bit device identifier used for replication guardrails.
  /// Always present with a default of 0; SDK overwrites it on each write.
  final BigInt mtdsDeviceId;

  /// Soft-delete marker (NULL = active, non-null = deleted at timestamp in milliseconds since client epoch)
  final BigInt? mtdsDeleteTs;
  final BigInt xDocStateTransitionId;
  final String channelStateName;
  final BigInt xDocActorId;
  final BigInt? channelStateId;
  final DateTime entryTime;
  final DateTime? exitTime;
  const XDocStateTransition({
    required this.mtdsClientTs,
    this.mtdsServerTs,
    required this.mtdsDeviceId,
    this.mtdsDeleteTs,
    required this.xDocStateTransitionId,
    required this.channelStateName,
    required this.xDocActorId,
    this.channelStateId,
    required this.entryTime,
    this.exitTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['mtds_client_ts'] = Variable<BigInt>(mtdsClientTs);
    if (!nullToAbsent || mtdsServerTs != null) {
      map['mtds_server_ts'] = Variable<BigInt>(mtdsServerTs);
    }
    map['mtds_device_id'] = Variable<BigInt>(mtdsDeviceId);
    if (!nullToAbsent || mtdsDeleteTs != null) {
      map['mtds_delete_ts'] = Variable<BigInt>(mtdsDeleteTs);
    }
    map['x_doc_state_transition_id'] = Variable<BigInt>(xDocStateTransitionId);
    map['channel_state_name'] = Variable<String>(channelStateName);
    map['x_doc_actor_id'] = Variable<BigInt>(xDocActorId);
    if (!nullToAbsent || channelStateId != null) {
      map['channel_state_id'] = Variable<BigInt>(channelStateId);
    }
    map['entry_time'] = Variable<DateTime>(entryTime);
    if (!nullToAbsent || exitTime != null) {
      map['exit_time'] = Variable<DateTime>(exitTime);
    }
    return map;
  }

  XDocStateTransitionsCompanion toCompanion(bool nullToAbsent) {
    return XDocStateTransitionsCompanion(
      mtdsClientTs: Value(mtdsClientTs),
      mtdsServerTs: mtdsServerTs == null && nullToAbsent
          ? const Value.absent()
          : Value(mtdsServerTs),
      mtdsDeviceId: Value(mtdsDeviceId),
      mtdsDeleteTs: mtdsDeleteTs == null && nullToAbsent
          ? const Value.absent()
          : Value(mtdsDeleteTs),
      xDocStateTransitionId: Value(xDocStateTransitionId),
      channelStateName: Value(channelStateName),
      xDocActorId: Value(xDocActorId),
      channelStateId: channelStateId == null && nullToAbsent
          ? const Value.absent()
          : Value(channelStateId),
      entryTime: Value(entryTime),
      exitTime: exitTime == null && nullToAbsent
          ? const Value.absent()
          : Value(exitTime),
    );
  }

  factory XDocStateTransition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XDocStateTransition(
      mtdsClientTs: serializer.fromJson<BigInt>(json['mtdsClientTs']),
      mtdsServerTs: serializer.fromJson<BigInt?>(json['mtdsServerTs']),
      mtdsDeviceId: serializer.fromJson<BigInt>(json['mtdsDeviceId']),
      mtdsDeleteTs: serializer.fromJson<BigInt?>(json['mtdsDeleteTs']),
      xDocStateTransitionId: serializer.fromJson<BigInt>(
        json['xDocStateTransitionId'],
      ),
      channelStateName: serializer.fromJson<String>(json['channelStateName']),
      xDocActorId: serializer.fromJson<BigInt>(json['xDocActorId']),
      channelStateId: serializer.fromJson<BigInt?>(json['channelStateId']),
      entryTime: serializer.fromJson<DateTime>(json['entryTime']),
      exitTime: serializer.fromJson<DateTime?>(json['exitTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mtdsClientTs': serializer.toJson<BigInt>(mtdsClientTs),
      'mtdsServerTs': serializer.toJson<BigInt?>(mtdsServerTs),
      'mtdsDeviceId': serializer.toJson<BigInt>(mtdsDeviceId),
      'mtdsDeleteTs': serializer.toJson<BigInt?>(mtdsDeleteTs),
      'xDocStateTransitionId': serializer.toJson<BigInt>(xDocStateTransitionId),
      'channelStateName': serializer.toJson<String>(channelStateName),
      'xDocActorId': serializer.toJson<BigInt>(xDocActorId),
      'channelStateId': serializer.toJson<BigInt?>(channelStateId),
      'entryTime': serializer.toJson<DateTime>(entryTime),
      'exitTime': serializer.toJson<DateTime?>(exitTime),
    };
  }

  XDocStateTransition copyWith({
    BigInt? mtdsClientTs,
    Value<BigInt?> mtdsServerTs = const Value.absent(),
    BigInt? mtdsDeviceId,
    Value<BigInt?> mtdsDeleteTs = const Value.absent(),
    BigInt? xDocStateTransitionId,
    String? channelStateName,
    BigInt? xDocActorId,
    Value<BigInt?> channelStateId = const Value.absent(),
    DateTime? entryTime,
    Value<DateTime?> exitTime = const Value.absent(),
  }) => XDocStateTransition(
    mtdsClientTs: mtdsClientTs ?? this.mtdsClientTs,
    mtdsServerTs: mtdsServerTs.present ? mtdsServerTs.value : this.mtdsServerTs,
    mtdsDeviceId: mtdsDeviceId ?? this.mtdsDeviceId,
    mtdsDeleteTs: mtdsDeleteTs.present ? mtdsDeleteTs.value : this.mtdsDeleteTs,
    xDocStateTransitionId: xDocStateTransitionId ?? this.xDocStateTransitionId,
    channelStateName: channelStateName ?? this.channelStateName,
    xDocActorId: xDocActorId ?? this.xDocActorId,
    channelStateId: channelStateId.present
        ? channelStateId.value
        : this.channelStateId,
    entryTime: entryTime ?? this.entryTime,
    exitTime: exitTime.present ? exitTime.value : this.exitTime,
  );
  XDocStateTransition copyWithCompanion(XDocStateTransitionsCompanion data) {
    return XDocStateTransition(
      mtdsClientTs: data.mtdsClientTs.present
          ? data.mtdsClientTs.value
          : this.mtdsClientTs,
      mtdsServerTs: data.mtdsServerTs.present
          ? data.mtdsServerTs.value
          : this.mtdsServerTs,
      mtdsDeviceId: data.mtdsDeviceId.present
          ? data.mtdsDeviceId.value
          : this.mtdsDeviceId,
      mtdsDeleteTs: data.mtdsDeleteTs.present
          ? data.mtdsDeleteTs.value
          : this.mtdsDeleteTs,
      xDocStateTransitionId: data.xDocStateTransitionId.present
          ? data.xDocStateTransitionId.value
          : this.xDocStateTransitionId,
      channelStateName: data.channelStateName.present
          ? data.channelStateName.value
          : this.channelStateName,
      xDocActorId: data.xDocActorId.present
          ? data.xDocActorId.value
          : this.xDocActorId,
      channelStateId: data.channelStateId.present
          ? data.channelStateId.value
          : this.channelStateId,
      entryTime: data.entryTime.present ? data.entryTime.value : this.entryTime,
      exitTime: data.exitTime.present ? data.exitTime.value : this.exitTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XDocStateTransition(')
          ..write('mtdsClientTs: $mtdsClientTs, ')
          ..write('mtdsServerTs: $mtdsServerTs, ')
          ..write('mtdsDeviceId: $mtdsDeviceId, ')
          ..write('mtdsDeleteTs: $mtdsDeleteTs, ')
          ..write('xDocStateTransitionId: $xDocStateTransitionId, ')
          ..write('channelStateName: $channelStateName, ')
          ..write('xDocActorId: $xDocActorId, ')
          ..write('channelStateId: $channelStateId, ')
          ..write('entryTime: $entryTime, ')
          ..write('exitTime: $exitTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mtdsClientTs,
    mtdsServerTs,
    mtdsDeviceId,
    mtdsDeleteTs,
    xDocStateTransitionId,
    channelStateName,
    xDocActorId,
    channelStateId,
    entryTime,
    exitTime,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XDocStateTransition &&
          other.mtdsClientTs == this.mtdsClientTs &&
          other.mtdsServerTs == this.mtdsServerTs &&
          other.mtdsDeviceId == this.mtdsDeviceId &&
          other.mtdsDeleteTs == this.mtdsDeleteTs &&
          other.xDocStateTransitionId == this.xDocStateTransitionId &&
          other.channelStateName == this.channelStateName &&
          other.xDocActorId == this.xDocActorId &&
          other.channelStateId == this.channelStateId &&
          other.entryTime == this.entryTime &&
          other.exitTime == this.exitTime);
}

class XDocStateTransitionsCompanion
    extends UpdateCompanion<XDocStateTransition> {
  final Value<BigInt> mtdsClientTs;
  final Value<BigInt?> mtdsServerTs;
  final Value<BigInt> mtdsDeviceId;
  final Value<BigInt?> mtdsDeleteTs;
  final Value<BigInt> xDocStateTransitionId;
  final Value<String> channelStateName;
  final Value<BigInt> xDocActorId;
  final Value<BigInt?> channelStateId;
  final Value<DateTime> entryTime;
  final Value<DateTime?> exitTime;
  const XDocStateTransitionsCompanion({
    this.mtdsClientTs = const Value.absent(),
    this.mtdsServerTs = const Value.absent(),
    this.mtdsDeviceId = const Value.absent(),
    this.mtdsDeleteTs = const Value.absent(),
    this.xDocStateTransitionId = const Value.absent(),
    this.channelStateName = const Value.absent(),
    this.xDocActorId = const Value.absent(),
    this.channelStateId = const Value.absent(),
    this.entryTime = const Value.absent(),
    this.exitTime = const Value.absent(),
  });
  XDocStateTransitionsCompanion.insert({
    this.mtdsClientTs = const Value.absent(),
    this.mtdsServerTs = const Value.absent(),
    this.mtdsDeviceId = const Value.absent(),
    this.mtdsDeleteTs = const Value.absent(),
    this.xDocStateTransitionId = const Value.absent(),
    required String channelStateName,
    required BigInt xDocActorId,
    this.channelStateId = const Value.absent(),
    required DateTime entryTime,
    this.exitTime = const Value.absent(),
  }) : channelStateName = Value(channelStateName),
       xDocActorId = Value(xDocActorId),
       entryTime = Value(entryTime);
  static Insertable<XDocStateTransition> custom({
    Expression<BigInt>? mtdsClientTs,
    Expression<BigInt>? mtdsServerTs,
    Expression<BigInt>? mtdsDeviceId,
    Expression<BigInt>? mtdsDeleteTs,
    Expression<BigInt>? xDocStateTransitionId,
    Expression<String>? channelStateName,
    Expression<BigInt>? xDocActorId,
    Expression<BigInt>? channelStateId,
    Expression<DateTime>? entryTime,
    Expression<DateTime>? exitTime,
  }) {
    return RawValuesInsertable({
      if (mtdsClientTs != null) 'mtds_client_ts': mtdsClientTs,
      if (mtdsServerTs != null) 'mtds_server_ts': mtdsServerTs,
      if (mtdsDeviceId != null) 'mtds_device_id': mtdsDeviceId,
      if (mtdsDeleteTs != null) 'mtds_delete_ts': mtdsDeleteTs,
      if (xDocStateTransitionId != null)
        'x_doc_state_transition_id': xDocStateTransitionId,
      if (channelStateName != null) 'channel_state_name': channelStateName,
      if (xDocActorId != null) 'x_doc_actor_id': xDocActorId,
      if (channelStateId != null) 'channel_state_id': channelStateId,
      if (entryTime != null) 'entry_time': entryTime,
      if (exitTime != null) 'exit_time': exitTime,
    });
  }

  XDocStateTransitionsCompanion copyWith({
    Value<BigInt>? mtdsClientTs,
    Value<BigInt?>? mtdsServerTs,
    Value<BigInt>? mtdsDeviceId,
    Value<BigInt?>? mtdsDeleteTs,
    Value<BigInt>? xDocStateTransitionId,
    Value<String>? channelStateName,
    Value<BigInt>? xDocActorId,
    Value<BigInt?>? channelStateId,
    Value<DateTime>? entryTime,
    Value<DateTime?>? exitTime,
  }) {
    return XDocStateTransitionsCompanion(
      mtdsClientTs: mtdsClientTs ?? this.mtdsClientTs,
      mtdsServerTs: mtdsServerTs ?? this.mtdsServerTs,
      mtdsDeviceId: mtdsDeviceId ?? this.mtdsDeviceId,
      mtdsDeleteTs: mtdsDeleteTs ?? this.mtdsDeleteTs,
      xDocStateTransitionId:
          xDocStateTransitionId ?? this.xDocStateTransitionId,
      channelStateName: channelStateName ?? this.channelStateName,
      xDocActorId: xDocActorId ?? this.xDocActorId,
      channelStateId: channelStateId ?? this.channelStateId,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mtdsClientTs.present) {
      map['mtds_client_ts'] = Variable<BigInt>(mtdsClientTs.value);
    }
    if (mtdsServerTs.present) {
      map['mtds_server_ts'] = Variable<BigInt>(mtdsServerTs.value);
    }
    if (mtdsDeviceId.present) {
      map['mtds_device_id'] = Variable<BigInt>(mtdsDeviceId.value);
    }
    if (mtdsDeleteTs.present) {
      map['mtds_delete_ts'] = Variable<BigInt>(mtdsDeleteTs.value);
    }
    if (xDocStateTransitionId.present) {
      map['x_doc_state_transition_id'] = Variable<BigInt>(
        xDocStateTransitionId.value,
      );
    }
    if (channelStateName.present) {
      map['channel_state_name'] = Variable<String>(channelStateName.value);
    }
    if (xDocActorId.present) {
      map['x_doc_actor_id'] = Variable<BigInt>(xDocActorId.value);
    }
    if (channelStateId.present) {
      map['channel_state_id'] = Variable<BigInt>(channelStateId.value);
    }
    if (entryTime.present) {
      map['entry_time'] = Variable<DateTime>(entryTime.value);
    }
    if (exitTime.present) {
      map['exit_time'] = Variable<DateTime>(exitTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XDocStateTransitionsCompanion(')
          ..write('mtdsClientTs: $mtdsClientTs, ')
          ..write('mtdsServerTs: $mtdsServerTs, ')
          ..write('mtdsDeviceId: $mtdsDeviceId, ')
          ..write('mtdsDeleteTs: $mtdsDeleteTs, ')
          ..write('xDocStateTransitionId: $xDocStateTransitionId, ')
          ..write('channelStateName: $channelStateName, ')
          ..write('xDocActorId: $xDocActorId, ')
          ..write('channelStateId: $channelStateId, ')
          ..write('entryTime: $entryTime, ')
          ..write('exitTime: $exitTime')
          ..write(')'))
        .toString();
  }
}

class $XDocsTable extends XDocs with TableInfo<$XDocsTable, XDoc> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XDocsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mtdsClientTsMeta = const VerificationMeta(
    'mtdsClientTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsClientTs = GeneratedColumn<BigInt>(
    'mtds_client_ts',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
    defaultValue: Constant(BigInt.from(0)),
  );
  static const VerificationMeta _mtdsServerTsMeta = const VerificationMeta(
    'mtdsServerTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsServerTs = GeneratedColumn<BigInt>(
    'mtds_server_ts',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mtdsDeviceIdMeta = const VerificationMeta(
    'mtdsDeviceId',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsDeviceId = GeneratedColumn<BigInt>(
    'mtds_device_id',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
    defaultValue: Constant(BigInt.from(0)),
  );
  static const VerificationMeta _mtdsDeleteTsMeta = const VerificationMeta(
    'mtdsDeleteTs',
  );
  @override
  late final GeneratedColumn<BigInt> mtdsDeleteTs = GeneratedColumn<BigInt>(
    'mtds_delete_ts',
    aliasedName,
    true,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xDocIdMeta = const VerificationMeta('xDocId');
  @override
  late final GeneratedColumn<int> xDocId = GeneratedColumn<int>(
    'x_doc_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _interconnectIdMeta = const VerificationMeta(
    'interconnectId',
  );
  @override
  late final GeneratedColumn<int> interconnectId = GeneratedColumn<int>(
    'interconnect_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _docNameMeta = const VerificationMeta(
    'docName',
  );
  @override
  late final GeneratedColumn<String> docName = GeneratedColumn<String>(
    'doc_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 63),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contextDataMeta = const VerificationMeta(
    'contextData',
  );
  @override
  late final GeneratedColumn<String> contextData = GeneratedColumn<String>(
    'context_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completionTimeMeta = const VerificationMeta(
    'completionTime',
  );
  @override
  late final GeneratedColumn<String> completionTime = GeneratedColumn<String>(
    'completion_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _insertTimeMeta = const VerificationMeta(
    'insertTime',
  );
  @override
  late final GeneratedColumn<int> insertTime = GeneratedColumn<int>(
    'insert_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedTimeMeta = const VerificationMeta(
    'deletedTime',
  );
  @override
  late final GeneratedColumn<int> deletedTime = GeneratedColumn<int>(
    'deleted_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isNotDeletedMeta = const VerificationMeta(
    'isNotDeleted',
  );
  @override
  late final GeneratedColumn<int> isNotDeleted = GeneratedColumn<int>(
    'is_not_deleted',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    mtdsClientTs,
    mtdsServerTs,
    mtdsDeviceId,
    mtdsDeleteTs,
    xDocId,
    interconnectId,
    docName,
    contextData,
    startTime,
    completionTime,
    insertTime,
    deletedTime,
    isNotDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'x_docs';
  @override
  VerificationContext validateIntegrity(
    Insertable<XDoc> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mtds_client_ts')) {
      context.handle(
        _mtdsClientTsMeta,
        mtdsClientTs.isAcceptableOrUnknown(
          data['mtds_client_ts']!,
          _mtdsClientTsMeta,
        ),
      );
    }
    if (data.containsKey('mtds_server_ts')) {
      context.handle(
        _mtdsServerTsMeta,
        mtdsServerTs.isAcceptableOrUnknown(
          data['mtds_server_ts']!,
          _mtdsServerTsMeta,
        ),
      );
    }
    if (data.containsKey('mtds_device_id')) {
      context.handle(
        _mtdsDeviceIdMeta,
        mtdsDeviceId.isAcceptableOrUnknown(
          data['mtds_device_id']!,
          _mtdsDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('mtds_delete_ts')) {
      context.handle(
        _mtdsDeleteTsMeta,
        mtdsDeleteTs.isAcceptableOrUnknown(
          data['mtds_delete_ts']!,
          _mtdsDeleteTsMeta,
        ),
      );
    }
    if (data.containsKey('x_doc_id')) {
      context.handle(
        _xDocIdMeta,
        xDocId.isAcceptableOrUnknown(data['x_doc_id']!, _xDocIdMeta),
      );
    }
    if (data.containsKey('interconnect_id')) {
      context.handle(
        _interconnectIdMeta,
        interconnectId.isAcceptableOrUnknown(
          data['interconnect_id']!,
          _interconnectIdMeta,
        ),
      );
    }
    if (data.containsKey('doc_name')) {
      context.handle(
        _docNameMeta,
        docName.isAcceptableOrUnknown(data['doc_name']!, _docNameMeta),
      );
    }
    if (data.containsKey('context_data')) {
      context.handle(
        _contextDataMeta,
        contextData.isAcceptableOrUnknown(
          data['context_data']!,
          _contextDataMeta,
        ),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('completion_time')) {
      context.handle(
        _completionTimeMeta,
        completionTime.isAcceptableOrUnknown(
          data['completion_time']!,
          _completionTimeMeta,
        ),
      );
    }
    if (data.containsKey('insert_time')) {
      context.handle(
        _insertTimeMeta,
        insertTime.isAcceptableOrUnknown(data['insert_time']!, _insertTimeMeta),
      );
    }
    if (data.containsKey('deleted_time')) {
      context.handle(
        _deletedTimeMeta,
        deletedTime.isAcceptableOrUnknown(
          data['deleted_time']!,
          _deletedTimeMeta,
        ),
      );
    }
    if (data.containsKey('is_not_deleted')) {
      context.handle(
        _isNotDeletedMeta,
        isNotDeleted.isAcceptableOrUnknown(
          data['is_not_deleted']!,
          _isNotDeletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {xDocId};
  @override
  XDoc map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XDoc(
      mtdsClientTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_client_ts'],
      )!,
      mtdsServerTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_server_ts'],
      ),
      mtdsDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_device_id'],
      )!,
      mtdsDeleteTs: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}mtds_delete_ts'],
      ),
      xDocId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}x_doc_id'],
      )!,
      interconnectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interconnect_id'],
      ),
      docName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_name'],
      ),
      contextData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_data'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      ),
      completionTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completion_time'],
      ),
      insertTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}insert_time'],
      ),
      deletedTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_time'],
      ),
      isNotDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_not_deleted'],
      )!,
    );
  }

  @override
  $XDocsTable createAlias(String alias) {
    return $XDocsTable(attachedDatabase, alias);
  }
}

class XDoc extends DataClass implements Insertable<XDoc> {
  /// Client-generated timestamp in milliseconds since client epoch.
  /// Always present with a default of 0 so change detection never hits NULL.
  final BigInt mtdsClientTs;

  /// Server-assigned authoritative timestamp in nanoseconds since epoch (NodeJS HR based).
  /// NULL until the record is synced to server.
  final BigInt? mtdsServerTs;

  /// 64-bit device identifier used for replication guardrails.
  /// Always present with a default of 0; SDK overwrites it on each write.
  final BigInt mtdsDeviceId;

  /// Soft-delete marker (NULL = active, non-null = deleted at timestamp in milliseconds since client epoch)
  final BigInt? mtdsDeleteTs;
  final int xDocId;
  final int? interconnectId;
  final String? docName;
  final String? contextData;
  final String? startTime;
  final String? completionTime;
  final int? insertTime;
  final int? deletedTime;
  final int isNotDeleted;
  const XDoc({
    required this.mtdsClientTs,
    this.mtdsServerTs,
    required this.mtdsDeviceId,
    this.mtdsDeleteTs,
    required this.xDocId,
    this.interconnectId,
    this.docName,
    this.contextData,
    this.startTime,
    this.completionTime,
    this.insertTime,
    this.deletedTime,
    required this.isNotDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['mtds_client_ts'] = Variable<BigInt>(mtdsClientTs);
    if (!nullToAbsent || mtdsServerTs != null) {
      map['mtds_server_ts'] = Variable<BigInt>(mtdsServerTs);
    }
    map['mtds_device_id'] = Variable<BigInt>(mtdsDeviceId);
    if (!nullToAbsent || mtdsDeleteTs != null) {
      map['mtds_delete_ts'] = Variable<BigInt>(mtdsDeleteTs);
    }
    map['x_doc_id'] = Variable<int>(xDocId);
    if (!nullToAbsent || interconnectId != null) {
      map['interconnect_id'] = Variable<int>(interconnectId);
    }
    if (!nullToAbsent || docName != null) {
      map['doc_name'] = Variable<String>(docName);
    }
    if (!nullToAbsent || contextData != null) {
      map['context_data'] = Variable<String>(contextData);
    }
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<String>(startTime);
    }
    if (!nullToAbsent || completionTime != null) {
      map['completion_time'] = Variable<String>(completionTime);
    }
    if (!nullToAbsent || insertTime != null) {
      map['insert_time'] = Variable<int>(insertTime);
    }
    if (!nullToAbsent || deletedTime != null) {
      map['deleted_time'] = Variable<int>(deletedTime);
    }
    map['is_not_deleted'] = Variable<int>(isNotDeleted);
    return map;
  }

  XDocsCompanion toCompanion(bool nullToAbsent) {
    return XDocsCompanion(
      mtdsClientTs: Value(mtdsClientTs),
      mtdsServerTs: mtdsServerTs == null && nullToAbsent
          ? const Value.absent()
          : Value(mtdsServerTs),
      mtdsDeviceId: Value(mtdsDeviceId),
      mtdsDeleteTs: mtdsDeleteTs == null && nullToAbsent
          ? const Value.absent()
          : Value(mtdsDeleteTs),
      xDocId: Value(xDocId),
      interconnectId: interconnectId == null && nullToAbsent
          ? const Value.absent()
          : Value(interconnectId),
      docName: docName == null && nullToAbsent
          ? const Value.absent()
          : Value(docName),
      contextData: contextData == null && nullToAbsent
          ? const Value.absent()
          : Value(contextData),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      completionTime: completionTime == null && nullToAbsent
          ? const Value.absent()
          : Value(completionTime),
      insertTime: insertTime == null && nullToAbsent
          ? const Value.absent()
          : Value(insertTime),
      deletedTime: deletedTime == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedTime),
      isNotDeleted: Value(isNotDeleted),
    );
  }

  factory XDoc.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XDoc(
      mtdsClientTs: serializer.fromJson<BigInt>(json['mtdsClientTs']),
      mtdsServerTs: serializer.fromJson<BigInt?>(json['mtdsServerTs']),
      mtdsDeviceId: serializer.fromJson<BigInt>(json['mtdsDeviceId']),
      mtdsDeleteTs: serializer.fromJson<BigInt?>(json['mtdsDeleteTs']),
      xDocId: serializer.fromJson<int>(json['xDocId']),
      interconnectId: serializer.fromJson<int?>(json['interconnectId']),
      docName: serializer.fromJson<String?>(json['docName']),
      contextData: serializer.fromJson<String?>(json['contextData']),
      startTime: serializer.fromJson<String?>(json['startTime']),
      completionTime: serializer.fromJson<String?>(json['completionTime']),
      insertTime: serializer.fromJson<int?>(json['insertTime']),
      deletedTime: serializer.fromJson<int?>(json['deletedTime']),
      isNotDeleted: serializer.fromJson<int>(json['isNotDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mtdsClientTs': serializer.toJson<BigInt>(mtdsClientTs),
      'mtdsServerTs': serializer.toJson<BigInt?>(mtdsServerTs),
      'mtdsDeviceId': serializer.toJson<BigInt>(mtdsDeviceId),
      'mtdsDeleteTs': serializer.toJson<BigInt?>(mtdsDeleteTs),
      'xDocId': serializer.toJson<int>(xDocId),
      'interconnectId': serializer.toJson<int?>(interconnectId),
      'docName': serializer.toJson<String?>(docName),
      'contextData': serializer.toJson<String?>(contextData),
      'startTime': serializer.toJson<String?>(startTime),
      'completionTime': serializer.toJson<String?>(completionTime),
      'insertTime': serializer.toJson<int?>(insertTime),
      'deletedTime': serializer.toJson<int?>(deletedTime),
      'isNotDeleted': serializer.toJson<int>(isNotDeleted),
    };
  }

  XDoc copyWith({
    BigInt? mtdsClientTs,
    Value<BigInt?> mtdsServerTs = const Value.absent(),
    BigInt? mtdsDeviceId,
    Value<BigInt?> mtdsDeleteTs = const Value.absent(),
    int? xDocId,
    Value<int?> interconnectId = const Value.absent(),
    Value<String?> docName = const Value.absent(),
    Value<String?> contextData = const Value.absent(),
    Value<String?> startTime = const Value.absent(),
    Value<String?> completionTime = const Value.absent(),
    Value<int?> insertTime = const Value.absent(),
    Value<int?> deletedTime = const Value.absent(),
    int? isNotDeleted,
  }) => XDoc(
    mtdsClientTs: mtdsClientTs ?? this.mtdsClientTs,
    mtdsServerTs: mtdsServerTs.present ? mtdsServerTs.value : this.mtdsServerTs,
    mtdsDeviceId: mtdsDeviceId ?? this.mtdsDeviceId,
    mtdsDeleteTs: mtdsDeleteTs.present ? mtdsDeleteTs.value : this.mtdsDeleteTs,
    xDocId: xDocId ?? this.xDocId,
    interconnectId: interconnectId.present
        ? interconnectId.value
        : this.interconnectId,
    docName: docName.present ? docName.value : this.docName,
    contextData: contextData.present ? contextData.value : this.contextData,
    startTime: startTime.present ? startTime.value : this.startTime,
    completionTime: completionTime.present
        ? completionTime.value
        : this.completionTime,
    insertTime: insertTime.present ? insertTime.value : this.insertTime,
    deletedTime: deletedTime.present ? deletedTime.value : this.deletedTime,
    isNotDeleted: isNotDeleted ?? this.isNotDeleted,
  );
  XDoc copyWithCompanion(XDocsCompanion data) {
    return XDoc(
      mtdsClientTs: data.mtdsClientTs.present
          ? data.mtdsClientTs.value
          : this.mtdsClientTs,
      mtdsServerTs: data.mtdsServerTs.present
          ? data.mtdsServerTs.value
          : this.mtdsServerTs,
      mtdsDeviceId: data.mtdsDeviceId.present
          ? data.mtdsDeviceId.value
          : this.mtdsDeviceId,
      mtdsDeleteTs: data.mtdsDeleteTs.present
          ? data.mtdsDeleteTs.value
          : this.mtdsDeleteTs,
      xDocId: data.xDocId.present ? data.xDocId.value : this.xDocId,
      interconnectId: data.interconnectId.present
          ? data.interconnectId.value
          : this.interconnectId,
      docName: data.docName.present ? data.docName.value : this.docName,
      contextData: data.contextData.present
          ? data.contextData.value
          : this.contextData,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      completionTime: data.completionTime.present
          ? data.completionTime.value
          : this.completionTime,
      insertTime: data.insertTime.present
          ? data.insertTime.value
          : this.insertTime,
      deletedTime: data.deletedTime.present
          ? data.deletedTime.value
          : this.deletedTime,
      isNotDeleted: data.isNotDeleted.present
          ? data.isNotDeleted.value
          : this.isNotDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XDoc(')
          ..write('mtdsClientTs: $mtdsClientTs, ')
          ..write('mtdsServerTs: $mtdsServerTs, ')
          ..write('mtdsDeviceId: $mtdsDeviceId, ')
          ..write('mtdsDeleteTs: $mtdsDeleteTs, ')
          ..write('xDocId: $xDocId, ')
          ..write('interconnectId: $interconnectId, ')
          ..write('docName: $docName, ')
          ..write('contextData: $contextData, ')
          ..write('startTime: $startTime, ')
          ..write('completionTime: $completionTime, ')
          ..write('insertTime: $insertTime, ')
          ..write('deletedTime: $deletedTime, ')
          ..write('isNotDeleted: $isNotDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mtdsClientTs,
    mtdsServerTs,
    mtdsDeviceId,
    mtdsDeleteTs,
    xDocId,
    interconnectId,
    docName,
    contextData,
    startTime,
    completionTime,
    insertTime,
    deletedTime,
    isNotDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XDoc &&
          other.mtdsClientTs == this.mtdsClientTs &&
          other.mtdsServerTs == this.mtdsServerTs &&
          other.mtdsDeviceId == this.mtdsDeviceId &&
          other.mtdsDeleteTs == this.mtdsDeleteTs &&
          other.xDocId == this.xDocId &&
          other.interconnectId == this.interconnectId &&
          other.docName == this.docName &&
          other.contextData == this.contextData &&
          other.startTime == this.startTime &&
          other.completionTime == this.completionTime &&
          other.insertTime == this.insertTime &&
          other.deletedTime == this.deletedTime &&
          other.isNotDeleted == this.isNotDeleted);
}

class XDocsCompanion extends UpdateCompanion<XDoc> {
  final Value<BigInt> mtdsClientTs;
  final Value<BigInt?> mtdsServerTs;
  final Value<BigInt> mtdsDeviceId;
  final Value<BigInt?> mtdsDeleteTs;
  final Value<int> xDocId;
  final Value<int?> interconnectId;
  final Value<String?> docName;
  final Value<String?> contextData;
  final Value<String?> startTime;
  final Value<String?> completionTime;
  final Value<int?> insertTime;
  final Value<int?> deletedTime;
  final Value<int> isNotDeleted;
  const XDocsCompanion({
    this.mtdsClientTs = const Value.absent(),
    this.mtdsServerTs = const Value.absent(),
    this.mtdsDeviceId = const Value.absent(),
    this.mtdsDeleteTs = const Value.absent(),
    this.xDocId = const Value.absent(),
    this.interconnectId = const Value.absent(),
    this.docName = const Value.absent(),
    this.contextData = const Value.absent(),
    this.startTime = const Value.absent(),
    this.completionTime = const Value.absent(),
    this.insertTime = const Value.absent(),
    this.deletedTime = const Value.absent(),
    this.isNotDeleted = const Value.absent(),
  });
  XDocsCompanion.insert({
    this.mtdsClientTs = const Value.absent(),
    this.mtdsServerTs = const Value.absent(),
    this.mtdsDeviceId = const Value.absent(),
    this.mtdsDeleteTs = const Value.absent(),
    this.xDocId = const Value.absent(),
    this.interconnectId = const Value.absent(),
    this.docName = const Value.absent(),
    this.contextData = const Value.absent(),
    this.startTime = const Value.absent(),
    this.completionTime = const Value.absent(),
    this.insertTime = const Value.absent(),
    this.deletedTime = const Value.absent(),
    this.isNotDeleted = const Value.absent(),
  });
  static Insertable<XDoc> custom({
    Expression<BigInt>? mtdsClientTs,
    Expression<BigInt>? mtdsServerTs,
    Expression<BigInt>? mtdsDeviceId,
    Expression<BigInt>? mtdsDeleteTs,
    Expression<int>? xDocId,
    Expression<int>? interconnectId,
    Expression<String>? docName,
    Expression<String>? contextData,
    Expression<String>? startTime,
    Expression<String>? completionTime,
    Expression<int>? insertTime,
    Expression<int>? deletedTime,
    Expression<int>? isNotDeleted,
  }) {
    return RawValuesInsertable({
      if (mtdsClientTs != null) 'mtds_client_ts': mtdsClientTs,
      if (mtdsServerTs != null) 'mtds_server_ts': mtdsServerTs,
      if (mtdsDeviceId != null) 'mtds_device_id': mtdsDeviceId,
      if (mtdsDeleteTs != null) 'mtds_delete_ts': mtdsDeleteTs,
      if (xDocId != null) 'x_doc_id': xDocId,
      if (interconnectId != null) 'interconnect_id': interconnectId,
      if (docName != null) 'doc_name': docName,
      if (contextData != null) 'context_data': contextData,
      if (startTime != null) 'start_time': startTime,
      if (completionTime != null) 'completion_time': completionTime,
      if (insertTime != null) 'insert_time': insertTime,
      if (deletedTime != null) 'deleted_time': deletedTime,
      if (isNotDeleted != null) 'is_not_deleted': isNotDeleted,
    });
  }

  XDocsCompanion copyWith({
    Value<BigInt>? mtdsClientTs,
    Value<BigInt?>? mtdsServerTs,
    Value<BigInt>? mtdsDeviceId,
    Value<BigInt?>? mtdsDeleteTs,
    Value<int>? xDocId,
    Value<int?>? interconnectId,
    Value<String?>? docName,
    Value<String?>? contextData,
    Value<String?>? startTime,
    Value<String?>? completionTime,
    Value<int?>? insertTime,
    Value<int?>? deletedTime,
    Value<int>? isNotDeleted,
  }) {
    return XDocsCompanion(
      mtdsClientTs: mtdsClientTs ?? this.mtdsClientTs,
      mtdsServerTs: mtdsServerTs ?? this.mtdsServerTs,
      mtdsDeviceId: mtdsDeviceId ?? this.mtdsDeviceId,
      mtdsDeleteTs: mtdsDeleteTs ?? this.mtdsDeleteTs,
      xDocId: xDocId ?? this.xDocId,
      interconnectId: interconnectId ?? this.interconnectId,
      docName: docName ?? this.docName,
      contextData: contextData ?? this.contextData,
      startTime: startTime ?? this.startTime,
      completionTime: completionTime ?? this.completionTime,
      insertTime: insertTime ?? this.insertTime,
      deletedTime: deletedTime ?? this.deletedTime,
      isNotDeleted: isNotDeleted ?? this.isNotDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mtdsClientTs.present) {
      map['mtds_client_ts'] = Variable<BigInt>(mtdsClientTs.value);
    }
    if (mtdsServerTs.present) {
      map['mtds_server_ts'] = Variable<BigInt>(mtdsServerTs.value);
    }
    if (mtdsDeviceId.present) {
      map['mtds_device_id'] = Variable<BigInt>(mtdsDeviceId.value);
    }
    if (mtdsDeleteTs.present) {
      map['mtds_delete_ts'] = Variable<BigInt>(mtdsDeleteTs.value);
    }
    if (xDocId.present) {
      map['x_doc_id'] = Variable<int>(xDocId.value);
    }
    if (interconnectId.present) {
      map['interconnect_id'] = Variable<int>(interconnectId.value);
    }
    if (docName.present) {
      map['doc_name'] = Variable<String>(docName.value);
    }
    if (contextData.present) {
      map['context_data'] = Variable<String>(contextData.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (completionTime.present) {
      map['completion_time'] = Variable<String>(completionTime.value);
    }
    if (insertTime.present) {
      map['insert_time'] = Variable<int>(insertTime.value);
    }
    if (deletedTime.present) {
      map['deleted_time'] = Variable<int>(deletedTime.value);
    }
    if (isNotDeleted.present) {
      map['is_not_deleted'] = Variable<int>(isNotDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XDocsCompanion(')
          ..write('mtdsClientTs: $mtdsClientTs, ')
          ..write('mtdsServerTs: $mtdsServerTs, ')
          ..write('mtdsDeviceId: $mtdsDeviceId, ')
          ..write('mtdsDeleteTs: $mtdsDeleteTs, ')
          ..write('xDocId: $xDocId, ')
          ..write('interconnectId: $interconnectId, ')
          ..write('docName: $docName, ')
          ..write('contextData: $contextData, ')
          ..write('startTime: $startTime, ')
          ..write('completionTime: $completionTime, ')
          ..write('insertTime: $insertTime, ')
          ..write('deletedTime: $deletedTime, ')
          ..write('isNotDeleted: $isNotDeleted')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChannelsTable channels = $ChannelsTable(this);
  late final $ChannelTagsTable channelTags = $ChannelTagsTable(this);
  late final $XDocActorsTable xDocActors = $XDocActorsTable(this);
  late final $XDocEventsTable xDocEvents = $XDocEventsTable(this);
  late final $XDocStateTransitionsTable xDocStateTransitions =
      $XDocStateTransitionsTable(this);
  late final $XDocsTable xDocs = $XDocsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    channels,
    channelTags,
    xDocActors,
    xDocEvents,
    xDocStateTransitions,
    xDocs,
  ];
}

typedef $$ChannelsTableCreateCompanionBuilder =
    ChannelsCompanion Function({
      Value<BigInt> mtdsClientTs,
      Value<BigInt?> mtdsServerTs,
      Value<BigInt> mtdsDeviceId,
      Value<BigInt?> mtdsDeleteTs,
      Value<int> channelId,
      required String channelName,
      required String channelDescription,
      Value<String> entityRoles,
      required BigInt actorSequence,
      Value<BigInt?> initialActorId,
      Value<BigInt?> otherActorId,
      Value<String?> contextTemplate,
      Value<bool> isTagRequired,
    });
typedef $$ChannelsTableUpdateCompanionBuilder =
    ChannelsCompanion Function({
      Value<BigInt> mtdsClientTs,
      Value<BigInt?> mtdsServerTs,
      Value<BigInt> mtdsDeviceId,
      Value<BigInt?> mtdsDeleteTs,
      Value<int> channelId,
      Value<String> channelName,
      Value<String> channelDescription,
      Value<String> entityRoles,
      Value<BigInt> actorSequence,
      Value<BigInt?> initialActorId,
      Value<BigInt?> otherActorId,
      Value<String?> contextTemplate,
      Value<bool> isTagRequired,
    });

class $$ChannelsTableFilterComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelName => $composableBuilder(
    column: $table.channelName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelDescription => $composableBuilder(
    column: $table.channelDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityRoles => $composableBuilder(
    column: $table.entityRoles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get actorSequence => $composableBuilder(
    column: $table.actorSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get initialActorId => $composableBuilder(
    column: $table.initialActorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get otherActorId => $composableBuilder(
    column: $table.otherActorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextTemplate => $composableBuilder(
    column: $table.contextTemplate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTagRequired => $composableBuilder(
    column: $table.isTagRequired,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChannelsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelName => $composableBuilder(
    column: $table.channelName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelDescription => $composableBuilder(
    column: $table.channelDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityRoles => $composableBuilder(
    column: $table.entityRoles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get actorSequence => $composableBuilder(
    column: $table.actorSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get initialActorId => $composableBuilder(
    column: $table.initialActorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get otherActorId => $composableBuilder(
    column: $table.otherActorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextTemplate => $composableBuilder(
    column: $table.contextTemplate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTagRequired => $composableBuilder(
    column: $table.isTagRequired,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChannelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<String> get channelName => $composableBuilder(
    column: $table.channelName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get channelDescription => $composableBuilder(
    column: $table.channelDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityRoles => $composableBuilder(
    column: $table.entityRoles,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get actorSequence => $composableBuilder(
    column: $table.actorSequence,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get initialActorId => $composableBuilder(
    column: $table.initialActorId,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get otherActorId => $composableBuilder(
    column: $table.otherActorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextTemplate => $composableBuilder(
    column: $table.contextTemplate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTagRequired => $composableBuilder(
    column: $table.isTagRequired,
    builder: (column) => column,
  );
}

class $$ChannelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChannelsTable,
          Channel,
          $$ChannelsTableFilterComposer,
          $$ChannelsTableOrderingComposer,
          $$ChannelsTableAnnotationComposer,
          $$ChannelsTableCreateCompanionBuilder,
          $$ChannelsTableUpdateCompanionBuilder,
          (Channel, BaseReferences<_$AppDatabase, $ChannelsTable, Channel>),
          Channel,
          PrefetchHooks Function()
        > {
  $$ChannelsTableTableManager(_$AppDatabase db, $ChannelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChannelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChannelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChannelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<BigInt> mtdsClientTs = const Value.absent(),
                Value<BigInt?> mtdsServerTs = const Value.absent(),
                Value<BigInt> mtdsDeviceId = const Value.absent(),
                Value<BigInt?> mtdsDeleteTs = const Value.absent(),
                Value<int> channelId = const Value.absent(),
                Value<String> channelName = const Value.absent(),
                Value<String> channelDescription = const Value.absent(),
                Value<String> entityRoles = const Value.absent(),
                Value<BigInt> actorSequence = const Value.absent(),
                Value<BigInt?> initialActorId = const Value.absent(),
                Value<BigInt?> otherActorId = const Value.absent(),
                Value<String?> contextTemplate = const Value.absent(),
                Value<bool> isTagRequired = const Value.absent(),
              }) => ChannelsCompanion(
                mtdsClientTs: mtdsClientTs,
                mtdsServerTs: mtdsServerTs,
                mtdsDeviceId: mtdsDeviceId,
                mtdsDeleteTs: mtdsDeleteTs,
                channelId: channelId,
                channelName: channelName,
                channelDescription: channelDescription,
                entityRoles: entityRoles,
                actorSequence: actorSequence,
                initialActorId: initialActorId,
                otherActorId: otherActorId,
                contextTemplate: contextTemplate,
                isTagRequired: isTagRequired,
              ),
          createCompanionCallback:
              ({
                Value<BigInt> mtdsClientTs = const Value.absent(),
                Value<BigInt?> mtdsServerTs = const Value.absent(),
                Value<BigInt> mtdsDeviceId = const Value.absent(),
                Value<BigInt?> mtdsDeleteTs = const Value.absent(),
                Value<int> channelId = const Value.absent(),
                required String channelName,
                required String channelDescription,
                Value<String> entityRoles = const Value.absent(),
                required BigInt actorSequence,
                Value<BigInt?> initialActorId = const Value.absent(),
                Value<BigInt?> otherActorId = const Value.absent(),
                Value<String?> contextTemplate = const Value.absent(),
                Value<bool> isTagRequired = const Value.absent(),
              }) => ChannelsCompanion.insert(
                mtdsClientTs: mtdsClientTs,
                mtdsServerTs: mtdsServerTs,
                mtdsDeviceId: mtdsDeviceId,
                mtdsDeleteTs: mtdsDeleteTs,
                channelId: channelId,
                channelName: channelName,
                channelDescription: channelDescription,
                entityRoles: entityRoles,
                actorSequence: actorSequence,
                initialActorId: initialActorId,
                otherActorId: otherActorId,
                contextTemplate: contextTemplate,
                isTagRequired: isTagRequired,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChannelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChannelsTable,
      Channel,
      $$ChannelsTableFilterComposer,
      $$ChannelsTableOrderingComposer,
      $$ChannelsTableAnnotationComposer,
      $$ChannelsTableCreateCompanionBuilder,
      $$ChannelsTableUpdateCompanionBuilder,
      (Channel, BaseReferences<_$AppDatabase, $ChannelsTable, Channel>),
      Channel,
      PrefetchHooks Function()
    >;
typedef $$ChannelTagsTableCreateCompanionBuilder =
    ChannelTagsCompanion Function({
      Value<BigInt> mtdsClientTs,
      Value<BigInt?> mtdsServerTs,
      Value<BigInt> mtdsDeviceId,
      Value<BigInt?> mtdsDeleteTs,
      Value<BigInt> channelTagId,
      required BigInt channelId,
      required String tag,
      Value<String?> tagDescription,
      Value<DateTime?> expireAt,
    });
typedef $$ChannelTagsTableUpdateCompanionBuilder =
    ChannelTagsCompanion Function({
      Value<BigInt> mtdsClientTs,
      Value<BigInt?> mtdsServerTs,
      Value<BigInt> mtdsDeviceId,
      Value<BigInt?> mtdsDeleteTs,
      Value<BigInt> channelTagId,
      Value<BigInt> channelId,
      Value<String> tag,
      Value<String?> tagDescription,
      Value<DateTime?> expireAt,
    });

class $$ChannelTagsTableFilterComposer
    extends Composer<_$AppDatabase, $ChannelTagsTable> {
  $$ChannelTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get channelTagId => $composableBuilder(
    column: $table.channelTagId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagDescription => $composableBuilder(
    column: $table.tagDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expireAt => $composableBuilder(
    column: $table.expireAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChannelTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChannelTagsTable> {
  $$ChannelTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get channelTagId => $composableBuilder(
    column: $table.channelTagId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagDescription => $composableBuilder(
    column: $table.tagDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expireAt => $composableBuilder(
    column: $table.expireAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChannelTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChannelTagsTable> {
  $$ChannelTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get channelTagId => $composableBuilder(
    column: $table.channelTagId,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<String> get tagDescription => $composableBuilder(
    column: $table.tagDescription,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expireAt =>
      $composableBuilder(column: $table.expireAt, builder: (column) => column);
}

class $$ChannelTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChannelTagsTable,
          ChannelTag,
          $$ChannelTagsTableFilterComposer,
          $$ChannelTagsTableOrderingComposer,
          $$ChannelTagsTableAnnotationComposer,
          $$ChannelTagsTableCreateCompanionBuilder,
          $$ChannelTagsTableUpdateCompanionBuilder,
          (
            ChannelTag,
            BaseReferences<_$AppDatabase, $ChannelTagsTable, ChannelTag>,
          ),
          ChannelTag,
          PrefetchHooks Function()
        > {
  $$ChannelTagsTableTableManager(_$AppDatabase db, $ChannelTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChannelTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChannelTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChannelTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<BigInt> mtdsClientTs = const Value.absent(),
                Value<BigInt?> mtdsServerTs = const Value.absent(),
                Value<BigInt> mtdsDeviceId = const Value.absent(),
                Value<BigInt?> mtdsDeleteTs = const Value.absent(),
                Value<BigInt> channelTagId = const Value.absent(),
                Value<BigInt> channelId = const Value.absent(),
                Value<String> tag = const Value.absent(),
                Value<String?> tagDescription = const Value.absent(),
                Value<DateTime?> expireAt = const Value.absent(),
              }) => ChannelTagsCompanion(
                mtdsClientTs: mtdsClientTs,
                mtdsServerTs: mtdsServerTs,
                mtdsDeviceId: mtdsDeviceId,
                mtdsDeleteTs: mtdsDeleteTs,
                channelTagId: channelTagId,
                channelId: channelId,
                tag: tag,
                tagDescription: tagDescription,
                expireAt: expireAt,
              ),
          createCompanionCallback:
              ({
                Value<BigInt> mtdsClientTs = const Value.absent(),
                Value<BigInt?> mtdsServerTs = const Value.absent(),
                Value<BigInt> mtdsDeviceId = const Value.absent(),
                Value<BigInt?> mtdsDeleteTs = const Value.absent(),
                Value<BigInt> channelTagId = const Value.absent(),
                required BigInt channelId,
                required String tag,
                Value<String?> tagDescription = const Value.absent(),
                Value<DateTime?> expireAt = const Value.absent(),
              }) => ChannelTagsCompanion.insert(
                mtdsClientTs: mtdsClientTs,
                mtdsServerTs: mtdsServerTs,
                mtdsDeviceId: mtdsDeviceId,
                mtdsDeleteTs: mtdsDeleteTs,
                channelTagId: channelTagId,
                channelId: channelId,
                tag: tag,
                tagDescription: tagDescription,
                expireAt: expireAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChannelTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChannelTagsTable,
      ChannelTag,
      $$ChannelTagsTableFilterComposer,
      $$ChannelTagsTableOrderingComposer,
      $$ChannelTagsTableAnnotationComposer,
      $$ChannelTagsTableCreateCompanionBuilder,
      $$ChannelTagsTableUpdateCompanionBuilder,
      (
        ChannelTag,
        BaseReferences<_$AppDatabase, $ChannelTagsTable, ChannelTag>,
      ),
      ChannelTag,
      PrefetchHooks Function()
    >;
typedef $$XDocActorsTableCreateCompanionBuilder =
    XDocActorsCompanion Function({
      Value<BigInt> mtdsClientTs,
      Value<BigInt?> mtdsServerTs,
      Value<BigInt> mtdsDeviceId,
      Value<BigInt?> mtdsDeleteTs,
      Value<BigInt> xDocActorId,
      required BigInt xDocId,
      required BigInt actorId,
      required BigInt channelId,
      Value<Uint8List?> encryptedSymmetricKey,
      Value<BigInt?> interconnectId,
      required String docName,
      required String contextData,
      required DateTime startTime,
      Value<DateTime?> completionTime,
    });
typedef $$XDocActorsTableUpdateCompanionBuilder =
    XDocActorsCompanion Function({
      Value<BigInt> mtdsClientTs,
      Value<BigInt?> mtdsServerTs,
      Value<BigInt> mtdsDeviceId,
      Value<BigInt?> mtdsDeleteTs,
      Value<BigInt> xDocActorId,
      Value<BigInt> xDocId,
      Value<BigInt> actorId,
      Value<BigInt> channelId,
      Value<Uint8List?> encryptedSymmetricKey,
      Value<BigInt?> interconnectId,
      Value<String> docName,
      Value<String> contextData,
      Value<DateTime> startTime,
      Value<DateTime?> completionTime,
    });

class $$XDocActorsTableFilterComposer
    extends Composer<_$AppDatabase, $XDocActorsTable> {
  $$XDocActorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get xDocActorId => $composableBuilder(
    column: $table.xDocActorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get xDocId => $composableBuilder(
    column: $table.xDocId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get encryptedSymmetricKey => $composableBuilder(
    column: $table.encryptedSymmetricKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get interconnectId => $composableBuilder(
    column: $table.interconnectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get docName => $composableBuilder(
    column: $table.docName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextData => $composableBuilder(
    column: $table.contextData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completionTime => $composableBuilder(
    column: $table.completionTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XDocActorsTableOrderingComposer
    extends Composer<_$AppDatabase, $XDocActorsTable> {
  $$XDocActorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get xDocActorId => $composableBuilder(
    column: $table.xDocActorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get xDocId => $composableBuilder(
    column: $table.xDocId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get encryptedSymmetricKey => $composableBuilder(
    column: $table.encryptedSymmetricKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get interconnectId => $composableBuilder(
    column: $table.interconnectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get docName => $composableBuilder(
    column: $table.docName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextData => $composableBuilder(
    column: $table.contextData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completionTime => $composableBuilder(
    column: $table.completionTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XDocActorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $XDocActorsTable> {
  $$XDocActorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get xDocActorId => $composableBuilder(
    column: $table.xDocActorId,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get xDocId =>
      $composableBuilder(column: $table.xDocId, builder: (column) => column);

  GeneratedColumn<BigInt> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<BigInt> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<Uint8List> get encryptedSymmetricKey => $composableBuilder(
    column: $table.encryptedSymmetricKey,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get interconnectId => $composableBuilder(
    column: $table.interconnectId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get docName =>
      $composableBuilder(column: $table.docName, builder: (column) => column);

  GeneratedColumn<String> get contextData => $composableBuilder(
    column: $table.contextData,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get completionTime => $composableBuilder(
    column: $table.completionTime,
    builder: (column) => column,
  );
}

class $$XDocActorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $XDocActorsTable,
          XDocActor,
          $$XDocActorsTableFilterComposer,
          $$XDocActorsTableOrderingComposer,
          $$XDocActorsTableAnnotationComposer,
          $$XDocActorsTableCreateCompanionBuilder,
          $$XDocActorsTableUpdateCompanionBuilder,
          (
            XDocActor,
            BaseReferences<_$AppDatabase, $XDocActorsTable, XDocActor>,
          ),
          XDocActor,
          PrefetchHooks Function()
        > {
  $$XDocActorsTableTableManager(_$AppDatabase db, $XDocActorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$XDocActorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XDocActorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$XDocActorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<BigInt> mtdsClientTs = const Value.absent(),
                Value<BigInt?> mtdsServerTs = const Value.absent(),
                Value<BigInt> mtdsDeviceId = const Value.absent(),
                Value<BigInt?> mtdsDeleteTs = const Value.absent(),
                Value<BigInt> xDocActorId = const Value.absent(),
                Value<BigInt> xDocId = const Value.absent(),
                Value<BigInt> actorId = const Value.absent(),
                Value<BigInt> channelId = const Value.absent(),
                Value<Uint8List?> encryptedSymmetricKey = const Value.absent(),
                Value<BigInt?> interconnectId = const Value.absent(),
                Value<String> docName = const Value.absent(),
                Value<String> contextData = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> completionTime = const Value.absent(),
              }) => XDocActorsCompanion(
                mtdsClientTs: mtdsClientTs,
                mtdsServerTs: mtdsServerTs,
                mtdsDeviceId: mtdsDeviceId,
                mtdsDeleteTs: mtdsDeleteTs,
                xDocActorId: xDocActorId,
                xDocId: xDocId,
                actorId: actorId,
                channelId: channelId,
                encryptedSymmetricKey: encryptedSymmetricKey,
                interconnectId: interconnectId,
                docName: docName,
                contextData: contextData,
                startTime: startTime,
                completionTime: completionTime,
              ),
          createCompanionCallback:
              ({
                Value<BigInt> mtdsClientTs = const Value.absent(),
                Value<BigInt?> mtdsServerTs = const Value.absent(),
                Value<BigInt> mtdsDeviceId = const Value.absent(),
                Value<BigInt?> mtdsDeleteTs = const Value.absent(),
                Value<BigInt> xDocActorId = const Value.absent(),
                required BigInt xDocId,
                required BigInt actorId,
                required BigInt channelId,
                Value<Uint8List?> encryptedSymmetricKey = const Value.absent(),
                Value<BigInt?> interconnectId = const Value.absent(),
                required String docName,
                required String contextData,
                required DateTime startTime,
                Value<DateTime?> completionTime = const Value.absent(),
              }) => XDocActorsCompanion.insert(
                mtdsClientTs: mtdsClientTs,
                mtdsServerTs: mtdsServerTs,
                mtdsDeviceId: mtdsDeviceId,
                mtdsDeleteTs: mtdsDeleteTs,
                xDocActorId: xDocActorId,
                xDocId: xDocId,
                actorId: actorId,
                channelId: channelId,
                encryptedSymmetricKey: encryptedSymmetricKey,
                interconnectId: interconnectId,
                docName: docName,
                contextData: contextData,
                startTime: startTime,
                completionTime: completionTime,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XDocActorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $XDocActorsTable,
      XDocActor,
      $$XDocActorsTableFilterComposer,
      $$XDocActorsTableOrderingComposer,
      $$XDocActorsTableAnnotationComposer,
      $$XDocActorsTableCreateCompanionBuilder,
      $$XDocActorsTableUpdateCompanionBuilder,
      (XDocActor, BaseReferences<_$AppDatabase, $XDocActorsTable, XDocActor>),
      XDocActor,
      PrefetchHooks Function()
    >;
typedef $$XDocEventsTableCreateCompanionBuilder =
    XDocEventsCompanion Function({
      Value<BigInt> mtdsClientTs,
      Value<BigInt?> mtdsServerTs,
      Value<BigInt> mtdsDeviceId,
      Value<BigInt?> mtdsDeleteTs,
      Value<BigInt> xDocEventId,
      required BigInt xDocActorId,
      Value<BigInt?> xDocId,
      Value<BigInt?> actorId,
      required String eventPayload,
      Value<String> contextData,
      required String entityRoles,
    });
typedef $$XDocEventsTableUpdateCompanionBuilder =
    XDocEventsCompanion Function({
      Value<BigInt> mtdsClientTs,
      Value<BigInt?> mtdsServerTs,
      Value<BigInt> mtdsDeviceId,
      Value<BigInt?> mtdsDeleteTs,
      Value<BigInt> xDocEventId,
      Value<BigInt> xDocActorId,
      Value<BigInt?> xDocId,
      Value<BigInt?> actorId,
      Value<String> eventPayload,
      Value<String> contextData,
      Value<String> entityRoles,
    });

class $$XDocEventsTableFilterComposer
    extends Composer<_$AppDatabase, $XDocEventsTable> {
  $$XDocEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get xDocEventId => $composableBuilder(
    column: $table.xDocEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get xDocActorId => $composableBuilder(
    column: $table.xDocActorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get xDocId => $composableBuilder(
    column: $table.xDocId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventPayload => $composableBuilder(
    column: $table.eventPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextData => $composableBuilder(
    column: $table.contextData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityRoles => $composableBuilder(
    column: $table.entityRoles,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XDocEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $XDocEventsTable> {
  $$XDocEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get xDocEventId => $composableBuilder(
    column: $table.xDocEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get xDocActorId => $composableBuilder(
    column: $table.xDocActorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get xDocId => $composableBuilder(
    column: $table.xDocId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventPayload => $composableBuilder(
    column: $table.eventPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextData => $composableBuilder(
    column: $table.contextData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityRoles => $composableBuilder(
    column: $table.entityRoles,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XDocEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $XDocEventsTable> {
  $$XDocEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get xDocEventId => $composableBuilder(
    column: $table.xDocEventId,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get xDocActorId => $composableBuilder(
    column: $table.xDocActorId,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get xDocId =>
      $composableBuilder(column: $table.xDocId, builder: (column) => column);

  GeneratedColumn<BigInt> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get eventPayload => $composableBuilder(
    column: $table.eventPayload,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextData => $composableBuilder(
    column: $table.contextData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityRoles => $composableBuilder(
    column: $table.entityRoles,
    builder: (column) => column,
  );
}

class $$XDocEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $XDocEventsTable,
          XDocEvent,
          $$XDocEventsTableFilterComposer,
          $$XDocEventsTableOrderingComposer,
          $$XDocEventsTableAnnotationComposer,
          $$XDocEventsTableCreateCompanionBuilder,
          $$XDocEventsTableUpdateCompanionBuilder,
          (
            XDocEvent,
            BaseReferences<_$AppDatabase, $XDocEventsTable, XDocEvent>,
          ),
          XDocEvent,
          PrefetchHooks Function()
        > {
  $$XDocEventsTableTableManager(_$AppDatabase db, $XDocEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$XDocEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XDocEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$XDocEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<BigInt> mtdsClientTs = const Value.absent(),
                Value<BigInt?> mtdsServerTs = const Value.absent(),
                Value<BigInt> mtdsDeviceId = const Value.absent(),
                Value<BigInt?> mtdsDeleteTs = const Value.absent(),
                Value<BigInt> xDocEventId = const Value.absent(),
                Value<BigInt> xDocActorId = const Value.absent(),
                Value<BigInt?> xDocId = const Value.absent(),
                Value<BigInt?> actorId = const Value.absent(),
                Value<String> eventPayload = const Value.absent(),
                Value<String> contextData = const Value.absent(),
                Value<String> entityRoles = const Value.absent(),
              }) => XDocEventsCompanion(
                mtdsClientTs: mtdsClientTs,
                mtdsServerTs: mtdsServerTs,
                mtdsDeviceId: mtdsDeviceId,
                mtdsDeleteTs: mtdsDeleteTs,
                xDocEventId: xDocEventId,
                xDocActorId: xDocActorId,
                xDocId: xDocId,
                actorId: actorId,
                eventPayload: eventPayload,
                contextData: contextData,
                entityRoles: entityRoles,
              ),
          createCompanionCallback:
              ({
                Value<BigInt> mtdsClientTs = const Value.absent(),
                Value<BigInt?> mtdsServerTs = const Value.absent(),
                Value<BigInt> mtdsDeviceId = const Value.absent(),
                Value<BigInt?> mtdsDeleteTs = const Value.absent(),
                Value<BigInt> xDocEventId = const Value.absent(),
                required BigInt xDocActorId,
                Value<BigInt?> xDocId = const Value.absent(),
                Value<BigInt?> actorId = const Value.absent(),
                required String eventPayload,
                Value<String> contextData = const Value.absent(),
                required String entityRoles,
              }) => XDocEventsCompanion.insert(
                mtdsClientTs: mtdsClientTs,
                mtdsServerTs: mtdsServerTs,
                mtdsDeviceId: mtdsDeviceId,
                mtdsDeleteTs: mtdsDeleteTs,
                xDocEventId: xDocEventId,
                xDocActorId: xDocActorId,
                xDocId: xDocId,
                actorId: actorId,
                eventPayload: eventPayload,
                contextData: contextData,
                entityRoles: entityRoles,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XDocEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $XDocEventsTable,
      XDocEvent,
      $$XDocEventsTableFilterComposer,
      $$XDocEventsTableOrderingComposer,
      $$XDocEventsTableAnnotationComposer,
      $$XDocEventsTableCreateCompanionBuilder,
      $$XDocEventsTableUpdateCompanionBuilder,
      (XDocEvent, BaseReferences<_$AppDatabase, $XDocEventsTable, XDocEvent>),
      XDocEvent,
      PrefetchHooks Function()
    >;
typedef $$XDocStateTransitionsTableCreateCompanionBuilder =
    XDocStateTransitionsCompanion Function({
      Value<BigInt> mtdsClientTs,
      Value<BigInt?> mtdsServerTs,
      Value<BigInt> mtdsDeviceId,
      Value<BigInt?> mtdsDeleteTs,
      Value<BigInt> xDocStateTransitionId,
      required String channelStateName,
      required BigInt xDocActorId,
      Value<BigInt?> channelStateId,
      required DateTime entryTime,
      Value<DateTime?> exitTime,
    });
typedef $$XDocStateTransitionsTableUpdateCompanionBuilder =
    XDocStateTransitionsCompanion Function({
      Value<BigInt> mtdsClientTs,
      Value<BigInt?> mtdsServerTs,
      Value<BigInt> mtdsDeviceId,
      Value<BigInt?> mtdsDeleteTs,
      Value<BigInt> xDocStateTransitionId,
      Value<String> channelStateName,
      Value<BigInt> xDocActorId,
      Value<BigInt?> channelStateId,
      Value<DateTime> entryTime,
      Value<DateTime?> exitTime,
    });

class $$XDocStateTransitionsTableFilterComposer
    extends Composer<_$AppDatabase, $XDocStateTransitionsTable> {
  $$XDocStateTransitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get xDocStateTransitionId => $composableBuilder(
    column: $table.xDocStateTransitionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelStateName => $composableBuilder(
    column: $table.channelStateName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get xDocActorId => $composableBuilder(
    column: $table.xDocActorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get channelStateId => $composableBuilder(
    column: $table.channelStateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get entryTime => $composableBuilder(
    column: $table.entryTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get exitTime => $composableBuilder(
    column: $table.exitTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XDocStateTransitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $XDocStateTransitionsTable> {
  $$XDocStateTransitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get xDocStateTransitionId => $composableBuilder(
    column: $table.xDocStateTransitionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelStateName => $composableBuilder(
    column: $table.channelStateName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get xDocActorId => $composableBuilder(
    column: $table.xDocActorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get channelStateId => $composableBuilder(
    column: $table.channelStateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get entryTime => $composableBuilder(
    column: $table.entryTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get exitTime => $composableBuilder(
    column: $table.exitTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XDocStateTransitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $XDocStateTransitionsTable> {
  $$XDocStateTransitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get xDocStateTransitionId => $composableBuilder(
    column: $table.xDocStateTransitionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get channelStateName => $composableBuilder(
    column: $table.channelStateName,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get xDocActorId => $composableBuilder(
    column: $table.xDocActorId,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get channelStateId => $composableBuilder(
    column: $table.channelStateId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get entryTime =>
      $composableBuilder(column: $table.entryTime, builder: (column) => column);

  GeneratedColumn<DateTime> get exitTime =>
      $composableBuilder(column: $table.exitTime, builder: (column) => column);
}

class $$XDocStateTransitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $XDocStateTransitionsTable,
          XDocStateTransition,
          $$XDocStateTransitionsTableFilterComposer,
          $$XDocStateTransitionsTableOrderingComposer,
          $$XDocStateTransitionsTableAnnotationComposer,
          $$XDocStateTransitionsTableCreateCompanionBuilder,
          $$XDocStateTransitionsTableUpdateCompanionBuilder,
          (
            XDocStateTransition,
            BaseReferences<
              _$AppDatabase,
              $XDocStateTransitionsTable,
              XDocStateTransition
            >,
          ),
          XDocStateTransition,
          PrefetchHooks Function()
        > {
  $$XDocStateTransitionsTableTableManager(
    _$AppDatabase db,
    $XDocStateTransitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$XDocStateTransitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XDocStateTransitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$XDocStateTransitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<BigInt> mtdsClientTs = const Value.absent(),
                Value<BigInt?> mtdsServerTs = const Value.absent(),
                Value<BigInt> mtdsDeviceId = const Value.absent(),
                Value<BigInt?> mtdsDeleteTs = const Value.absent(),
                Value<BigInt> xDocStateTransitionId = const Value.absent(),
                Value<String> channelStateName = const Value.absent(),
                Value<BigInt> xDocActorId = const Value.absent(),
                Value<BigInt?> channelStateId = const Value.absent(),
                Value<DateTime> entryTime = const Value.absent(),
                Value<DateTime?> exitTime = const Value.absent(),
              }) => XDocStateTransitionsCompanion(
                mtdsClientTs: mtdsClientTs,
                mtdsServerTs: mtdsServerTs,
                mtdsDeviceId: mtdsDeviceId,
                mtdsDeleteTs: mtdsDeleteTs,
                xDocStateTransitionId: xDocStateTransitionId,
                channelStateName: channelStateName,
                xDocActorId: xDocActorId,
                channelStateId: channelStateId,
                entryTime: entryTime,
                exitTime: exitTime,
              ),
          createCompanionCallback:
              ({
                Value<BigInt> mtdsClientTs = const Value.absent(),
                Value<BigInt?> mtdsServerTs = const Value.absent(),
                Value<BigInt> mtdsDeviceId = const Value.absent(),
                Value<BigInt?> mtdsDeleteTs = const Value.absent(),
                Value<BigInt> xDocStateTransitionId = const Value.absent(),
                required String channelStateName,
                required BigInt xDocActorId,
                Value<BigInt?> channelStateId = const Value.absent(),
                required DateTime entryTime,
                Value<DateTime?> exitTime = const Value.absent(),
              }) => XDocStateTransitionsCompanion.insert(
                mtdsClientTs: mtdsClientTs,
                mtdsServerTs: mtdsServerTs,
                mtdsDeviceId: mtdsDeviceId,
                mtdsDeleteTs: mtdsDeleteTs,
                xDocStateTransitionId: xDocStateTransitionId,
                channelStateName: channelStateName,
                xDocActorId: xDocActorId,
                channelStateId: channelStateId,
                entryTime: entryTime,
                exitTime: exitTime,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XDocStateTransitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $XDocStateTransitionsTable,
      XDocStateTransition,
      $$XDocStateTransitionsTableFilterComposer,
      $$XDocStateTransitionsTableOrderingComposer,
      $$XDocStateTransitionsTableAnnotationComposer,
      $$XDocStateTransitionsTableCreateCompanionBuilder,
      $$XDocStateTransitionsTableUpdateCompanionBuilder,
      (
        XDocStateTransition,
        BaseReferences<
          _$AppDatabase,
          $XDocStateTransitionsTable,
          XDocStateTransition
        >,
      ),
      XDocStateTransition,
      PrefetchHooks Function()
    >;
typedef $$XDocsTableCreateCompanionBuilder =
    XDocsCompanion Function({
      Value<BigInt> mtdsClientTs,
      Value<BigInt?> mtdsServerTs,
      Value<BigInt> mtdsDeviceId,
      Value<BigInt?> mtdsDeleteTs,
      Value<int> xDocId,
      Value<int?> interconnectId,
      Value<String?> docName,
      Value<String?> contextData,
      Value<String?> startTime,
      Value<String?> completionTime,
      Value<int?> insertTime,
      Value<int?> deletedTime,
      Value<int> isNotDeleted,
    });
typedef $$XDocsTableUpdateCompanionBuilder =
    XDocsCompanion Function({
      Value<BigInt> mtdsClientTs,
      Value<BigInt?> mtdsServerTs,
      Value<BigInt> mtdsDeviceId,
      Value<BigInt?> mtdsDeleteTs,
      Value<int> xDocId,
      Value<int?> interconnectId,
      Value<String?> docName,
      Value<String?> contextData,
      Value<String?> startTime,
      Value<String?> completionTime,
      Value<int?> insertTime,
      Value<int?> deletedTime,
      Value<int> isNotDeleted,
    });

class $$XDocsTableFilterComposer extends Composer<_$AppDatabase, $XDocsTable> {
  $$XDocsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xDocId => $composableBuilder(
    column: $table.xDocId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interconnectId => $composableBuilder(
    column: $table.interconnectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get docName => $composableBuilder(
    column: $table.docName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextData => $composableBuilder(
    column: $table.contextData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completionTime => $composableBuilder(
    column: $table.completionTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get insertTime => $composableBuilder(
    column: $table.insertTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedTime => $composableBuilder(
    column: $table.deletedTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isNotDeleted => $composableBuilder(
    column: $table.isNotDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XDocsTableOrderingComposer
    extends Composer<_$AppDatabase, $XDocsTable> {
  $$XDocsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xDocId => $composableBuilder(
    column: $table.xDocId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interconnectId => $composableBuilder(
    column: $table.interconnectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get docName => $composableBuilder(
    column: $table.docName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextData => $composableBuilder(
    column: $table.contextData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completionTime => $composableBuilder(
    column: $table.completionTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get insertTime => $composableBuilder(
    column: $table.insertTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedTime => $composableBuilder(
    column: $table.deletedTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isNotDeleted => $composableBuilder(
    column: $table.isNotDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XDocsTableAnnotationComposer
    extends Composer<_$AppDatabase, $XDocsTable> {
  $$XDocsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<BigInt> get mtdsClientTs => $composableBuilder(
    column: $table.mtdsClientTs,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsServerTs => $composableBuilder(
    column: $table.mtdsServerTs,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsDeviceId => $composableBuilder(
    column: $table.mtdsDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get mtdsDeleteTs => $composableBuilder(
    column: $table.mtdsDeleteTs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xDocId =>
      $composableBuilder(column: $table.xDocId, builder: (column) => column);

  GeneratedColumn<int> get interconnectId => $composableBuilder(
    column: $table.interconnectId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get docName =>
      $composableBuilder(column: $table.docName, builder: (column) => column);

  GeneratedColumn<String> get contextData => $composableBuilder(
    column: $table.contextData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get completionTime => $composableBuilder(
    column: $table.completionTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get insertTime => $composableBuilder(
    column: $table.insertTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedTime => $composableBuilder(
    column: $table.deletedTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isNotDeleted => $composableBuilder(
    column: $table.isNotDeleted,
    builder: (column) => column,
  );
}

class $$XDocsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $XDocsTable,
          XDoc,
          $$XDocsTableFilterComposer,
          $$XDocsTableOrderingComposer,
          $$XDocsTableAnnotationComposer,
          $$XDocsTableCreateCompanionBuilder,
          $$XDocsTableUpdateCompanionBuilder,
          (XDoc, BaseReferences<_$AppDatabase, $XDocsTable, XDoc>),
          XDoc,
          PrefetchHooks Function()
        > {
  $$XDocsTableTableManager(_$AppDatabase db, $XDocsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$XDocsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XDocsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$XDocsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<BigInt> mtdsClientTs = const Value.absent(),
                Value<BigInt?> mtdsServerTs = const Value.absent(),
                Value<BigInt> mtdsDeviceId = const Value.absent(),
                Value<BigInt?> mtdsDeleteTs = const Value.absent(),
                Value<int> xDocId = const Value.absent(),
                Value<int?> interconnectId = const Value.absent(),
                Value<String?> docName = const Value.absent(),
                Value<String?> contextData = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<String?> completionTime = const Value.absent(),
                Value<int?> insertTime = const Value.absent(),
                Value<int?> deletedTime = const Value.absent(),
                Value<int> isNotDeleted = const Value.absent(),
              }) => XDocsCompanion(
                mtdsClientTs: mtdsClientTs,
                mtdsServerTs: mtdsServerTs,
                mtdsDeviceId: mtdsDeviceId,
                mtdsDeleteTs: mtdsDeleteTs,
                xDocId: xDocId,
                interconnectId: interconnectId,
                docName: docName,
                contextData: contextData,
                startTime: startTime,
                completionTime: completionTime,
                insertTime: insertTime,
                deletedTime: deletedTime,
                isNotDeleted: isNotDeleted,
              ),
          createCompanionCallback:
              ({
                Value<BigInt> mtdsClientTs = const Value.absent(),
                Value<BigInt?> mtdsServerTs = const Value.absent(),
                Value<BigInt> mtdsDeviceId = const Value.absent(),
                Value<BigInt?> mtdsDeleteTs = const Value.absent(),
                Value<int> xDocId = const Value.absent(),
                Value<int?> interconnectId = const Value.absent(),
                Value<String?> docName = const Value.absent(),
                Value<String?> contextData = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<String?> completionTime = const Value.absent(),
                Value<int?> insertTime = const Value.absent(),
                Value<int?> deletedTime = const Value.absent(),
                Value<int> isNotDeleted = const Value.absent(),
              }) => XDocsCompanion.insert(
                mtdsClientTs: mtdsClientTs,
                mtdsServerTs: mtdsServerTs,
                mtdsDeviceId: mtdsDeviceId,
                mtdsDeleteTs: mtdsDeleteTs,
                xDocId: xDocId,
                interconnectId: interconnectId,
                docName: docName,
                contextData: contextData,
                startTime: startTime,
                completionTime: completionTime,
                insertTime: insertTime,
                deletedTime: deletedTime,
                isNotDeleted: isNotDeleted,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XDocsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $XDocsTable,
      XDoc,
      $$XDocsTableFilterComposer,
      $$XDocsTableOrderingComposer,
      $$XDocsTableAnnotationComposer,
      $$XDocsTableCreateCompanionBuilder,
      $$XDocsTableUpdateCompanionBuilder,
      (XDoc, BaseReferences<_$AppDatabase, $XDocsTable, XDoc>),
      XDoc,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChannelsTableTableManager get channels =>
      $$ChannelsTableTableManager(_db, _db.channels);
  $$ChannelTagsTableTableManager get channelTags =>
      $$ChannelTagsTableTableManager(_db, _db.channelTags);
  $$XDocActorsTableTableManager get xDocActors =>
      $$XDocActorsTableTableManager(_db, _db.xDocActors);
  $$XDocEventsTableTableManager get xDocEvents =>
      $$XDocEventsTableTableManager(_db, _db.xDocEvents);
  $$XDocStateTransitionsTableTableManager get xDocStateTransitions =>
      $$XDocStateTransitionsTableTableManager(_db, _db.xDocStateTransitions);
  $$XDocsTableTableManager get xDocs =>
      $$XDocsTableTableManager(_db, _db.xDocs);
}
