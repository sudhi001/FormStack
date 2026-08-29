import 'package:flutter/widgets.dart';

/// Scans a barcode or QR code using the device camera.
///
/// FormStack declares no camera dependency, so `InputType.barcode` cannot scan
/// on its own — it falls back to manual entry. Supply an implementation backed
/// by the scanner package of your choice and the built-in widget will use it:
///
/// ```dart
/// class MobileScannerAdapter implements BarcodeScanner {
///   @override
///   Future<String?> scan(BuildContext context) => Navigator.of(context).push(
///         MaterialPageRoute(builder: (_) => const MyScannerPage()),
///       );
/// }
///
/// DeviceCapabilities.instance.barcodeScanner = MobileScannerAdapter();
/// ```
///
/// This is the lighter of the two extension points: it keeps FormStack's
/// layout, validation and result handling and replaces only the capture step.
/// To replace the whole widget instead, register one with `InputRegistry`.
abstract class BarcodeScanner {
  /// Presents a scanner and completes with the scanned value.
  ///
  /// Return null when the user cancels. Throwing is reported through
  /// `FlutterError` and leaves any previous answer intact.
  Future<String?> scan(BuildContext context);
}

/// A completed audio recording.
class AudioRecording {
  /// Where the recording was written — a file path, or a URI on the web.
  final String path;

  /// How long the recording lasted.
  final Duration duration;

  /// Creates an [AudioRecording].
  const AudioRecording({required this.path, required this.duration});

  /// Converts to a JSON-serializable map.
  Map<String, dynamic> toJson() =>
      {'path': path, 'durationMs': duration.inMilliseconds};

  @override
  String toString() => 'AudioRecording($path, ${duration.inSeconds}s)';
}

/// Records audio from the device microphone.
///
/// FormStack declares no microphone dependency, so `InputType.audio` only
/// tracks elapsed time on its own. Supply an implementation backed by the
/// recording package of your choice:
///
/// ```dart
/// class RecordAdapter implements AudioRecorder {
///   final _recorder = AudioRecorder();
///   DateTime? _startedAt;
///
///   @override
///   Future<void> start() async {
///     _startedAt = DateTime.now();
///     await _recorder.start(const RecordConfig(), path: await _tempPath());
///   }
///
///   @override
///   Future<AudioRecording?> stop() async {
///     final path = await _recorder.stop();
///     if (path == null) return null;
///     return AudioRecording(
///       path: path,
///       duration: DateTime.now().difference(_startedAt!),
///     );
///   }
/// }
///
/// DeviceCapabilities.instance.audioRecorder = RecordAdapter();
/// ```
abstract class AudioRecorder {
  /// Begins recording. Requesting permission is the implementation's job.
  Future<void> start();

  /// Stops recording and completes with the result, or null if nothing was
  /// captured.
  Future<AudioRecording?> stop();
}

/// Device capabilities FormStack can use when an application provides them.
///
/// FormStack keeps its dependency footprint small: an application that only
/// collects text and choices should not inherit a camera or audio SDK. The
/// inputs that need hardware therefore ship as UI scaffolds and become fully
/// functional once the corresponding capability is supplied here.
///
/// Set these once at start-up:
///
/// ```dart
/// void main() {
///   DeviceCapabilities.instance
///     ..barcodeScanner = MobileScannerAdapter()
///     ..audioRecorder = RecordAdapter();
///   runApp(const MyApp());
/// }
/// ```
class DeviceCapabilities {
  DeviceCapabilities._();

  /// The process-wide capability set consulted by the built-in inputs.
  static final DeviceCapabilities instance = DeviceCapabilities._();

  /// Scanner used by `InputType.barcode`, or null to fall back to manual entry.
  BarcodeScanner? barcodeScanner;

  /// Recorder used by `InputType.audio`, or null to track elapsed time only.
  AudioRecorder? audioRecorder;

  /// Whether a real barcode scanner is available.
  bool get canScanBarcodes => barcodeScanner != null;

  /// Whether a real audio recorder is available.
  bool get canRecordAudio => audioRecorder != null;

  /// Clears every registered capability. Intended for tests.
  void reset() {
    barcodeScanner = null;
    audioRecorder = null;
  }
}
