import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mouse_and_keyboard_remote_controller/constants/routes.dart';
import 'package:mouse_and_keyboard_remote_controller/cubit/connection_cubit.dart';
import 'package:mouse_and_keyboard_remote_controller/models/connection_info.dart';
import 'package:mouse_and_keyboard_remote_controller/presentation/screens/connection_screen.dart';
import 'package:mouse_and_keyboard_remote_controller/presentation/screens/main_controller_screen.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case connectionScreen:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => ConnectionCubit(),
            child: ConnectionScreen(),
          ),
        );
      case mainScreen:
        final List<Object> args =
            settings.arguments as List<Object>;
        final ConnectionInfo connectionInfo = args[0] as ConnectionInfo;
        final ConnectionCubit cubit = args[1] as ConnectionCubit;
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: cubit,
            child: MainControllerScreen(
              connectionInfo: connectionInfo,
            ),
          ),
        );
    }
  }
}
