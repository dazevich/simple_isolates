# SimpleIsolates

## Общие сведения
`SimpleIsolates` - класс, предоставляющий API для создания, хранения и удаления изолятов.

Для создания изолята достаточно выполнить
```dart
final runner = await SimpleIsolates.getRunner();
```
Чтобы изолят выполнил нужную функцию, необходимо передать ему соответствующий запрос. Запросы бывают двух типов:
- [RequestSync](/simple_isolates.md) - запрос с синхронной функцией (расчет, парсинг)
- [RequestAsync](/simple_isolates.md) - запрос с ассинхронной функцией (http запрос)
Оба этих запроса наследуются от класса [Request](/simple_isolates.md). Чтобы изолят посчитал сумму двух чисел, необходимо:
```dart
 final runner = SimpleIsolates.activeRunners.first;
 final request = RequestSync(
  arguments: {},
  callBack: (args) => 2 + 2
 );
 final runnerResult = await runner.run(RequestSync(arguments: args, callBack: callBack));
 // runnerResult = 4
```

## Classes
- [SimpleIsolates](/simple_isolates.md)
- [Runner](/simple_isolates.md)
- [Request](/simple_isolates.md)
- [RequestSync](/simple_isolates.md)
- [RequestAsync](/simple_isolates.md)
- [Answer](/simple_isolates.md)
- [SimpleIsolatesException](/simple_isolates.md)

## Methods
- void [_createIsolate](/simple_isolates.md)(Map<String, dynamic> initMessage)
