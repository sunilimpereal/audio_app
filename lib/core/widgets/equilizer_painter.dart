import 'package:flutter/material.dart';

class EqualizerPainter extends CustomPainter {
  final List<double> waveform;
  final Color barColor;
  final double barWidthFactor;
  final double barHeightFactor;
  final double barSpacingFactor;

  EqualizerPainter({
    required this.waveform,
    this.barColor = Colors.blueAccent,
    this.barWidthFactor = 2.0,
    this.barHeightFactor = 30.0,
    this.barSpacingFactor = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final int numberOfBars = waveform.length;
    final double barWidth = size.width / (numberOfBars * barWidthFactor);
    final double spacing = barWidth / barSpacingFactor;

    final double totalBarsWidth =
        numberOfBars * barWidth + (numberOfBars - 1) * spacing;
    final double startX = (size.width - totalBarsWidth) / 2;

    for (int i = 0; i < numberOfBars; i++) {
      final double barHeight = waveform[i] * size.height * barHeightFactor;
      final double offsetY = (size.height - barHeight) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            startX + i * (barWidth + spacing),
            offsetY,
            barWidth,
            barHeight,
          ),
          Radius.circular(barWidth / 2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class EqualizerVisualizer extends StatelessWidget {
  final List<double> waveform;
  final Color barColor;
  final double barWidthFactor;
  final double barHeightFactor;
  final double barSpacingFactor;

  const EqualizerVisualizer({
    super.key,
    required this.waveform,
    this.barColor = Colors.blueAccent,
    this.barWidthFactor = 2.0,
    this.barHeightFactor = 30.0,
    this.barSpacingFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 60), // Customize size if needed
      painter: EqualizerPainter(
        waveform: waveform,
        barColor: barColor,
        barWidthFactor: barWidthFactor,
        barHeightFactor: barHeightFactor,
        barSpacingFactor: barSpacingFactor,
      ),
    );
  }
}
