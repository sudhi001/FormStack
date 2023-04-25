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

class DynamicData {
  final String title;
  final String? subTitle;
  final String? trailing;
  final String? leading;
  DynamicData(this.title, {this.subTitle, this.trailing, this.leading});

  factory DynamicData.from(Map<String, dynamic> data) {
    return DynamicData(data["title"],
        subTitle: data["subTitle"],
        trailing: data["trailing"],
        leading: data["leading"]);
  }

  static List<DynamicData> parseDynamicData(List<dynamic> element) {
    List<DynamicData> data = [];
    for (var el in element) {
      data.add(DynamicData.from(el));
    }
    return data;
  }
}
