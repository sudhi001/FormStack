import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formstack/formstack.dart';

class _StubScanner implements BarcodeScanner {
  _StubScanner(this.value);
  final String? value;
  int calls = 0;

  @override
  Future<String?> scan(BuildContext context) async {
    calls++;
    return value;
  }
}

class _ThrowingScanner implements BarcodeScanner {
  @override
  Future<String?> scan(BuildContext context) async =>
      throw StateError('camera unavailable');
}

class _StubRecorder implements AudioRecorder {
  bool started = false;

  @override
  Future<void> start() async => started = true;

  @override
  Future<AudioRecording?> stop() async => const AudioRecording(
    path: '/tmp/recording.m4a',
    duration: Duration(seconds: 3),
  );
}

void main() {
  setUp(() {
    FormStack.clearConfiguration();
    DeviceCapabilities.instance.reset();
  });
  tearDown(DeviceCapabilities.instance.reset);

  Future<QuestionStep> pump(WidgetTester tester, InputType type) async {
    final step = QuestionStep(
      id: GenericIdentifier(id: 'q'),
      inputType: type,
      title: 'Capture',
      isOptional: true,
    );
    FormStack.api().form(
      steps: [
        step,
        InstructionStep(id: GenericIdentifier(id: 'end')),
      ],
      mapKey: MapKey('', '', ''),
      initialLocation: LocationWrapper(0, 0),
    );
    await tester.pumpWidget(MaterialApp(home: FormStack.api().render()));
    return step;
  }

  group('DeviceCapabilities', () {
    test('reports what is available', () {
      expect(DeviceCapabilities.instance.canScanBarcodes, isFalse);
      expect(DeviceCapabilities.instance.canRecordAudio, isFalse);

      DeviceCapabilities.instance
        ..barcodeScanner = _StubScanner('x')
        ..audioRecorder = _StubRecorder();

      expect(DeviceCapabilities.instance.canScanBarcodes, isTrue);
      expect(DeviceCapabilities.instance.canRecordAudio, isTrue);
    });
  });

  group('barcode input', () {
    testWidgets('uses a registered scanner and stores its value', (
      tester,
    ) async {
      final scanner = _StubScanner('9780306406157');
      DeviceCapabilities.instance.barcodeScanner = scanner;

      final step = await pump(tester, InputType.barcode);
      await tester.tap(find.text('Tap to Scan'));
      await tester.pumpAndSettle();

      expect(scanner.calls, 1);
      expect(step.result, '9780306406157');
    });

    testWidgets('a cancelled scan leaves the previous answer alone', (
      tester,
    ) async {
      DeviceCapabilities.instance.barcodeScanner = _StubScanner(null);
      final step = await pump(tester, InputType.barcode);
      step.result = 'previous';

      await tester.tap(find.text('Tap to Scan'));
      await tester.pumpAndSettle();

      expect(step.result, 'previous');
    });

    testWidgets('a failing scanner does not take the form down', (
      tester,
    ) async {
      DeviceCapabilities.instance.barcodeScanner = _ThrowingScanner();
      await pump(tester, InputType.barcode);

      await tester.tap(find.text('Tap to Scan'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isA<StateError>());
      expect(find.text('Capture'), findsOneWidget);
    });

    testWidgets('falls back to manual entry with no scanner registered', (
      tester,
    ) async {
      await pump(tester, InputType.barcode);
      await tester.tap(find.text('Tap to Scan'));
      await tester.pumpAndSettle();

      // The manual-entry dialog stands in for the camera.
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('audio input', () {
    testWidgets('uses a registered recorder and stores the file path', (
      tester,
    ) async {
      final recorder = _StubRecorder();
      DeviceCapabilities.instance.audioRecorder = recorder;

      final step = await pump(tester, InputType.audio);
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();
      expect(recorder.started, isTrue);

      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();

      expect(step.result, '/tmp/recording.m4a');
    });

    testWidgets('without a recorder it records a duration marker only', (
      tester,
    ) async {
      final step = await pump(tester, InputType.audio);

      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();

      expect(step.result, isA<String>());
      expect(step.result as String, startsWith('audio_'));
    });
  });
}
