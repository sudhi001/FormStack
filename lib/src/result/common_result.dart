class Options {
  final String key;
  final String title;
  final String? subTitle;
  Options(this.key, this.title, {this.subTitle = ""});
}

class GeoLocationResult {
  final double latitude;
  final double longitude;
  GeoLocationResult({required this.latitude, required this.longitude});
}

class Instruction {
  final String title;
  final String? subTitle;
  final String? trailing;
  final String? leading;
  Instruction(this.title, {this.subTitle, this.trailing, this.leading});
}
