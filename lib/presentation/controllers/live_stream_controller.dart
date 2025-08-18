import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/live_stream_model.dart';
import '../../data/models/live_comment_model.dart';
import '../../data/models/live_gift_model.dart';
import '../../core/types/result.dart';
import '../../core/errors/failures.dart';

class LiveStreamController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  LiveStreamModel? _currentStream;
  List<LiveCommentModel> _comments = [];
  List<LiveGiftModel> _gifts = [];
  List<String> _viewers = [];
  bool _isLive = false;
  bool _isLoading = false;
  String? _error;
  
  // Stream statistics
  int _viewerCount = 0;
  int _peakViewerCount = 0;
  int _likeCount = 0;
  int _commentCount = 0;
  int _giftCount = 0;
  double _totalEarnings = 0.0;
  DateTime? _streamStartTime;
  
  // Getters
  LiveStreamModel? get currentStream => _currentStream;
  List<LiveCommentModel> get comments => _comments;
  List<LiveGiftModel> get gifts => _gifts;
  List<String> get viewers => _viewers;
  bool get isLive => _isLive;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get viewerCount => _viewerCount;
  int get peakViewerCount => _peakViewerCount;
  int get likeCount => _likeCount;
  int get commentCount => _commentCount;
  int get giftCount => _giftCount;
  double get totalEarnings => _totalEarnings;
  DateTime? get streamStartTime => _streamStartTime;

  // Initialize controller
  void initialize() {
    _setupStreamListeners();
  }

  // Start a new live stream
  Future<Result<void>> startLiveStream({
    required String title,
    required String description,
    required String category,
    List<String> tags = const [],
    bool isPrivate = false,
    List<String> allowedViewers = const [],
    Map<String, dynamic> settings = const {},
  }) async {
    try {
      _setLoading(true);
      
      final stream = LiveStreamModel(
        id: _generateStreamId(),
        hostId: 'current_user_id', // Get from auth service
        hostUsername: 'Current User', // Get from auth service
        hostAvatar: 'https://picsum.photos/200/200?random=1',
        title: title,
        description: description,
        streamUrl: 'rtmp://stream.example.com/live/stream_${_generateStreamId()}',
        thumbnailUrl: 'https://picsum.photos/400/300?random=${_generateStreamId()}',
        startTime: DateTime.now(),
        isLive: true,
        viewerCount: 0,
        peakViewerCount: 0,
        likeCount: 0,
        commentCount: 0,
        giftCount: 0,
        totalEarnings: 0.0,
        tags: tags,
        category: category,
        isPrivate: isPrivate,
        allowedViewers: allowedViewers,
        settings: settings,
        status: 'live',
        duration: 0,
        quality: '720p',
        hasModerators: false,
        moderatorIds: [],
        allowComments: true,
        allowGifts: true,
        allowDuets: false,
        allowReactions: true,
        language: 'en',
        region: 'US',
        analytics: {},
      );

      // Save to Firestore
      await _firestore
          .collection('live_streams')
          .doc(stream.id)
          .set(stream.toJson());

      _currentStream = stream;
      _isLive = true;
      _streamStartTime = DateTime.now();
      _resetStats();
      _setupStreamListeners();
      
      _setLoading(false);
      notifyListeners();
      
      return Success(null);
    } catch (e) {
      _setLoading(false);
      _setError('Failed to start live stream: $e');
      return ResultFailure(UnknownFailure(message: Exception('Failed to start live stream: $e').toString()));
    }
  }

  // Stop the current live stream
  Future<Result<void>> stopLiveStream() async {
    try {
      if (_currentStream == null) {
        return Success(null);
      }

      _setLoading(true);
      
      final endTime = DateTime.now();
      final duration = endTime.difference(_streamStartTime ?? endTime).inSeconds;
      
      final updatedStream = _currentStream!.copyWith(
        endTime: endTime,
        isLive: false,
        status: 'ended',
        duration: duration,
        viewerCount: _viewerCount,
        peakViewerCount: _peakViewerCount,
        likeCount: _likeCount,
        commentCount: _commentCount,
        giftCount: _giftCount,
        totalEarnings: _totalEarnings,
      );

      // Update in Firestore
      await _firestore
          .collection('live_streams')
          .doc(updatedStream.id)
          .update(updatedStream.toJson());

      _currentStream = updatedStream;
      _isLive = false;
      
      _setLoading(false);
      notifyListeners();
      
      return Success(null);
    } catch (e) {
      _setLoading(false);
      _setError('Failed to stop live stream: $e');
      return ResultFailure(UnknownFailure(message: Exception('Failed to stop live stream: $e').toString()));
    }
  }

  // Add a comment to the live stream
  Future<Result<void>> addComment(String message) async {
    try {
      if (_currentStream == null || !_currentStream!.allowComments) {
        return ResultFailure(UnknownFailure(message: Exception('Cannot add comment').toString()));
      }

      final comment = LiveCommentModel(
        id: _generateCommentId(),
        userId: 'current_user_id', // Get from auth service
        username: 'Current User', // Get from auth service
        message: message,
        timestamp: DateTime.now(),
        avatar: 'https://picsum.photos/200/200?random=1',
      );

      // Save to Firestore
      await _firestore
          .collection('live_streams')
          .doc(_currentStream!.id)
          .collection('comments')
          .doc(comment.id)
          .set(comment.toJson());

      _comments.add(comment);
      _commentCount++;
      
      notifyListeners();
      
      return Success(null);
    } catch (e) {
      _setError('Failed to add comment: $e');
      return ResultFailure(UnknownFailure(message: Exception('Failed to add comment: $e').toString()));
    }
  }

  // Send a gift to the live stream
  Future<Result<void>> sendGift(String giftId, int quantity) async {
    try {
      if (_currentStream == null || !_currentStream!.allowGifts) {
        return ResultFailure(UnknownFailure(message: Exception('Cannot send gift').toString()));
      }

      final gift = _gifts.firstWhere((g) => g.id == giftId);
      final totalCost = gift.price * quantity;

      // Check if user has enough coins/currency
      // This would be implemented with a wallet service
      
      // Save gift to Firestore
      await _firestore
          .collection('live_streams')
          .doc(_currentStream!.id)
          .collection('gifts')
          .add({
        'giftId': giftId,
        'senderId': 'current_user_id', // Get from auth service
        'senderName': 'Current User', // Get from auth service
        'quantity': quantity,
        'totalCost': totalCost,
        'timestamp': DateTime.now().toIso8601String(),
      });

      _giftCount += quantity;
      _totalEarnings += totalCost;
      
      notifyListeners();
      
      return Success(null);
    } catch (e) {
      _setError('Failed to send gift: $e');
      return ResultFailure(UnknownFailure(message: Exception('Failed to send gift: $e').toString()));
    }
  }

  // Like the live stream
  Future<Result<void>> likeStream() async {
    try {
      if (_currentStream == null) {
        return ResultFailure(UnknownFailure(message: Exception('No active stream').toString()));
      }

      _likeCount++;
      
      // Update in Firestore
      await _firestore
          .collection('live_streams')
          .doc(_currentStream!.id)
          .update({'likeCount': _likeCount});
      
      notifyListeners();
      
      return Success(null);
    } catch (e) {
      _setError('Failed to like stream: $e');
      return ResultFailure(UnknownFailure(message: Exception('Failed to like stream: $e').toString()));
    }
  }

  // Join the live stream as a viewer
  Future<Result<void>> joinStream() async {
    try {
      if (_currentStream == null) {
        return ResultFailure(UnknownFailure(message: Exception('No active stream').toString()));
      }

      final viewerId = 'current_user_id'; // Get from auth service
      
      if (!_viewers.contains(viewerId)) {
        _viewers.add(viewerId);
        _viewerCount++;
        
        if (_viewerCount > _peakViewerCount) {
          _peakViewerCount = _viewerCount;
        }
        
        // Update in Firestore
        await _firestore
            .collection('live_streams')
            .doc(_currentStream!.id)
            .update({
          'viewerCount': _viewerCount,
          'peakViewerCount': _peakViewerCount,
        });
        
        notifyListeners();
      }
      
      return Success(null);
    } catch (e) {
      _setError('Failed to join stream: $e');
      return ResultFailure(UnknownFailure(message: Exception('Failed to join stream: $e').toString()));
    }
  }

  // Leave the live stream
  Future<Result<void>> leaveStream() async {
    try {
      if (_currentStream == null) {
        return Success(null);
      }

      final viewerId = 'current_user_id'; // Get from auth service
      
      if (_viewers.contains(viewerId)) {
        _viewers.remove(viewerId);
        _viewerCount = _viewerCount > 0 ? _viewerCount - 1 : 0;
        
        // Update in Firestore
        await _firestore
            .collection('live_streams')
            .doc(_currentStream!.id)
            .update({'viewerCount': _viewerCount});
        
        notifyListeners();
      }
      
      return Success(null);
    } catch (e) {
      _setError('Failed to leave stream: $e');
      return ResultFailure(UnknownFailure(message: Exception('Failed to leave stream: $e').toString()));
    }
  }

  // Load live stream data
  Future<Result<void>> loadLiveStream(String streamId) async {
    try {
      _setLoading(true);
      
      final doc = await _firestore
          .collection('live_streams')
          .doc(streamId)
          .get();
      
      if (!doc.exists) {
        _setError('Stream not found');
        return ResultFailure(UnknownFailure(message: Exception('Stream not found').toString()));
      }

      _currentStream = LiveStreamModel.fromJson(doc.data()!);
      _isLive = _currentStream!.isLive;
      
      if (_isLive) {
        await _loadStreamData(streamId);
      }
      // Start realtime listeners
      _setupStreamListeners();
      
      _setLoading(false);
      notifyListeners();
      
      return Success(null);
    } catch (e) {
      _setLoading(false);
      _setError('Failed to load stream: $e');
      return ResultFailure(UnknownFailure(message: Exception('Failed to load stream: $e').toString()));
    }
  }

  // Load stream data (comments, gifts, viewers)
  Future<void> _loadStreamData(String streamId) async {
    try {
      // Load comments
      final commentsSnapshot = await _firestore
          .collection('live_streams')
          .doc(streamId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();
      
      _comments = commentsSnapshot.docs
          .map((doc) => LiveCommentModel.fromJson(doc.data()))
          .toList();
      
      // Load gifts
      final giftsSnapshot = await _firestore
          .collection('live_streams')
          .doc(streamId)
          .collection('gifts')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      
      // Process gifts to get counts
      _giftCount = giftsSnapshot.docs.length;
      _totalEarnings = giftsSnapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc.data()['totalCost'] ?? 0.0);
      });
      
      // Load available gifts
      await _loadAvailableGifts();
      
      // Load viewers
      final viewersSnapshot = await _firestore
          .collection('live_streams')
          .doc(streamId)
          .collection('viewers')
          .get();
      
      _viewers = viewersSnapshot.docs.map((doc) => doc.id).toList();
      _viewerCount = _viewers.length;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load stream data: $e');
    }
  }

  // Load available gifts
  Future<void> _loadAvailableGifts() async {
    try {
      final giftsSnapshot = await _firestore
          .collection('gifts')
          .where('isAvailable', isEqualTo: true)
          .get();
      
      _gifts = giftsSnapshot.docs
          .map((doc) => LiveGiftModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _setError('Failed to load gifts: $e');
    }
  }

  // Setup real-time listeners
  void _setupStreamListeners() {
    if (_currentStream == null) return;
    
    // Listen for new comments
    _firestore
        .collection('live_streams')
        .doc(_currentStream!.id)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .listen((snapshot) {
      final newComments = snapshot.docs
          .map((doc) => LiveCommentModel.fromJson(doc.data()))
          .toList();
      
      if (newComments.isNotEmpty) {
        _comments = newComments;
        _commentCount = _comments.length;
        notifyListeners();
      }
    });

    // Listen for new gifts
    _firestore
        .collection('live_streams')
        .doc(_currentStream!.id)
        .collection('gifts')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      _giftCount = snapshot.docs.length;
      _totalEarnings = snapshot.docs.fold(0.0, (sum, doc) {
        return sum + (doc.data()['totalCost'] ?? 0.0);
      });
      notifyListeners();
    });

    // Listen for viewer changes
    _firestore
        .collection('live_streams')
        .doc(_currentStream!.id)
        .collection('viewers')
        .snapshots()
        .listen((snapshot) {
      _viewers = snapshot.docs.map((doc) => doc.id).toList();
      _viewerCount = _viewers.length;
      
      if (_viewerCount > _peakViewerCount) {
        _peakViewerCount = _viewerCount;
      }
      
      notifyListeners();
    });
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _resetStats() {
    _viewerCount = 0;
    _peakViewerCount = 0;
    _likeCount = 0;
    _commentCount = 0;
    _giftCount = 0;
    _totalEarnings = 0.0;
    _comments.clear();
    _gifts.clear();
    _viewers.clear();
  }

  String _generateStreamId() {
    return 'stream_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(6)}';
  }

  String _generateCommentId() {
    return 'comment_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(6)}';
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(DateTime.now().millisecond % chars.length),
    ));
  }

  // Cleanup
  @override
  void dispose() {
    // Cleanup listeners and resources
    super.dispose();
  }
}

