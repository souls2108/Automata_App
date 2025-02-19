class InvalidAutomataInputException implements Exception {
  String message;
  InvalidAutomataInputException({this.message = 'Incorrect input to automata'});
}
