import 'package:uuid/uuid.dart';

var uuid = const Uuid();

/// Base class for step and form identifiers.
///
/// If no [id] is provided, a UUID v1 is generated automatically.
abstract class Identifier {
  /// The unique identifier string.
  String? id;

  /// Creates an [Identifier]. Generates a UUID if [id] is null or empty.
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

/// Identifier for a form instance.
class FormIdentifier extends Identifier {}

/// Auto-generated identifier for a form step.
class StepIdentifier extends Identifier {}

/// General-purpose identifier with an explicit [id].
///
/// ```dart
/// GenericIdentifier(id: "email_step")
/// ```
class GenericIdentifier extends Identifier {
  /// Creates a [GenericIdentifier] with the given [id].
  GenericIdentifier({super.id});
}
