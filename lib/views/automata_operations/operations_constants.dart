enum OperationButtons {
  bracketOpen,
  bracketClose,
  union,
  intersection,
  complement,
  reverse,
  concat,
}

int getPrecedence(OperationButtons operation) {
  switch (operation) {
    case OperationButtons.bracketOpen:
    case OperationButtons.bracketClose:
      return 6;
    case OperationButtons.complement:
    case OperationButtons.reverse:
      return 4;
    case OperationButtons.concat:
      return 3;
    case OperationButtons.intersection:
      return 2;
    case OperationButtons.union:
      return 1;
  }
}

class UnintializedAutomata {}
