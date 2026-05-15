// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DownloadsTable extends Downloads
    with TableInfo<$DownloadsTable, DownloadRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountKeyMeta = const VerificationMeta(
    'accountKey',
  );
  @override
  late final GeneratedColumn<String> accountKey = GeneratedColumn<String>(
    'account_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(legacyAccountKey),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
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
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seriesNameMeta = const VerificationMeta(
    'seriesName',
  );
  @override
  late final GeneratedColumn<String> seriesName = GeneratedColumn<String>(
    'series_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonIdMeta = const VerificationMeta(
    'seasonId',
  );
  @override
  late final GeneratedColumn<String> seasonId = GeneratedColumn<String>(
    'season_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonNumberMeta = const VerificationMeta(
    'seasonNumber',
  );
  @override
  late final GeneratedColumn<int> seasonNumber = GeneratedColumn<int>(
    'season_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _episodeNumberMeta = const VerificationMeta(
    'episodeNumber',
  );
  @override
  late final GeneratedColumn<int> episodeNumber = GeneratedColumn<int>(
    'episode_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _runtimeTicksMeta = const VerificationMeta(
    'runtimeTicks',
  );
  @override
  late final GeneratedColumn<int> runtimeTicks = GeneratedColumn<int>(
    'runtime_ticks',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _backdropImagePathMeta = const VerificationMeta(
    'backdropImagePath',
  );
  @override
  late final GeneratedColumn<String> backdropImagePath =
      GeneratedColumn<String>(
        'backdrop_image_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _seriesImagePathMeta = const VerificationMeta(
    'seriesImagePath',
  );
  @override
  late final GeneratedColumn<String> seriesImagePath = GeneratedColumn<String>(
    'series_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overviewMeta = const VerificationMeta(
    'overview',
  );
  @override
  late final GeneratedColumn<String> overview = GeneratedColumn<String>(
    'overview',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productionYearMeta = const VerificationMeta(
    'productionYear',
  );
  @override
  late final GeneratedColumn<int> productionYear = GeneratedColumn<int>(
    'production_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _communityRatingMeta = const VerificationMeta(
    'communityRating',
  );
  @override
  late final GeneratedColumn<double> communityRating = GeneratedColumn<double>(
    'community_rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _officialRatingMeta = const VerificationMeta(
    'officialRating',
  );
  @override
  late final GeneratedColumn<String> officialRating = GeneratedColumn<String>(
    'official_rating',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genresMeta = const VerificationMeta('genres');
  @override
  late final GeneratedColumn<String> genres = GeneratedColumn<String>(
    'genres',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _containerMeta = const VerificationMeta(
    'container',
  );
  @override
  late final GeneratedColumn<String> container = GeneratedColumn<String>(
    'container',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DownloadStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DownloadStatus>($DownloadsTable.$converterstatus);
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    attempts,
    lastAttemptAt,
    nextRetryAt,
    lastError,
    accountKey,
    itemId,
    itemType,
    name,
    seriesId,
    seriesName,
    seasonId,
    seasonNumber,
    episodeNumber,
    runtimeTicks,
    imagePath,
    backdropImagePath,
    seriesImagePath,
    overview,
    productionYear,
    communityRating,
    officialRating,
    genres,
    localFilePath,
    container,
    sizeBytes,
    status,
    progress,
    taskId,
    errorMessage,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloads';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('account_key')) {
      context.handle(
        _accountKeyMeta,
        accountKey.isAcceptableOrUnknown(data['account_key']!, _accountKeyMeta),
      );
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('series_name')) {
      context.handle(
        _seriesNameMeta,
        seriesName.isAcceptableOrUnknown(data['series_name']!, _seriesNameMeta),
      );
    }
    if (data.containsKey('season_id')) {
      context.handle(
        _seasonIdMeta,
        seasonId.isAcceptableOrUnknown(data['season_id']!, _seasonIdMeta),
      );
    }
    if (data.containsKey('season_number')) {
      context.handle(
        _seasonNumberMeta,
        seasonNumber.isAcceptableOrUnknown(
          data['season_number']!,
          _seasonNumberMeta,
        ),
      );
    }
    if (data.containsKey('episode_number')) {
      context.handle(
        _episodeNumberMeta,
        episodeNumber.isAcceptableOrUnknown(
          data['episode_number']!,
          _episodeNumberMeta,
        ),
      );
    }
    if (data.containsKey('runtime_ticks')) {
      context.handle(
        _runtimeTicksMeta,
        runtimeTicks.isAcceptableOrUnknown(
          data['runtime_ticks']!,
          _runtimeTicksMeta,
        ),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('backdrop_image_path')) {
      context.handle(
        _backdropImagePathMeta,
        backdropImagePath.isAcceptableOrUnknown(
          data['backdrop_image_path']!,
          _backdropImagePathMeta,
        ),
      );
    }
    if (data.containsKey('series_image_path')) {
      context.handle(
        _seriesImagePathMeta,
        seriesImagePath.isAcceptableOrUnknown(
          data['series_image_path']!,
          _seriesImagePathMeta,
        ),
      );
    }
    if (data.containsKey('overview')) {
      context.handle(
        _overviewMeta,
        overview.isAcceptableOrUnknown(data['overview']!, _overviewMeta),
      );
    }
    if (data.containsKey('production_year')) {
      context.handle(
        _productionYearMeta,
        productionYear.isAcceptableOrUnknown(
          data['production_year']!,
          _productionYearMeta,
        ),
      );
    }
    if (data.containsKey('community_rating')) {
      context.handle(
        _communityRatingMeta,
        communityRating.isAcceptableOrUnknown(
          data['community_rating']!,
          _communityRatingMeta,
        ),
      );
    }
    if (data.containsKey('official_rating')) {
      context.handle(
        _officialRatingMeta,
        officialRating.isAcceptableOrUnknown(
          data['official_rating']!,
          _officialRatingMeta,
        ),
      );
    }
    if (data.containsKey('genres')) {
      context.handle(
        _genresMeta,
        genres.isAcceptableOrUnknown(data['genres']!, _genresMeta),
      );
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    }
    if (data.containsKey('container')) {
      context.handle(
        _containerMeta,
        container.isAcceptableOrUnknown(data['container']!, _containerMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountKey, itemId};
  @override
  DownloadRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadRow(
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      accountKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_key'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      ),
      seriesName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_name'],
      ),
      seasonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season_id'],
      ),
      seasonNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season_number'],
      ),
      episodeNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_number'],
      ),
      runtimeTicks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}runtime_ticks'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      backdropImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backdrop_image_path'],
      ),
      seriesImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_image_path'],
      ),
      overview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overview'],
      ),
      productionYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}production_year'],
      ),
      communityRating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}community_rating'],
      ),
      officialRating: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}official_rating'],
      ),
      genres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres'],
      ),
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      ),
      container: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}container'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      status: $DownloadsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $DownloadsTable createAlias(String alias) {
    return $DownloadsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DownloadStatus, String, String> $converterstatus =
      const EnumNameConverter<DownloadStatus>(DownloadStatus.values);
}

class DownloadRow extends DataClass implements Insertable<DownloadRow> {
  final int attempts;
  final DateTime? lastAttemptAt;
  final DateTime? nextRetryAt;
  final String? lastError;
  final String accountKey;
  final String itemId;
  final String itemType;
  final String name;
  final String? seriesId;
  final String? seriesName;
  final String? seasonId;
  final int? seasonNumber;
  final int? episodeNumber;
  final int? runtimeTicks;
  final String? imagePath;
  final String? backdropImagePath;
  final String? seriesImagePath;
  final String? overview;
  final int? productionYear;
  final double? communityRating;
  final String? officialRating;
  final String? genres;
  final String? localFilePath;
  final String? container;
  final int? sizeBytes;
  final DownloadStatus status;
  final double progress;
  final String? taskId;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;
  const DownloadRow({
    required this.attempts,
    this.lastAttemptAt,
    this.nextRetryAt,
    this.lastError,
    required this.accountKey,
    required this.itemId,
    required this.itemType,
    required this.name,
    this.seriesId,
    this.seriesName,
    this.seasonId,
    this.seasonNumber,
    this.episodeNumber,
    this.runtimeTicks,
    this.imagePath,
    this.backdropImagePath,
    this.seriesImagePath,
    this.overview,
    this.productionYear,
    this.communityRating,
    this.officialRating,
    this.genres,
    this.localFilePath,
    this.container,
    this.sizeBytes,
    required this.status,
    required this.progress,
    this.taskId,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['account_key'] = Variable<String>(accountKey);
    map['item_id'] = Variable<String>(itemId);
    map['item_type'] = Variable<String>(itemType);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<String>(seriesId);
    }
    if (!nullToAbsent || seriesName != null) {
      map['series_name'] = Variable<String>(seriesName);
    }
    if (!nullToAbsent || seasonId != null) {
      map['season_id'] = Variable<String>(seasonId);
    }
    if (!nullToAbsent || seasonNumber != null) {
      map['season_number'] = Variable<int>(seasonNumber);
    }
    if (!nullToAbsent || episodeNumber != null) {
      map['episode_number'] = Variable<int>(episodeNumber);
    }
    if (!nullToAbsent || runtimeTicks != null) {
      map['runtime_ticks'] = Variable<int>(runtimeTicks);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || backdropImagePath != null) {
      map['backdrop_image_path'] = Variable<String>(backdropImagePath);
    }
    if (!nullToAbsent || seriesImagePath != null) {
      map['series_image_path'] = Variable<String>(seriesImagePath);
    }
    if (!nullToAbsent || overview != null) {
      map['overview'] = Variable<String>(overview);
    }
    if (!nullToAbsent || productionYear != null) {
      map['production_year'] = Variable<int>(productionYear);
    }
    if (!nullToAbsent || communityRating != null) {
      map['community_rating'] = Variable<double>(communityRating);
    }
    if (!nullToAbsent || officialRating != null) {
      map['official_rating'] = Variable<String>(officialRating);
    }
    if (!nullToAbsent || genres != null) {
      map['genres'] = Variable<String>(genres);
    }
    if (!nullToAbsent || localFilePath != null) {
      map['local_file_path'] = Variable<String>(localFilePath);
    }
    if (!nullToAbsent || container != null) {
      map['container'] = Variable<String>(container);
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    {
      map['status'] = Variable<String>(
        $DownloadsTable.$converterstatus.toSql(status),
      );
    }
    map['progress'] = Variable<double>(progress);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  DownloadsCompanion toCompanion(bool nullToAbsent) {
    return DownloadsCompanion(
      attempts: Value(attempts),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      accountKey: Value(accountKey),
      itemId: Value(itemId),
      itemType: Value(itemType),
      name: Value(name),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      seriesName: seriesName == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesName),
      seasonId: seasonId == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonId),
      seasonNumber: seasonNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(seasonNumber),
      episodeNumber: episodeNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(episodeNumber),
      runtimeTicks: runtimeTicks == null && nullToAbsent
          ? const Value.absent()
          : Value(runtimeTicks),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      backdropImagePath: backdropImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(backdropImagePath),
      seriesImagePath: seriesImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesImagePath),
      overview: overview == null && nullToAbsent
          ? const Value.absent()
          : Value(overview),
      productionYear: productionYear == null && nullToAbsent
          ? const Value.absent()
          : Value(productionYear),
      communityRating: communityRating == null && nullToAbsent
          ? const Value.absent()
          : Value(communityRating),
      officialRating: officialRating == null && nullToAbsent
          ? const Value.absent()
          : Value(officialRating),
      genres: genres == null && nullToAbsent
          ? const Value.absent()
          : Value(genres),
      localFilePath: localFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localFilePath),
      container: container == null && nullToAbsent
          ? const Value.absent()
          : Value(container),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      status: Value(status),
      progress: Value(progress),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory DownloadRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadRow(
      attempts: serializer.fromJson<int>(json['attempts']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      accountKey: serializer.fromJson<String>(json['accountKey']),
      itemId: serializer.fromJson<String>(json['itemId']),
      itemType: serializer.fromJson<String>(json['itemType']),
      name: serializer.fromJson<String>(json['name']),
      seriesId: serializer.fromJson<String?>(json['seriesId']),
      seriesName: serializer.fromJson<String?>(json['seriesName']),
      seasonId: serializer.fromJson<String?>(json['seasonId']),
      seasonNumber: serializer.fromJson<int?>(json['seasonNumber']),
      episodeNumber: serializer.fromJson<int?>(json['episodeNumber']),
      runtimeTicks: serializer.fromJson<int?>(json['runtimeTicks']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      backdropImagePath: serializer.fromJson<String?>(
        json['backdropImagePath'],
      ),
      seriesImagePath: serializer.fromJson<String?>(json['seriesImagePath']),
      overview: serializer.fromJson<String?>(json['overview']),
      productionYear: serializer.fromJson<int?>(json['productionYear']),
      communityRating: serializer.fromJson<double?>(json['communityRating']),
      officialRating: serializer.fromJson<String?>(json['officialRating']),
      genres: serializer.fromJson<String?>(json['genres']),
      localFilePath: serializer.fromJson<String?>(json['localFilePath']),
      container: serializer.fromJson<String?>(json['container']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      status: $DownloadsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      progress: serializer.fromJson<double>(json['progress']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attempts': serializer.toJson<int>(attempts),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'lastError': serializer.toJson<String?>(lastError),
      'accountKey': serializer.toJson<String>(accountKey),
      'itemId': serializer.toJson<String>(itemId),
      'itemType': serializer.toJson<String>(itemType),
      'name': serializer.toJson<String>(name),
      'seriesId': serializer.toJson<String?>(seriesId),
      'seriesName': serializer.toJson<String?>(seriesName),
      'seasonId': serializer.toJson<String?>(seasonId),
      'seasonNumber': serializer.toJson<int?>(seasonNumber),
      'episodeNumber': serializer.toJson<int?>(episodeNumber),
      'runtimeTicks': serializer.toJson<int?>(runtimeTicks),
      'imagePath': serializer.toJson<String?>(imagePath),
      'backdropImagePath': serializer.toJson<String?>(backdropImagePath),
      'seriesImagePath': serializer.toJson<String?>(seriesImagePath),
      'overview': serializer.toJson<String?>(overview),
      'productionYear': serializer.toJson<int?>(productionYear),
      'communityRating': serializer.toJson<double?>(communityRating),
      'officialRating': serializer.toJson<String?>(officialRating),
      'genres': serializer.toJson<String?>(genres),
      'localFilePath': serializer.toJson<String?>(localFilePath),
      'container': serializer.toJson<String?>(container),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'status': serializer.toJson<String>(
        $DownloadsTable.$converterstatus.toJson(status),
      ),
      'progress': serializer.toJson<double>(progress),
      'taskId': serializer.toJson<String?>(taskId),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  DownloadRow copyWith({
    int? attempts,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<DateTime?> nextRetryAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    String? accountKey,
    String? itemId,
    String? itemType,
    String? name,
    Value<String?> seriesId = const Value.absent(),
    Value<String?> seriesName = const Value.absent(),
    Value<String?> seasonId = const Value.absent(),
    Value<int?> seasonNumber = const Value.absent(),
    Value<int?> episodeNumber = const Value.absent(),
    Value<int?> runtimeTicks = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
    Value<String?> backdropImagePath = const Value.absent(),
    Value<String?> seriesImagePath = const Value.absent(),
    Value<String?> overview = const Value.absent(),
    Value<int?> productionYear = const Value.absent(),
    Value<double?> communityRating = const Value.absent(),
    Value<String?> officialRating = const Value.absent(),
    Value<String?> genres = const Value.absent(),
    Value<String?> localFilePath = const Value.absent(),
    Value<String?> container = const Value.absent(),
    Value<int?> sizeBytes = const Value.absent(),
    DownloadStatus? status,
    double? progress,
    Value<String?> taskId = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => DownloadRow(
    attempts: attempts ?? this.attempts,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    accountKey: accountKey ?? this.accountKey,
    itemId: itemId ?? this.itemId,
    itemType: itemType ?? this.itemType,
    name: name ?? this.name,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    seriesName: seriesName.present ? seriesName.value : this.seriesName,
    seasonId: seasonId.present ? seasonId.value : this.seasonId,
    seasonNumber: seasonNumber.present ? seasonNumber.value : this.seasonNumber,
    episodeNumber: episodeNumber.present
        ? episodeNumber.value
        : this.episodeNumber,
    runtimeTicks: runtimeTicks.present ? runtimeTicks.value : this.runtimeTicks,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    backdropImagePath: backdropImagePath.present
        ? backdropImagePath.value
        : this.backdropImagePath,
    seriesImagePath: seriesImagePath.present
        ? seriesImagePath.value
        : this.seriesImagePath,
    overview: overview.present ? overview.value : this.overview,
    productionYear: productionYear.present
        ? productionYear.value
        : this.productionYear,
    communityRating: communityRating.present
        ? communityRating.value
        : this.communityRating,
    officialRating: officialRating.present
        ? officialRating.value
        : this.officialRating,
    genres: genres.present ? genres.value : this.genres,
    localFilePath: localFilePath.present
        ? localFilePath.value
        : this.localFilePath,
    container: container.present ? container.value : this.container,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    taskId: taskId.present ? taskId.value : this.taskId,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  DownloadRow copyWithCompanion(DownloadsCompanion data) {
    return DownloadRow(
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      accountKey: data.accountKey.present
          ? data.accountKey.value
          : this.accountKey,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      name: data.name.present ? data.name.value : this.name,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      seriesName: data.seriesName.present
          ? data.seriesName.value
          : this.seriesName,
      seasonId: data.seasonId.present ? data.seasonId.value : this.seasonId,
      seasonNumber: data.seasonNumber.present
          ? data.seasonNumber.value
          : this.seasonNumber,
      episodeNumber: data.episodeNumber.present
          ? data.episodeNumber.value
          : this.episodeNumber,
      runtimeTicks: data.runtimeTicks.present
          ? data.runtimeTicks.value
          : this.runtimeTicks,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      backdropImagePath: data.backdropImagePath.present
          ? data.backdropImagePath.value
          : this.backdropImagePath,
      seriesImagePath: data.seriesImagePath.present
          ? data.seriesImagePath.value
          : this.seriesImagePath,
      overview: data.overview.present ? data.overview.value : this.overview,
      productionYear: data.productionYear.present
          ? data.productionYear.value
          : this.productionYear,
      communityRating: data.communityRating.present
          ? data.communityRating.value
          : this.communityRating,
      officialRating: data.officialRating.present
          ? data.officialRating.value
          : this.officialRating,
      genres: data.genres.present ? data.genres.value : this.genres,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      container: data.container.present ? data.container.value : this.container,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadRow(')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('accountKey: $accountKey, ')
          ..write('itemId: $itemId, ')
          ..write('itemType: $itemType, ')
          ..write('name: $name, ')
          ..write('seriesId: $seriesId, ')
          ..write('seriesName: $seriesName, ')
          ..write('seasonId: $seasonId, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('runtimeTicks: $runtimeTicks, ')
          ..write('imagePath: $imagePath, ')
          ..write('backdropImagePath: $backdropImagePath, ')
          ..write('seriesImagePath: $seriesImagePath, ')
          ..write('overview: $overview, ')
          ..write('productionYear: $productionYear, ')
          ..write('communityRating: $communityRating, ')
          ..write('officialRating: $officialRating, ')
          ..write('genres: $genres, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('container: $container, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('taskId: $taskId, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    attempts,
    lastAttemptAt,
    nextRetryAt,
    lastError,
    accountKey,
    itemId,
    itemType,
    name,
    seriesId,
    seriesName,
    seasonId,
    seasonNumber,
    episodeNumber,
    runtimeTicks,
    imagePath,
    backdropImagePath,
    seriesImagePath,
    overview,
    productionYear,
    communityRating,
    officialRating,
    genres,
    localFilePath,
    container,
    sizeBytes,
    status,
    progress,
    taskId,
    errorMessage,
    createdAt,
    completedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadRow &&
          other.attempts == this.attempts &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.nextRetryAt == this.nextRetryAt &&
          other.lastError == this.lastError &&
          other.accountKey == this.accountKey &&
          other.itemId == this.itemId &&
          other.itemType == this.itemType &&
          other.name == this.name &&
          other.seriesId == this.seriesId &&
          other.seriesName == this.seriesName &&
          other.seasonId == this.seasonId &&
          other.seasonNumber == this.seasonNumber &&
          other.episodeNumber == this.episodeNumber &&
          other.runtimeTicks == this.runtimeTicks &&
          other.imagePath == this.imagePath &&
          other.backdropImagePath == this.backdropImagePath &&
          other.seriesImagePath == this.seriesImagePath &&
          other.overview == this.overview &&
          other.productionYear == this.productionYear &&
          other.communityRating == this.communityRating &&
          other.officialRating == this.officialRating &&
          other.genres == this.genres &&
          other.localFilePath == this.localFilePath &&
          other.container == this.container &&
          other.sizeBytes == this.sizeBytes &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.taskId == this.taskId &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class DownloadsCompanion extends UpdateCompanion<DownloadRow> {
  final Value<int> attempts;
  final Value<DateTime?> lastAttemptAt;
  final Value<DateTime?> nextRetryAt;
  final Value<String?> lastError;
  final Value<String> accountKey;
  final Value<String> itemId;
  final Value<String> itemType;
  final Value<String> name;
  final Value<String?> seriesId;
  final Value<String?> seriesName;
  final Value<String?> seasonId;
  final Value<int?> seasonNumber;
  final Value<int?> episodeNumber;
  final Value<int?> runtimeTicks;
  final Value<String?> imagePath;
  final Value<String?> backdropImagePath;
  final Value<String?> seriesImagePath;
  final Value<String?> overview;
  final Value<int?> productionYear;
  final Value<double?> communityRating;
  final Value<String?> officialRating;
  final Value<String?> genres;
  final Value<String?> localFilePath;
  final Value<String?> container;
  final Value<int?> sizeBytes;
  final Value<DownloadStatus> status;
  final Value<double> progress;
  final Value<String?> taskId;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const DownloadsCompanion({
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.accountKey = const Value.absent(),
    this.itemId = const Value.absent(),
    this.itemType = const Value.absent(),
    this.name = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.seriesName = const Value.absent(),
    this.seasonId = const Value.absent(),
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.runtimeTicks = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.backdropImagePath = const Value.absent(),
    this.seriesImagePath = const Value.absent(),
    this.overview = const Value.absent(),
    this.productionYear = const Value.absent(),
    this.communityRating = const Value.absent(),
    this.officialRating = const Value.absent(),
    this.genres = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.container = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.taskId = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadsCompanion.insert({
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.accountKey = const Value.absent(),
    required String itemId,
    required String itemType,
    required String name,
    this.seriesId = const Value.absent(),
    this.seriesName = const Value.absent(),
    this.seasonId = const Value.absent(),
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.runtimeTicks = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.backdropImagePath = const Value.absent(),
    this.seriesImagePath = const Value.absent(),
    this.overview = const Value.absent(),
    this.productionYear = const Value.absent(),
    this.communityRating = const Value.absent(),
    this.officialRating = const Value.absent(),
    this.genres = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.container = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    required DownloadStatus status,
    this.progress = const Value.absent(),
    this.taskId = const Value.absent(),
    this.errorMessage = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       itemType = Value(itemType),
       name = Value(name),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<DownloadRow> custom({
    Expression<int>? attempts,
    Expression<DateTime>? lastAttemptAt,
    Expression<DateTime>? nextRetryAt,
    Expression<String>? lastError,
    Expression<String>? accountKey,
    Expression<String>? itemId,
    Expression<String>? itemType,
    Expression<String>? name,
    Expression<String>? seriesId,
    Expression<String>? seriesName,
    Expression<String>? seasonId,
    Expression<int>? seasonNumber,
    Expression<int>? episodeNumber,
    Expression<int>? runtimeTicks,
    Expression<String>? imagePath,
    Expression<String>? backdropImagePath,
    Expression<String>? seriesImagePath,
    Expression<String>? overview,
    Expression<int>? productionYear,
    Expression<double>? communityRating,
    Expression<String>? officialRating,
    Expression<String>? genres,
    Expression<String>? localFilePath,
    Expression<String>? container,
    Expression<int>? sizeBytes,
    Expression<String>? status,
    Expression<double>? progress,
    Expression<String>? taskId,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (attempts != null) 'attempts': attempts,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (lastError != null) 'last_error': lastError,
      if (accountKey != null) 'account_key': accountKey,
      if (itemId != null) 'item_id': itemId,
      if (itemType != null) 'item_type': itemType,
      if (name != null) 'name': name,
      if (seriesId != null) 'series_id': seriesId,
      if (seriesName != null) 'series_name': seriesName,
      if (seasonId != null) 'season_id': seasonId,
      if (seasonNumber != null) 'season_number': seasonNumber,
      if (episodeNumber != null) 'episode_number': episodeNumber,
      if (runtimeTicks != null) 'runtime_ticks': runtimeTicks,
      if (imagePath != null) 'image_path': imagePath,
      if (backdropImagePath != null) 'backdrop_image_path': backdropImagePath,
      if (seriesImagePath != null) 'series_image_path': seriesImagePath,
      if (overview != null) 'overview': overview,
      if (productionYear != null) 'production_year': productionYear,
      if (communityRating != null) 'community_rating': communityRating,
      if (officialRating != null) 'official_rating': officialRating,
      if (genres != null) 'genres': genres,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (container != null) 'container': container,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (taskId != null) 'task_id': taskId,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadsCompanion copyWith({
    Value<int>? attempts,
    Value<DateTime?>? lastAttemptAt,
    Value<DateTime?>? nextRetryAt,
    Value<String?>? lastError,
    Value<String>? accountKey,
    Value<String>? itemId,
    Value<String>? itemType,
    Value<String>? name,
    Value<String?>? seriesId,
    Value<String?>? seriesName,
    Value<String?>? seasonId,
    Value<int?>? seasonNumber,
    Value<int?>? episodeNumber,
    Value<int?>? runtimeTicks,
    Value<String?>? imagePath,
    Value<String?>? backdropImagePath,
    Value<String?>? seriesImagePath,
    Value<String?>? overview,
    Value<int?>? productionYear,
    Value<double?>? communityRating,
    Value<String?>? officialRating,
    Value<String?>? genres,
    Value<String?>? localFilePath,
    Value<String?>? container,
    Value<int?>? sizeBytes,
    Value<DownloadStatus>? status,
    Value<double>? progress,
    Value<String?>? taskId,
    Value<String?>? errorMessage,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return DownloadsCompanion(
      attempts: attempts ?? this.attempts,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastError: lastError ?? this.lastError,
      accountKey: accountKey ?? this.accountKey,
      itemId: itemId ?? this.itemId,
      itemType: itemType ?? this.itemType,
      name: name ?? this.name,
      seriesId: seriesId ?? this.seriesId,
      seriesName: seriesName ?? this.seriesName,
      seasonId: seasonId ?? this.seasonId,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      runtimeTicks: runtimeTicks ?? this.runtimeTicks,
      imagePath: imagePath ?? this.imagePath,
      backdropImagePath: backdropImagePath ?? this.backdropImagePath,
      seriesImagePath: seriesImagePath ?? this.seriesImagePath,
      overview: overview ?? this.overview,
      productionYear: productionYear ?? this.productionYear,
      communityRating: communityRating ?? this.communityRating,
      officialRating: officialRating ?? this.officialRating,
      genres: genres ?? this.genres,
      localFilePath: localFilePath ?? this.localFilePath,
      container: container ?? this.container,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      taskId: taskId ?? this.taskId,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (accountKey.present) {
      map['account_key'] = Variable<String>(accountKey.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (seriesName.present) {
      map['series_name'] = Variable<String>(seriesName.value);
    }
    if (seasonId.present) {
      map['season_id'] = Variable<String>(seasonId.value);
    }
    if (seasonNumber.present) {
      map['season_number'] = Variable<int>(seasonNumber.value);
    }
    if (episodeNumber.present) {
      map['episode_number'] = Variable<int>(episodeNumber.value);
    }
    if (runtimeTicks.present) {
      map['runtime_ticks'] = Variable<int>(runtimeTicks.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (backdropImagePath.present) {
      map['backdrop_image_path'] = Variable<String>(backdropImagePath.value);
    }
    if (seriesImagePath.present) {
      map['series_image_path'] = Variable<String>(seriesImagePath.value);
    }
    if (overview.present) {
      map['overview'] = Variable<String>(overview.value);
    }
    if (productionYear.present) {
      map['production_year'] = Variable<int>(productionYear.value);
    }
    if (communityRating.present) {
      map['community_rating'] = Variable<double>(communityRating.value);
    }
    if (officialRating.present) {
      map['official_rating'] = Variable<String>(officialRating.value);
    }
    if (genres.present) {
      map['genres'] = Variable<String>(genres.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (container.present) {
      map['container'] = Variable<String>(container.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $DownloadsTable.$converterstatus.toSql(status.value),
      );
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadsCompanion(')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('accountKey: $accountKey, ')
          ..write('itemId: $itemId, ')
          ..write('itemType: $itemType, ')
          ..write('name: $name, ')
          ..write('seriesId: $seriesId, ')
          ..write('seriesName: $seriesName, ')
          ..write('seasonId: $seasonId, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('runtimeTicks: $runtimeTicks, ')
          ..write('imagePath: $imagePath, ')
          ..write('backdropImagePath: $backdropImagePath, ')
          ..write('seriesImagePath: $seriesImagePath, ')
          ..write('overview: $overview, ')
          ..write('productionYear: $productionYear, ')
          ..write('communityRating: $communityRating, ')
          ..write('officialRating: $officialRating, ')
          ..write('genres: $genres, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('container: $container, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('taskId: $taskId, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedResponsesTable extends CachedResponses
    with TableInfo<$CachedResponsesTable, CachedResponse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedResponsesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountKeyMeta = const VerificationMeta(
    'accountKey',
  );
  @override
  late final GeneratedColumn<String> accountKey = GeneratedColumn<String>(
    'account_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(legacyAccountKey),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [accountKey, key, payload, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_responses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedResponse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_key')) {
      context.handle(
        _accountKeyMeta,
        accountKey.isAcceptableOrUnknown(data['account_key']!, _accountKeyMeta),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountKey, key};
  @override
  CachedResponse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedResponse(
      accountKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_key'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $CachedResponsesTable createAlias(String alias) {
    return $CachedResponsesTable(attachedDatabase, alias);
  }
}

class CachedResponse extends DataClass implements Insertable<CachedResponse> {
  final String accountKey;
  final String key;
  final String payload;
  final int fetchedAt;
  const CachedResponse({
    required this.accountKey,
    required this.key,
    required this.payload,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_key'] = Variable<String>(accountKey);
    map['key'] = Variable<String>(key);
    map['payload'] = Variable<String>(payload);
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  CachedResponsesCompanion toCompanion(bool nullToAbsent) {
    return CachedResponsesCompanion(
      accountKey: Value(accountKey),
      key: Value(key),
      payload: Value(payload),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CachedResponse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedResponse(
      accountKey: serializer.fromJson<String>(json['accountKey']),
      key: serializer.fromJson<String>(json['key']),
      payload: serializer.fromJson<String>(json['payload']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountKey': serializer.toJson<String>(accountKey),
      'key': serializer.toJson<String>(key),
      'payload': serializer.toJson<String>(payload),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  CachedResponse copyWith({
    String? accountKey,
    String? key,
    String? payload,
    int? fetchedAt,
  }) => CachedResponse(
    accountKey: accountKey ?? this.accountKey,
    key: key ?? this.key,
    payload: payload ?? this.payload,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  CachedResponse copyWithCompanion(CachedResponsesCompanion data) {
    return CachedResponse(
      accountKey: data.accountKey.present
          ? data.accountKey.value
          : this.accountKey,
      key: data.key.present ? data.key.value : this.key,
      payload: data.payload.present ? data.payload.value : this.payload,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedResponse(')
          ..write('accountKey: $accountKey, ')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(accountKey, key, payload, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedResponse &&
          other.accountKey == this.accountKey &&
          other.key == this.key &&
          other.payload == this.payload &&
          other.fetchedAt == this.fetchedAt);
}

class CachedResponsesCompanion extends UpdateCompanion<CachedResponse> {
  final Value<String> accountKey;
  final Value<String> key;
  final Value<String> payload;
  final Value<int> fetchedAt;
  final Value<int> rowid;
  const CachedResponsesCompanion({
    this.accountKey = const Value.absent(),
    this.key = const Value.absent(),
    this.payload = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedResponsesCompanion.insert({
    this.accountKey = const Value.absent(),
    required String key,
    required String payload,
    required int fetchedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       payload = Value(payload),
       fetchedAt = Value(fetchedAt);
  static Insertable<CachedResponse> custom({
    Expression<String>? accountKey,
    Expression<String>? key,
    Expression<String>? payload,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountKey != null) 'account_key': accountKey,
      if (key != null) 'key': key,
      if (payload != null) 'payload': payload,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedResponsesCompanion copyWith({
    Value<String>? accountKey,
    Value<String>? key,
    Value<String>? payload,
    Value<int>? fetchedAt,
    Value<int>? rowid,
  }) {
    return CachedResponsesCompanion(
      accountKey: accountKey ?? this.accountKey,
      key: key ?? this.key,
      payload: payload ?? this.payload,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountKey.present) {
      map['account_key'] = Variable<String>(accountKey.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedResponsesCompanion(')
          ..write('accountKey: $accountKey, ')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _accountKeyMeta = const VerificationMeta(
    'accountKey',
  );
  @override
  late final GeneratedColumn<String> accountKey = GeneratedColumn<String>(
    'account_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(legacyAccountKey),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncOperation, String> operation =
      GeneratedColumn<String>(
        'operation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncOperation>($SyncQueueTable.$converteroperation);
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    attempts,
    lastAttemptAt,
    nextRetryAt,
    lastError,
    id,
    accountKey,
    itemId,
    operation,
    payloadJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_key')) {
      context.handle(
        _accountKeyMeta,
        accountKey.isAcceptableOrUnknown(data['account_key']!, _accountKeyMeta),
      );
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueRow(
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_key'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      operation: $SyncQueueTable.$converteroperation.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}operation'],
        )!,
      ),
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncOperation, String, String> $converteroperation =
      const EnumNameConverter<SyncOperation>(SyncOperation.values);
}

class SyncQueueRow extends DataClass implements Insertable<SyncQueueRow> {
  final int attempts;
  final DateTime? lastAttemptAt;
  final DateTime? nextRetryAt;
  final String? lastError;
  final int id;
  final String accountKey;
  final String itemId;
  final SyncOperation operation;
  final String payloadJson;
  final DateTime createdAt;
  const SyncQueueRow({
    required this.attempts,
    this.lastAttemptAt,
    this.nextRetryAt,
    this.lastError,
    required this.id,
    required this.accountKey,
    required this.itemId,
    required this.operation,
    required this.payloadJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['id'] = Variable<int>(id);
    map['account_key'] = Variable<String>(accountKey);
    map['item_id'] = Variable<String>(itemId);
    {
      map['operation'] = Variable<String>(
        $SyncQueueTable.$converteroperation.toSql(operation),
      );
    }
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      attempts: Value(attempts),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      id: Value(id),
      accountKey: Value(accountKey),
      itemId: Value(itemId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueRow(
      attempts: serializer.fromJson<int>(json['attempts']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      id: serializer.fromJson<int>(json['id']),
      accountKey: serializer.fromJson<String>(json['accountKey']),
      itemId: serializer.fromJson<String>(json['itemId']),
      operation: $SyncQueueTable.$converteroperation.fromJson(
        serializer.fromJson<String>(json['operation']),
      ),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attempts': serializer.toJson<int>(attempts),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'lastError': serializer.toJson<String?>(lastError),
      'id': serializer.toJson<int>(id),
      'accountKey': serializer.toJson<String>(accountKey),
      'itemId': serializer.toJson<String>(itemId),
      'operation': serializer.toJson<String>(
        $SyncQueueTable.$converteroperation.toJson(operation),
      ),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueRow copyWith({
    int? attempts,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<DateTime?> nextRetryAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    int? id,
    String? accountKey,
    String? itemId,
    SyncOperation? operation,
    String? payloadJson,
    DateTime? createdAt,
  }) => SyncQueueRow(
    attempts: attempts ?? this.attempts,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    id: id ?? this.id,
    accountKey: accountKey ?? this.accountKey,
    itemId: itemId ?? this.itemId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncQueueRow copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueRow(
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      id: data.id.present ? data.id.value : this.id,
      accountKey: data.accountKey.present
          ? data.accountKey.value
          : this.accountKey,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueRow(')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('id: $id, ')
          ..write('accountKey: $accountKey, ')
          ..write('itemId: $itemId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    attempts,
    lastAttemptAt,
    nextRetryAt,
    lastError,
    id,
    accountKey,
    itemId,
    operation,
    payloadJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueRow &&
          other.attempts == this.attempts &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.nextRetryAt == this.nextRetryAt &&
          other.lastError == this.lastError &&
          other.id == this.id &&
          other.accountKey == this.accountKey &&
          other.itemId == this.itemId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueRow> {
  final Value<int> attempts;
  final Value<DateTime?> lastAttemptAt;
  final Value<DateTime?> nextRetryAt;
  final Value<String?> lastError;
  final Value<int> id;
  final Value<String> accountKey;
  final Value<String> itemId;
  final Value<SyncOperation> operation;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  const SyncQueueCompanion({
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.id = const Value.absent(),
    this.accountKey = const Value.absent(),
    this.itemId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.id = const Value.absent(),
    this.accountKey = const Value.absent(),
    required String itemId,
    required SyncOperation operation,
    this.payloadJson = const Value.absent(),
    required DateTime createdAt,
  }) : itemId = Value(itemId),
       operation = Value(operation),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueRow> custom({
    Expression<int>? attempts,
    Expression<DateTime>? lastAttemptAt,
    Expression<DateTime>? nextRetryAt,
    Expression<String>? lastError,
    Expression<int>? id,
    Expression<String>? accountKey,
    Expression<String>? itemId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (attempts != null) 'attempts': attempts,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (lastError != null) 'last_error': lastError,
      if (id != null) 'id': id,
      if (accountKey != null) 'account_key': accountKey,
      if (itemId != null) 'item_id': itemId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? attempts,
    Value<DateTime?>? lastAttemptAt,
    Value<DateTime?>? nextRetryAt,
    Value<String?>? lastError,
    Value<int>? id,
    Value<String>? accountKey,
    Value<String>? itemId,
    Value<SyncOperation>? operation,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
  }) {
    return SyncQueueCompanion(
      attempts: attempts ?? this.attempts,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastError: lastError ?? this.lastError,
      id: id ?? this.id,
      accountKey: accountKey ?? this.accountKey,
      itemId: itemId ?? this.itemId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountKey.present) {
      map['account_key'] = Variable<String>(accountKey.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(
        $SyncQueueTable.$converteroperation.toSql(operation.value),
      );
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('id: $id, ')
          ..write('accountKey: $accountKey, ')
          ..write('itemId: $itemId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DownloadsTable downloads = $DownloadsTable(this);
  late final $CachedResponsesTable cachedResponses = $CachedResponsesTable(
    this,
  );
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final Index downloadsTaskIdIdx = Index(
    'downloads_task_id_idx',
    'CREATE INDEX downloads_task_id_idx ON downloads (task_id)',
  );
  late final Index downloadsAccountIdx = Index(
    'downloads_account_idx',
    'CREATE INDEX downloads_account_idx ON downloads (account_key)',
  );
  late final Index cachedResponsesAccountIdx = Index(
    'cached_responses_account_idx',
    'CREATE INDEX cached_responses_account_idx ON cached_responses (account_key)',
  );
  late final Index syncQueueItemIdx = Index(
    'sync_queue_item_idx',
    'CREATE INDEX sync_queue_item_idx ON sync_queue (item_id)',
  );
  late final Index syncQueueAccountIdx = Index(
    'sync_queue_account_idx',
    'CREATE INDEX sync_queue_account_idx ON sync_queue (account_key)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    downloads,
    cachedResponses,
    syncQueue,
    downloadsTaskIdIdx,
    downloadsAccountIdx,
    cachedResponsesAccountIdx,
    syncQueueItemIdx,
    syncQueueAccountIdx,
  ];
}

typedef $$DownloadsTableCreateCompanionBuilder =
    DownloadsCompanion Function({
      Value<int> attempts,
      Value<DateTime?> lastAttemptAt,
      Value<DateTime?> nextRetryAt,
      Value<String?> lastError,
      Value<String> accountKey,
      required String itemId,
      required String itemType,
      required String name,
      Value<String?> seriesId,
      Value<String?> seriesName,
      Value<String?> seasonId,
      Value<int?> seasonNumber,
      Value<int?> episodeNumber,
      Value<int?> runtimeTicks,
      Value<String?> imagePath,
      Value<String?> backdropImagePath,
      Value<String?> seriesImagePath,
      Value<String?> overview,
      Value<int?> productionYear,
      Value<double?> communityRating,
      Value<String?> officialRating,
      Value<String?> genres,
      Value<String?> localFilePath,
      Value<String?> container,
      Value<int?> sizeBytes,
      required DownloadStatus status,
      Value<double> progress,
      Value<String?> taskId,
      Value<String?> errorMessage,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$DownloadsTableUpdateCompanionBuilder =
    DownloadsCompanion Function({
      Value<int> attempts,
      Value<DateTime?> lastAttemptAt,
      Value<DateTime?> nextRetryAt,
      Value<String?> lastError,
      Value<String> accountKey,
      Value<String> itemId,
      Value<String> itemType,
      Value<String> name,
      Value<String?> seriesId,
      Value<String?> seriesName,
      Value<String?> seasonId,
      Value<int?> seasonNumber,
      Value<int?> episodeNumber,
      Value<int?> runtimeTicks,
      Value<String?> imagePath,
      Value<String?> backdropImagePath,
      Value<String?> seriesImagePath,
      Value<String?> overview,
      Value<int?> productionYear,
      Value<double?> communityRating,
      Value<String?> officialRating,
      Value<String?> genres,
      Value<String?> localFilePath,
      Value<String?> container,
      Value<int?> sizeBytes,
      Value<DownloadStatus> status,
      Value<double> progress,
      Value<String?> taskId,
      Value<String?> errorMessage,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

class $$DownloadsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesName => $composableBuilder(
    column: $table.seriesName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seasonId => $composableBuilder(
    column: $table.seasonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seasonNumber => $composableBuilder(
    column: $table.seasonNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episodeNumber => $composableBuilder(
    column: $table.episodeNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get runtimeTicks => $composableBuilder(
    column: $table.runtimeTicks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backdropImagePath => $composableBuilder(
    column: $table.backdropImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesImagePath => $composableBuilder(
    column: $table.seriesImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productionYear => $composableBuilder(
    column: $table.productionYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get communityRating => $composableBuilder(
    column: $table.communityRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get officialRating => $composableBuilder(
    column: $table.officialRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get container => $composableBuilder(
    column: $table.container,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DownloadStatus, DownloadStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesName => $composableBuilder(
    column: $table.seriesName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seasonId => $composableBuilder(
    column: $table.seasonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seasonNumber => $composableBuilder(
    column: $table.seasonNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episodeNumber => $composableBuilder(
    column: $table.episodeNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get runtimeTicks => $composableBuilder(
    column: $table.runtimeTicks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backdropImagePath => $composableBuilder(
    column: $table.backdropImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesImagePath => $composableBuilder(
    column: $table.seriesImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productionYear => $composableBuilder(
    column: $table.productionYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get communityRating => $composableBuilder(
    column: $table.communityRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get officialRating => $composableBuilder(
    column: $table.officialRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get container => $composableBuilder(
    column: $table.container,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<String> get seriesName => $composableBuilder(
    column: $table.seriesName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seasonId =>
      $composableBuilder(column: $table.seasonId, builder: (column) => column);

  GeneratedColumn<int> get seasonNumber => $composableBuilder(
    column: $table.seasonNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get episodeNumber => $composableBuilder(
    column: $table.episodeNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get runtimeTicks => $composableBuilder(
    column: $table.runtimeTicks,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get backdropImagePath => $composableBuilder(
    column: $table.backdropImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seriesImagePath => $composableBuilder(
    column: $table.seriesImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overview =>
      $composableBuilder(column: $table.overview, builder: (column) => column);

  GeneratedColumn<int> get productionYear => $composableBuilder(
    column: $table.productionYear,
    builder: (column) => column,
  );

  GeneratedColumn<double> get communityRating => $composableBuilder(
    column: $table.communityRating,
    builder: (column) => column,
  );

  GeneratedColumn<String> get officialRating => $composableBuilder(
    column: $table.officialRating,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genres =>
      $composableBuilder(column: $table.genres, builder: (column) => column);

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get container =>
      $composableBuilder(column: $table.container, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DownloadStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$DownloadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadsTable,
          DownloadRow,
          $$DownloadsTableFilterComposer,
          $$DownloadsTableOrderingComposer,
          $$DownloadsTableAnnotationComposer,
          $$DownloadsTableCreateCompanionBuilder,
          $$DownloadsTableUpdateCompanionBuilder,
          (
            DownloadRow,
            BaseReferences<_$AppDatabase, $DownloadsTable, DownloadRow>,
          ),
          DownloadRow,
          PrefetchHooks Function()
        > {
  $$DownloadsTableTableManager(_$AppDatabase db, $DownloadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> accountKey = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<String?> seriesName = const Value.absent(),
                Value<String?> seasonId = const Value.absent(),
                Value<int?> seasonNumber = const Value.absent(),
                Value<int?> episodeNumber = const Value.absent(),
                Value<int?> runtimeTicks = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> backdropImagePath = const Value.absent(),
                Value<String?> seriesImagePath = const Value.absent(),
                Value<String?> overview = const Value.absent(),
                Value<int?> productionYear = const Value.absent(),
                Value<double?> communityRating = const Value.absent(),
                Value<String?> officialRating = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<String?> localFilePath = const Value.absent(),
                Value<String?> container = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<DownloadStatus> status = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadsCompanion(
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                accountKey: accountKey,
                itemId: itemId,
                itemType: itemType,
                name: name,
                seriesId: seriesId,
                seriesName: seriesName,
                seasonId: seasonId,
                seasonNumber: seasonNumber,
                episodeNumber: episodeNumber,
                runtimeTicks: runtimeTicks,
                imagePath: imagePath,
                backdropImagePath: backdropImagePath,
                seriesImagePath: seriesImagePath,
                overview: overview,
                productionYear: productionYear,
                communityRating: communityRating,
                officialRating: officialRating,
                genres: genres,
                localFilePath: localFilePath,
                container: container,
                sizeBytes: sizeBytes,
                status: status,
                progress: progress,
                taskId: taskId,
                errorMessage: errorMessage,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String> accountKey = const Value.absent(),
                required String itemId,
                required String itemType,
                required String name,
                Value<String?> seriesId = const Value.absent(),
                Value<String?> seriesName = const Value.absent(),
                Value<String?> seasonId = const Value.absent(),
                Value<int?> seasonNumber = const Value.absent(),
                Value<int?> episodeNumber = const Value.absent(),
                Value<int?> runtimeTicks = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> backdropImagePath = const Value.absent(),
                Value<String?> seriesImagePath = const Value.absent(),
                Value<String?> overview = const Value.absent(),
                Value<int?> productionYear = const Value.absent(),
                Value<double?> communityRating = const Value.absent(),
                Value<String?> officialRating = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<String?> localFilePath = const Value.absent(),
                Value<String?> container = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                required DownloadStatus status,
                Value<double> progress = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadsCompanion.insert(
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                accountKey: accountKey,
                itemId: itemId,
                itemType: itemType,
                name: name,
                seriesId: seriesId,
                seriesName: seriesName,
                seasonId: seasonId,
                seasonNumber: seasonNumber,
                episodeNumber: episodeNumber,
                runtimeTicks: runtimeTicks,
                imagePath: imagePath,
                backdropImagePath: backdropImagePath,
                seriesImagePath: seriesImagePath,
                overview: overview,
                productionYear: productionYear,
                communityRating: communityRating,
                officialRating: officialRating,
                genres: genres,
                localFilePath: localFilePath,
                container: container,
                sizeBytes: sizeBytes,
                status: status,
                progress: progress,
                taskId: taskId,
                errorMessage: errorMessage,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadsTable,
      DownloadRow,
      $$DownloadsTableFilterComposer,
      $$DownloadsTableOrderingComposer,
      $$DownloadsTableAnnotationComposer,
      $$DownloadsTableCreateCompanionBuilder,
      $$DownloadsTableUpdateCompanionBuilder,
      (
        DownloadRow,
        BaseReferences<_$AppDatabase, $DownloadsTable, DownloadRow>,
      ),
      DownloadRow,
      PrefetchHooks Function()
    >;
typedef $$CachedResponsesTableCreateCompanionBuilder =
    CachedResponsesCompanion Function({
      Value<String> accountKey,
      required String key,
      required String payload,
      required int fetchedAt,
      Value<int> rowid,
    });
typedef $$CachedResponsesTableUpdateCompanionBuilder =
    CachedResponsesCompanion Function({
      Value<String> accountKey,
      Value<String> key,
      Value<String> payload,
      Value<int> fetchedAt,
      Value<int> rowid,
    });

class $$CachedResponsesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedResponsesTable> {
  $$CachedResponsesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedResponsesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedResponsesTable> {
  $$CachedResponsesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedResponsesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedResponsesTable> {
  $$CachedResponsesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CachedResponsesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedResponsesTable,
          CachedResponse,
          $$CachedResponsesTableFilterComposer,
          $$CachedResponsesTableOrderingComposer,
          $$CachedResponsesTableAnnotationComposer,
          $$CachedResponsesTableCreateCompanionBuilder,
          $$CachedResponsesTableUpdateCompanionBuilder,
          (
            CachedResponse,
            BaseReferences<
              _$AppDatabase,
              $CachedResponsesTable,
              CachedResponse
            >,
          ),
          CachedResponse,
          PrefetchHooks Function()
        > {
  $$CachedResponsesTableTableManager(
    _$AppDatabase db,
    $CachedResponsesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedResponsesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedResponsesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedResponsesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedResponsesCompanion(
                accountKey: accountKey,
                key: key,
                payload: payload,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> accountKey = const Value.absent(),
                required String key,
                required String payload,
                required int fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedResponsesCompanion.insert(
                accountKey: accountKey,
                key: key,
                payload: payload,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedResponsesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedResponsesTable,
      CachedResponse,
      $$CachedResponsesTableFilterComposer,
      $$CachedResponsesTableOrderingComposer,
      $$CachedResponsesTableAnnotationComposer,
      $$CachedResponsesTableCreateCompanionBuilder,
      $$CachedResponsesTableUpdateCompanionBuilder,
      (
        CachedResponse,
        BaseReferences<_$AppDatabase, $CachedResponsesTable, CachedResponse>,
      ),
      CachedResponse,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> attempts,
      Value<DateTime?> lastAttemptAt,
      Value<DateTime?> nextRetryAt,
      Value<String?> lastError,
      Value<int> id,
      Value<String> accountKey,
      required String itemId,
      required SyncOperation operation,
      Value<String> payloadJson,
      required DateTime createdAt,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> attempts,
      Value<DateTime?> lastAttemptAt,
      Value<DateTime?> nextRetryAt,
      Value<String?> lastError,
      Value<int> id,
      Value<String> accountKey,
      Value<String> itemId,
      Value<SyncOperation> operation,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncOperation, SyncOperation, String>
  get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncOperation, String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueRow,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueRow,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>,
          ),
          SyncQueueRow,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> accountKey = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<SyncOperation> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncQueueCompanion(
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                id: id,
                accountKey: accountKey,
                itemId: itemId,
                operation: operation,
                payloadJson: payloadJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> accountKey = const Value.absent(),
                required String itemId,
                required SyncOperation operation,
                Value<String> payloadJson = const Value.absent(),
                required DateTime createdAt,
              }) => SyncQueueCompanion.insert(
                attempts: attempts,
                lastAttemptAt: lastAttemptAt,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                id: id,
                accountKey: accountKey,
                itemId: itemId,
                operation: operation,
                payloadJson: payloadJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueRow,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueRow,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>,
      ),
      SyncQueueRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DownloadsTableTableManager get downloads =>
      $$DownloadsTableTableManager(_db, _db.downloads);
  $$CachedResponsesTableTableManager get cachedResponses =>
      $$CachedResponsesTableTableManager(_db, _db.cachedResponses);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
