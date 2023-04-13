import 'package:formstack/src/core/identifiers.dart';

abstract class NavigationRule {
  final StepIdentifier destinationIdentifier;

  NavigationRule(this.destinationIdentifier);
}

class DirectNavigationRule extends NavigationRule {
  DirectNavigationRule(super.destinationIdentifier);
}

class ConditionalNavigationRule extends NavigationRule {
  ConditionalNavigationRule(super.destinationIdentifier);
}
