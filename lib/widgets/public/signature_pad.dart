import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key});

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final List<Offset?> _points = <Offset?>[];

  void _addPoint(Offset point) {
    setState(() {
      _points.add(point);
    });
  }

  void _endStroke() {
    setState(() {
      _points.add(null);
    });
  }

  void _clear() {
    setState(() {
      _points.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text(
              'Tanda Tangan Digital',
              style: TextStyle(
                color: AppColors.slate700,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: _clear,
              child: const Text(
                'Hapus',
                style: TextStyle(color: AppColors.red),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.slate300, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: GestureDetector(
                    onPanStart: (DragStartDetails details) {
                      _addPoint(details.localPosition);
                    },
                    onPanUpdate: (DragUpdateDetails details) {
                      _addPoint(details.localPosition);
                    },
                    onPanEnd: (_) => _endStroke(),
                    child: CustomPaint(
                      painter: _SignaturePainter(points: _points),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Center(
                    child: Text(
                      _points.isEmpty ? 'Tanda tangan di sini' : '',
                      style: const TextStyle(
                        color: AppColors.slate400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter({required this.points});

  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final Paint paint = Paint()
      ..color = AppColors.slate800
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Use a single Path to draw everything in a single draw call.
    // This is hardware-accelerated and vastly faster than calling canvas.drawLine in a loop.
    final Path path = Path();
    bool isStarting = true;

    for (int index = 0; index < points.length; index++) {
      final Offset? point = points[index];
      if (point != null) {
        if (isStarting) {
          path.moveTo(point.dx, point.dy);
          isStarting = false;
        } else {
          path.lineTo(point.dx, point.dy);
        }
      } else {
        isStarting = true;
      }
    }

    // Set paint style to stroke to draw lines
    paint.style = PaintingStyle.stroke;
    paint.strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    // Always return true so that updates in the points array are drawn instantly.
    // Since points are mutated in-place, the list reference remains identical,
    // which caused the old delegate comparison (oldDelegate.points != points) to evaluate to false,
    // causing extreme drawing lag or skipped frames.
    return true;
  }
}
