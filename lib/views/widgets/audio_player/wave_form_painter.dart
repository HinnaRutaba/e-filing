import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final double progress;
  Color playedColor;
  Color unplayedColor;
  double barWidth;

  WaveformPainter(this.waveformData, this.progress,
      {this.playedColor = Colors.blue,
      this.unplayedColor = Colors.grey,
      this.barWidth = 2});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = unplayedColor
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    int playedLines = (waveformData.length * progress).round();

    double middleY = size.height;

    for (int i = 0; i < waveformData.length; i++) {
      double x = (size.width / waveformData.length) * i;
      double y = middleY - (waveformData[i] * middleY);
      canvas.drawLine(Offset(x, middleY - (y)), Offset(x, y),
          paint..color = i <= playedLines ? playedColor : unplayedColor);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint whenever the data changes
  }
}
