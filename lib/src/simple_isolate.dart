import 'dart:async';
import 'package:simple_isolate/src/classes/simple_isolate_exception.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'dart:isolate';
import 'classes/answer.dart';
import 'classes/request.dart';
import 'classes/runner.dart';

/// ## [SimpleIsolates]
/// [Подробнее про SimpleIsolates](https://google.com)
///
/// [SimpleIsolates] - класс, реализующий доступ к открытым изолятам и предоставляющий
/// апи для создания новых.
class SimpleIsolates {
  static final _runners = <String, Runner>{};

  static List<Runner> get activeRunners => _runners.values.toList();

  static void deleteIsolate(String key) => _runners.remove(key);

  static void closeIsolate(String id) {
    if (_runners.containsKey(id)) {
      _runners[id]?.close();
      deleteIsolate(id);
    } else {
      throw SimpleIsolateException('runner not found');
    }
  }

  static Runner? get openedRunner =>
      activeRunners.isEmpty ? null : activeRunners.first;

  static Future<Runner> getRunner() async {
    final runner = Completer<Runner>();
    final port = ReceivePort();
    final stream = port.asBroadcastStream();
    final id = Uuid().v4().split('-').last;
    StreamSubscription? sb;

    sb = stream.listen((message) {
      if (message is SendPort) {
        final newRunner = Runner(id, port, stream, message);
        _runners[id] = newRunner;
        runner.complete(newRunner);
        sb?.cancel();
      }
    });

    final initMessage = <String, dynamic>{
      'id': id,
      'sendPort': port.sendPort,
    };

    Isolate.spawn(_createIsolate, initMessage);
    return runner.future;
  }
}

void _createIsolate(Map<String, dynamic> initMessage) {
  final logger = Logger(
    printer: PrettyPrinter(methodCount: 1, printEmojis: true),
    level: Level.debug,
  );
  final id = initMessage['id'] as String;
  final receiver = initMessage['sendPort'] as SendPort;
  bool isPause = false;
  logger.d('[$id] >>> hello');
  StreamSubscription? listener;
  Capability? capability;
  final port = ReceivePort();
  receiver.send(port.sendPort);
  listener = port.listen((message) {
    logger.d("[$id] >>> Receive new message: $message");
    if (message is RequestSync) {
      final result = message.callBack(message.arguments);
      final answer = Answer(message.id, result);
      logger.d('[$id] Return answer: $answer');
      receiver.send(answer);
    } else if (message is RequestAsync) {
      final result = message.callBack(message.arguments).then((data) {
        final answer = Answer(message.id, data);
        logger.d('[$id] >>> Return answer: $answer');
        receiver.send(answer);
      });
    } else if (message is Command) {
      switch (message) {
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
