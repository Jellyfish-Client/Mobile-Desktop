/// Subset of the Sonarr v3 `SystemStatus` payload we surface on mobile.
class SonarrSystemStatus {
  const SonarrSystemStatus({
    required this.version,
    required this.appName,
    this.startTime,
  });

  factory SonarrSystemStatus.fromJson(Map<String, dynamic> json) {
    return SonarrSystemStatus(
      version: (json['version'] as String?) ?? '',
      appName: (json['appName'] as String?) ?? 'Sonarr',
      startTime: DateTime.tryParse((json['startTime'] as String?) ?? ''),
    );
  }

  final String version;
  final String appName;
  final DateTime? startTime;
}

class SonarrSeries {
  const SonarrSeries({
    required this.id,
    required this.title,
    required this.year,
    required this.monitored,
    required this.statistics,
    this.overview,
    this.posterUrl,
    this.tvdbId,
    this.tmdbId,
  });

  factory SonarrSeries.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List?) ?? const [];
    String? poster;
    for (final img in images) {
      if (img is! Map) continue;
      if (img['coverType'] == 'poster') {
        poster = (img['remoteUrl'] as String?) ?? (img['url'] as String?);
        break;
      }
    }
    final statsRaw = json['statistics'];
    return SonarrSeries(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      monitored: json['monitored'] == true,
      statistics: statsRaw is Map
          ? SonarrSeriesStatistics.fromJson(Map<String, dynamic>.from(statsRaw))
          : const SonarrSeriesStatistics(),
      overview: json['overview'] as String?,
      posterUrl: poster,
      tvdbId: (json['tvdbId'] as num?)?.toInt(),
      tmdbId: (json['tmdbId'] as num?)?.toInt(),
    );
  }

  final int id;
  final String title;
  final int year;
  final bool monitored;
  final SonarrSeriesStatistics statistics;
  final String? overview;
  final String? posterUrl;
  final int? tvdbId;
  final int? tmdbId;
}

class SonarrSeriesStatistics {
  const SonarrSeriesStatistics({
    this.episodeCount = 0,
    this.episodeFileCount = 0,
    this.totalEpisodeCount = 0,
  });

  factory SonarrSeriesStatistics.fromJson(Map<String, dynamic> json) {
    return SonarrSeriesStatistics(
      episodeCount: (json['episodeCount'] as num?)?.toInt() ?? 0,
      episodeFileCount: (json['episodeFileCount'] as num?)?.toInt() ?? 0,
      totalEpisodeCount: (json['totalEpisodeCount'] as num?)?.toInt() ?? 0,
    );
  }

  final int episodeCount;
  final int episodeFileCount;
  final int totalEpisodeCount;
}

class SonarrEpisode {
  const SonarrEpisode({
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    required this.hasFile,
    required this.monitored,
    this.overview,
    this.airDateUtc,
  });

  factory SonarrEpisode.fromJson(Map<String, dynamic> json) {
    return SonarrEpisode(
      id: (json['id'] as num?)?.toInt() ?? 0,
      seriesId: (json['seriesId'] as num?)?.toInt() ?? 0,
      seasonNumber: (json['seasonNumber'] as num?)?.toInt() ?? 0,
      episodeNumber: (json['episodeNumber'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      hasFile: json['hasFile'] == true,
      monitored: json['monitored'] == true,
      overview: json['overview'] as String?,
      airDateUtc: DateTime.tryParse((json['airDateUtc'] as String?) ?? ''),
    );
  }

  final int id;
  final int seriesId;
  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final bool hasFile;
  final bool monitored;
  final String? overview;
  final DateTime? airDateUtc;
}

class SonarrQueueItem {
  const SonarrQueueItem({
    required this.id,
    required this.seriesId,
    required this.episodeId,
    required this.title,
    required this.status,
    this.size,
    this.sizeLeft,
    this.estimatedCompletionTime,
  });

  factory SonarrQueueItem.fromJson(Map<String, dynamic> json) {
    return SonarrQueueItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      seriesId: (json['seriesId'] as num?)?.toInt() ?? 0,
      episodeId: (json['episodeId'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      size: (json['size'] as num?)?.toDouble(),
      sizeLeft: (json['sizeleft'] as num?)?.toDouble(),
      estimatedCompletionTime: DateTime.tryParse(
        (json['estimatedCompletionTime'] as String?) ?? '',
      ),
    );
  }

  final int id;
  final int seriesId;
  final int episodeId;
  final String title;
  final String status;
  final double? size;
  final double? sizeLeft;
  final DateTime? estimatedCompletionTime;
}

class SonarrQueuePage {
  const SonarrQueuePage({required this.records, required this.totalRecords});

  factory SonarrQueuePage.fromJson(Map<String, dynamic> json) {
    final records = ((json['records'] as List?) ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => SonarrQueueItem.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    return SonarrQueuePage(
      records: records,
      totalRecords: (json['totalRecords'] as num?)?.toInt() ?? records.length,
    );
  }

  final List<SonarrQueueItem> records;
  final int totalRecords;
}

class SonarrHistoryEntry {
  const SonarrHistoryEntry({
    required this.id,
    required this.seriesId,
    required this.episodeId,
    required this.eventType,
    required this.date,
    this.sourceTitle,
  });

  factory SonarrHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SonarrHistoryEntry(
      id: (json['id'] as num?)?.toInt() ?? 0,
      seriesId: (json['seriesId'] as num?)?.toInt() ?? 0,
      episodeId: (json['episodeId'] as num?)?.toInt() ?? 0,
      eventType: (json['eventType'] as String?) ?? '',
      date:
          DateTime.tryParse((json['date'] as String?) ?? '') ?? DateTime.now(),
      sourceTitle: json['sourceTitle'] as String?,
    );
  }

  final int id;
  final int seriesId;
  final int episodeId;
  final String eventType;
  final DateTime date;
  final String? sourceTitle;
}

class SonarrHistoryPage {
  const SonarrHistoryPage({required this.records, required this.totalRecords});

  factory SonarrHistoryPage.fromJson(Map<String, dynamic> json) {
    final records = ((json['records'] as List?) ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => SonarrHistoryEntry.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    return SonarrHistoryPage(
      records: records,
      totalRecords: (json['totalRecords'] as num?)?.toInt() ?? records.length,
    );
  }

  final List<SonarrHistoryEntry> records;
  final int totalRecords;
}

class SonarrCalendarEntry {
  const SonarrCalendarEntry({
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.title,
    required this.hasFile,
    this.seriesTitle,
    this.airDateUtc,
  });

  factory SonarrCalendarEntry.fromJson(Map<String, dynamic> json) {
    final seriesRaw = json['series'];
    String? seriesTitle;
    if (seriesRaw is Map) {
      seriesTitle = seriesRaw['title'] as String?;
    }
    return SonarrCalendarEntry(
      id: (json['id'] as num?)?.toInt() ?? 0,
      seriesId: (json['seriesId'] as num?)?.toInt() ?? 0,
      seasonNumber: (json['seasonNumber'] as num?)?.toInt() ?? 0,
      episodeNumber: (json['episodeNumber'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      hasFile: json['hasFile'] == true,
      seriesTitle: seriesTitle,
      airDateUtc: DateTime.tryParse((json['airDateUtc'] as String?) ?? ''),
    );
  }

  final int id;
  final int seriesId;
  final int seasonNumber;
  final int episodeNumber;
  final String title;
  final bool hasFile;
  final String? seriesTitle;
  final DateTime? airDateUtc;
}
