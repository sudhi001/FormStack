import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:formstack/src/other/model/place_details.dart';
import 'package:formstack/src/other/model/prediction.dart';
import 'package:http/http.dart' as http;

class GooglePlaceAutoCompleteTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String googleAPIKey;
  final InputDecoration? inputDecoration;
  final TextStyle? textStyle;
  final int debounceTime;
  final bool isLatLngRequired;
  final List<String>? countries;
  final void Function(Prediction)? itmClick;
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
  OverlayEntry? _overlayEntry;
  final List<Prediction> _predictions = [];
  final LayerLink _layerLink = LayerLink();
  final http.Client _client = http.Client();
  final Map<String, List<Prediction>> _cache = {};
  static const int _maxCacheSize = 50;

  // Debounce state. This used to be an rxdart PublishSubject with .distinct()
  // and .debounceTime(); a timer and the last-seen value do the same job
  // without the dependency.
  Timer? _debounce;
  String? _lastQuery;

  /// Schedules [text] for lookup once typing pauses, skipping a repeat of the
  /// value already queried.
  void _onQueryChanged(String text) {
    if (text == _lastQuery) return;
    _lastQuery = text;
    _debounce?.cancel();
    _debounce = Timer(
      Duration(milliseconds: widget.debounceTime),
      () => _onTextChanged(text),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _client.close();
    _removeOverlay();
    _cache.clear();
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
        onChanged: _onQueryChanged,
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
      _addToCache(text, predictions);

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

  void _addToCache(String key, List<Prediction> value) {
    if (_cache.length >= _maxCacheSize) {
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    _cache[key] = value;
  }

  Future<List<Prediction>> _getLocation(String text) async {
    // Built through Uri rather than string interpolation: the query is
    // whatever the user typed, and an unescaped '&' or '=' would otherwise
    // rewrite the request.
    final uri =
        Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
          'input': text,
          'key': widget.googleAPIKey,
          if (widget.countries?.isNotEmpty ?? false)
            'components': widget.countries!.map((c) => 'country:$c').join('|'),
        });

    final body = await _getJson(uri);
    if (body == null) return const [];
    return PlacesAutocompleteResponse.fromJson(body).predictions ?? const [];
  }

  /// Performs a GET and decodes the JSON body, or returns null on any
  /// non-200 response or unparseable payload.
  Future<Map<String, dynamic>?> _getJson(Uri uri) async {
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      debugPrint(
        'formstack: Places request failed (${response.statusCode}) for ${uri.path}',
      );
      return null;
    }
    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : null;
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
                itemExtent: 48.0,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        {'place_id': prediction.placeId ?? '', 'key': widget.googleAPIKey},
      );

      final body = await _getJson(uri);
      if (body == null) return;
      final placeDetails = PlaceDetails.fromJson(body);

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
