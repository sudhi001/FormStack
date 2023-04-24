class Options {
  final String key;
  final String text;
  Options(this.key, this.text);
}

class GeoLocationResult {
  final double latitude;
  final double longitude;
  GeoLocationResult({required this.latitude, required this.longitude});
}