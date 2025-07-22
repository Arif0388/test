import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String? url;
  final File? file;
  const VideoPlayerWidget({super.key, this.url, this.file});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.file != null) {
      _controller = VideoPlayerController.file(widget.file!)
        ..initialize().then((_) {
          setState(() {});
        });
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url!))
        ..initialize().then((_) {
          setState(() {});
        });
    }

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
    return Container(
        margin: const EdgeInsets.only(top: 5),
        width: MediaQuery.of(context).size.width - 10,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(20),
        ),
        height: 300,
        child: Center(
          child: _controller.value.isInitialized
              ? Chewie(
                  controller: _chewieController,
                )
              : const CircularProgressIndicator(),
        ));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ChewieController>(
        '_chewieController', _chewieController));
  }
}
