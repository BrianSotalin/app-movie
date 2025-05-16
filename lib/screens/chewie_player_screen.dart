import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ChewiePlayerScreen extends StatefulWidget {
  final String videoUrl;

  const ChewiePlayerScreen({super.key, required this.videoUrl});

  @override
  State<ChewiePlayerScreen> createState() => _ChewiePlayerScreenState();
}

class _ChewiePlayerScreenState extends State<ChewiePlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      )
      ..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          aspectRatio: _videoPlayerController.value.aspectRatio,
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
    return Scaffold(
      appBar: AppBar(title: const Text('Reproductor')),
      body: Center(
        child:
            _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const CircularProgressIndicator(),
      ),
    );
  }
}
