import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerPage extends StatefulWidget {
  final String url;
  const VideoPlayerPage({super.key, required this.url});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {});
      });

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: false,
      looping: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.red,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.lightGreen,
      ),
      placeholder: Container(
        color: Colors.grey,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Center(
        child: _controller.value.isInitialized
            ? Chewie(
                controller: _chewieController,
              )
            : const CircularProgressIndicator(),
      ),
      Positioned(
          left: 16,
          top: 16,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.blue,
            onPressed: () {
              Navigator.pop(context);
            },
          )),
    ]));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ChewieController>(
        '_chewieController', _chewieController));
  }
}
