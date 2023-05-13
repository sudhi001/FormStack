// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_maps/google_maps.dart';

import 'map_widget.dart';

MapWidget getMapWidget() => const WebMap();

class WebMap extends StatefulWidget implements MapWidget {
  const WebMap({Key? key}) : super(key: key);

  @override
  State<WebMap> createState() => WebMapState();
}

class WebMapState extends State<WebMap> {
  @override
  Widget build(BuildContext context) {
    const String htmlId = "map";

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
      final mapOptions = MapOptions()
        ..zoom = 15.0
        ..center = LatLng(35.7560423, 139.7803552);

      final elem = DivElement()..id = htmlId;
      final map = GMap(elem, mapOptions);

      map.onCenterChanged.listen((event) {});
      map.onDragstart.listen((event) {});
      map.onDragend.listen((event) {});

      Marker(MarkerOptions()
        ..position = map.center
        ..map = map);

      return elem;
    });
    return const HtmlElementView(viewType: htmlId);
  }
}
