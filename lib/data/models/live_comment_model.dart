class LiveCommentModel {
  final String id;
  final String userId;
  final String username;
  final String message;
  final DateTime timestamp;
  final String? avatar;
  final bool isVerified;
  final bool isModerator;
  final bool isHost;
  final String? userLevel;
  final int? userPoints;
  final String? userBadge;
  final bool isPinned;
  final bool isDeleted;
  final String? replyToId;
  final List<String> mentions;
  final Map<String, dynamic> metadata;

  LiveCommentModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.message,
    required this.timestamp,
    this.avatar,
    this.isVerified = false,
    this.isModerator = false,
    this.isHost = false,
    this.userLevel,
    this.userPoints,
    this.userBadge,
    this.isPinned = false,
    this.isDeleted = false,
    this.replyToId,
    this.mentions = const [],
    this.metadata = const {},
  });

  factory LiveCommentModel.fromJson(Map<String, dynamic> json) {
    return LiveCommentModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      avatar: json['avatar'],
      isVerified: json['isVerified'] ?? false,
      isModerator: json['isModerator'] ?? false,
      isHost: json['isHost'] ?? false,
      userLevel: json['userLevel'],
      userPoints: json['userPoints'],
      userBadge: json['userBadge'],
      isPinned: json['isPinned'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      replyToId: json['replyToId'],
      mentions: List<String>.from(json['mentions'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'avatar': avatar,
      'isVerified': isVerified,
      'isModerator': isModerator,
      'isHost': isHost,
      'userLevel': userLevel,
      'userPoints': userPoints,
      'userBadge': userBadge,
      'isPinned': isPinned,
      'isDeleted': isDeleted,
      'replyToId': replyToId,
      'mentions': mentions,
      'metadata': metadata,
    };
  }

  LiveCommentModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? message,
    DateTime? timestamp,
    String? avatar,
    bool? isVerified,
    bool? isModerator,
    bool? isHost,
    String? userLevel,
    int? userPoints,
    String? userBadge,
    bool? isPinned,
    bool? isDeleted,
    String? replyToId,
    List<String>? mentions,
    Map<String, dynamic>? metadata,
  }) {
    return LiveCommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      isModerator: isModerator ?? this.isModerator,
      isHost: isHost ?? this.isHost,
      userLevel: userLevel ?? this.userLevel,
      userPoints: userPoints ?? this.userPoints,
      userBadge: userBadge ?? this.userBadge,
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
      replyToId: replyToId ?? this.replyToId,
      mentions: mentions ?? this.mentions,
      metadata: metadata ?? this.metadata,
    );
  }

  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get displayName {
    if (isHost) {
      return '$username 👑';
    } else if (isModerator) {
      return '$username 🛡️';
    } else if (isVerified) {
      return '$username ✓';
    } else {
      return username;
    }
  }

  bool get hasSpecialRole => isHost || isModerator || isVerified;
}

