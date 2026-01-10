import 'dart:math';
import 'package:flutter/material.dart';

/// Animated math symbols background with polished shapes and slanted animations
/// Fully theme-aware for light and dark modes
class AnimatedMathBackground extends StatefulWidget {
  final Color? symbolColor;
  final double opacity;
  final int symbolCount;
  final double animationSpeed;

  const AnimatedMathBackground({
    Key? key,
    this.symbolColor,
    this.opacity = 0.08,
    this.symbolCount = 20,
    this.animationSpeed = 1.0,
  }) : super(key: key);

  @override
  State<AnimatedMathBackground> createState() => _AnimatedMathBackgroundState();
}

class _AnimatedMathBackgroundState extends State<AnimatedMathBackground>
    with TickerProviderStateMixin {
  late List<MathSymbol> symbols;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initializeSymbols();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: (30 / widget.animationSpeed).round()),
    )..repeat();
  }

  void _initializeSymbols() {
    final random = Random();
    symbols = List.generate(widget.symbolCount, (index) {
      return MathSymbol(
        symbol: _getRandomSymbol(random),
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 20 + random.nextDouble() * 40,
        rotation: random.nextDouble() * pi * 2,
        speed: 0.3 + random.nextDouble() * 0.7,
        angle:
            -pi / 6 + random.nextDouble() * pi / 12, // Slight slant variation
      );
    });
  }

  String _getRandomSymbol(Random random) {
    const symbols = [
      '+',
      '−',
      '×',
      '÷',
      '=',
      '√',
      'π',
      '∞',
      '%',
      '∑',
      '∫',
      '≈',
      '≠',
      '≤',
      '≥',
      '²',
      '³',
      '½',
      '¼',
      '¾',
    ];
    return symbols[random.nextInt(symbols.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = widget.symbolColor ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: MathSymbolPainter(
            symbols: symbols,
            progress: _controller.value,
            color: effectiveColor.withOpacity(widget.opacity),
          ),
          child: Container(),
        );
      },
    );
  }
}

class MathSymbol {
  final String symbol;
  final double x;
  final double y;
  final double size;
  final double rotation;
  final double speed;
  final double angle; // Slant angle for movement

  MathSymbol({
    required this.symbol,
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.speed,
    required this.angle,
  });
}

class MathSymbolPainter extends CustomPainter {
  final List<MathSymbol> symbols;
  final double progress;
  final Color color;

  MathSymbolPainter({
    required this.symbols,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (final symbol in symbols) {
      // Calculate position with slanted movement
      final animatedProgress = (progress * symbol.speed) % 1.0;
      final dx =
          symbol.x * size.width +
          (cos(symbol.angle) * animatedProgress * size.height * 0.3);
      final dy =
          symbol.y * size.height +
          (sin(symbol.angle) * animatedProgress * size.height);

      // Wrap around screen
      final wrappedDx = dx % size.width;
      final wrappedDy = dy % size.height;

      canvas.save();
      canvas.translate(wrappedDx, wrappedDy);
      canvas.rotate(symbol.rotation + (progress * pi * 2 * 0.1));

      // Create polished text with subtle shadow
      textPainter.text = TextSpan(
        text: symbol.symbol,
        style: TextStyle(
          fontSize: symbol.size,
          fontWeight: FontWeight.w700,
          color: color,
          shadows: [
            Shadow(
              color: color.withOpacity(0.3),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(MathSymbolPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
