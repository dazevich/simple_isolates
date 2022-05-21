import 'dart:convert';
import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_isolate/simple_isolate.dart';
import 'package:simple_isolate/src/simple_isolate.dart';
import 'package:http/http.dart' as http;

void main() {
  // подготовка
  for(final runner in SimpleIsolates.activeRunners) {
    log('close ${runner.id}');
    SimpleIsolates.closeIsolate(runner.id);
  }
  test('Шаг 1: Создание изолята', createIsolate);
  test('Шаг 2: Выполнение простой операции', runCallback);
  test('Шаг 3: Выполнение ассинхронной операции', runAsyncCallback);
  test('Шаг 4: Закрытие изолята', closeIsolate);
}

void createIsolate() async {
  final runner = await SimpleIsolates.getRunner();
  expect(SimpleIsolates.activeRunners.length, 1);
}

void runCallback() async {
  expect(SimpleIsolates.activeRunners.isNotEmpty, true);
  final runner = SimpleIsolates.activeRunners.first;
  final args = {'value' : 2};
  callBack(args) => args['value'] * 2;
  final runnerResult = await runner.run(RequestSync(arguments: args, callBack: callBack));
  final localResult = callBack(args);
  expect(runnerResult, localResult);
}

void runAsyncCallback() async {
  expect(SimpleIsolates.activeRunners.isNotEmpty, true);
  final runner = SimpleIsolates.activeRunners.first;
  final url = Uri.parse('https://jsonplaceholder.typicode.com/comments');
  final preResponse = await http.get(url);
  if(preResponse.statusCode != 200) {
    markTestSkipped('Тестовый API недоступен');
    return;
  }
  final args = {'url' : url};
  callBack(args) async {
    final response = await http.get(args['url']);
    final comments = json.decode(utf8.decode(response.bodyBytes));
    return comments as List<dynamic>;
  }
  final runnerResult = await runner.run<List<dynamic>>(
      RequestAsync<List<dynamic>>(arguments: args, callBack: callBack));
  expect(runnerResult?.isNotEmpty, true);
}

void closeIsolate() async {
  expect(SimpleIsolates.activeRunners.isNotEmpty, true);
  final runner = SimpleIsolates.activeRunners.first;
  SimpleIsolates.closeIsolate(runner.id);
  expect(SimpleIsolates.openedRunner, null);
}