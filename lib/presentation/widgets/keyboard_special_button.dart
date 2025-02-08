import 'package:flutter/material.dart';
import 'package:mouse_and_keyboard_remote_controller/constants/my_colors.dart';

class KeyboardSpecialButton extends StatefulWidget {
  final Function? onTapDown;
  final Function? onTapUp;
  final VoidCallback? onTap;
  final Widget child;
  final bool isFocused; // Allows focus-based color changes

  const KeyboardSpecialButton({
    super.key,
    required this.child,
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.isFocused = false,
  });

  @override
  _KeyboardSpecialButtonState createState() => _KeyboardSpecialButtonState();
}

class _KeyboardSpecialButtonState extends State<KeyboardSpecialButton> {
  bool _isActive = false; // Tracks button press state

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isActive = true;
    });
    if (widget.onTapDown != null) widget.onTapDown!();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isActive = false;
    });
    if (widget.onTapUp != null) widget.onTapUp!();
  }

  void _handleTapCancel() {
    setState(() {
      _isActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic foreground color based on state
    Color foregroundColor = _isActive || widget.isFocused
        ? MyColors.primaryColor
        : Colors.grey[300]!;
    Color backgroundColor = _isActive
    ? Colors.grey[800]!
    : Colors.grey[900]!;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTap: widget.onTap,
      onTapCancel: _handleTapCancel,
      child: Container(
        width: 70,
        decoration: BoxDecoration(
          color: backgroundColor, // Background color
        ),
        child: Center(
          child: DefaultTextStyle(
            style: TextStyle(color: foregroundColor), // Applies to text
            child: IconTheme(
              data: IconThemeData(color: foregroundColor), // Applies to icons
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
