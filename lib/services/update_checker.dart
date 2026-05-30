import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  static const _apiUrl = 'http://149.104.92.205:25461/app/version?type=mobile';

  static Future<void> check(BuildContext context) async {
    try {
      final r = await http.get(Uri.parse(_apiUrl)).timeout(const Duration(seconds: 5));
      if (r.statusCode != 200) return;
      final data = jsonDecode(r.body);
      final info = await PackageInfo.fromPlatform();
      final current = info.version;
      final latest = (data['version'] ?? '1.0.0').replaceAll(RegExp(r'[^0-9.]'), '');
      final apkUrl = data['apkUrl'] ?? '';
      if (apkUrl.isEmpty) return;
      if (_isNewer(latest, current) && context.mounted) {
        _showDialog(context, latest, data['changelog'] ?? '', apkUrl, data['forceUpdate'] == true);
      }
    } catch (_) {}
  }

  static bool _isNewer(String latest, String current) {
    final l = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final c = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (int i = 0; i < 3; i++) {
      final li = i < l.length ? l[i] : 0;
      final ci = i < c.length ? c[i] : 0;
      if (li > ci) return true;
      if (li < ci) return false;
    }
    return false;
  }

  static void _showDialog(BuildContext ctx, String version, String changelog, String apkUrl, bool force) {
    showDialog(
      context: ctx,
      barrierDismissible: !force,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: Text('Nueva version $version', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(changelog.isNotEmpty ? changelog : 'Hay una nueva version disponible.', style: const TextStyle(color: Colors.grey)),
        actions: [
          if (!force) TextButton(onPressed: () => Navigator.pop(c), child: const Text('Despues', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00CFDD)),
            onPressed: () async {
              Navigator.pop(c);
              final uri = Uri.parse(apkUrl);
              if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            child: const Text('Actualizar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}