part of 'connection_cubit.dart';

@immutable
sealed class ConnectionCubitState {}

final class ConnectionInitial extends ConnectionCubitState {}

final class ConnectionLoading extends ConnectionCubitState {}

final class ConnectionSuccess extends ConnectionCubitState {
  final ConnectionInfo connectionInfo;
  ConnectionSuccess({required this.connectionInfo});
}

final class ConnectionFailure extends ConnectionCubitState {
  final String errorMessage;
  ConnectionFailure({required this.errorMessage});
}

final class ConnectionDisconnected extends ConnectionCubitState {}