# SimpleIsolates

API для простого использования изолятов

Для создания изолята просто вызовите:
```dart
final isolate = await SimpleIsolates.getRunner()
```
Чтобы изолят выполнил какую-то работу, передайте в него коллбэк и аргументы, используя `RequestSync` или `RequestAsync`:
```dart
 final args = {'value' : 2};
 callBack(args) => args['value'] * 2;
 final request = RequestSync(arguments: args, callBack: callBack);
 final runnerResult = await runner.run(request);
```
Чтобы закрыть изолят, вызовите `isolate.close()`