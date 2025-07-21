import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as ft;
import 'package:formstack/src/other/google_places_flutter.dart';
import 'package:formstack/src/other/model/prediction.dart';
import 'package:formstack/src/result/common_result.dart';
import 'package:google_maps/google_maps.dart';
import 'package:location/location.dart' as lo;
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
    currentLat = LatLng(widget.latLng?.lat ?? 0.0, widget.latLng?.lng ?? 0.0);
    super.initState();
    _goToTheLake();
  }

  TextEditingController controller = TextEditingController();

  LocationWrapper getUserLocation() =>
      LocationWrapper(currentLat.lat.toDouble(), currentLat.lng.toDouble());

  @override
  Widget build(BuildContext context) {
    // For web, we'll use a placeholder since platformViewRegistry is not available
    // in the current Flutter web version
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
          child: Container(
            color: Colors.grey[300],
            child: const Center(
              child: Text('Map view not available in web version'),
            ),
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
        currentLat =
            LatLng(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
        widget.onChange.call(getUserLocation());
      });
    }
  }
}
