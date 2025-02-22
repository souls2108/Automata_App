class InvalidDFATableException implements Exception {
  String message;
  Set<String> errorCells;
  InvalidDFATableException({
    this.message = 'Invalid tarnsition table data',
    this.errorCells = const {},
  });
}

class InvalidDFASymbolException implements Exception {
  String message;
  String symbol;
  InvalidDFASymbolException({
    this.message = 'Invalid symbol',
    this.symbol = '',
  });
}

class InvalidRegexException implements Exception {
  String message;
  InvalidRegexException({this.message = 'Incorrect input to automata'});
}
