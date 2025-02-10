import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mouse_and_keyboard_remote_controller/core/app_router.dart';
import 'package:mouse_and_keyboard_remote_controller/cubit/connection_cubit.dart';
import 'package:mouse_and_keyboard_remote_controller/theme/my_theme.dart';

void main() {
  runApp(MyApp(appRouter: AppRouter(),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appRouter});
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConnectionCubit(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: myTheme,
          onGenerateRoute: appRouter.generateRoute,
        ),
    );
  }
}