import 'map_widget.dart';

//the error is shown in case of wrong version loaded on wrong platform
MapWidget getMapWidget() => throw UnsupportedError(
    'Cannot create a map without dart:html or google_maps_flutter');
