class JsonConversionException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  JsonConversionException(this.message, [this.stackTrace]);

  @override
  String toString() {
    return message;
  }
}
