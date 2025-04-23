import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';

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
                _controller.value.isPlaying ? _controller.pause() : _controller.play();
              });
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: screenSize.width,
                  height: screenSize.height,
                  child: VideoPlayer(_controller),
                ),
                VideoProgressIndicator(_controller, allowScrubbing: true),
                Positioned(
                  bottom: 70, // Increased spacing to avoid overlap with navbar
                  right: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Tombol Like dengan angka like di bawah
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isLiked = !isLiked;
                            if (isLiked) {
                              likeCount++;
                            } else {
                              likeCount--;
                            }
                          });
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.thumb_up,
                              color: isLiked ? Colors.red : Colors.white,
                              size: 30,
                            ),
                            SizedBox(height: 8), // Spasi antara ikon like dan angka
                            Text(
                              '$likeCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20), // Spasi antara like count dan comment
                      // Tombol Comment
                      GestureDetector(
                        onTap: () {
                          print('Comment tapped');
                        },
                        child: Icon(
                          Icons.comment,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Center(child: CircularProgressIndicator());
  }
}