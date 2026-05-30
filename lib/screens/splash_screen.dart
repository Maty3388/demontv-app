import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/update_checker.dart';
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _State();
}

class _State extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        final hasToken = await ApiService.loadToken();
        Navigator.pushReplacementNamed(context, hasToken ? '/profile' : '/login');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) UpdateChecker.check(context);
      }
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: Stack(children: [
      Positioned.fill(child: CustomPaint(painter: _WavePainter())),
      Center(child: FadeTransition(opacity: _fade, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          ShaderMask(blendMode: BlendMode.srcIn, shaderCallback: (b) => const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFAA00)]).createShader(b),
            child: const Icon(Icons.all_inclusive, size: 42, color: Colors.white)),
          const SizedBox(width: 12),
          const Text('DemonTv Plus', style: TextStyle(color: Color(0xFFFFD700), fontSize: 28, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 60),
        const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2.5)),
      ]))),
    ]),
  );
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFF0A0A0A));
    for (int w = 0; w < 6; w++) {
      _drawWave(canvas, size, 0.15 + w * 0.15, const Color(0xFFFFD700), 1.5);
    }
  }
  void _drawWave(Canvas canvas, Size size, double yFraction, Color color, double stroke) {
    final paint = Paint()..color = color.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = stroke;
    for (int i = 0; i < 4; i++) {
      final path = Path();
      final baseY = size.height * yFraction + i * 20.0;
      path.moveTo(0, baseY);
      double x = 0;
      while (x < size.width + 60) { path.cubicTo(x+30, baseY-15, x+60, baseY+15, x+90, baseY); x += 90; }
      canvas.drawPath(path, paint);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter o) => false;
}
