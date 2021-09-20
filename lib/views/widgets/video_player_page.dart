
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoPlayerController videoPlayerController;

  const VideoPlayerScreen({Key key, this.videoPlayerController})
      : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.videoPlayerController;

    _controller.addListener(() {
      setState(() {});
    });

    _controller.setLooping(true);

    _controller.initialize().then((_) => setState(() {
          // _controller.seekTo(Duration(seconds: 1));
        }));

    _controller.pause();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: Key("unique key"),
        onVisibilityChanged: (VisibilityInfo info) {
          // var visiblePercentage = visibilityInfo.visibleFraction * 100;
          debugPrint("${info.visibleFraction} of my widget is visible");
          if (info.visibleFraction == 0) {
            _controller.pause();
          // } else if (info.visibleFraction > 0.9) {
          //   _controller.play();
          // } else {
          //   _controller.play();
          }
        },
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 1.0),
              child: Container(
                  child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    VideoPlayer(_controller),
                    _PlayPauseOverlay(controller: _controller),
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                          playedColor: Colors.grey[800],
                          backgroundColor: Colors.black),
                    ),
                  ],
                ),
              )),
            ),
          ],
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    // _controller.pause();
    super.dispose();
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 50.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}

