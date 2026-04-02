# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-04-02

### Added
- `boolean` input type - Yes/No toggle buttons
- `imageChoice` input type - select from a grid of images with labels
- `ReviewStep` - displays all collected answers for review before submission
- `ConsentStep` with `ConsentSection` model and 8 predefined section types (overview, dataGathering, privacy, dataUse, timeCommitment, studyTasks, withdrawing, custom)
- Built-in progress bar UI with step counter ("Step 3 of 10") and percentage
- Result timestamps (`startTime`, `endTime`) recorded per step for analytics
- Static image support via `titleIconImagePath` (asset or network URL)
- Video URL support in `InstructionStep` via `videoUrl`
- `dateRange` validator with `minDate`/`maxDate` bounds
- `ResultFormat` public constructor for custom validator subclassing
- `BaseStepView` and `FormStepView` exported for custom input widget creation
- `StepResult` and `TaskResult` classes for structured result hierarchy (modeled after ResearchKit's ORKTaskResult)
- Step lifecycle callbacks: `onStepWillPresent`, `onStepDidComplete`
- API methods: `getStep()`, `getStepResult()`, `getTaskResult()`, `exportAsJson()`
- ResearchKit migration guide in README with side-by-side Swift/Dart examples
- New exports: `ReviewStep`, `ConsentStep`, `ConsentSection`, `ConsentSectionType`, `BaseStepView`, `FormStepView`, `StepResult`, `TaskResult`

## [2.0.0] - 2026-04-02

### Added
- 8 new input types: `slider`, `rating`, `nps`, `consent`, `signature`, `ranking`, `phone`, `currency`
- 12 new validators: `min`, `max`, `range`, `minLength`, `maxLength`, `pattern`, `minSelections`, `maxSelections`, `fileSize`, `iban`, `consent`, `compose`
- `FormStep` properties: `helperText`, `defaultValue`, `semanticLabel`
- `QuestionStep` properties: `minValue`, `maxValue`, `stepValue`, `minSelections`, `maxSelections`, `consentText`, `currencySymbol`, `phoneCountryCode`, `ratingCount`
- New exports: `RelevantCondition`, `ExpressionRelevant`, `DynamicConditionalRelevant`, `NestedStep`, `DisplayStep`, `UIStyle`
- Full JSON schema support for all new input types and properties
- Comprehensive example app with 10 demo screens
- Dartdoc comments on all public API classes and members

### Changed
- Renamed `formKitForm` to `formStackForm` across codebase
- Renamed `TextFeildWidgetView` to `TextFieldWidgetView`
- Renamed `inputBoder()` to `inputBorder()` across all input fields
- Renamed `intput` to `input` in expression evaluators
- Renamed `htm_field.dart` to `html_input_field.dart`
- Renamed `mapview_field.dart` to `map_input_field.dart`
- Replaced `GlobalKey` anti-pattern with `ValueNotifier` in `BaseStepView` and `CompletionStepView`
- Updated `index.html` to modern `FlutterLoader.load` initialization
- Updated README with complete documentation, screenshots, and JSON schema reference

### Fixed
- Memory leak: OTP field controllers recreated on every build
- Memory leak: verification code list growing indefinitely on rebuilds
- Memory leak: `addPostFrameCallback` firing on every rebuild in text, nested, and completion views
- Performance: image memory bloat from full-resolution decoding (added `cacheWidth`/`cacheHeight`)
- Performance: dynamic key-value controller text resetting on every build
- Fixed typos in class names (`_TextesultType`, `_MultipleChoiceesultType`)
- Fixed `nextFormSatck` typo in `formstack_form.dart`
- Cleaned up dead commented-out code in `htm_field.dart` and `web_view.dart`
- Removed unnecessary imports across all internal files
- Added `cacheExtent` to all `ListView` widgets for smoother scrolling

### Updated
- `google_maps_flutter`: ^2.14.0 -> ^2.17.0
- `google_maps_flutter_web`: ^0.5.14+3 -> ^0.6.2
- `dio`: ^5.9.0 -> ^5.9.2
- `uuid`: ^4.5.2 -> ^4.5.3
- `file_picker`: ^10.3.7 -> ^10.3.10
- `webview_flutter`: ^4.13.0 -> ^4.13.1
- `google_maps`: ^8.1.1 -> ^8.2.0
- `flutter_lints`: ^2.0.0 -> ^6.0.0 (example)

## [1.1.2] - 2024-12-01

### Changed
- Removed performance analysis file
- Updated version to 1.1.2

## [1.1.1] - 2024-11-15

### Fixed
- Memory leak in Google Places autocomplete stream subscription
- Component disposal in nested step views
- Undefined `mounted` property in completion step view
- Auto-trigger callback firing multiple times

### Changed
- Added cache size limit (50 items) to prevent unbounded memory growth
- Optimized image memory usage by clearing file results after encoding
- Optimized controller recreation to only occur when form step result changes
- Reduced unnecessary setState calls in base step view
- Added proper GoogleMapController disposal
- Added lazy loading for background animations

### Updated
- `webview_flutter`: ^4.9.0 -> ^4.13.0
- `dio`: ^5.8.0+1 -> ^5.9.0
- `uuid`: ^4.5.1 -> ^4.5.2
- `lottie`: ^3.3.1 -> ^3.3.2
- `file_picker`: ^8.3.7 -> ^10.3.7
- `google_maps_flutter_web`: ^0.5.12+2 -> ^0.5.14+3
- `google_maps_flutter`: ^2.12.3 -> ^2.14.0
- `http`: ^1.4.0 -> ^1.6.0

## [1.1.0] - 2024-10-01

### Changed
- Initial release with dependency updates and optimizations

## [0.9.33] - 2024-06-01

### Added
- Nested step with OR condition validation expression

## [0.9.4] - 2024-03-01

### Added
- Nested step OR condition for multiple components

## [0.7.7] - 2023-12-01

### Added
- Location picker with Google Maps

## [0.7.5] - 2023-11-01

### Added
- HTML editor input type

## [0.7.4] - 2023-10-15

### Added
- Dropdown button with component styles (minimal and basic)
- Dynamic key-value widget

## [0.7.0] - 2023-10-01

### Changed
- Date format result uses UTC format

## [0.6.4] - 2023-09-15

### Added
- Choice field with toggle switch selection type

## [0.6.3] - 2023-09-01

### Added
- OTP view support
- File input type (single file selection)

## [0.6.1] - 2023-08-15

### Added
- Disable UI fields dynamically via `setDisabledUI`

## [0.6.0] - 2023-08-01

### Added
- Set error messages dynamically via `setError`
- Set form data dynamically via `setResult`

## [0.5.1] - 2023-07-15

### Changed
- Renamed `NestedQuestionStep` to `NestedStep`

## [0.4.0] - 2023-07-01

### Added
- `NestedStep` to display multiple questions on a single screen

## [0.2.10] - 2023-06-01

### Changed
- Documentation updates and code optimisation

## [0.1.3] - 2023-05-15

### Added
- Example application

## [0.1.1] - 2023-05-01

### Added
- Initial release with model-based UI rendering
