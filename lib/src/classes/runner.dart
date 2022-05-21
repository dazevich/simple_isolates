import 'dart:async';
import 'dart:isolate';

import 'package:logger/logger.dart';
import 'package:simple_isolate/src/classes/simple_isolate_exception.dart';

import '../../simple_isolate.dart';

/// [Command] -  передаваемые изоляту команды, на которые он отреагирует
/// * [Command.close] - закрыть изолят
// TODO: implements Command.pause and Command.resume
enum Command {close}

/// [Runner] - класс, который общается с изолятом
class Runner {
  /// [id] - id изолята
  final String id;
  /// [_controlPort] - объект [ReceivePort], который был передан изоляту.
  /// При закрытии этого порта изолят будет убит.
  final ReceivePort _controlPort;
  /// [_stream] - поток данных от изолята (broadcast)
  final Stream<dynamic> _stream;
  /// [_sendPort] - порт, на который будут передаваться данные для изолята
  final SendPort _sendPort;

  Runner(this.id, this._controlPort, this._stream, this._sendPort);

  /// ## Передача callBack на выполнение
  ///
  /// [Подробнее про Runner.run](https://google.com)
  ///
  /// [run] передает функцию на исполнение в изолят.
  /// **Важно помнить, что изоляты не имеют доступа к переменным и ссылкам из**
  /// **других иззолятов.** В коллбэке, передаваемом в [Request.callBack],
  /// все передаваемые переменные должны быть использованы через [Request.arguments].
  Future<T?> run<T>(Request request) async {
    final result = Completer<T>();
    _stream
        .firstWhere((message) {
      if (message is Answer) {
        final id = message.id;
        return (id == request.id && message.data is T);
      }
      return false;
    })
        .then((value) => result.complete(value.data))
        .timeout(const Duration(seconds: 10), onTimeout: () => result.complete(null));
    _sendPort.send(request);
    return result.future;
  }

  /// [close] - закрыть изолят
  void close() {
    _sendPort.send(Command.close);
    _controlPort.close();
    SimpleIsolates.deleteIsolate(id);
  }
}