import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

/// Demonstrates the 3.0 extension points: registering a custom input type,
/// overriding a built-in one, adding a named validator usable from JSON,
/// supplying a device capability, and scoping the theme.
///
/// Everything here is registered once at start-up in a real app; it is done in
/// [initState] so the demo can be opened repeatedly.
class ExtensibilityDemo extends StatefulWidget {
  const ExtensibilityDemo({super.key});

  @override
  State<ExtensibilityDemo> createState() => _ExtensibilityDemoState();
}

class _ExtensibilityDemoState extends State<ExtensibilityDemo> {
  bool _loading = true;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _register();
    _buildForm();
  }

  void _register() {
    // 1. A brand-new input type, usable from Dart via InputType.custom and
    //    from JSON simply as "inputType": "colorPicker".
    InputRegistry.instance.register(
      'colorPicker',
      (ctx) => _ColorPickerView(ctx.form, ctx.step, ctx.text, title: ctx.title),
      defaultValidator: () => ResultFormat.notNull('Please pick a colour.'),
    );

    // 2. A validator resolvable by name, including from JSON.
    ResultFormat.register(
      'evenNumber',
      (message, args) => ResultFormat.custom(
        message,
        (value) => (int.tryParse(value) ?? 1).isEven,
      ),
    );

    // 3. A device capability. A real app would delegate to mobile_scanner;
    //    this stub shows where the seam is, and that the built-in barcode
    //    widget uses it instead of falling back to manual entry.
    DeviceCapabilities.instance.barcodeScanner = _DemoScanner();
  }

  void _buildForm() {
    FormStack.clearForms();
    FormStack.api().form(
      steps: [
        InstructionStep(
          id: GenericIdentifier(id: 'intro'),
          title: 'Extension points',
          text:
              'A custom input, a named validator and a device capability, all '
              'registered by this app rather than built into the library.',
          cancellable: false,
        ),
        QuestionStep(
          id: GenericIdentifier(id: 'colour'),
          title: 'Pick a colour',
          text: 'Rendered by an input type this app registered.',
          inputType: InputType.custom,
          customInputType: 'colorPicker',
        ),
        QuestionStep(
          id: GenericIdentifier(id: 'evens'),
          title: 'Enter an even number',
          text: 'Validated by a rule this app registered by name.',
          inputType: InputType.number,
          resultFormat: ResultFormat.fromJson({
            'type': 'evenNumber',
            'message': 'That is not an even number.',
          }),
        ),
        QuestionStep(
          id: GenericIdentifier(id: 'code'),
          title: 'Scan a code',
          text: 'The built-in barcode widget, driven by the scanner capability '
              'this app supplied.',
          inputType: InputType.barcode,
        ),
        CompletionStep(
          id: GenericIdentifier(id: 'done'),
          title: 'Done',
          text: 'Every answer above came through a registered extension.',
          onFinish: (result) {
            setState(() => _result = result.toString());
            if (mounted) Navigator.of(context).pop();
          },
        ),
      ],
      mapKey: MapKey('', '', ''),
      initialLocation: LocationWrapper(0, 0),
    );
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    // Leave the global registries as they were, so reopening the demo -- or
    // opening another one -- starts from a clean slate.
    InputRegistry.instance.unregister('colorPicker');
    ValidatorRegistry.instance.unregister('evenNumber');
    DeviceCapabilities.instance.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // A scoped theme: narrower content and squarer corners than the defaults,
    // applied to everything the form renders.
    return FormStackThemeScope(
      theme: const FormStackTheme(maxContentWidth: 520, borderRadius: 4),
      child: Scaffold(
        body: FormStack.api().render(),
        bottomSheet: _result.isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_result),
              ),
      ),
    );
  }
}

/// A minimal custom input: three swatches, one selectable.
///
/// Shows the five members every input must implement, and the disposal
/// contract — step views are `StatelessWidget`s, so the form releases them.
// ignore: must_be_immutable
class _ColorPickerView extends BaseStepView<QuestionStep> {
  _ColorPickerView(super.form, super.step, super.text, {super.title});

  static const _swatches = <String, Color>{
    'red': Colors.red,
    'green': Colors.green,
    'blue': Colors.blue,
  };

  final ValueNotifier<String?> _selected = ValueNotifier<String?>(null);

  @override
  Widget? buildWInputWidget(BuildContext context, QuestionStep formStep) {
    _selected.value ??= formStep.result as String?;
    return ValueListenableBuilder<String?>(
      valueListenable: _selected,
      builder: (context, selected, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _swatches.entries.map((entry) {
          final isSelected = selected == entry.key;
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: entry.key,
              child: InkWell(
                onTap: formStep.disabled
                    ? null
                    : () {
                        _selected.value = entry.key;
                        formStep.result = entry.key;
                        hideValidationError();
                      },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: entry.value,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  bool isValid() => formStep.resultFormat?.isValid(_selected.value) ?? true;

  @override
  String validationError() => formStep.resultFormat?.error() ?? '';

  @override
  dynamic resultValue() => _selected.value;

  @override
  void requestFocus() {}

  @override
  void clearFocus() {}

  // Required: the framework never disposes a StatelessWidget, so anything
  // allocated here is released by the form through this method.
  @override
  void dispose() {
    _selected.dispose();
    super.dispose();
  }
}

/// Stands in for a real scanner so the demo runs without a camera.
class _DemoScanner implements BarcodeScanner {
  int _n = 0;

  @override
  Future<String?> scan(BuildContext context) async {
    // A real adapter would push a scanner route and return what it read.
    // Returning null means the user cancelled, and leaves the answer alone.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return '978030640615${_n++ % 10}';
  }
}
