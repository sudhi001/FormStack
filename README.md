# FormStack

[![pub package](https://img.shields.io/pub/v/formstack.svg)](https://pub.dev/packages/formstack)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D1.17-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-blue)](https://flutter.dev/multi-platform)

A cross-platform alternative to Apple ResearchKit for Flutter. Build dynamic forms, surveys, and research questionnaires from Dart objects or JSON -- on iOS, Android, Web, macOS, Windows, and Linux.

35 input types, 9 step types, 35+ validators, conditional navigation, structured consent flows, answer review, progress tracking, and full extensibility. Every ResearchKit UI pattern can be reproduced with FormStack.

### Why FormStack over ResearchKit?

| | ResearchKit | FormStack |
|---|---|---|
| **Platforms** | iOS only | iOS, Android, Web, macOS, Windows, Linux |
| **Language** | Swift/Objective-C | Dart (Flutter) |
| **Form source** | Code only | Dart objects or JSON |
| **Input types** | ~15 answer formats | 35 input types |
| **Validators** | Basic (length, regex) | 35+ built-in + custom subclassing |
| **Extensibility** | Subclass ORKStep | Subclass FormStep, BaseStepView, ResultFormat, RelevantCondition |
| **Results** | ORKTaskResult hierarchy | TaskResult/StepResult with timestamps + JSON export |
| **Consent flow** | ORKConsentDocument | ConsentStep with sections + agreement |
| **Review step** | ORKReviewStep | ReviewStep with formatted answer display |
| **Progress bar** | Built-in | Built-in with step counter |

## Screenshots

<p align="center">
  <img src="https://raw.githubusercontent.com/sudhi001/FormStack/main/screenshots/img1.png" width="200" alt="Instruction Step" />
  <img src="https://raw.githubusercontent.com/sudhi001/FormStack/main/screenshots/img2.png" width="200" alt="Name Input" />
  <img src="https://raw.githubusercontent.com/sudhi001/FormStack/main/screenshots/img3.png" width="200" alt="Email Input" />
  <img src="https://raw.githubusercontent.com/sudhi001/FormStack/main/screenshots/img4.png" width="200" alt="Multiline Text" />
</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/sudhi001/FormStack/main/screenshots/img5.png" width="200" alt="Multiple Choice" />
  <img src="https://raw.githubusercontent.com/sudhi001/FormStack/main/screenshots/img6.png" width="200" alt="Multiple Choice Selected" />
  <img src="https://raw.githubusercontent.com/sudhi001/FormStack/main/screenshots/img7.png" width="200" alt="Single Choice" />
  <img src="https://raw.githubusercontent.com/sudhi001/FormStack/main/screenshots/img8.png" width="200" alt="Time Picker" />
</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/sudhi001/FormStack/main/screenshots/img9.png" width="200" alt="Date Picker" />
  <img src="https://raw.githubusercontent.com/sudhi001/FormStack/main/screenshots/img10.png" width="200" alt="Smile Rating" />
  <img src="https://raw.githubusercontent.com/sudhi001/FormStack/main/screenshots/img11.png" width="200" alt="Completion Step" />
</p>

## ResearchKit to FormStack Migration

If you're migrating from Apple ResearchKit, here's how the concepts map:

### Step Types

| ResearchKit (iOS) | FormStack (Flutter) | Notes |
|---|---|---|
| `ORKInstructionStep` | `InstructionStep` | Supports Lottie animations, static images, and video URLs |
| `ORKQuestionStep` | `QuestionStep` | 35 input types vs ResearchKit's ~15 |
| `ORKFormStep` | `NestedStep` | Multiple fields on one screen with cross-field validation |
| `ORKCompletionStep` | `CompletionStep` | Loading/success/error Lottie animations, async callbacks |
| `ORKConsentDocument` + `ORKVisualConsentStep` | `ConsentStep` | Expandable sections with 8 predefined types |
| `ORKConsentReviewStep` | `ConsentStep` (agreement checkbox) | Built into ConsentStep |
| `ORKReviewStep` | `ReviewStep` | Displays all answers before submission |
| `ORKSignatureStep` | `QuestionStep(inputType: InputType.signature)` | Canvas drawing, returns base64 PNG |
| `ORKWebViewStep` | `DisplayStep(displayStepType: DisplayStepType.web)` | WebView content |
| `ORKNavigableOrderedTask` | `FormStack.api().form(steps: [...])` | Conditional navigation via `relevantConditions` |

### Answer Formats

| ResearchKit (iOS) | FormStack (Flutter) | Code |
|---|---|---|
| `ORKTextAnswerFormat` | `InputType.text` | `QuestionStep(inputType: InputType.text, numberOfLines: 3)` |
| `ORKNumericAnswerFormat` | `InputType.number` | `QuestionStep(inputType: InputType.number)` |
| `ORKScaleAnswerFormat` | `InputType.slider` | `QuestionStep(inputType: InputType.slider, minValue: 0, maxValue: 10)` |
| `ORKBooleanAnswerFormat` | `InputType.boolean` | `QuestionStep(inputType: InputType.boolean)` |
| `ORKTextChoiceAnswerFormat` (single) | `InputType.singleChoice` | `QuestionStep(inputType: InputType.singleChoice, options: [...])` |
| `ORKTextChoiceAnswerFormat` (multi) | `InputType.multipleChoice` | `QuestionStep(inputType: InputType.multipleChoice, options: [...])` |
| `ORKImageChoiceAnswerFormat` | `InputType.imageChoice` | `QuestionStep(inputType: InputType.imageChoice, options: [...])` |
| `ORKValuePickerAnswerFormat` | `InputType.dropdown` | `QuestionStep(inputType: InputType.dropdown, options: [...])` |
| `ORKDateAnswerFormat` | `InputType.date` | `QuestionStep(inputType: InputType.date)` |
| `ORKTimeOfDayAnswerFormat` | `InputType.time` | `QuestionStep(inputType: InputType.time)` |
| `ORKLocationAnswerFormat` | `InputType.mapLocation` | `QuestionStep(inputType: InputType.mapLocation)` |

### Navigation Rules

| ResearchKit (iOS) | FormStack (Flutter) | Code |
|---|---|---|
| `ORKPredicateStepNavigationRule` | `ExpressionRelevant` | `ExpressionRelevant(identifier: GenericIdentifier(id: "step"), expression: "IN value")` |
| `ORKDirectStepNavigationRule` | `ExpressionRelevant` with `FOR_ALL` | `ExpressionRelevant(identifier: ..., expression: "FOR_ALL")` |
| Custom delegate | `DynamicConditionalRelevant` | `DynamicConditionalRelevant(identifier: ..., isValidCallBack: (result) => ...)` |

### Results

| ResearchKit (iOS) | FormStack (Flutter) | Code |
|---|---|---|
| `ORKTaskResult` | `TaskResult` | `FormStack.api().getTaskResult()` |
| `ORKStepResult` | `StepResult` | Includes `startTime`, `endTime`, `duration`, `value` |
| `result.startDate` / `endDate` | `step.startTime` / `endTime` | Automatic timestamp recording |
| JSON serialization | `exportAsJson()` | `FormStack.api().exportAsJson(formName: "myForm")` |

### Quick Migration Example

**ResearchKit (Swift):**
```swift
let step1 = ORKInstructionStep(identifier: "intro")
step1.title = "Welcome"
step1.text = "This survey takes 5 minutes"

let step2 = ORKQuestionStep(identifier: "name")
step2.title = "Your Name"
step2.answerFormat = ORKTextAnswerFormat(maximumLength: 50)

let step3 = ORKQuestionStep(identifier: "satisfaction")
step3.title = "How satisfied are you?"
step3.answerFormat = ORKScaleAnswerFormat(maximumValue: 10, minimumValue: 0, defaultValue: 5, step: 1)

let task = ORKOrderedTask(identifier: "survey", steps: [step1, step2, step3])
let taskVC = ORKTaskViewController(task: task, taskRun: nil)
```

**FormStack (Dart) - same UI, all platforms:**
```dart
FormStack.api().form(steps: [
  InstructionStep(
    id: GenericIdentifier(id: "intro"),
    title: "Welcome",
    text: "This survey takes 5 minutes",
  ),
  QuestionStep(
    id: GenericIdentifier(id: "name"),
    title: "Your Name",
    inputType: InputType.name,
    lengthLimit: 50,
  ),
  QuestionStep(
    id: GenericIdentifier(id: "satisfaction"),
    title: "How satisfied are you?",
    inputType: InputType.slider,
    minValue: 0,
    maxValue: 10,
    stepValue: 1,
    defaultValue: 5,
  ),
]);

// Render in any Flutter widget
Scaffold(body: FormStack.api().render());
```

---

## Installation

```yaml
dependencies:
  formstack: ^2.5.0
```

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:formstack/formstack.dart';

// Build and render a form
FormStack.api().form(steps: [
  QuestionStep(
    title: "Your Name",
    inputType: InputType.name,
    id: GenericIdentifier(id: "name"),
  ),
  QuestionStep(
    title: "Email",
    inputType: InputType.email,
    id: GenericIdentifier(id: "email"),
  ),
  CompletionStep(
    title: "Done!",
    id: GenericIdentifier(id: "done"),
    onFinish: (result) => print(result),
  ),
]);

// In your widget
Scaffold(body: FormStack.api().render());
```

Or load from JSON:

```dart
await FormStack.api().loadFromAsset('assets/form.json');
Scaffold(body: FormStack.api().render());
```

---

## Supported Input Types

### Text Inputs

| InputType | Description | Keyboard | Validation |
|-----------|-------------|----------|------------|
| `email` | Email address | Email keyboard | Regex email validation |
| `name` | Person name | Text, auto-capitalize words | Letters only, min 2 chars |
| `password` | Secure password | Visible password | Uppercase, lowercase, digit, special char, 8+ |
| `text` | General text | Multiline | Non-empty, configurable `numberOfLines` |
| `number` | Numeric input | Number pad | Digits only, supports `mask` formatting |
| `phone` | Phone with country code | Phone | Country code dropdown + E.164 format |
| `currency` | Money amount | Decimal number | Currency symbol prefix, formatted input |

### Date & Time

| InputType | Description | Result Type |
|-----------|-------------|-------------|
| `date` | Date picker | `DateTime` |
| `time` | Time picker | `DateTime` |
| `dateTime` | Combined date + time | `DateTime` |

### Choice Inputs

| InputType | Description | Selection Styles |
|-----------|-------------|-----------------|
| `singleChoice` | Select one option | `arrow`, `tick`, `toggle` |
| `multipleChoice` | Select multiple | `tick`, `toggle` |
| `dropdown` | Dropdown menu | Standard dropdown |
| `ranking` | Drag-to-reorder list | Reorderable with rank numbers |
| `boolean` | Yes/No toggle buttons | Two-button selection |
| `imageChoice` | Select from a grid of images | Image cards with labels |

### Survey & Rating

| InputType | Description | Result Type |
|-----------|-------------|-------------|
| `slider` | Range slider | `double` (configurable min/max/step) |
| `rating` | Star rating | `int` (1 to N stars) |
| `nps` | Net Promoter Score (0-10) | `int` (color-coded scale) |
| `smile` | Emoji satisfaction | `int` (1-5 scale) |

### Media & Files

| InputType | Description | Result Type |
|-----------|-------------|-------------|
| `file` | File picker with filters | `PlatformFile` |
| `avatar` | Circular image upload | `String` (base64) |
| `banner` | Rectangular image upload | `String` (base64) |
| `signature` | Draw signature on canvas | `String` (base64 PNG) |
| `mapLocation` | Google Maps picker | Location coordinates |
| `geotrace` | Trace a path/line on map | `List<Map>` (lat/lng points) |
| `geoshape` | Draw a polygon on map | `List<Map>` (lat/lng points) |

### Special

| InputType | Description | Result Type |
|-----------|-------------|-------------|
| `otp` | Multi-digit OTP entry | `int` |
| `consent` | Checkbox with agreement text | `bool` |
| `dynamicKeyValue` | Add/remove key-value pairs | `List<KeyValue>` |
| `htmlEditor` | Rich text editor | `String` |
| `hidden` | Hidden data field (no UI, auto-advances) | `dynamic` |
| `calculate` | Auto-computed from other results | `dynamic` |
| `barcode` | Barcode/QR scan, with manual entry fallback | `String` |
| `audio` | Audio recording with timer | `String` (file path) |

> **`barcode` and `audio` need a capability from your app.** FormStack declares
> no camera or microphone dependency, so an application that never scans or
> records does not inherit those SDKs. Both inputs work out of the box in
> degraded form — `barcode` falls back to manual entry, `audio` records only a
> duration — and become fully functional once you register a capability. See
> [Device capabilities](#device-capabilities).

---

## Step Types

### InstructionStep

Welcome screens, information pages, instructions.

```dart
InstructionStep(
  id: GenericIdentifier(id: "welcome"),
  title: "Customer Survey",
  text: "This will take about 2 minutes",
  cancellable: false,
  display: Display.medium,
)
```

### QuestionStep

The main input step. Supports all 28 input types.

```dart
QuestionStep(
  id: GenericIdentifier(id: "email"),
  title: "Email Address",
  text: "We'll send your receipt here",
  inputType: InputType.email,
  inputStyle: InputStyle.outline,
  isOptional: false,
  hint: "you@example.com",
)
```

### CompletionStep

Form completion with loading/success/error animations.

```dart
CompletionStep(
  id: GenericIdentifier(id: "done"),
  title: "Submitting...",
  autoTrigger: false,
  onFinish: (result) => print("Result: $result"),
  onBeforeFinishCallback: (result) async {
    await submitToApi(result);
    return true; // false shows error animation
  },
)
```

### NestedStep

Multiple fields on a single screen.

```dart
NestedStep(
  id: GenericIdentifier(id: "contact"),
  title: "Contact Information",
  verticalPadding: 10,
  validationExpression: "",
  steps: [
    QuestionStep(title: "", inputType: InputType.name, label: "First Name",
        id: GenericIdentifier(id: "first"), width: 400),
    QuestionStep(title: "", inputType: InputType.name, label: "Last Name",
        id: GenericIdentifier(id: "last"), width: 400),
    QuestionStep(title: "", inputType: InputType.email, label: "Email",
        id: GenericIdentifier(id: "email"), width: 400),
  ],
)
```

### ReviewStep

Displays all collected answers for review before submission. Place before CompletionStep.

```dart
ReviewStep(
  id: GenericIdentifier(id: "review"),
  title: "Review Your Answers",
  text: "Verify before submitting",
  nextButtonText: "Submit",
)
```

### ConsentStep

Structured consent document with expandable sections, agreement checkbox, and optional signature. Modeled after Apple ResearchKit's consent flow.

```dart
ConsentStep(
  id: GenericIdentifier(id: "consent"),
  title: "Informed Consent",
  requiresSignature: true,
  agreementText: "I agree to participate",
  sections: [
    ConsentSection(
      type: ConsentSectionType.overview,
      title: "About This Study",
      summary: "Brief overview...",
      content: "Full details shown on expand...",
    ),
    ConsentSection(
      type: ConsentSectionType.privacy,
      title: "Your Privacy",
      summary: "Data is encrypted and anonymized.",
    ),
    ConsentSection(
      type: ConsentSectionType.withdrawing,
      title: "Withdrawing",
      summary: "You can stop at any time.",
    ),
  ],
)
```

**ConsentSectionType values:** `overview`, `dataGathering`, `privacy`, `dataUse`, `timeCommitment`, `studyTasks`, `withdrawing`, `custom`

### RepeatStep

Dynamic repeating sections where users add/remove entries. Modeled after ODK's `repeat`.

```dart
RepeatStep(
  id: GenericIdentifier(id: "members"),
  title: "Household Members",
  minRepeat: 1,
  maxRepeat: 10,
  addButtonText: "Add Member",
  steps: [
    QuestionStep(title: "", inputType: InputType.name, label: "Name",
        id: GenericIdentifier(id: "name"), width: 400),
    QuestionStep(title: "", inputType: InputType.number, label: "Age",
        id: GenericIdentifier(id: "age"), width: 400),
  ],
)
```

Result: `List<Map<String, dynamic>>` - one map per repetition.

### DisplayStep

Show web content or data lists.

```dart
DisplayStep(
  id: GenericIdentifier(id: "info"),
  url: "https://example.com/terms",
  displayStepType: DisplayStepType.web,
)
```

---

## Validation

### Built-in Validators

```dart
// Text validators
ResultFormat.email("Invalid email")
ResultFormat.name("Invalid name")
ResultFormat.password("Weak password")
ResultFormat.text("Required")
ResultFormat.number("Must be a number")
ResultFormat.phone("Invalid phone")
ResultFormat.url("Invalid URL")

// Numeric range validators
ResultFormat.min("Must be at least 18", 18)
ResultFormat.max("Cannot exceed 100", 100)
ResultFormat.range("Must be 1-10", 1, 10)
ResultFormat.age("Invalid age (0-150)")
ResultFormat.percentage("Must be 0-100")

// String length validators
ResultFormat.minLength("Too short", 3)
ResultFormat.maxLength("Too long", 50)
ResultFormat.pattern("Invalid format", r'^[A-Z]{3}\d{4}$')
ResultFormat.length("Must be exactly 6 digits", 6)

// Choice validators
ResultFormat.singleChoice("Please select one")
ResultFormat.multipleChoice("Select at least one")
ResultFormat.minSelections("Select at least 2", 2)
ResultFormat.maxSelections("Select at most 3", 3)

// Specialty validators
ResultFormat.creditCard("Invalid card number")    // Luhn algorithm
ResultFormat.ssn("Invalid SSN")                    // ###-##-####
ResultFormat.zipCode("Invalid zip")                // #####(-####)
ResultFormat.iban("Invalid IBAN")                  // ISO 13616
ResultFormat.consent("You must agree")             // Must be true
ResultFormat.dateRange("Invalid date", "dd-MM-yyyy",
    minDate: DateTime(2000), maxDate: DateTime(2030)) // Date bounds
ResultFormat.fileSize("File too large", 5242880)   // Max bytes
ResultFormat.notNull("Required")
ResultFormat.notBlank("Cannot be empty")
ResultFormat.notEmpty("List cannot be empty")

// Custom validator
ResultFormat.custom("Must start with 'hello'",
    (value) => value.startsWith('hello'))

// Compose multiple validators
ResultFormat.compose([
  ResultFormat.minLength("Too short", 3),
  ResultFormat.maxLength("Too long", 50),
  ResultFormat.pattern("Letters only", r'^[a-zA-Z\s]+$'),
])
```

---

---

## Extending FormStack

FormStack resolves input widgets, step types and validators through registries.
Anything you register is available to Dart-defined *and* JSON-defined forms,
which means you can add capabilities — or replace built-in ones — without
forking the library.

### Custom input types

Register a builder, then use it by name:

```dart
// Once, at start-up.
InputRegistry.instance.register(
  'creditCardScanner',
  (ctx) => CreditCardScannerView(ctx.form, ctx.step, ctx.text, ctx.resultFormat,
      title: ctx.title),
  defaultValidator: () => ResultFormat.creditCard('Invalid card number'),
);
```

From Dart:

```dart
QuestionStep(
  id: GenericIdentifier(id: "card"),
  inputType: InputType.custom,
  customInputType: "creditCardScanner",
  title: "Scan your card",
)
```

From JSON — just name it:

```json
{ "type": "QuestionStep", "id": "card", "inputType": "creditCardScanner" }
```

A custom input extends `BaseStepView<QuestionStep>` and implements five members:

```dart
// ignore: must_be_immutable
class CreditCardScannerView extends BaseStepView<QuestionStep> {
  CreditCardScannerView(super.form, super.step, super.text, this.resultFormat,
      {super.title});

  final ResultFormat resultFormat;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget? buildWInputWidget(BuildContext context, QuestionStep formStep) =>
      TextField(controller: _controller);

  @override
  bool isValid() => resultFormat.isValid(_controller.text);

  @override
  String validationError() => resultFormat.error();

  @override
  dynamic resultValue() => _controller.text;

  @override
  void clearFocus() {}

  @override
  void requestFocus() {}

  // Required whenever your view allocates anything disposable.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Replacing a built-in input

Registering an existing name overrides it for every form:

```dart
// Every `signature` step now uses your pad instead of the built-in canvas.
InputRegistry.instance.register('signature', (ctx) => CompliantSignaturePad(ctx));
```

This is also how you make `barcode` and `audio` real — see the note under
[Media & Files](#media--files).

### Device capabilities

Two inputs need hardware FormStack does not depend on. Supply the capability
once at start-up and the built-in widgets use it — you keep FormStack's layout,
validation and result handling and replace only the capture step.

```dart
void main() {
  DeviceCapabilities.instance
    ..barcodeScanner = MobileScannerAdapter()
    ..audioRecorder = RecordAdapter();
  runApp(const MyApp());
}
```

```dart
class MobileScannerAdapter implements BarcodeScanner {
  @override
  Future<String?> scan(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MyScannerPage()),
      );
}

class RecordAdapter implements AudioRecorder {
  final _recorder = AudioRecorder();       // from package:record
  DateTime? _startedAt;

  @override
  Future<void> start() async {
    _startedAt = DateTime.now();
    await _recorder.start(const RecordConfig(), path: await _tempPath());
  }

  @override
  Future<AudioRecording?> stop() async {
    final path = await _recorder.stop();
    if (path == null) return null;
    return AudioRecording(
      path: path,
      duration: DateTime.now().difference(_startedAt!),
    );
  }
}
```

Returning null from `scan` or `stop` means the user cancelled and leaves any
existing answer untouched. Throwing is reported through `FlutterError` rather
than crashing the form.

With a scanner registered, `InputType.barcode` stores the scanned string; with
a recorder, `InputType.audio` stores the recording's file path. Without them
the inputs still render and the form still completes.

To replace an input entirely rather than just its capture step, register a
widget with [`InputRegistry`](#custom-input-types).

### Custom step types

```dart
StepRegistry.instance.register(
  'PaymentStep',
  (json, conditions) => PaymentStep.from(json, conditions),
);
```

`{"type": "PaymentStep", ...}` is then parseable by every JSON loader.

### Custom validators

```dart
ResultFormat.register(
  'nhsNumber',
  (message, args) => NhsNumberFormat(message),
);
```

```json
{"type": "nhsNumber", "message": "Not a valid NHS number"}
```

---

## Validation in JSON

JSON-defined steps can use the full validator library, not just the default
implied by `inputType`. Declare `validators` as a single object or a list — a
list is evaluated in order and reports the first failure:

```json
{
  "type": "QuestionStep",
  "id": "age",
  "title": "Your age",
  "inputType": "number",
  "validators": [
    {"type": "notBlank", "message": "Age is required"},
    {"type": "range", "message": "Must be between 18 and 120", "min": 18, "max": 120}
  ]
}
```

Every `ResultFormat` factory has a JSON name. Arguments map to the factory's
parameters: `min`, `max`, `count`, `maxBytes`, `regex`, `expression`, `format`,
`minDate`, `maxDate`.

### Structured validation results

`validate()` returns a stable code and the constraint parameters alongside the
message, so failures can be localized or reported without matching on strings:

```dart
final outcome = ResultFormat.range("Must be 18-120", 18, 120).validate(5);

outcome.isValid;  // false
outcome.code;     // 'range'
outcome.params;   // {'min': 18, 'max': 120}
outcome.message;  // 'Must be 18-120'
```

Localize by mapping the code through your own catalogue:

```dart
String localize(ValidationResult r, FormStackLocale l10n) => r.isValid
    ? ''
    : l10n.tf('validation.${r.code}', [...r.params.values.map((v) => '$v')]);
```

`isValid()` and `error()` continue to work unchanged.

---

## Performance notes

- **Step views are cached and bounded.** `FormStackForm.maxCachedViews`
  (default 12) caps how many step views are retained, so a long survey does not
  hold every controller alive. The current step is never evicted. Raise it to
  trade memory for back-navigation fidelity, or set `0` to disable caching.
- **Views are disposed with the form.** Removing `FormStack.api().render()`
  from the tree releases every cached view. If you build custom inputs,
  override `dispose()` and call `super.dispose()`.
- **Step lookup is indexed.** `getStep`, `getCurrentIndex` and `progress` are
  constant-time rather than walking the step list.
- **Use `form.progress`** rather than calling `getCurrentIndex()` and
  `getTotalSteps()` separately — it computes both in one pass.

## Styling

### Input Styles

```dart
inputStyle: InputStyle.basic      // Flat, no border
inputStyle: InputStyle.outline    // Full border
inputStyle: InputStyle.underLined // Bottom border only
```

### Component Styles

```dart
componentsStyle: ComponentsStyle.minimal  // Clean, minimal
componentsStyle: ComponentsStyle.basic    // Card-style with background
```

### Display Sizes

```dart
display: Display.small       // Compact
display: Display.normal      // Standard (default)
display: Display.medium      // Larger headings
display: Display.large       // Big text
display: Display.extraLarge  // Maximum size
```

### Selection Types (for choices)

```dart
selectionType: SelectionType.arrow    // Navigate arrows
selectionType: SelectionType.tick     // Checkmark
selectionType: SelectionType.toggle   // Switch toggle
selectionType: SelectionType.dropdown // Dropdown menu
```

### Custom Theme (Dart)

```dart
QuestionStep(
  title: "Styled",
  inputType: InputType.text,
  style: UIStyle(
    Colors.indigo,       // Button background
    Colors.white,        // Button foreground
    Colors.indigo,       // Input border color
    8.0,                 // Title bottom padding
    12.0,                // Button border radius
    inputBackground: Colors.grey.shade100,
    inputTextColor: Colors.black87,
    titleColor: Colors.indigo,
    iconColor: Colors.indigo,
    cardBackground: Colors.white,
    fontSize: 16.0,
  ),
)
```

### Custom Theme (JSON)

Apply a form-level theme to all steps, or style individual steps:

```json
{
  "my_form": {
    "theme": {
      "backgroundColor": "#3F51B5",
      "foregroundColor": "#FFFFFF",
      "borderColor": "#3F51B5",
      "borderRadius": 12,
      "inputBackground": "#F5F5F5",
      "inputTextColor": "#212121",
      "titleColor": "#3F51B5",
      "subtitleColor": "#757575",
      "iconColor": "#3F51B5",
      "cardBackground": "#FFFFFF",
      "fontSize": 16
    },
    "steps": [
      {
        "type": "QuestionStep",
        "id": "name",
        "title": "Your Name",
        "inputType": "name",
        "style": {
          "backgroundColor": "#FF5722",
          "foregroundColor": "#FFFFFF",
          "borderRadius": 24
        }
      }
    ]
  }
}
```

The `theme` key applies to all steps as a default. Individual step `style` overrides the form theme.

### Dark Mode

FormStack automatically adapts to your app's theme. No configuration needed:

```dart
MaterialApp(
  theme: ThemeData.light(useMaterial3: true),
  darkTheme: ThemeData.dark(useMaterial3: true),
  themeMode: ThemeMode.system, // Auto dark/light
  home: Scaffold(body: FormStack.api().render()),
)
```

All colors resolve from `Theme.of(context).colorScheme` at runtime.

---

## Cascading Selects

Filter choices based on previous answers:

```dart
QuestionStep(
  title: "State",
  inputType: InputType.dropdown,
  options: allStates, // Full list
  choiceFilter: (options, results) =>
      options.where((o) => o.value == results["country"]).toList(),
)
```

## Calculated Fields

Auto-compute values from other step results:

```dart
QuestionStep(
  title: "BMI",
  inputType: InputType.calculate,
  calculateCallback: (results) {
    final weight = double.tryParse(results["weight"]?.toString() ?? "") ?? 0;
    final height = double.tryParse(results["height"]?.toString() ?? "") ?? 1;
    return (weight / (height * height)).toStringAsFixed(1);
  },
  helperText: "Calculated from height and weight",
)
```

## Multi-Language Support

```dart
final locale = FormStackLocale(
  defaultLocale: 'en',
  translations: {
    'en': {'name_title': 'Your Name', 'name_hint': 'Enter full name'},
    'es': {'name_title': 'Tu Nombre', 'name_hint': 'Ingrese nombre completo'},
    'fr': {'name_title': 'Votre Nom', 'name_hint': 'Entrez le nom complet'},
  },
);

QuestionStep(
  title: locale.t('name_title'),
  hint: locale.t('name_hint'),
  inputType: InputType.name,
)

// Switch language at runtime
locale.setLocale('es');
```

## Conditional Navigation

Route users to different steps based on their answers:

```dart
QuestionStep(
  id: GenericIdentifier(id: "role"),
  title: "Your Role",
  inputType: InputType.singleChoice,
  autoTrigger: true,
  options: [
    Options("dev", "Developer"),
    Options("designer", "Designer"),
  ],
  relevantConditions: [
    ExpressionRelevant(
      identifier: GenericIdentifier(id: "dev_questions"),
      expression: "IN dev",
    ),
    ExpressionRelevant(
      identifier: GenericIdentifier(id: "design_questions"),
      expression: "IN designer",
    ),
  ],
)
```

**Expression syntax:**
- `IN value` - Result contains the value
- `NOT_IN value` - Result does not contain the value
- `FOR_ALL` - Always matches (converge paths)
- `= value` / `!= value` - Exact match

Cross-form navigation with `formName`:

```dart
ExpressionRelevant(
  identifier: GenericIdentifier(id: "step_id"),
  expression: "IN selected_option",
  formName: "another_form",  // Navigate to a different form
)
```

---

## API Reference

### FormStack

```dart
// Create/get instance (supports named instances)
FormStack.api()
FormStack.api(name: "myForm")

// Build form from Dart objects
FormStack.api().form(steps: [...], name: "formName")

// Load from JSON
await FormStack.api().loadFromAsset('assets/form.json')
await FormStack.api().loadFromAssets(['assets/a.json', 'assets/b.json'])

// Render
FormStack.api().render()
FormStack.api().render(name: "formName")

// Pre-fill data
FormStack.api().setResult({"email": "user@test.com"}, formName: "myForm")

// Set validation error on a field
FormStack.api().setError(GenericIdentifier(id: "email"), "Already taken", formName: "myForm")

// Update options dynamically
FormStack.api().setOptions([Options("a", "A")], GenericIdentifier(id: "choice"))

// Disable specific fields
FormStack.api().setDisabledUI(["field_id_1", "field_id_2"])

// Completion callback with async pre-validation
FormStack.api().addCompletionCallback(
  GenericIdentifier(id: "done"),
  formName: "myForm",
  onFinish: (result) => print(result),
  onBeforeFinishCallback: (result) async {
    final success = await api.submit(result);
    return success; // false = show error animation
  },
);

// Progress tracking
double progress = FormStack.api().getFormProgress();       // 0.0 - 1.0
int step = FormStack.api().getCurrentStepIndex();
bool done = FormStack.api().isFormCompleted();
Map stats = FormStack.api().getFormStats();
// stats: {totalSteps, completedSteps, requiredSteps, optionalSteps, progress, isCompleted}

// Back navigation control
FormStack.api().systemBackNavigation(true, () => print("Back pressed"));

// Cleanup
FormStack.clearForms();
FormStack.api().clearConfiguration();
```

---

## JSON Schema

All step types and properties are supported in JSON. Wrap forms in a named object:

```json
{
  "my_form": {
    "backgroundAnimationFile": "assets/bg.json",
    "steps": [
      {
        "type": "InstructionStep",
        "id": "welcome",
        "title": "Welcome",
        "text": "Complete this survey",
        "cancellable": false,
        "display": "medium"
      },
      {
        "type": "QuestionStep",
        "id": "name",
        "title": "Full Name",
        "inputType": "name",
        "inputStyle": "outline",
        "isOptional": false,
        "hint": "John Doe",
        "helperText": "Enter your legal name",
        "validators": [
          {"type": "notBlank", "message": "Name is required"},
          {"type": "minLength", "message": "Too short", "min": 2}
        ]
      },
      {
        "type": "QuestionStep",
        "id": "satisfaction",
        "title": "How satisfied are you?",
        "inputType": "slider",
        "minValue": 0,
        "maxValue": 10,
        "stepValue": 1,
        "defaultValue": 5
      },
      {
        "type": "QuestionStep",
        "id": "rating",
        "title": "Rate our service",
        "inputType": "rating",
        "ratingCount": 5
      },
      {
        "type": "QuestionStep",
        "id": "recommend",
        "title": "Would you recommend us?",
        "inputType": "nps"
      },
      {
        "type": "QuestionStep",
        "id": "country",
        "title": "Country",
        "inputType": "dropdown",
        "componentsStyle": "basic",
        "options": [
          {"key": "US", "title": "United States"},
          {"key": "UK", "title": "United Kingdom"},
          {"key": "IN", "title": "India"}
        ]
      },
      {
        "type": "QuestionStep",
        "id": "phone",
        "title": "Phone",
        "inputType": "phone",
        "phoneCountryCode": "+1"
      },
      {
        "type": "QuestionStep",
        "id": "budget",
        "title": "Budget",
        "inputType": "currency",
        "currencySymbol": "$"
      },
      {
        "type": "QuestionStep",
        "id": "priorities",
        "title": "Rank by priority",
        "inputType": "ranking",
        "options": [
          {"key": "speed", "title": "Speed"},
          {"key": "quality", "title": "Quality"},
          {"key": "cost", "title": "Cost"}
        ]
      },
      {
        "type": "QuestionStep",
        "id": "agree",
        "title": "Agreement",
        "inputType": "consent",
        "consentText": "I agree to the terms and conditions"
      },
      {
        "type": "QuestionStep",
        "id": "sig",
        "title": "Signature",
        "inputType": "signature"
      },
      {
        "type": "CompletionStep",
        "id": "done",
        "title": "Thank you!",
        "autoTrigger": true
      }
    ]
  }
}
```

### Supported JSON Fields

**All Steps:** `type`, `id`, `title`, `text`, `description`, `hint`, `label`, `display`, `isOptional`, `cancellable`, `disabled`, `nextButtonText`, `backButtonText`, `cancelButtonText`, `footerBackButton`, `componentsStyle`, `crossAxisAlignmentContent`, `titleIconAnimationFile`, `titleIconMaxWidth`, `width`, `helperText`, `defaultValue`, `semanticLabel`, `style`

**QuestionStep:** `inputType`, `inputStyle`, `options`, `selectionType`, `autoTrigger`, `numberOfLines`, `count`, `maxCount`, `mask`, `filter`, `maxHeight`, `lengthLimit`, `textAlign`, `relevantConditions`, `minValue`, `maxValue`, `stepValue`, `minSelections`, `maxSelections`, `consentText`, `currencySymbol`, `phoneCountryCode`, `ratingCount`

**CompletionStep:** `autoTrigger`, `successLottieAssetsFilePath`, `loadingLottieAssetsFilePath`, `errorLottieAssetsFilePath`

**NestedStep:** `steps`, `validationExpression`, `verticalPadding`

**DisplayStep:** `url`, `displayStepType`, `data`

---

## Examples

The [example app](example/) demonstrates all features across 12 demo screens:

| Demo | Features |
|------|----------|
| All Input Types | Core input types: text, email, name, password, number, date, time, choices, OTP, smile, file, key-value, avatar, banner |
| Styles & Display | InputStyle, ComponentsStyle, Display sizes, UIStyle, JSON theming, dark mode |
| Selection Types | Arrow, tick, toggle, dropdown |
| Validation | Email, password, phone, URL, age, zip, dateRange, custom, compose |
| Conditional Nav | ExpressionRelevant branching and path convergence |
| Nested Steps | Multi-field screens with cross-field validation |
| API Features | setResult, setError, callbacks, progress tracking |
| Survey Components | Slider, rating, NPS, consent, signature, ranking, phone, currency |
| ResearchKit Features | Boolean, image choice, consent flow, review step, progress bar, timestamps |
| Data Collection (ODK) | RepeatStep, calculate, hidden, cascading selects, barcode, audio, geotrace, geoshape |
| Multi-Language & Offline | FormStackLocale, runtime language switching, DisplayStep, offline save/resume |
| Load from JSON | Multi-file JSON loading with form linking |

Run the example:

```bash
cd example
flutter run
```

---

## Extending by Subclassing

The [registries](#extending-formstack) are the way to make an extension
available to JSON forms and to override built-ins. When you only need a
one-off used from Dart, you can also pass a subclass directly.

### Custom Validators

Subclass `ResultFormat` directly:

```dart
class PalindromeValidator extends ResultFormat {
  final String errorMsg;
  PalindromeValidator(this.errorMsg);

  @override
  bool isValid(dynamic input) {
    final str = (input as String?)?.toLowerCase() ?? '';
    return str == str.split('').reversed.join();
  }

  @override
  String error() => errorMsg;
}

// Use it
QuestionStep(
  inputType: InputType.text,
  resultFormat: PalindromeValidator("Must be a palindrome"),
)
```

### Custom Input Widgets

Extend `BaseStepView` to create custom inputs:

```dart
// ignore: must_be_immutable
class ColorPickerWidget extends BaseStepView<QuestionStep> {
  ColorPickerWidget(super.formStackForm, super.formStep, super.text);

  Color _selected = Colors.red;
  final ValueNotifier<Color> _notifier = ValueNotifier(Colors.red);

  @override
  Widget? buildWInputWidget(BuildContext context, QuestionStep formStep) {
    return StatefulBuilder(builder: (context, setState) {
      // Your custom color picker UI here
    });
  }

  @override
  bool isValid() => true;
  @override
  String validationError() => "";
  @override
  dynamic resultValue() => _selected.value;
  @override
  void requestFocus() {}
  @override
  void clearFocus() {}

  // Step views are StatelessWidgets, so the framework never disposes them --
  // the form does. Release anything disposable here and call super.
  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }
}
```

### Custom Step Types

Subclass `FormStep` for entirely new step types:

```dart
class VideoStep extends FormStep {
  final String videoUrl;
  VideoStep({required this.videoUrl, super.id, super.title});

  @override
  FormStepView buildView(FormStackForm formStackForm) {
    return MyVideoStepView(formStackForm, this, text);
  }
}
```

### Custom Navigation Rules

Subclass `RelevantCondition`:

```dart
class ScoreThresholdCondition extends RelevantCondition {
  final int threshold;
  ScoreThresholdCondition({required super.identifier, required this.threshold});

  @override
  bool isValid(dynamic result) => (result as int?) != null && result >= threshold;
}
```

### Step Lifecycle Callbacks

Hook into step events for analytics or custom behavior:

```dart
QuestionStep(
  title: "Email",
  inputType: InputType.email,
  onStepWillPresent: (step) => analytics.trackStepView(step.id?.id),
  onStepDidComplete: (step, result) => analytics.trackStepComplete(step.id?.id, result),
)
```

### Structured Result Export

Get typed results with timestamps (modeled after ResearchKit's ORKTaskResult):

```dart
final taskResult = FormStack.api().getTaskResult(formName: "myForm");
print(taskResult.totalDuration);
print(taskResult.completedSteps);

// Full JSON export with step-level timestamps and metadata
final json = FormStack.api().exportAsJson(formName: "myForm");
await http.post('/api/submit', body: jsonEncode(json));

// Access individual step results
final email = FormStack.api().getStepResult("email");
final step = FormStack.api().getStep("email");
print(step?.startTime); // When user saw this step
print(step?.endTime);   // When user completed it
```

---

## Architecture

```
lib/
  formstack.dart              # Public API exports
  src/
    formstack.dart             # FormStack singleton API
    formstack_form.dart        # Form navigation and state
    input_types.dart           # InputType enum (35 values)
    core/
      form_step.dart           # Base FormStep class, enums
      parser.dart              # JSON parser (registry-driven)
      ui_style.dart            # UIStyle, HexColor
      form_locale.dart         # FormStackLocale (multi-language)
      form_persistence.dart    # FormPersistence port, in-memory impl
      external_data.dart       # ExternalDataProvider port
      registry/
        input_registry.dart    # Pluggable input widgets
        step_registry.dart     # Pluggable step types
        validator_registry.dart # Named validators, JSON validator support
      validation/
        validation_result.dart # Structured validation outcome
    step/
      question_step.dart       # QuestionStep (all input types)
      completion_step.dart     # CompletionStep (finish with animation)
      instruction_step.dart    # InstructionStep (info/video screens)
      nested_step.dart         # NestedStep (multi-field)
      display_step.dart        # DisplayStep (web/list content)
      review_step.dart         # ReviewStep (answer review before submit)
      consent_step.dart        # ConsentStep (consent document flow)
      repeat_step.dart         # RepeatStep (dynamic repeating sections)
      pop_step.dart            # PopStep (navigation)
    result/
      result_format.dart       # 35+ validators (subclassable)
      step_result.dart         # StepResult, TaskResult hierarchy
      common_result.dart       # Options, KeyValue, DynamicData
      identifiers.dart         # GenericIdentifier, StepIdentifier
    relevant/
      relevant_condition.dart  # RelevantCondition base
      expression_relevant_condition.dart  # Expression-based routing
      dynamic_relevant_condition.dart     # Callback-based routing
    ui/views/input/
      text_input_field.dart    # Text/email/password/number
      choice_input_field.dart  # Single/multiple choice
      date_input_field.dart    # Date/time pickers
      slider_input_field.dart  # Range slider
      rating_input_field.dart  # Star rating
      nps_input_field.dart     # Net Promoter Score
      consent_input_field.dart # Checkbox consent
      signature_input_field.dart # Signature pad
      ranking_input_field.dart # Drag-to-reorder
      phone_input_field.dart   # Phone with country code
      currency_input_field.dart # Currency input
      boolean_input_field.dart  # Yes/No toggle
      image_choice_input_field.dart # Image grid selection
      otp_input_field.dart     # OTP digits
      smile_input_field.dart   # Emoji rating
      image_input_field.dart   # Avatar/banner upload
      dynamic_key_value_field.dart # Key-value pairs
      map_input_field.dart     # Google Maps
      hidden_input_field.dart   # Hidden data field
      calculate_input_field.dart # Calculated field
      barcode_input_field.dart  # Barcode/QR scanner
      audio_input_field.dart    # Audio recording
      geotrace_input_field.dart # Geotrace/geoshape map input
      html_input_field.dart    # Rich text editor
```

For the layering rationale, the view-ownership rule, and the list of known
architectural debt, see [ARCHITECTURE.md](ARCHITECTURE.md).

## License

MIT License. See [LICENSE](LICENSE) for details.

## Links

- [pub.dev](https://pub.dev/packages/formstack)
- [API Docs](https://pub.dev/documentation/formstack/latest/)
- [Issues](https://github.com/sudhi001/FormStack/issues)
- [Source](https://github.com/sudhi001/FormStack)
