import 'package:flutter/material.dart';

///
/// String to Alignment
/// "center" => Alignment.center
/// "bottomCenter" => Alignment.bottomCenter
/// "bottomLeft" => Alignment.bottomLeft
/// "bottomRight" => Alignment.bottomRight
/// "centerLeft" => Alignment.centerLeft
/// "centerRight" => Alignment.centerRight
/// "topCenter" => Alignment.topCenter
///  "topLeft" => Alignment.topLeft
///  "topLeft" => Alignment.topLeft
///
Alignment? alignmentFromString(String? aliment) {
  if (aliment != null) {
    switch (aliment) {
      case "center":
        return Alignment.center;
      case "bottomCenter":
        return Alignment.bottomCenter;
      case "bottomLeft":
        return Alignment.bottomLeft;
      case "bottomRight":
        return Alignment.bottomRight;
      case "centerLeft":
        return Alignment.centerLeft;
      case "centerRight":
        return Alignment.centerRight;
      case "topCenter":
        return Alignment.topCenter;
      case "topLeft":
        return Alignment.topLeft;
      case "topRight":
        return Alignment.topRight;
    }
  }
  return null;
}

///
/// String to CrossAxisAlignment
/// "center" => CrossAxisAlignment.center
/// "end" => CrossAxisAlignment.end
/// "baseline" => CrossAxisAlignment.baseline
/// "start" => CrossAxisAlignment.start
/// "stretch" => CrossAxisAlignment.stretch
///
CrossAxisAlignment? textAlignmentFromString(String? aliment) {
  if (aliment != null) {
    switch (aliment) {
      case "center":
        return CrossAxisAlignment.center;
      case "end":
        return CrossAxisAlignment.end;
      case "baseline":
        return CrossAxisAlignment.baseline;
      case "start":
        return CrossAxisAlignment.start;
      case "stretch":
        return CrossAxisAlignment.stretch;
    }
  }
  return null;
}
