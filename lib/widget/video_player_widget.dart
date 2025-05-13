import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';

import '../search_page.dart'; // pastikan SearchPage dibuat

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool isLiked = false;
  int likeCount = 100 + (Random().nextInt(900));

  final String username = "@user${Random().nextInt(999)}";
  final String caption = "Gak nyangka gerakan ini bisa sekeren itu 😱🔥\nKalau kamu bisa ngikutin, duet yuk!\n#dancechallenge #foryoupage #gerakankeren #viral";

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return _controller.value.isInitialized
        ? GestureDetector(
            onTap: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            child: Stack(
              children: [
                // VIDEO
                SizedBox(
                  width: screenSize.width,
                  height: screenSize.height,
                  child: VideoPlayer(_controller),
                ),

                // SEARCH BAR STATIC TENGAH ATAS, TAP-TO-NAVIGATE
                Positioned(
                  top: 20,
                  left: 24,
                  right: 24,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SearchPage()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Search / For You',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(color: Colors.black26, blurRadius: 2)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // CAPTION & USERNAME DI BAGIAN PALING BAWAH
                Positioned(
                  bottom: 10,
                  left: 16,
                  right: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        caption,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ],
                  ),
                ),

                // TOMBOL LIKE & COMMENT
                Positioned(
                  bottom: 80,
                  right: 20,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isLiked = !isLiked;
                            likeCount += isLiked ? 1 : -1;
                          });
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.thumb_up,
                              color: isLiked ? Colors.red : Colors.white,
                              size: 30,
                            ),
                            SizedBox(height: 6),
                            Text(
                              '$likeCount',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Icon(Icons.comment, color: Colors.white, size: 30),
                    ],
                  ),
                ),

                // PROGRESS BAR VIDEO
                Align(
                  alignment: Alignment.bottomCenter,
                  child: VideoProgressIndicator(_controller, allowScrubbing: true),
                ),
              ],
            ),
          )
        : Center(child: CircularProgressIndicator());
  }
}
