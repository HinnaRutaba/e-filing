import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final dynamic video;
  final bool showControls;
  const VideoPlayerScreen({
    super.key,
    required this.video,
    this.showControls = true,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    if (widget.video is String) {
      if ((widget.video as String).startsWith('http')) {
        _videoPlayerController =
            VideoPlayerController.networkUrl(Uri.parse(widget.video));
      } else {
        _videoPlayerController = VideoPlayerController.asset(widget.video);
      }
    } else if (widget.video is File) {
      _videoPlayerController = VideoPlayerController.file(widget.video);
    }
    _videoPlayerController.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: true,
        looping: false,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.showControls
        ? Center(
            child: _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const CircularProgressIndicator(),
          )
        : Center(
            child: _videoPlayerController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
                  )
                : const CircularProgressIndicator(),
          );
  }
}
