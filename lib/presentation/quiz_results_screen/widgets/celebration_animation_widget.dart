import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Celebration animation widget with pixel-style confetti and bouncing mathematical symbols
class CelebrationAnimationWidget extends StatefulWidget {
  final int score;
  final int totalQuestions;

  const CelebrationAnimationWidget({
    Key? key,
    required this.score,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  State<CelebrationAnimationWidget> createState() =>
      _CelebrationAnimationWidgetState();
}

class _CelebrationAnimationWidgetState extends State<CelebrationAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _symbolController;
  final List<ConfettiParticle> _confettiParticles = [];
  final List<MathSymbol> _mathSymbols = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _symbolController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _initializeParticles();
    _confettiController.forward();
    _symbolController.repeat(reverse: true);
  }

  void _initializeParticles() {
    // Generate confetti particles
    for (int i = 0; i < 50; i++) {
      _confettiParticles.add(
        ConfettiParticle(
          x: _random.nextDouble(),
          y: -0.1,
          color: _getRandomColor(),
          size: _random.nextDouble() * 8 + 4,
          velocity: _random.nextDouble() * 2 + 1,
          rotation: _random.nextDouble() * math.pi * 2,
        ),
      );
    }

    // Generate math symbols
    final symbols = ['+', '-', '×', '÷', '=', '√', '%'];
    for (int i = 0; i < 8; i++) {
      _mathSymbols.add(
        MathSymbol(
          symbol: symbols[_random.nextInt(symbols.length)],
          x: _random.nextDouble() * 0.8 + 0.1,
          y: _random.nextDouble() * 0.6 + 0.2,
          color: _getRandomColor(),
          size: _random.nextDouble() * 20 + 30,
        ),
      );
    }
  }

  Color _getRandomColor() {
    final colors = [
      const Color(0xFF4A90E2),
      const Color(0xFFF39C12),
      const Color(0xFF27AE60),
      const Color(0xFF9B59B6),
      const Color(0xFFE74C3C),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_confettiController, _symbolController]),
      builder: (context, child) {
        return CustomPaint(
          painter: CelebrationPainter(
            confettiParticles: _confettiParticles,
            mathSymbols: _mathSymbols,
            confettiProgress: _confettiController.value,
            symbolProgress: _symbolController.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class ConfettiParticle {
  final double x;
  final double y;
  final Color color;
  final double size;
  final double velocity;
  final double rotation;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.velocity,
    required this.rotation,
  });
}

class MathSymbol {
  final String symbol;
  final double x;
  final double y;
  final Color color;
  final double size;

  MathSymbol({
    required this.symbol,
    required this.x,
    required this.y,
    required this.color,
    required this.size,
  });
}

class CelebrationPainter extends CustomPainter {
  final List<ConfettiParticle> confettiParticles;
  final List<MathSymbol> mathSymbols;
  final double confettiProgress;
  final double symbolProgress;

  CelebrationPainter({
    required this.confettiParticles,
    required this.mathSymbols,
    required this.confettiProgress,
    required this.symbolProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw confetti
    for (var particle in confettiParticles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      final yPos =
          particle.y + (confettiProgress * particle.velocity * size.height);
      if (yPos < size.height) {
        canvas.save();
        canvas.translate(particle.x * size.width, yPos);
        canvas.rotate(particle.rotation + confettiProgress * math.pi * 4);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size,
          ),
          paint,
        );
        canvas.restore();
      }
    }

    // Draw bouncing math symbols
    for (var symbol in mathSymbols) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: symbol.symbol,
          style: TextStyle(
            fontSize: symbol.size,
            fontWeight: FontWeight.bold,
            color: symbol.color.withValues(alpha: 0.3),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final bounce = math.sin(symbolProgress * math.pi) * 20;
      textPainter.paint(
        canvas,
        Offset(
          symbol.x * size.width - textPainter.width / 2,
          symbol.y * size.height - textPainter.height / 2 + bounce,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(CelebrationPainter oldDelegate) => true;
}
