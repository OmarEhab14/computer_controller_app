import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  const MyTextfield({super.key, required this.hintText, required this.controller});
  final String hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
              cursorColor: const Color(0xffe4016b), // Custom cursor color
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[850], // Dark grey background
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xffe4016b),
                      width: 2
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Colors.white54),
                  focusColor: const Color(0xffe4016b)),
              style: const TextStyle(color: Colors.white), // Text color
            );
  }
}