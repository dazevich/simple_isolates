import 'package:uuid/uuid.dart';


abstract class Request<T> {
  abstract final Map<String, dynamic> arguments;
  abstract final String id;
  abstract final dynamic Function(Map<String, dynamic> arguments) callBack;

  @override
  String toString() {
    return '\nRequest-id: $id\nArguments: $arguments\n$callBack';
  }
}

class RequestSync<T> extends Request {
  final Map<String, dynamic> arguments;
  final String id;
  final T Function(Map<String, dynamic> arguments) callBack;

  RequestSync({
    required this.arguments,
    required this.callBack,
  }) : id = const Uuid().v4();
}

class RequestAsync<T> extends Request {
  final Map<String, dynamic> arguments;
  final String id;
  final Future<T> Function(Map<String, dynamic> arguments) callBack;

  RequestAsync({
    required this.arguments,
    required this.callBack,
  }) : id = const Uuid().v4();

  @override
  String toString() {
    return '\nRequest-id: $id\nArguments: $arguments\n$callBack';
  }
}