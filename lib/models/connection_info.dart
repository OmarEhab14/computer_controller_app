import 'package:web_socket_channel/web_socket_channel.dart';

class ConnectionInfo {
  final String ip;
  final String port;
  final WebSocketChannel channel;
  ConnectionInfo({required this.ip, required this.port, required this.channel});

}