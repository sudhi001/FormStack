import 'package:uuid/uuid.dart';

var uuid = const Uuid();

abstract class Identifier {
  String? id;
  Identifier({this.id}) {
    if (id?.isEmpty ?? true) {
      id = uuid.v1();
    }
  }
  @override
  bool operator ==(other) => other is Identifier && id == other.id;
  @override
  int get hashCode => id.hashCode;
}

class FormIdentifier extends Identifier {}

class StepIdentifier extends Identifier {}

class InputIdentifier extends Identifier {}

class GenericIdentifier extends Identifier {
  GenericIdentifier({super.id});
}

abstract class RelevantCondition {
  Identifier identifier;
  dynamic result;
  RelevantCondition({required this.identifier, dynamic result});
  bool isValid() {
    return true;
  }
}
