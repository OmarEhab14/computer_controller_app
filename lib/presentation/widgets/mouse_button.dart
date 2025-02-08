import 'package:flutter/material.dart';

class MouseButton extends StatelessWidget {
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCallback? onTapCancel;
  const MouseButton({super.key, this.onTap, this.onDoubleTap, this.onTapDown, this.onTapUp, this.onTapCancel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: Colors.grey[400]!,
            width: 1,
          ),
        ),
        height: 55,
      ),
    );
  }
}
