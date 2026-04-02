# FormStack

[![pub package](https://img.shields.io/pub/v/formstack.svg)](https://pub.dev/packages/formstack)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D1.17-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-blue)](https://flutter.dev/multi-platform)

A cross-platform alternative to Apple ResearchKit for Flutter. Build dynamic forms, surveys, and research questionnaires from Dart objects or JSON -- on iOS, Android, Web, macOS, Windows, and Linux.

30 input types, 8 step types, 35+ validators, conditional navigation, structured consent flows, answer review, progress tracking, and full extensibility. Every ResearchKit UI pattern can be reproduced with FormStack.

### Why FormStack over ResearchKit?

| | ResearchKit | FormStack |
|---|---|---|
| **Platforms** | iOS only | iOS, Android, Web, macOS, Windows, Linux |
| **Language** | Swift/Objective-C | Dart (Flutter) |
| **Form source** | Code only | Dart objects or JSON |
| **Input types** | ~15 answer formats | 30 input types |
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
| `ORKQuestionStep` | `QuestionStep` | 30 input types vs ResearchKit's ~15 |
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
  formstack: ^2.1.1
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

### Special

| InputType | Description | Result Type |
|-----------|-------------|-------------|
| `otp` | Multi-digit OTP entry | `int` |
| `consent` | Checkbox with agreement text | `bool` |
| `dynamicKeyValue` | Add/remove key-value pairs | `List<KeyValue>` |
| `htmlEditor` | Rich text editor | `String` |

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

### Custom Theme

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
  ),
  nextButtonText: "Continue",
  backButtonText: "Previous",
)
```

---

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
        "helperText": "Enter your legal name"
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

The [example app](example/) demonstrates all features across 10 demo screens:

| Demo | Features |
|------|----------|
| All Input Types | All 30 input types with descriptions |
| Styles & Display | InputStyle, ComponentsStyle, Display sizes, UIStyle |
| Selection Types | Arrow, tick, toggle, dropdown |
| Validation | Email, password, phone, URL, age, zip, dateRange, custom, compose |
| Conditional Nav | ExpressionRelevant branching and path convergence |
| Nested Steps | Multi-field screens with cross-field validation |
| API Features | setResult, setError, callbacks, progress tracking |
| Survey Components | Slider, rating, NPS, consent, signature, ranking, phone, currency |
| ResearchKit Features | Boolean, image choice, consent flow, review step, progress bar, timestamps |
| Load from JSON | Multi-file JSON loading with form linking |

Run the example:

```bash
cd example
flutter run
```

---

## Extensibility

FormStack is designed for extension at every layer, following Apple ResearchKit's architecture.

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
class ColorPickerWidget extends BaseStepView<QuestionStep> {
  ColorPickerWidget(super.formStackForm, super.formStep, super.text);

  Color _selected = Colors.red;

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
    input_types.dart           # InputType enum (30 values)
    core/
      form_step.dart           # Base FormStep class, enums
      parser.dart              # JSON parser
      ui_style.dart            # UIStyle, HexColor
    step/
      question_step.dart       # QuestionStep (all input types)
      completion_step.dart     # CompletionStep (finish with animation)
      instruction_step.dart    # InstructionStep (info/video screens)
      nested_step.dart         # NestedStep (multi-field)
      display_step.dart        # DisplayStep (web/list content)
      review_step.dart         # ReviewStep (answer review before submit)
      consent_step.dart        # ConsentStep (consent document flow)
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
      html_input_field.dart    # Rich text editor
```

## License

MIT License. See [LICENSE](LICENSE) for details.

## Links

- [pub.dev](https://pub.dev/packages/formstack)
- [API Docs](https://pub.dev/documentation/formstack/latest/)
- [Issues](https://github.com/sudhi001/FormStack/issues)
- [Source](https://github.com/sudhi001/FormStack)
