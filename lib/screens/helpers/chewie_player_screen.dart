import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../helpers/cast_screen.dart';

class ChewiePlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String name;
  final String imgUrl;

  const ChewiePlayerScreen({
    super.key,
    required this.videoUrl,
    required this.name,
    required this.imgUrl,
  });

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
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            icon: Icon(Icons.cast),
            onPressed: () async {
              // Pausar el video antes de abrir la pantalla Cast
              if (_videoPlayerController.value.isPlaying) {
                await _videoPlayerController.pause();
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CastScreen(
                        videoUrl: widget.videoUrl,
                        name: widget.name,
                        imgUrl: widget.imgUrl,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child:
            _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                ),
      ),
    );
  }
}
