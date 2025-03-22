import 'package:automata_app/services/automata/automata.dart';
import 'package:automata_app/views/automata_operations/evaluation_exceptions.dart';
import 'package:automata_app/views/automata_operations/operations_constants.dart';
import 'dart:developer' as devtools show log;

extension _Stack<T> on List<T> {
  T pop() {
    if (isEmpty) {
      throw InvalidExpression(message: "Invalid Expression");
    }
    return removeLast();
  }

  T push(T item) {
    add(item);
    return item;
  }

  T peek() {
    if (isEmpty) {
      throw InvalidExpression(message: "Invalid Expression");
    }
    return last;
  }
}

Automata evaluateExpression(List expression) {
  List postfix = infixToPostfix(expression);
  devtools.log(postfix.toString());
  List<Automata> automataStack = [];
  for (var item in postfix) {
    if (item is Automata) {
      automataStack.push(item);
    } else if (item is OperationButtons) {
      switch (item) {
        case OperationButtons.union:
          {
            var a = automataStack.pop();
            var b = automataStack.pop();
            automataStack.push(a.union(b));
          }
          break;
        case OperationButtons.intersection:
          {
            var a = automataStack.pop();
            var b = automataStack.pop();
            automataStack.push(a.intersection(b));
          }
          break;
        case OperationButtons.concat:
          {
            var a = automataStack.pop();
            var b = automataStack.pop();
            automataStack.push(a.concat(b));
          }
          break;
        case OperationButtons.reverse:
          {
            var a = automataStack.pop();
            automataStack.push(a.reverse());
          }
          break;
        case OperationButtons.complement:
          {
            var a = automataStack.pop();
            automataStack.push(a.complement());
          }
          break;
        case OperationButtons.bracketOpen:
        case OperationButtons.bracketClose:
          throw InvalidExpression(
            message: "Invalid Expression unexpected bracket",
          );
      }
    }
  }

  if (automataStack.length != 1) {
    throw InvalidExpression(message: "Invalid Expression too many operands");
  }

  return automataStack.first;
}

List infixToPostfix(List infix) {
  List postfix = [];
  List<OperationButtons> operatorStack = [];

  for (var item in infix) {
    if (item is Automata) {
      postfix.add(item);
    } else if (item is OperationButtons) {
      if (item == OperationButtons.bracketOpen) {
        operatorStack.push(item);
      } else if (item == OperationButtons.bracketClose) {
        while (operatorStack.peek() != OperationButtons.bracketOpen) {
          postfix.add(operatorStack.pop());
        }
        operatorStack.pop();
      } else {
        while (operatorStack.isNotEmpty &&
            getPrecedence(operatorStack.peek()) >= getPrecedence(item)) {
          postfix.add(operatorStack.pop());
        }
        operatorStack.push(item);
      }
    }
    devtools.log("Postfix: ");
    devtools.log(postfix.toString());
    devtools.log("Stack: ");
    devtools.log(operatorStack.toString());
  }

  while (operatorStack.isNotEmpty) {
    postfix.add(operatorStack.pop());
  }

  return postfix;
}

// class Evaluation {
//   static Automata evaluate(List expression) {
//     return evaluateExpression(expression);
//   }
// }

// class LL1Parser {
//   Map<NonTerminal, Map<Terminal, GrammarRule>> table;
//   NonTerminal start;
//   LL1Parser(this.table, this.start);

//   GrammarRule? getRule(NonTerminal nonTerminal, Terminal terminal) {
//     return table[nonTerminal]?[terminal];
//   }

//   Automata evaluate(List<Terminal> expression) {
//     List stack = [ Terminal.stackSymbol, start];
//     int index = 0;
//     while (index < expression.length && stack.isNotEmpty) {
//       var top = stack.pop();
//       if (top is Terminal) {
//         if (top == expression[index]) {
//           index++;
//         } else {
//           throw InvalidExpression(message: "Invalid Expression");
//         }
//       } else if (top is NonTerminal) {
//         var rule = getRule(top, expression[index]);
//         if (rule == null) {
//           throw InvalidExpression(message: "Invalid Expression");
//         }
//         stack.pushAll(rule.right.reversed);
//       } else {
//         throw InvalidExpression(message: "Invalid Expression");
//       }
//     }
//     return ;
//   }

//   T evaluate<T>(List<Terminal> expression, Map<Terminal, Function> functionMap) {
//     List stack = [start];
//     int index = 0;
//     while (stack.isNotEmpty) {
//       var top = stack.pop();
//       if (top is Terminal) {
//         if (top == expression[index]) {
//           index++;
//         } else {
//           throw InvalidExpression(message: "Invalid Expression");
//         }
//       } else if (top is NonTerminal) {
//         var rule = getRule(top, expression[index]);
//         stack.(rule.right.reversed);
//       } else {
//         var function = functionMap[top];
//         stack.push(function());
//       }
//     }
//     return null;
//   }



// }

// class GrammarRule<Terminal, NonTerminal> {
//   NonTerminal left;
//   List<GrammarSymbols> right;
//   GrammarRule(this.left, this.right);
// }

// abstract class GrammarSymbols {}

// enum Terminal implements GrammarSymbols {
//   union,
//   intersection,
//   complement,
//   difference,
//   reverse,
//   concat,
//   bracketOpen,
//   bracketClose,
//   automata,
//   epsilon,
//   stackSymbol,
// }

// enum NonTerminal implements GrammarSymbols {
//   E,
//   primeE,
//   S,
//   primeS,
//   P,
//   primeP,
//   Q,
//   primeQ,
//   R,
// }

// /**
//  *
// E -> S E'
// E'-> - S E'
// E'-> ''
// S -> P S'
// S' -> u P S'
// S' -> ''
// P -> Q P'
// P' -> i Q P'
// P' -> ''
// Q -> R Q'
// Q' -> con R Q'
// Q' -> ''
// R -> r R
// R -> c R
// R -> automata
// R -> ( E )
//  */
// /**
//  * FIRST	FOLLOW	Nonterminal	+	*	(	)	id	$
// {(,id}	{$,)}	E			E -> T E'		E -> T E'	
// {+,''}	{$,)}	E'	E' -> + T E'			E' -> ''		E' -> ''
// {(,id}	{+,$,)}	T			T -> F T'		T -> F T'	
// {*,''}	{+,$,)}	T'	T' -> ''	T' -> * F T'		T' -> ''		T' -> ''
// {(,id}	{*,+,$,)}	F			F -> ( E )		F -> id	
//  */