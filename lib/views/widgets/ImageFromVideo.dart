import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ImageShowFromVideo extends StatefulWidget {
  final String videoUrl;

  const ImageShowFromVideo({Key key, this.videoUrl}) : super(key: key);
  @override
  _ImageShowFromVideoState createState() => _ImageShowFromVideoState();
}

class _ImageShowFromVideoState extends State<ImageShowFromVideo> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _controller.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(aspectRatio: 2 / 3, child: VideoPlayer(_controller)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topRight,
            child: Icon(Icons.play_circle_outline_sharp, color: Colors.grey,),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
