class SimpleIsolateException {
  final String message;
  SimpleIsolateException(this.message);

  @override
  String toString() => 'SimpleIsolateException: $message';
}