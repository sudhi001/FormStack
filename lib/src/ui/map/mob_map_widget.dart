import 'dart:async';

import 'package:flutter/material.dart';
import 'package:formstack/src/result/common_result.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_widget.dart';

MapWidget getMapWidget(MapKey mapKey, LocationWrapper? latLng,
        Function(LocationWrapper) onChange) =>
    MobileMap(mapKey, latLng ?? LocationWrapper(7.3697, 12.3547), onChange);

class MobileMap extends StatefulWidget implements MapWidget {
  final LocationWrapper latLng;
  final MapKey mapKey;
  final Function(LocationWrapper) onChange;
  const MobileMap(this.mapKey, this.latLng, this.onChange, {super.key});

  @override
  State<MobileMap> createState() => MobileMapState();
}

class MobileMapState extends State<MobileMap> {
  final Completer<GoogleMapController> _controller = Completer();

  static late CameraPosition _kFalentexHouse;
  @override
  void initState() {
    _kFalentexHouse =
        CameraPosition(target: LatLng(widget.latLng.lat, widget.latLng.lng));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.hybrid,
      initialCameraPosition: _kFalentexHouse,
      onMapCreated: _controller.complete,
    );
  }
}
