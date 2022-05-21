import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'dart:isolate';
import 'classes/answer.dart';
import 'classes/request.dart';

/// [Command] -  передаваемые изоляту команды, на которые он отреагирует
/// * [Command.close] - закрыть изолят
// TODO: implements Command.pause and Command.resume
enum Command {close}

/// [Runner] - класс, который общается с изолятом
class Runner {
  /// [_controlPort] - объект [ReceivePort], который был передан изоляту.
  /// При закрытии этого порта изолят будет убит.
  final ReceivePort _controlPort;
  /// [_stream] - поток данных от изолята (broadcast)
  final Stream<dynamic> _stream;
  /// [_sendPort] - порт, на который будут передаваться данные для изолята
  final SendPort _sendPort;

  Runner(this._controlPort, this._stream, this._sendPort);

  /// ## Передача callBack на выполнение
  ///
  /// [Подробнее про Runner.run](https://google.com)
  ///
  /// [run] передает функцию на исполнение в изолят.
  /// **Важно помнить, что изоляты не имеют доступа к переменным и ссылкам из**
  /// **других иззолятов.** В коллбэке, передаваемом в [Request.callBack],
  /// все передаваемые переменные должны быть использованы через [Request.arguments].
  Future<T?> run<T>(Request<T> request) async {
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
    // _controlPort.close();
  }
}

class SimpleIsolates {
  static Future<Runner> getRunner() async {
    final runner = Completer<Runner>();
    final port = ReceivePort();
    final stream = port.asBroadcastStream();
    StreamSubscription? sb;

    sb = stream.listen((message) {
      if (message is SendPort) {
        runner.complete(Runner(port, stream, message));
        sb?.cancel();
      }
    });

    Isolate.spawn(_createIsolate, port.sendPort);
    return runner.future;
  }
}

void _createIsolate(SendPort receiver) {
  final logger = Logger(
    printer: PrettyPrinter(methodCount: 1, printEmojis: true),
    level: Level.debug,
  );
  final id = const Uuid().v1().split('-').first;
  bool isPause = false;
  logger.d('[$id] >>> hello');
  StreamSubscription? listener;
  Capability? capability;
  final port = ReceivePort();
  receiver.send(port.sendPort);
  listener = port.listen((message) {
    logger.d("[$id] >>> Receive new message: $message");
    if(message is RequestSync) {
      final result = message.callBack(message.arguments);
      receiver.send(Answer(message.id, result));
    } else if(message is RequestAsync) {
      final result = message.callBack(message.arguments).then((data){
        receiver.send(Answer(message.id, data));
      });
    }
    else if (message is Command) {
      switch(message){

        case Command.close:
          logger.d('[$id] >>> bye');
          break;
        default:
          logger.e('[$id] >>> unexpected command: $message');
      }
    } else {
      logger.e('[$id] >>> unexpected message: $message');
    }
  });
}
