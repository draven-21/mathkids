import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Particle background widget with floating animated particles
class ParticleBackgroundWidget extends StatefulWidget {
  const ParticleBackgroundWidget({Key? key}) : super(key: key);

  @override
  State<ParticleBackgroundWidget> createState() =>
      _ParticleBackgroundWidgetState();
}

class _ParticleBackgroundWidgetState extends State<ParticleBackgroundWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final int _particleCount = 30;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Initialize particles with random properties
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(Particle());
    }

    _controller.addListener(() {
      setState(() {
        for (var particle in _particles) {
          particle.update();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return CustomPaint(
      size: size,
      painter: ParticlePainter(
        particles: _particles,
        primaryColor: theme.colorScheme.primary,
        secondaryColor: theme.colorScheme.secondary,
        tertiaryColor: theme.colorScheme.tertiary,
      ),
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double size;
  late double speedX;
  late double speedY;
  late double opacity;
  late int colorIndex;

  Particle() {
    final random = math.Random();
    x = random.nextDouble();
    y = random.nextDouble();
    size = 2 + random.nextDouble() * 6;
    speedX = (random.nextDouble() - 0.5) * 0.002;
    speedY = (random.nextDouble() - 0.5) * 0.002;
    opacity = 0.2 + random.nextDouble() * 0.5;
    colorIndex = random.nextInt(3);
  }

  void update() {
    x += speedX;
    y += speedY;

    // Wrap around screen edges
    if (x < 0) x = 1;
    if (x > 1) x = 0;
    if (y < 0) y = 1;
    if (y > 1) y = 0;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;

  ParticlePainter({
    required this.particles,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      Color color;
      switch (particle.colorIndex) {
        case 0:
          color = primaryColor.withValues(alpha: particle.opacity);
          break;
        case 1:
          color = secondaryColor.withValues(alpha: particle.opacity);
          break;
        default:
          color = tertiaryColor.withValues(alpha: particle.opacity);
      }

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final position = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );

      // Draw particle with glow effect
      canvas.drawCircle(position, particle.size, paint);

      // Draw glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: particle.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(position, particle.size * 2, glowPaint);
    }

    // Draw connecting lines between nearby particles
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final p1 = particles[i];
        final p2 = particles[j];

        final dx = (p1.x - p2.x) * size.width;
        final dy = (p1.y - p2.y) * size.height;
        final distance = math.sqrt(dx * dx + dy * dy);

        if (distance < 150) {
          final opacity = (1 - distance / 150) * 0.15;
          final linePaint = Paint()
            ..color = primaryColor.withValues(alpha: opacity)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;

          canvas.drawLine(
            Offset(p1.x * size.width, p1.y * size.height),
            Offset(p2.x * size.width, p2.y * size.height),
            linePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
