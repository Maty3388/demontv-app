import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player/better_player.dart';
import 'package:better_player/better_player.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;
  const PlayerScreen({super.key, required this.channel});
  @override State<PlayerScreen> createState() => _State();
}

class _State extends State<PlayerScreen> {
  BetterPlayerController? _ctrl;
  bool _hasError = false;
  Timer? _reconnectTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _initPlayer();
  }

  void _initPlayer() {
    _ctrl?.dispose();
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

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network, url,
      headers: headers,
      liveStream: widget.channel.isLive,
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 3000, maxBufferMs: 15000,
        bufferForPlaybackMs: 1500, bufferForPlaybackAfterRebufferMs: 3000,
      ),
    );

    _ctrl = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        fullScreenByDefault: false,
        allowedScreenSleep: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableFullscreen: true,
          enableOverflowMenu: false,
          enablePip: false,
          enableSkips: false,
          enablePlaybackSpeed: false,
          controlBarColor: Colors.black54,
          iconsColor: Colors.white,
          progressBarPlayedColor: AppTheme.accentCyan,
          progressBarHandleColor: AppTheme.accentCyan,
        ),
        eventListener: (e) {
          if (e.betterPlayerEventType == BetterPlayerEventType.exception) {
            if (mounted) setState(() => _hasError = true);
            _reconnectTimer?.cancel();
            _reconnectTimer = Timer(const Duration(seconds: 3), () {
              if (mounted) { setState(() => _hasError = false); _initPlayer(); }
            });
          } else if (e.betterPlayerEventType == BetterPlayerEventType.initialized) {
            if (mounted) setState(() => _hasError = false);
          }
        },
      ),
      betterPlayerDataSource: dataSource,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _ctrl?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: Stack(children: [
      if (_ctrl != null) BetterPlayer(controller: _ctrl!)
      else const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan)),
      if (_hasError) Positioned.fill(child: Container(
        color: Colors.black87,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.signal_wifi_off, color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          const Text('Canal no disponible', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Reconectando...', style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 24),
          const CircularProgressIndicator(color: AppTheme.accentCyan, strokeWidth: 2),
        ]))),
    ]));
}
