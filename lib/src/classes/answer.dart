class Answer<T> {
  final String id;
  final T data;

  const Answer(this.id, this.data);

  @override
  String toString() {
    return '\nRequest-id: $id\nResult: ${_prepareAnswer(data)}';
  }

  String _prepareAnswer(dynamic result) {
    switch(result.runtimeType) {
      case List:
        return 'List with length ${result.length}';
      case Map:
        return 'Map with ${result.keys.length} keys';
      default:
        return result.toString();
    }
  }
}