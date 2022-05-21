import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

typedef SyncCallback<T> = T Function(Map<String, dynamic>);
typedef AsyncCallback<T> = Future<T> Function(Map<String, dynamic>);

abstract class Request<T> {
  abstract final Map<String, dynamic> arguments;
  abstract final String id;
  abstract final Function(Map<String, dynamic> arguments) callBack;

  @override
  String toString() {
    return '\nRequest-id: $id\nArguments: $arguments\n$callBack';
  }
}

class RequestSync<T> extends Request {
  @override
  final Map<String, dynamic> arguments;
  @override
  final String id;
  @override
  final SyncCallback<T> callBack;

  RequestSync({
    required this.arguments,
    required this.callBack,
  }) : id = const Uuid().v4();
}

class RequestAsync<T> extends Request {
  @override
  final Map<String, dynamic> arguments;
  @override
  final String id;
  @override
  final AsyncCallback<T> callBack;

  RequestAsync({
    required this.arguments,
    required this.callBack,
  }) : id = const Uuid().v4();

  @override
  String toString() {
    return '\nRequest-id: $id\nArguments: $arguments\n$callBack';
  }
}