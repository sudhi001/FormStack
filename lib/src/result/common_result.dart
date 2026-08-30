import 'package:formstack/src/core/json_reader.dart';
import 'package:formstack/formstack.dart'
    show InputType, InstructionStep, DisplayStep;

/// A selectable option used in choice-based inputs.
///
/// Used with [InputType.singleChoice], [InputType.multipleChoice],
/// [InputType.dropdown], and [InputType.ranking].
class Options {
  /// Unique identifier for this option.
  final String key;

  /// Display text shown to the user.
  final String title;

  /// Optional secondary text shown below the title.
  final String? subTitle;

  /// Optional value associated with this option.
  final dynamic value;

  /// Creates an [Options] instance.
  Options(this.key, this.title, {this.subTitle, this.value});

  /// Creates an [Options] from a JSON map.
  factory Options.from(Map<String, dynamic> data) {
    final read = JsonReader(data, context: 'Options');
    return Options(
      read.string('key') ?? '',
      read.string('title') ?? '',
      subTitle: read.string('subTitle'),
      value: read.raw('value'),
    );
  }

  /// Converts this option to a JSON map.
  Map<String, dynamic> toJson() => {
    "key": key,
    "title": title,
    "subTitle": subTitle,
    "value": value,
  };

  @override
  bool operator ==(Object other) {
    return (other is Options) && other.key == key;
  }

  @override
  int get hashCode => Object.hash(key, title);
}

/// A key-value pair used with [InputType.dynamicKeyValue].
class KeyValue {
  /// The key string.
  final String key;

  /// The value string.
  final String value;

  /// Creates a [KeyValue] instance.
  KeyValue(this.key, this.value);

  /// Converts this pair to a JSON map.
  Map<String, dynamic> toJson() => {"key": key, "value": value};
}

/// Data item for [InstructionStep] instructions list or [DisplayStep] data.
class DynamicData {
  /// Primary display text.
  final String title;

  /// Optional secondary text.
  final String? subTitle;

  /// Optional trailing text (displayed on the right).
  final String? trailing;

  /// Optional leading text (displayed on the left).
  final String? leading;

  /// Creates a [DynamicData] instance.
  DynamicData(this.title, {this.subTitle, this.trailing, this.leading});

  /// Creates a [DynamicData] from a JSON map.
  factory DynamicData.from(Map<String, dynamic> data) {
    final read = JsonReader(data, context: 'DynamicData');
    return DynamicData(
      read.string('title') ?? '',
      subTitle: read.string('subTitle'),
      trailing: read.string('trailing'),
      leading: read.string('leading'),
    );
  }

  /// Parses a list of JSON maps into [DynamicData] instances.
  static List<DynamicData> parseDynamicData(List<dynamic> element) {
    final List<DynamicData> data = [];
    for (final el in element) {
      data.add(DynamicData.from(Map<String, dynamic>.from(el as Map)));
    }
    return data;
  }

  /// Converts this data to a JSON map.
  Map<String, dynamic> toJson() => {
    "title": title,
    "subTitle": subTitle,
    "trailing": trailing,
    "leading": leading,
  };
}

/// Wrapper for latitude/longitude coordinates.
///
/// Used with [InputType.mapLocation] to set initial map position.
class LocationWrapper {
  /// Latitude coordinate.
  final double lat;

  /// Longitude coordinate.
  final double lng;

  /// Creates a [LocationWrapper] with the given coordinates.
  LocationWrapper(this.lat, this.lng);

  /// Converts to a JSON map.
  Map<String, dynamic> toJson() => {"lat": lat, "lng": lng};
}

/// Google Maps API keys for each platform.
///
/// Required when using [InputType.mapLocation].
class MapKey {
  /// Google Maps API key for Android.
  final String android;

  /// Google Maps API key for iOS.
  final String ios;

  /// Google Maps API key for Web.
  final String web;

  /// Creates a [MapKey] with platform-specific API keys.
  MapKey(this.android, this.ios, this.web);

  /// Converts to a JSON map.
  Map<String, dynamic> toJson() => {"android": android, "ios": ios, "web": web};
}
