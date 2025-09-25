import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoDialog extends StatefulWidget {
  final String videoId;
  final Color color;
  const VideoDialog({required this.videoId, required this.color, Key? key})
      : super(key: key);

  @override
  State<VideoDialog> createState() => _VideoDialogState();
}

class _VideoDialogState extends State<VideoDialog> {
  YoutubePlayerController? _controller;
  bool _videoError = false;
  bool isDrive = false;

  @override
  void initState() {
    super.initState();
    final id = widget.videoId;
    isDrive = id.length > 20 && !id.contains('http');
    if (!isDrive) {
      if (id.isEmpty) {
        _videoError = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {});
        });
      } else {
        _controller = YoutubePlayerController(
          initialVideoId: id,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      contentPadding: const EdgeInsets.all(8),
      content: isDrive
          ? SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: WebViewWidget(
                  controller: WebViewController()
                    ..setJavaScriptMode(JavaScriptMode.unrestricted)
                    ..loadRequest(Uri.parse('https://drive.google.com/file/d/${widget.videoId}/view?usp=sharing')),
                ),
              ),
            )
          : _videoError
              ? const SizedBox(
                  width: 300,
                  child: Text(
                    'No se pudo cargar el video. URL inválida.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                )
              : SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: YoutubePlayer(
                    controller: _controller!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: widget.color,
                  ),
                ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: widget.color),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
