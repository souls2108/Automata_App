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

class DotTextException implements Exception {
  String message;
  DotTextException({this.message = 'Error generating dot text'});
}

class SvgException implements Exception {
  String message;
  SvgException({this.message = 'Error generating svg'});
}

class AutomataServiceConverterUninitialized implements Exception {
  String message;
  AutomataServiceConverterUninitialized({
    this.message = 'AutomataServiceConverter is not initialized',
  });
}
