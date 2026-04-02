import 'package:formstack/src/result/identifiers.dart';

/// Relevant condition abstract class
abstract class RelevantCondition {
  RelevantCondition({required this.identifier, this.formName});

  /// [identifier] - Identifier eg: GenericIdentifier(id:"DEMO")
  final Identifier identifier;

  /// [formName] - name of Form
  final String? formName;

  ///
  /// Check the result is valid or not
  ///
  bool isValid(dynamic result);
}
