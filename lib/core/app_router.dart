import 'package:flutter/material.dart';
import 'package:mouse_and_keyboard_remote_controller/constants/routes.dart';
import 'package:mouse_and_keyboard_remote_controller/models/connection_info.dart';
import 'package:mouse_and_keyboard_remote_controller/presentation/screens/connection_screen.dart';
import 'package:mouse_and_keyboard_remote_controller/presentation/screens/main_controller_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case connectionScreen:
        return MaterialPageRoute(
          builder: (context) => ConnectionScreen(),
        );
      case mainScreen:
        final ConnectionInfo connectionInfo = settings.arguments as ConnectionInfo;
        return MaterialPageRoute(
          builder: (context) => MainControllerScreen(
            connectionInfo: connectionInfo,
          ),
        );
    }
    return null;
  }
}
