import 'package:flutter/material.dart';
import 'package:formstack/src/core/form_step.dart' show InputStyle;
import 'package:formstack/src/core/ui_style.dart' show UIStyle;

/// Resolves an [InputStyle] to the Material border that renders it.
///
/// Previously each input widget carried its own identical copy of this
/// mapping, so a change to the outline border had to be made in five places.
extension InputStyleBorder on InputStyle {
  /// The border for this style, honouring [style]'s border colour and radius
  /// when one is supplied.
  InputBorder toInputBorder({UIStyle? style}) {
    switch (this) {
      case InputStyle.basic:
        return InputBorder.none;
      case InputStyle.outline:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(style?.borderRadius ?? 4),
          borderSide: style != null
              ? BorderSide(color: style.borderColor)
              : const BorderSide(),
        );
      case InputStyle.underLined:
        return style != null
            ? UnderlineInputBorder(
                borderSide: BorderSide(color: style.borderColor))
            : const UnderlineInputBorder();
    }
  }
}
