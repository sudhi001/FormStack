import 'package:formstack/src/core/identifiers.dart';

abstract class Result {
  final Identifier id;
  final DateTime startDate;
  final DateTime endDate;
  Result(this.id, this.startDate, this.endDate);
}

class InputResult extends Result {
  InputResult(super.id, super.startDate, super.endDate);
}

class StepResult extends Result {
  List<InputResult> results = [];
  StepResult(super.id, super.startDate, super.endDate);
}
