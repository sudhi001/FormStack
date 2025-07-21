library google_places_flutter;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:formstack/src/other/model/prediction.dart';
import 'package:formstack/src/other/model/place_details.dart';

class GooglePlaceAutoCompleteTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String googleAPIKey;
  final InputDecoration? inputDecoration;
  final TextStyle? textStyle;
  final int debounceTime;
  final bool isLatLngRequired;
  final List<String>? countries;
  final Function(Prediction)? itmClick;
  final GetPlaceDetailswWithLatLng? getPlaceDetailWithLatLng;

  const GooglePlaceAutoCompleteTextField({
    super.key,
    required this.textEditingController,
    required this.googleAPIKey,
    this.inputDecoration,
    this.textStyle,
    this.debounceTime = 800,
    this.isLatLngRequired = true,
    this.countries,
    this.itmClick,
    this.getPlaceDetailWithLatLng,
  });

  @override
  State<GooglePlaceAutoCompleteTextField> createState() =>
      _GooglePlaceAutoCompleteTextFieldState();
}

class _GooglePlaceAutoCompleteTextFieldState
    extends State<GooglePlaceAutoCompleteTextField> {
  final PublishSubject<String> _subject = PublishSubject<String>();
  OverlayEntry? _overlayEntry;
  final List<Prediction> _predictions = [];
  final LayerLink _layerLink = LayerLink();
  final Dio _dio = Dio();
  final Map<String, List<Prediction>> _cache = {};

  @override
  void initState() {
    super.initState();
    _subject.stream
        .distinct()
        .debounceTime(Duration(milliseconds: widget.debounceTime))
        .listen(_onTextChanged);
  }

  @override
  void dispose() {
    _subject.close();
    _dio.close();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        decoration: widget.inputDecoration,
        style: widget.textStyle,
        controller: widget.textEditingController,
        onChanged: (string) => _subject.add(string),
      ),
    );
  }

  Future<void> _onTextChanged(String text) async {
    if (text.isEmpty) {
      _predictions.clear();
      _removeOverlay();
      return;
    }

    // Check cache first
    if (_cache.containsKey(text)) {
      _predictions.clear();
      _predictions.addAll(_cache[text]!);
      _showOverlay();
      return;
    }

    try {
      final predictions = await _getLocation(text);
      _cache[text] = predictions;

      if (mounted) {
        setState(() {
          _predictions.clear();
          _predictions.addAll(predictions);
        });
        _showOverlay();
      }
    } catch (e) {
      // Handle error silently or show user-friendly message
      debugPrint('Error fetching predictions: $e');
    }
  }

  Future<List<Prediction>> _getLocation(String text) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$text&key=${widget.googleAPIKey}";

    if (widget.countries != null && widget.countries!.isNotEmpty) {
      final countries = widget.countries!.map((c) => "country:$c").join('|');
      url = "$url&components=$countries";
    }

    final response = await _dio.get(url);
    final subscriptionResponse =
        PlacesAutocompleteResponse.fromJson(response.data);

    return subscriptionResponse.predictions ?? [];
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    if (_overlayEntry != null) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry? _createOverlayEntry() {
    if (context.findRenderObject() == null) return null;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: size.height + offset.dy,
        width: size.width,
        child: CompositedTransformFollower(
          showWhenUnlinked: false,
          link: _layerLink,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _predictions.length,
                itemBuilder: (BuildContext context, int index) {
                  final prediction = _predictions[index];
                  return InkWell(
                    onTap: () => _onPredictionSelected(prediction),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        prediction.description ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onPredictionSelected(Prediction prediction) {
    widget.itmClick?.call(prediction);

    if (widget.isLatLngRequired) {
      _getPlaceDetailsFromPlaceId(prediction);
    }

    _removeOverlay();
  }

  Future<void> _getPlaceDetailsFromPlaceId(Prediction prediction) async {
    try {
      final url =
          "https://maps.googleapis.com/maps/api/place/details/json?place_id=${prediction.placeId}&key=${widget.googleAPIKey}";

      final response = await _dio.get(url);
      final placeDetails = PlaceDetails.fromJson(response.data);

      if (placeDetails.result != null) {
        final lat =
            placeDetails.result!.geometry?.location?.lat?.toString() ?? '0';
        final lng =
            placeDetails.result!.geometry?.location?.lng?.toString() ?? '0';

        prediction.lat = lat;
        prediction.lng = lng;

        widget.getPlaceDetailWithLatLng?.call(prediction);
      }
    } catch (e) {
      debugPrint('Error fetching place details: $e');
    }
  }
}

typedef GetPlaceDetailswWithLatLng = void Function(Prediction prediction);
