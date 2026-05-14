/// Subset of the Radarr v3 `SystemStatus` payload we need on mobile. The
/// raw shape carries dozens of fields; we keep only what's surfaced in the UI.
class RadarrSystemStatus {
  const RadarrSystemStatus({
    required this.version,
    required this.appName,
    this.startTime,
  });

  factory RadarrSystemStatus.fromJson(Map<String, dynamic> json) {
    return RadarrSystemStatus(
      version: (json['version'] as String?) ?? '',
      appName: (json['appName'] as String?) ?? 'Radarr',
      startTime: DateTime.tryParse((json['startTime'] as String?) ?? ''),
    );
  }

  final String version;
  final String appName;
  final DateTime? startTime;
}

class RadarrMovie {
  const RadarrMovie({
    required this.id,
    required this.title,
    required this.year,
    required this.hasFile,
    required this.monitored,
    this.overview,
    this.posterUrl,
    this.tmdbId,
    this.releaseDate,
  });

  factory RadarrMovie.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List?) ?? const [];
    String? poster;
    for (final img in images) {
      if (img is! Map) continue;
      if (img['coverType'] == 'poster') {
        poster = (img['remoteUrl'] as String?) ?? (img['url'] as String?);
        break;
      }
    }
    return RadarrMovie(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      hasFile: json['hasFile'] == true,
      monitored: json['monitored'] == true,
      overview: json['overview'] as String?,
      posterUrl: poster,
      tmdbId: (json['tmdbId'] as num?)?.toInt(),
      releaseDate:
          DateTime.tryParse((json['releaseDate'] as String?) ?? '') ??
          DateTime.tryParse((json['digitalRelease'] as String?) ?? '') ??
          DateTime.tryParse((json['physicalRelease'] as String?) ?? '') ??
          DateTime.tryParse((json['inCinemas'] as String?) ?? ''),
    );
  }

  final int id;
  final String title;
  final int year;
  final bool hasFile;
  final bool monitored;
  final String? overview;
  final String? posterUrl;
  final int? tmdbId;
  final DateTime? releaseDate;
}

class RadarrQueueItem {
  const RadarrQueueItem({
    required this.id,
    required this.movieId,
    required this.title,
    required this.status,
    this.size,
    this.sizeLeft,
    this.estimatedCompletionTime,
  });

  factory RadarrQueueItem.fromJson(Map<String, dynamic> json) {
    return RadarrQueueItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      movieId: (json['movieId'] as num?)?.toInt() ?? 0,
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
  final int movieId;
  final String title;
  final String status;
  final double? size;
  final double? sizeLeft;
  final DateTime? estimatedCompletionTime;
}

class RadarrQueuePage {
  const RadarrQueuePage({required this.records, required this.totalRecords});

  factory RadarrQueuePage.fromJson(Map<String, dynamic> json) {
    final records = ((json['records'] as List?) ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => RadarrQueueItem.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    return RadarrQueuePage(
      records: records,
      totalRecords: (json['totalRecords'] as num?)?.toInt() ?? records.length,
    );
  }

  final List<RadarrQueueItem> records;
  final int totalRecords;
}

class RadarrHistoryEntry {
  const RadarrHistoryEntry({
    required this.id,
    required this.movieId,
    required this.eventType,
    required this.date,
    this.sourceTitle,
  });

  factory RadarrHistoryEntry.fromJson(Map<String, dynamic> json) {
    return RadarrHistoryEntry(
      id: (json['id'] as num?)?.toInt() ?? 0,
      movieId: (json['movieId'] as num?)?.toInt() ?? 0,
      eventType: (json['eventType'] as String?) ?? '',
      date:
          DateTime.tryParse((json['date'] as String?) ?? '') ?? DateTime.now(),
      sourceTitle: json['sourceTitle'] as String?,
    );
  }

  final int id;
  final int movieId;
  final String eventType;
  final DateTime date;
  final String? sourceTitle;
}

class RadarrHistoryPage {
  const RadarrHistoryPage({required this.records, required this.totalRecords});

  factory RadarrHistoryPage.fromJson(Map<String, dynamic> json) {
    final records = ((json['records'] as List?) ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => RadarrHistoryEntry.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    return RadarrHistoryPage(
      records: records,
      totalRecords: (json['totalRecords'] as num?)?.toInt() ?? records.length,
    );
  }

  final List<RadarrHistoryEntry> records;
  final int totalRecords;
}

class RadarrCalendarEntry {
  const RadarrCalendarEntry({
    required this.id,
    required this.title,
    required this.year,
    required this.hasFile,
    this.tmdbId,
    this.releaseDate,
    this.posterUrl,
  });

  factory RadarrCalendarEntry.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List?) ?? const [];
    String? poster;
    for (final img in images) {
      if (img is! Map) continue;
      if (img['coverType'] == 'poster') {
        poster = (img['remoteUrl'] as String?) ?? (img['url'] as String?);
        break;
      }
    }
    return RadarrCalendarEntry(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      hasFile: json['hasFile'] == true,
      tmdbId: (json['tmdbId'] as num?)?.toInt(),
      // Radarr's calendar surfaces `releaseDate` (the configured release
      // type, typically the digital/physical date) as the canonical date
      // for the entry. `inCinemas` is often in the past once the digital
      // release is queued, so use it only as a fallback.
      releaseDate:
          DateTime.tryParse((json['releaseDate'] as String?) ?? '') ??
          DateTime.tryParse((json['digitalRelease'] as String?) ?? '') ??
          DateTime.tryParse((json['physicalRelease'] as String?) ?? '') ??
          DateTime.tryParse((json['inCinemas'] as String?) ?? ''),
      posterUrl: poster,
    );
  }

  final int id;
  final String title;
  final int year;
  final bool hasFile;
  final int? tmdbId;
  final DateTime? releaseDate;
  final String? posterUrl;
}
