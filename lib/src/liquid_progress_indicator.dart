import 'package:flutter/material.dart';

import 'wave.dart';

/// 液体线性进度指示器
class LiquidLinearProgressIndicator extends ProgressIndicator {
  ///The width of the border, if this is set [borderColor] must also be set.
  final double? borderWidth;

  ///The color of the border, if this is set [borderWidth] must also be set.
  final Color? borderColor;

  ///The radius of the border.
  final double? borderRadius;

  ///The widget to show in the center of the progress indicator.
  final Widget? center;

  ///The direction the liquid travels.
  final Axis direction;

  LiquidLinearProgressIndicator({
    super.key,
    double super.value = 0.5,
    super.backgroundColor,
    Animation<Color>? super.valueColor,
    this.borderWidth,
    this.borderColor,
    this.borderRadius,
    this.center,
    this.direction = Axis.horizontal,
  }) {
    if (borderWidth != null && borderColor == null ||
        borderColor != null && borderWidth == null) {
      throw ArgumentError("borderWidth and borderColor should both be set.");
    }
  }

  Color _getBackgroundColor(BuildContext context) =>
      backgroundColor ??
      const Color(0x0000BFFF); //Theme.of(context).backgroundColor;

  Color _getValueColor(BuildContext context) =>
      valueColor?.value ??
      const Color(0x6600BFFF); //Theme.of(context).accentColor;

  @override
  State<StatefulWidget> createState() => _LiquidLinearProgressIndicatorState();
}

class _LiquidLinearProgressIndicatorState
    extends State<LiquidLinearProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _LinearClipper(
        radius: widget.borderRadius,
      ),
      child: CustomPaint(
        painter: _LinearPainter(
          color: widget._getBackgroundColor(context),
          radius: widget.borderRadius,
        ),
        foregroundPainter: _LinearBorderPainter(
          color: widget.borderColor,
          width: widget.borderWidth,
          radius: widget.borderRadius,
        ),
        child: Stack(
          children: <Widget>[
            Wave(
              value: widget.value ?? 0,
              color: widget._getValueColor(context),
              direction: widget.direction,
            ),
            widget.center != null ? Center(child: widget.center) : Container(),
          ],
        ),
      ),
    );
  }
}

class _LinearPainter extends CustomPainter {
  final Color color;
  final double? radius;

  _LinearPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius ?? 0),
        ),
        paint);
  }

  @override
  bool shouldRepaint(_LinearPainter oldDelegate) => color != oldDelegate.color;
}

class _LinearBorderPainter extends CustomPainter {
  final Color? color;
  final double? width;
  final double? radius;

  _LinearBorderPainter({
    required this.color,
    required this.width,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (color == null || width == null) {
      return;
    }

    final paint = Paint()
      ..color = color!
      ..style = PaintingStyle.stroke
      ..strokeWidth = width!;
    final alteredRadius = radius ?? 0;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(width! / 2, width! / 2, size.width - width!,
              size.height - width!),
          Radius.circular(alteredRadius - width!),
        ),
        paint);
  }

  @override
  bool shouldRepaint(_LinearBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      width != oldDelegate.width ||
      radius != oldDelegate.radius;
}

class _LinearClipper extends CustomClipper<Path> {
  final double? radius;

  _LinearClipper({required this.radius});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius ?? 0),
        ),
      );
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
