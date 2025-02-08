import 'package:flutter/material.dart';
import 'package:mouse_and_keyboard_remote_controller/constants/my_colors.dart';

class MyAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  const MyAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromWidth(double.infinity),
      child: AppBar(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.white,
              ),
            ),
            actions: actions,
            elevation: 0,
            backgroundColor: MyColors.primaryColor,
          ),
    );
  }
}