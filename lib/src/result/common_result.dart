class Options {
  final String key;
  final String title;
  final String? subTitle;
  final dynamic value;
  Options(this.key, this.title, {this.subTitle, this.value});
  factory Options.from(Map<String, dynamic> data) {
    return Options(data["key"], data["title"],
        subTitle: data["subTitle"], value: data["value"]);
  }
  Map<String, dynamic> toJson() =>
      {"key": key, "title": title, "subTitle": subTitle, "value": value};
  @override
  bool operator ==(Object other) {
    return (other is Options) && other.key == key;
  }

  @override
  int get hashCode => Object.hash(key, title);
}

class KeyValue {
  final String key;
  final String value;
  KeyValue(this.key, this.value);
  Map<String, dynamic> toJson() => {"key": key, "value": value};
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

  Map<String, dynamic> toJson() => {
        "title": title,
        "subTitle": subTitle,
        "trailing": trailing,
        "leading": leading
      };
}

class LocationWrapper {
  final double lat;
  final double lng;

  LocationWrapper(this.lat, this.lng);
  Map<String, dynamic> toJson() => {"lat": lat, "lng": lng};
}

class MapKey {
  final String android;
  final String ios;
  final String web;

  MapKey(this.android, this.ios, this.web);
  Map<String, dynamic> toJson() => {"android": android, "ios": ios, "web": web};
}
