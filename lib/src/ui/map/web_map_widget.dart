// ignore: avoid_web_libraries_in_flutter
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as ft;
import 'package:formstack/src/other/google_places_flutter.dart';
import 'package:formstack/src/other/model/prediction.dart';
import 'package:formstack/src/result/common_result.dart';
// ignore: depend_on_referenced_packages
import 'package:google_maps/google_maps.dart';
import 'package:location/location.dart' as lo;
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;
import 'map_widget.dart';

MapWidget getMapWidget(MapKey mapKey, LocationWrapper? latLng,
        Function(LocationWrapper) onChange) =>
    WebMap(mapKey, latLng, onChange);

class WebMap extends StatefulWidget implements MapWidget {
  final LocationWrapper? latLng;
  final MapKey mapKey;
  final Function(LocationWrapper) onChange;
  const WebMap(this.mapKey, this.latLng, this.onChange, {super.key});

  @override
  State<WebMap> createState() => WebMapState();
}

class WebMapState extends State<WebMap> {
  late LatLng currentLat;
  @override
  void initState() {
    currentLat = LatLng(widget.latLng?.lat ?? 0, widget.latLng?.lng ?? 0);
    super.initState();
    _goToTheLake();
  }

  TextEditingController controller = TextEditingController();

  LocationWrapper getUserLocation() =>
      LocationWrapper(currentLat.lat.toDouble(), currentLat.lng.toDouble());
  @override
  Widget build(BuildContext context) {
    const htmlId = 'map';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
      final mapOptions = MapOptions()
        ..zoom = 15.0
        ..center = currentLat;
      final elem = web.document.getElementById(htmlId);
      final map = GMap(elem as web.HTMLElement, mapOptions);
      map.onDragstart.listen((event) {});
      map.onDragend.listen((event) {});
      map.onCenterChanged.listen((event) {
        if (map.center != null) {
          currentLat = LatLng(map.center?.lat, map.center?.lng);
          widget.onChange.call(getUserLocation());
        }
      });

      Marker(MarkerOptions()
        ..position = map.center
        ..map = map);

      return elem;
    });

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GooglePlaceAutoCompleteTextField(
                  textEditingController: controller,
                  googleAPIKey: widget.mapKey.web,
                  inputDecoration:
                      const InputDecoration(hintText: "SEARCH PLACE HERE.."),
                  debounceTime: 800,
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (Prediction prediction) {
                    setState(() {
                      currentLat = LatLng(double.parse(prediction.lat ?? '0'),
                          double.parse(prediction.lng ?? '0'));
                      widget.onChange.call(getUserLocation());
                    });
                  },
                  itmClick: (Prediction prediction) {
                    controller
                      ..text = prediction.description ?? ''
                      ..selection = TextSelection.fromPosition(
                          TextPosition(offset: prediction.description!.length));
                  }),
            ),
            IconButton(
                onPressed: _goToTheLake,
                icon: const ft.Icon(Icons.my_location, color: Colors.black))
          ],
        ),
        Expanded(
          child: Stack(
            children: [
              HtmlElementView(viewType: htmlId, key: UniqueKey()),
              const Center(
                child: ft.Icon(Icons.person_pin_circle,
                    size: 52, color: Colors.black),
              )
            ],
          ),
        ),
      ],
    );
  }

  void _goToTheLake() async {
    var location = lo.Location();
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }
    var permissionGranted = await location.hasPermission();
    if (permissionGranted == lo.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != lo.PermissionStatus.granted) {
        return null;
      }
    }
    var locationData = await location.getLocation();
    if (locationData.latitude != 0) {
      setState(() {
        currentLat = LatLng(locationData.latitude, locationData.longitude);
        widget.onChange.call(getUserLocation());
      });
    }
  }
}
