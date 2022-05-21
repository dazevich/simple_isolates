# SimpleIsolates

## Общие сведения
`SimpleIsolates` - класс, предоставляющий API для создания, хранения и удаления изолятов.

## class SimpleIsolates
### Поля
- `static List<Runner> get activeRunners` - список открытых изолятов
- `static Runner? get openedRunner` - возвращает изолят, если есть хоть один открытый. Иначе null
### Методы
- `Future<Runner> getRunner()` - Метод создает изолят и возвращает объект [`Runner`](#runner)
- `void deleteIsolate(String key)` - удаляет изолят из списка. **Данный метод не звкрывает изолят, а лишь удаляет его из массива**
- `void closeIsolate(String id)` - закрывает изолят id

## Runner
### Поля
### Методы
