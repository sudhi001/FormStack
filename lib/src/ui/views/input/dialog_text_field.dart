import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A text field inside a dialog that owns and disposes its controller.
///
/// A `TextEditingController` created inside a `showDialog` builder is never
/// disposed, and the builder runs on every rebuild of the dialog route — so
/// the naive form leaks a controller per rebuild, not merely per dialog. This
/// widget ties the controller to an element that the framework will dispose.
///
/// [onChanged] reports the current text so the caller can read it when the
/// dialog is confirmed, without holding the controller itself.
class DialogTextField extends StatefulWidget {
  /// Creates a [DialogTextField].
  const DialogTextField({
    required this.onChanged,
    super.key,
    this.labelText,
    this.hintText,
    this.autofocus = false,
    this.keyboardType,
    this.inputFormatters,
  });

  /// Called with the field's text whenever it changes.
  final ValueChanged<String> onChanged;

  /// Label shown above the field.
  final String? labelText;

  /// Placeholder shown when the field is empty.
  final String? hintText;

  /// Whether the field takes focus when the dialog opens.
  final bool autofocus;

  /// Keyboard to present.
  final TextInputType? keyboardType;

  /// Formatters applied as the user types.
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<DialogTextField> createState() => _DialogTextFieldState();
}

class _DialogTextFieldState extends State<DialogTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    autofocus: widget.autofocus,
    keyboardType: widget.keyboardType,
    inputFormatters: widget.inputFormatters,
    onChanged: widget.onChanged,
    decoration: InputDecoration(
      labelText: widget.labelText,
      hintText: widget.hintText,
      border: const OutlineInputBorder(),
    ),
  );
}
