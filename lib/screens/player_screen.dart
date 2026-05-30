import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;
  const PlayerScreen({super.key, required this.channel});
  @override State<PlayerScreen> createState() => _State();
}

class _State extends State<PlayerScreen> {
  late final Player _player;
  late final VideoController _ctrl;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _ctrl = VideoController(_player);
    _initPlayer();
  }

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
    await _player.open(Media(url, httpHeaders: headers));
    _player.play();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Center(child: Video(controller: _ctrl))));
}