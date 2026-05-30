import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;
  const PlayerScreen({super.key, required this.channel});
  @override State<PlayerScreen> createState() => _State();
}

class _State extends State<PlayerScreen> {
  VideoPlayerController? _ctrl;
  bool _buffering = true;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  @override
  void initState() { super.initState(); _initPlayer(); }

  Future<void> _initPlayer() async {
    final rawUrl = widget.channel.streamUrl;
    final parts = rawUrl.split('|');
    final url = parts[0].trim();
    final headers = <String, String>{'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36'};
    if (parts.length > 1) {
      for (final kv in parts[1].split('&')) {
        final idx = kv.indexOf('=');
        if (idx > 0) headers[kv.substring(0, idx).trim()] = kv.substring(idx + 1).trim();
      }
    }
    headers.addAll(widget.channel.headers);
    _ctrl?.dispose();
    final ctrl = VideoPlayerController.networkUrl(Uri.parse(url), httpHeaders: headers);
    await ctrl.initialize();
    if (!mounted) return;
    setState(() { _ctrl = ctrl; _buffering = false; });
    ctrl.addListener(() {
      if (!mounted) return;
      if (ctrl.value.hasError && _reconnectAttempts < 5) {
        _reconnectTimer?.cancel();
        _reconnectTimer = Timer(const Duration(seconds: 3), () { _reconnectAttempts++; _initPlayer(); });
      } else if (!ctrl.value.hasError) _reconnectAttempts = 0;
    });
    ctrl.play();
  }

  @override
  void dispose() { _reconnectTimer?.cancel(); _ctrl?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: _buffering || _ctrl == null
      ? const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan))
      : GestureDetector(onTap: () => Navigator.pop(context),
          child: SizedBox.expand(child: VideoPlayer(_ctrl!))));
}