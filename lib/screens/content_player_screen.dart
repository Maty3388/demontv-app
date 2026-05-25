import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ContentPlayerScreen extends StatefulWidget {
  final Content content;
  final Episode? episode;
  const ContentPlayerScreen({super.key, required this.content, this.episode});
  @override State<ContentPlayerScreen> createState() => _State();
}

class _State extends State<ContentPlayerScreen> {
  VideoPlayerController? _ctrl;
  bool _buffering = true, _playing = false;
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final url = (widget.episode?.streamUrl ?? widget.content.streamUrl ?? '').split('|')[0].trim();
    if (url.isEmpty) return;
    final ctrl = VideoPlayerController.networkUrl(Uri.parse(url),
      httpHeaders: {'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36'});
    ctrl.addListener(() {
      if (!mounted) return;
      setState(() {
        _pos = ctrl.value.position;
        _dur = ctrl.value.duration;
        _buffering = ctrl.value.isBuffering;
        _playing = ctrl.value.isPlaying;
      });
    });
    await ctrl.initialize();
    if (!mounted) return;
    setState(() { _ctrl = ctrl; _buffering = false; });
    ctrl.play();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _ctrl?.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
    return h > 0 ? '$h:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}' : '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: GestureDetector(
      onTap: _toggleControls,
      child: Stack(children: [
        if (_ctrl != null && _ctrl!.value.isInitialized)
          Center(child: AspectRatio(aspectRatio: _ctrl!.value.aspectRatio, child: VideoPlayer(_ctrl!)))
        else
          const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan)),
        if (_buffering)
          const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan)),
        if (_showControls) ...[
          Positioned(top: 0, left: 0, right: 0,
            child: AppBar(backgroundColor: Colors.black54, title: Text(widget.episode?.title ?? widget.content.title))),
          Positioned(bottom: 0, left: 0, right: 0,
            child: Container(color: Colors.black54, padding: const EdgeInsets.all(8), child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (_dur.inSeconds > 0) VideoProgressIndicator(_ctrl!, allowScrubbing: true, colors: const VideoProgressColors(playedColor: AppTheme.accentCyan)),
              Row(children: [
                IconButton(icon: Icon(_playing ? Icons.pause : Icons.play_arrow, color: Colors.white), onPressed: () => _playing ? _ctrl?.pause() : _ctrl?.play()),
                Text('${_fmt(_pos)} / ${_fmt(_dur)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ]),
            ]))),
        ],
      ])));
}
