import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:meta/meta.dart';
import 'package:mouse_and_keyboard_remote_controller/models/connection_info.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'connection_state.dart';

class ConnectionCubit extends Cubit<ConnectionCubitState> {
  ConnectionCubit() : super(ConnectionInitial());
  WebSocketChannel? _channel;

  Future<void> connect(String ip, String port) async {
    if (!_isValid(port, ip)) {
      String errorMessage = 'Invalid IP or Port';
      emit(ConnectionFailure(errorMessage: errorMessage));
      return;
    }
    emit(ConnectionLoading());
    _channel = WebSocketChannel.connect(Uri.parse('ws://$ip:$port'));
    try {
      await Future.any([
        _channel!.ready,
        Future.delayed(const Duration(seconds: 10),
            () => throw TimeoutException('Connection timed out')),
      ]);
      ConnectionInfo connectionInfo =
          ConnectionInfo(ip: ip, port: port, channel: _channel!,);
      emit(ConnectionSuccess(connectionInfo: connectionInfo));
      String deviceName = await _getDeviceName();
      _channel!.sink.add('DEVICE_NAME:$deviceName');
      _channel!.stream.listen(
        (message) {
          log('Received: $message');
        },
        onDone: () => emit(ConnectionDisconnected()),
        onError: (error) => emit(ConnectionFailure(errorMessage: error)),
        cancelOnError: true,
      );

    } catch (e) {
      log('A problem has happened');
      emit(ConnectionFailure(errorMessage: e.toString()));
      closeConnection();
    }
  }

  void closeConnection() async {
    log('closing web socket...');
    await _channel?.sink.close();

    log('web socket closed');
    _channel = null;
    emit(ConnectionDisconnected());
  }

  bool _isValid(String port, String ip) {
    final validIp = InternetAddress.tryParse(ip) != null;
    final validPort = int.tryParse(port) != null;
    return validIp && validPort;
  }

  Future<String> _getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return '${androidInfo.brand} ${androidInfo.model}';
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name;
    }

    return 'Unknown Device';
  }
}
