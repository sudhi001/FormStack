import 'package:formstack/src/core/identifiers.dart';

abstract class RelevantCondition {
  RelevantCondition({required this.identifier});

  final Identifier identifier;

  bool isValid(dynamic result);
}
