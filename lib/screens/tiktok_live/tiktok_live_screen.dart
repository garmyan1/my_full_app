import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';

class TikTokLiveScreen extends StatefulWidget {
  const TikTokLiveScreen({Key? key}) : super(key: key);

  @override
  State<TikTokLiveScreen> createState() => _TikTokLiveScreenState();
}

class _TikTokLiveScreenState extends State<TikTokLiveScreen> with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  int _viewerCount = 1234;
  int _giftCount = 0;
  int _likeCount = 0;
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, String>> _comments = [];

  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  bool _commentsVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    )..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _likeAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _likeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _likeAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _commentController.dispose();
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _sendGift() {
    setState(() {
      _giftCount++;
    });
    // TODO: Add gift animation
  }

  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _comments.add({
          'username': 'User${_comments.length + 1}',
          'avatar': 'https://i.pravatar.cc/150?img=${(_comments.length % 70) + 1}',
          'comment': text,
        });
        _commentController.clear();
      });
    }
  }

  void _onLikePressed() {
    setState(() {
      _likeCount++;
    });
    _likeAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen live video
          Positioned.fill(
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),

          // Center animated like boost
          Center(
            child: ScaleTransition(
              scale: _likeAnimation,
              child: const Icon(Icons.favorite, color: Colors.pinkAccent, size: 100),
            ),
          ),

          // Top left: Host profile, viewer count, and like count
          Positioned(
            top: 40,
            left: 16,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  Color(0xFF69C9D0),
                                  Color(0xFFEE1D52),
                                  Color(0xFF69C9D0),
                                ],
                                startAngle: 0.0,
                                endAngle: 6.28318,
                                stops: [0.0, 0.5, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pinkAccent.withOpacity(0.6),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Host Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('$_viewerCount viewers', style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              const Icon(Icons.favorite, color: Colors.pinkAccent, size: 20),
                              const SizedBox(width: 4),
                              Text('$_likeCount', style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom left: Comments with scrolling
          Positioned(
            left: 8,
            bottom: 120,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Comments ${_comments.length}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(
                        _commentsVisible ? Icons.expand_more : Icons.chevron_right,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _commentsVisible = !_commentsVisible;
                        });
                      },
                    ),
                  ],
                ),
                if (_commentsVisible)
                  Container(
                    constraints: const BoxConstraints(minHeight: 150),
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundImage: NetworkImage(comment['avatar']!),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${comment['username']}: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: comment['comment'],
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Gift button and count
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _sendGift,
                  backgroundColor: Colors.pinkAccent,
                  child: const Icon(Icons.card_giftcard),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gifts:  $_giftCount',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          // Bottom interaction bar with like, comment input, and send
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ScaleTransition(
                        scale: _likeAnimation,
                        child: const Icon(Icons.favorite, color: Colors.pinkAccent, size: 32),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.white, size: 32),
                        onPressed: _onLikePressed,
                      ),
                    ],
                  ),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Say something...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.white12,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double progress;

  _SparklePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pinkAccent.withOpacity(1.0 - progress)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * progress;

    for (int i = 0; i < 8; i++) {
      final angle = (2 * 3.141592653589793 * i) / 8;
      final dx = center.dx + radius * cos(angle);
      final dy = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(dx, dy), 4 * (1.0 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}