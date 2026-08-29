import 'package:flutter/material.dart';
import 'package:formstack/src/result/common_result.dart';

import 'map_widget_stub.dart'
    if (dart.library.html) 'web_map_widget.dart'
    if (dart.library.io) 'mob_map_widget.dart';

/// A map viewport, resolved to the mobile or web implementation at compile
/// time by conditional import.
///
/// Used by the location, geotrace and geoshape inputs.
abstract class MapWidget extends StatefulWidget {
  /// Creates the map implementation for the current platform.
  factory MapWidget(
    MapKey mapKey,
    LocationWrapper? latLng,
    Function(LocationWrapper) onChange,
  ) => getMapWidget(mapKey, latLng, onChange);
}
