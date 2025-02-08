import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mouse_and_keyboard_remote_controller/constants/my_colors.dart';
import 'package:mouse_and_keyboard_remote_controller/constants/routes.dart';
import 'package:mouse_and_keyboard_remote_controller/cubit/connection_cubit.dart';
import 'package:mouse_and_keyboard_remote_controller/models/connection_info.dart';
import 'package:mouse_and_keyboard_remote_controller/presentation/widgets/my_textfield.dart';

class ConnectionScreen extends StatelessWidget {
  ConnectionScreen({super.key});

  final TextEditingController _ipController = TextEditingController();

  final TextEditingController _portController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionCubit, ConnectionCubitState>(
      listener: (context, state) {
        if (state is ConnectionSuccess) {
          ConnectionInfo connectionInfo = state.connectionInfo;
          ConnectionCubit cubit = context.read<ConnectionCubit>();
          
          Navigator.pushReplacementNamed(context, mainScreen,
              arguments: [connectionInfo, cubit],);
        } else if (state is ConnectionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage, style: const TextStyle(
                color: Colors.white
              ),),
              backgroundColor: Colors.red,
              
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            'Connect to Server',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.white,
            ),
          ),
          elevation: 0,
          backgroundColor: MyColors.primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(15, 30, 15, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('IP Address'),
              const SizedBox(
                height: 10,
              ),
              MyTextfield(
                hintText: 'IP Address...',
                controller: _ipController,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text('Port number'),
              const SizedBox(
                height: 10,
              ),
              MyTextfield(
                hintText: 'Port Number...',
                controller: _portController,
              ),
              const SizedBox(
                height: 15,
              ),
              const Expanded(child: SizedBox()),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      String ip = _ipController.text.trim();
                      String port = _portController.text.trim();
                      BlocProvider.of<ConnectionCubit>(context)
                          .connect(ip, port);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.primaryColor,
                      padding: const EdgeInsets.all(12),
                    ),
                    child: BlocBuilder<ConnectionCubit, ConnectionCubitState>(
                      builder: (context, state) {
                        if (state is ConnectionLoading) {
                          return const CircularProgressIndicator(
                            color: Colors.white,
                          );
                        } else {
                          return const Text(
                            'Connect',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
