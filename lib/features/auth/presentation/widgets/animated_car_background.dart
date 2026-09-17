import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedCarBackground extends StatefulWidget {
  final Widget child;
  final String imagePath;

  const AnimatedCarBackground({
    super.key,
    required this.child,
    this.imagePath = 'assets/images/cool_car_landing.jpg',
  });

  @override
  State<AnimatedCarBackground> createState() => _AnimatedCarBackgroundState();
}

class _AnimatedCarBackgroundState extends State<AnimatedCarBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // 1. Cool Car Image Layer with Subtle Zoom & Floating Motion
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = 1.05 + (math.sin(_controller.value * math.pi * 2) * 0.03);
            final offsetY = math.cos(_controller.value * math.pi * 2) * 6;

            return Transform.translate(
              offset: Offset(0, offsetY),
              child: Transform.scale(
                scale: scale,
                child: SizedBox.expand(
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),

        // 2. Animated Custom Glow & Speed Particles Overlay
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: GlowParticlesPainter(
                progress: _controller.value,
                isDark: isDark,
              ),
            );
          },
        ),

        // 3. Dark / Light Dynamic Glass Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      const Color(0xCC0D1311),
                      const Color(0x990D1311),
                      const Color(0xE60D1311),
                      const Color(0xFF0D1311),
                    ]
                  : [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.black.withValues(alpha: 0.25),
                      const Color(0xF20F4C3A),
                      const Color(0xFF0F4C3A),
                    ],
              stops: const [0.0, 0.35, 0.75, 1.0],
            ),
          ),
        ),

        // 4. Content Child (Landing text, controls, onboarding step)
        widget.child,
      ],
    );
  }
}

class GlowParticlesPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  GlowParticlesPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);

    // Draw ambient glowing light blobs
    final centerPulse = 0.5 + 0.5 * math.sin(progress * math.pi * 2);
    final glowPaint = Paint()
      ..color = (isDark ? const Color(0xFF00C853) : const Color(0xFF16A34A))
          .withValues(alpha: 0.15 * centerPulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.65),
      size.width * 0.45 * (0.9 + 0.2 * centerPulse),
      glowPaint,
    );

    // Draw animated light particles / speed streaks
    for (int i = 0; i < 24; i++) {
      final startX = rand.nextDouble() * size.width;
      final speed = 0.4 + rand.nextDouble() * 0.6;
      final yPos = ((rand.nextDouble() * size.height) + (progress * size.height * speed)) %
          size.height;
      final length = 15.0 + rand.nextDouble() * 35.0;
      final alpha = (0.2 + 0.5 * math.sin((progress + rand.nextDouble()) * math.pi * 2))
          .clamp(0.05, 0.8);

      final linePaint = Paint()
        ..color = (i % 2 == 0 ? const Color(0xFF00E676) : const Color(0xFF00E5FF))
            .withValues(alpha: alpha)
        ..strokeWidth = 1.5 + rand.nextDouble() * 1.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(startX, yPos),
        Offset(startX + (length * 0.3), yPos - length),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GlowParticlesPainter oldDelegate) => true;
}
