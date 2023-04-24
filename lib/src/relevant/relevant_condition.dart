import 'package:formstack/src/result/identifiers.dart';

abstract class RelevantCondition {
  RelevantCondition({required this.identifier, this.formName});

  final Identifier identifier;
  final String? formName;
  bool isValid(dynamic result);
}
