class LiveStreamModel {
  final String id;
  final String hostId;
  final String hostUsername;
  final String hostAvatar;
  final String title;
  final String description;
  final String streamUrl;
  final String thumbnailUrl;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isLive;
  final int viewerCount;
  final int peakViewerCount;
  final int likeCount;
  final int commentCount;
  final int giftCount;
  final double totalEarnings;
  final List<String> tags;
  final String category;
  final bool isPrivate;
  final List<String> allowedViewers;
  final Map<String, dynamic> settings;
  final String status; // 'scheduled', 'live', 'ended', 'paused'
  final int duration; // in seconds
  final String quality; // '720p', '1080p', etc.
  final bool hasModerators;
  final List<String> moderatorIds;
  final bool allowComments;
  final bool allowGifts;
  final bool allowDuets;
  final bool allowReactions;
  final String language;
  final String region;
  final Map<String, dynamic> analytics;

  LiveStreamModel({
    required this.id,
    required this.hostId,
    required this.hostUsername,
    required this.hostAvatar,
    required this.title,
    required this.description,
    required this.streamUrl,
    required this.thumbnailUrl,
    required this.startTime,
    this.endTime,
    required this.isLive,
    required this.viewerCount,
    required this.peakViewerCount,
    required this.likeCount,
    required this.commentCount,
    required this.giftCount,
    required this.totalEarnings,
    required this.tags,
    required this.category,
    required this.isPrivate,
    required this.allowedViewers,
    required this.settings,
    required this.status,
    required this.duration,
    required this.quality,
    required this.hasModerators,
    required this.moderatorIds,
    required this.allowComments,
    required this.allowGifts,
    required this.allowDuets,
    required this.allowReactions,
    required this.language,
    required this.region,
    required this.analytics,
  });

  factory LiveStreamModel.fromJson(Map<String, dynamic> json) {
    return LiveStreamModel(
      id: json['id'] ?? '',
      hostId: json['hostId'] ?? '',
      hostUsername: json['hostUsername'] ?? '',
      hostAvatar: json['hostAvatar'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      streamUrl: json['streamUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      isLive: json['isLive'] ?? false,
      viewerCount: json['viewerCount'] ?? 0,
      peakViewerCount: json['peakViewerCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      giftCount: json['giftCount'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'] ?? '',
      isPrivate: json['isPrivate'] ?? false,
      allowedViewers: List<String>.from(json['allowedViewers'] ?? []),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      status: json['status'] ?? 'scheduled',
      duration: json['duration'] ?? 0,
      quality: json['quality'] ?? '720p',
      hasModerators: json['hasModerators'] ?? false,
      moderatorIds: List<String>.from(json['moderatorIds'] ?? []),
      allowComments: json['allowComments'] ?? true,
      allowGifts: json['allowGifts'] ?? true,
      allowDuets: json['allowDuets'] ?? false,
      allowReactions: json['allowReactions'] ?? true,
      language: json['language'] ?? 'en',
      region: json['region'] ?? 'US',
      analytics: Map<String, dynamic>.from(json['analytics'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostId': hostId,
      'hostUsername': hostUsername,
      'hostAvatar': hostAvatar,
      'title': title,
      'description': description,
      'streamUrl': streamUrl,
      'thumbnailUrl': thumbnailUrl,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isLive': isLive,
      'viewerCount': viewerCount,
      'peakViewerCount': peakViewerCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'giftCount': giftCount,
      'totalEarnings': totalEarnings,
      'tags': tags,
      'category': category,
      'isPrivate': isPrivate,
      'allowedViewers': allowedViewers,
      'settings': settings,
      'status': status,
      'duration': duration,
      'quality': quality,
      'hasModerators': hasModerators,
      'moderatorIds': moderatorIds,
      'allowComments': allowComments,
      'allowGifts': allowGifts,
      'allowDuets': allowDuets,
      'allowReactions': allowReactions,
      'language': language,
      'region': region,
      'analytics': analytics,
    };
  }

  LiveStreamModel copyWith({
    String? id,
    String? hostId,
    String? hostUsername,
    String? hostAvatar,
    String? title,
    String? description,
    String? streamUrl,
    String? thumbnailUrl,
    DateTime? startTime,
    DateTime? endTime,
    bool? isLive,
    int? viewerCount,
    int? peakViewerCount,
    int? likeCount,
    int? commentCount,
    int? giftCount,
    double? totalEarnings,
    List<String>? tags,
    String? category,
    bool? isPrivate,
    List<String>? allowedViewers,
    Map<String, dynamic>? settings,
    String? status,
    int? duration,
    String? quality,
    bool? hasModerators,
    List<String>? moderatorIds,
    bool? allowComments,
    bool? allowGifts,
    bool? allowDuets,
    bool? allowReactions,
    String? language,
    String? region,
    Map<String, dynamic>? analytics,
  }) {
    return LiveStreamModel(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      hostUsername: hostUsername ?? this.hostUsername,
      hostAvatar: hostAvatar ?? this.hostAvatar,
      title: title ?? this.title,
      description: description ?? this.description,
      streamUrl: streamUrl ?? this.streamUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isLive: isLive ?? this.isLive,
      viewerCount: viewerCount ?? this.viewerCount,
      peakViewerCount: peakViewerCount ?? this.peakViewerCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      giftCount: giftCount ?? this.giftCount,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      isPrivate: isPrivate ?? this.isPrivate,
      allowedViewers: allowedViewers ?? this.allowedViewers,
      settings: settings ?? this.settings,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      quality: quality ?? this.quality,
      hasModerators: hasModerators ?? this.hasModerators,
      moderatorIds: moderatorIds ?? this.moderatorIds,
      allowComments: allowComments ?? this.allowComments,
      allowGifts: allowGifts ?? this.allowGifts,
      allowDuets: allowDuets ?? this.allowDuets,
      allowReactions: allowReactions ?? this.allowReactions,
      language: language ?? this.language,
      region: region ?? this.region,
      analytics: analytics ?? this.analytics,
    );
  }

  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get formattedViewerCount {
    if (viewerCount >= 1000000) {
      return '${(viewerCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewerCount >= 1000) {
      return '${(viewerCount / 1000).toStringAsFixed(1)}K';
    } else {
      return viewerCount.toString();
    }
  }

  String get formattedLikeCount {
    if (likeCount >= 1000000) {
      return '${(likeCount / 1000000).toStringAsFixed(1)}M';
    } else if (likeCount >= 1000) {
      return '${(likeCount / 1000).toStringAsFixed(1)}K';
    } else {
      return likeCount.toString();
    }
  }

  String get formattedEarnings {
    return '\$${totalEarnings.toStringAsFixed(2)}';
  }

  bool get isEnded => status == 'ended';
  bool get isScheduled => status == 'scheduled';
  bool get isPaused => status == 'paused';
}

