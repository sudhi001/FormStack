import 'package:flutter/material.dart';

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
