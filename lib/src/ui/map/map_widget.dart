import 'package:flutter/material.dart';

import 'map_widget_stub.dart'
    if (dart.library.html) 'web_map_widget.dart'
    if (dart.library.io) 'mob_map_widget.dart';

abstract class MapWidget extends StatefulWidget {
  factory MapWidget(MapKey mapKey, LocationWrapper? latLng,
          Function(LocationWrapper) onChange) =>
      getMapWidget(mapKey, latLng, onChange);
}

class LocationWrapper {
  final double lat;
  final double lng;

  LocationWrapper(this.lat, this.lng);
}

class MapKey {
  final String android;
  final String ios;
  final String web;

  MapKey(this.android, this.ios, this.web);
}
