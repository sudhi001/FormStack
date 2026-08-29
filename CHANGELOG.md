# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 3.0.0

A correctness, extensibility and packaging release. The breaking changes are
confined to the step model; forms defined through `FormStack.api().form(...)`
or JSON are unaffected.

### Fixed

- **Step views were never disposed.** Every step view is a `StatelessWidget`
  holding a `TextEditingController`, `FocusNode` and `ValueNotifier`, and
  nothing in the framework releases those. `FormStackView` now disposes the
  form's cached views when it is removed from the tree, and `FormStackForm`
  disposes views it evicts. A form run no longer leaks one controller set per
  step. Covered by a regression test.
- **The view cache was unbounded.** `FormStackForm.maxCachedViews` (default 12)
  now caps retained step views; the current step is never evicted. A
  hundred-step survey previously held every view for the lifetime of the form.
- **The "submitting" spinner never appeared.** `isProcessing` was a plain field
  on a `StatelessWidget`, so changing it could not repaint. It is now backed by
  a `ValueNotifier` and the primary button listens to it, which also means the
  button is genuinely disabled during an async `onBeforeFinish`.
- **JSON parse errors were swallowed.** `ParserUtils.buildFormFromJson` was an
  `async void` method, so its `FormatException`s escaped to the zone instead of
  reaching the caller — `loadFromAsset` reported success on a malformed file.
  It is synchronous again and errors propagate.
- **`ResultFormat.notEmpty` rejected every string.** It only recognised `List`,
  so `notEmpty` on a text field could never pass. It now accepts `String`,
  `Iterable` and `Map`. This is a widening: nothing that passed before fails.
- **`ResultFormat.notBlank` accepted whitespace.** `"   "` passed a `notBlank`
  check because the value was never trimmed. It now trims, matching the
  conventional meaning of "blank".
- **The form-level JSON `theme` never applied.** Every step parsed from JSON
  received a fully-defaulted `UIStyle`, so `step.style ??= formTheme` never
  fired and the documented `"theme"` key was silently ignored. Step factories
  now use `UIStyle.maybeFrom`, which returns null for an absent style.
- **Malformed form definitions failed obscurely.** A relevant condition without
  an `id` or `expression`, an option that is not an object, or a
  `relevantConditions` value that is not a list produced a `NoSuchMethodError`
  on a dynamic call or a condition that could never match. Each is now a
  `FormatException` naming what is wrong.
- Numeric values in a JSON `theme` written as strings (`"borderRadius": "12"`)
  are coerced rather than discarded.
- Two `Future`s returned from inside `try` blocks were not awaited, so their
  errors bypassed the surrounding `catch`.
- A failed or cancelled image pick no longer clears an answer the user had
  already given, and reports through `FlutterError` rather than `print`.
- **The signature pad overflowed its container by 6 pixels on every build.**
  Its wrapper capped height at 200px while the canvas, spacing and Clear button
  needed ~206px. Found by the new input smoke tests.

### Added

- **`InputRegistry`** — register application-defined input types, or override a
  built-in one, without forking the library. Reachable from Dart via
  `InputType.custom` + `QuestionStep.customInputType`, and from JSON by naming
  the registered type directly in `inputType`.
- **`StepRegistry`** — the JSON parser resolves step types through a registry
  instead of a hard-coded `if`/`else` chain, so a new step type is a
  registration rather than a change to the parser.
- **`ValidatorRegistry` and validators in JSON** — a JSON-defined step can now
  declare `"validators"`, unlocking the full validator library to JSON forms.
  Previously a JSON form could only get the default validator implied by its
  `inputType`; anything more required dropping down to Dart. Applications can
  register their own named validators.
- **`ValidationResult` and `ResultFormat.validate()`** — validation returns a
  stable `code` plus constraint `params` alongside the message, so failures can
  be localized or reported without string-matching. `isValid`/`error` still
  work; the new method is expressed in terms of them.
- **`FormProgress`** — position, total and percentage as one value object,
  computed in a single pass.
- **`DeviceCapabilities`** — `BarcodeScanner` and `AudioRecorder` ports that
  make `InputType.barcode` and `InputType.audio` genuinely functional. Both
  previously rendered a UI scaffold with nothing behind it, because the library
  declares no camera or microphone dependency. Register an adapter backed by
  the package of your choice and the built-in widgets use it, keeping
  FormStack's layout, validation and result handling. Without one, `barcode`
  falls back to manual entry and `audio` records a duration marker, so an app
  that collects only text and choices still inherits no hardware SDK.
- **`FormStackThemeScope`** — `FormStackTheme`'s instance fields were inert:
  every call site used the static helpers with hard-coded defaults, so
  constructing one had no effect. `maxContentWidth`, `contentPadding`,
  `borderRadius` and `elementSpacing` now apply to the subtree, with
  `FormStackTheme.of(context)`, `copyWith` and value equality.
- `FormStackForm.stepAfter` / `stepBefore` for explicit ordered navigation.
- A test suite — 141 tests, 52% line coverage, from none — covering validators,
  navigation and branching, JSON parsing and its failure modes, the registries,
  persistence, the view-disposal chain, and a smoke test that builds every
  built-in input type, the input registry's resolution order, the theme scope,
  the device-capability ports, plus a guard that the example app's own JSON
  assets still parse.
- A CI pipeline covering formatting, analysis with warnings fatal, tests on
  Linux, macOS and Windows, the suite again on the oldest supported Flutter, an
  example build, and pub.dev publish readiness with a `pana` score threshold.
- `ARCHITECTURE.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, issue and pull
  request templates, and Dependabot configuration.
- An **Extension Points** screen in the example app
  (`example/lib/extensibility_demo.dart`) showing a registered custom input, a
  named validator resolved from a JSON spec, a device capability, and a scoped
  theme — with a test covering the same combination.

### Changed

- **Built-in inputs resolve through `InputRegistry` like everything else.**
  `QuestionStep.buildView` was a 35-arm `switch`, so the library's own widgets
  and the extension point had different shapes. `BuiltInInputs` registers each
  built-in with `registerIfAbsent`, `buildView` is a lookup, and an application
  override installed first is preserved.
- **`FormStep` no longer extends `LinkedListEntry`.** A step described *what to
  ask* but was also a node in a list, which meant a step definition could
  belong to only one form — sharing one threw at runtime. Ordering now lives in
  the form. This also unblocked the Dart 3 migration: `LinkedListEntry` is
  `base`, which would otherwise have forced `base` onto every step subclass
  including application-defined ones.
- **`FormStackForm.steps` is `List<FormStep>`** rather than
  `LinkedList<FormStep>`.
- **`FormStep` no longer takes a type parameter.** `T` was declared and never
  used; its only effect was to make every reference to `FormStep` a raw type.
  With it gone, `strict-raw-types` is enabled and the package is free of raw
  types.
- JSON decoding in the parser, the step factories and the Google Places models
  is typed rather than reaching through `dynamic`, so malformed input produces
  a `FormatException` instead of a `NoSuchMethodError`.
- `getStep` and `getCurrentIndex` are backed by an index instead of walking the
  step list. The progress bar previously indexed the list twice per build.
- Validator regular expressions are compiled once rather than on every
  keystroke.
- `ResultFormat.compose` no longer keeps mutable state across calls.
- The duplicated `inputBorder()` implementation, previously copied into five
  input widgets, is a single `InputStyle.toInputBorder` extension.
- **SDK floor corrected to Dart 3.10 / Flutter 3.38.2.** The package declared
  `flutter: ">=1.17.0"` while using `Color.withValues` (3.27) and
  `PopScope.onPopInvokedWithResult` (3.24), so the declared floor could never
  have compiled. The new floor is the lowest combination CI actually builds
  and tests against, in the `min-sdk` job — an untested floor is a guess. The
  binding constraint is `file_picker` 12, which requires Dart 3.10.
- **Removed the root `android/`, `ios/`, `linux/`, `macos/` and `windows/`
  folders.** This is a pure Dart package with no native code; they were
  `flutter create` leftovers containing only generated plugin registrants,
  which `flutter pub get` rewrote on every machine. Platform support is
  declared in `pubspec.yaml` and is unchanged at 6 of 6.
- Dropped the unused `http` dependency.
- Upgraded `file_picker` (10 → 12) and `location` (8 → 10), which were two and
  three major versions behind and caused resolution conflicts for applications
  using either package directly. The `file_picker` 12 API made the
  web-versus-native branch in the image input unnecessary, so image picking no
  longer reaches for `dart:io`.
- `UIStyle.maybeFrom` added; `UIStyle.from` is unchanged.
- **The public top-level `uuid` variable is gone.** `identifiers.dart` exported
  a mutable top-level `uuid`, so every importer of the library had that very
  collidable name in scope. It is package-private now.
- **The published API is fully documented.** Every symbol reachable from
  `package:formstack/formstack.dart` carries a doc comment, including all 37
  `ResultFormat` factories, `FormStackForm`, `QuestionStep`, `FormStepView` and
  every step type.
- `InputRegistry.build` no longer stamps `ResultFormat.none()` onto a step that
  declared no validator and whose type registered no default. Doing so marked
  the step permanently valid and made a validator assigned later unreachable.

### Documentation

- `MIGRATION.md`'s v2 → v3 section was written speculatively before 3.0 existed
  and described a release that does not match this one — it listed OTP, HTML
  and map inputs as new and stated there were no breaking changes. Rewritten
  against what actually shipped.
- `FAQ.md` now covers the registries, validators in JSON, localizing validation
  through `ValidationResult.code`, the disposal contract for custom inputs, the
  bounded view cache, and which platform SDKs the package does and does not
  pull in.

### Migration

- `step.next` / `step.previous` → `form.stepAfter(step)` /
  `form.stepBefore(step)`.
- `class MyStep extends FormStep<MyStep>` → `class MyStep extends FormStep`.
- The top-level `uuid` variable is no longer exported; use `package:uuid`
  directly if you were relying on it.
- Code that typed a variable as `LinkedList<FormStep>` should use
  `List<FormStep>`.
- Subclasses of `FormStep` need no changes.
- Review any use of `notBlank`, which now rejects whitespace-only input, and of
  `notEmpty` on text fields, which now works.

## [2.5.0] - 2026-04-02

### Added
- 2 new example demo screens: "Data Collection (ODK)" and "Multi-Language & Offline" (total: 12 demos)
- Data Collection demo covers: RepeatStep, calculate fields, hidden fields, cascading selects, barcode, audio, geotrace, geoshape
- Multi-Language demo covers: FormStackLocale with EN/ES/FR, DisplayStep with listTile data, runtime language switching
- `geotrace` and `geoshape` added to README input type tables
- Form-level `defaultStyle` parameter for applying UIStyle to all steps at once
- JSON `theme` key at form level for form-wide styling from JSON

### Changed
- Example app now demonstrates all 35 input types and all 9 step types
- README examples table expanded to 12 demo screens
- Architecture file listing updated with all new files
- Input type count corrected to 36 throughout all docs

## [2.4.0] - 2026-04-02

### Added
- `FormStackTheme` - centralized theme system with responsive sizing, dark/light mode colors, and accessibility helpers
- Responsive layout: all widgets adapt to mobile (< 600px), tablet (600-1200px), and desktop (> 1200px) screens
- Dark mode support: all colors resolve from `Theme.of(context).colorScheme` instead of hardcoded values
- Semantics wrappers for accessibility on interactive elements
- `FormStackTheme.responsiveMaxWidth()`, `responsiveInputWidth()`, `responsivePadding()`, `responsiveIconSize()`, `responsiveButtonHeight()`
- Theme-aware NPS colors (`npsDetractorColor`, `npsPassiveColor`, `npsPromoterColor`)
- Canvas colors adapt to dark mode (`canvasStrokeColor`, `canvasBackgroundColor`)

### Changed
- Replaced 47 hardcoded color values with theme-aware alternatives across all view files
- Replaced 45+ hardcoded BoxConstraints with responsive sizing
- Error text uses `Theme.of(context).colorScheme.error` instead of `Colors.red`
- Input backgrounds use `colorScheme.surfaceContainerHighest` instead of hardcoded grey
- Borders use `colorScheme.outline` instead of `Colors.grey`
- Buttons use responsive heights based on screen size
- `UIStyle` expanded with 7 new properties: `inputBackground`, `inputTextColor`, `titleColor`, `subtitleColor`, `iconColor`, `cardBackground`, `fontSize` - all settable from JSON
- Form-level `defaultStyle` parameter applies to all steps without individual styling
- JSON `theme` key at form level applies default styling to all steps in that form

## [2.3.0] - 2026-04-02

### Added
- 2 new input types: `geotrace` (trace path on map), `geoshape` (draw polygon on map)
- Offline save & resume via `FormPersistence` interface (`enablePersistence`, `saveDraft`, `resumeDraft`, `deleteDraft`, `listDrafts`)
- `InMemoryFormPersistence` built-in implementation for testing
- `FormDraft` serializable model for draft state
- `ExternalDataProvider` interface for loading options from CSV/API/database
- `StaticDataProvider` built-in implementation with `fromCsv` factory
- `QuestionStep.optionsProvider` and `optionsSourceId` for external data-backed choices
- All new types supported in JSON parser

## [2.2.0] - 2026-04-02

### Added
- 4 new input types: `hidden` (data-only, no UI), `calculate` (auto-computed from other results), `barcode` (QR/barcode scanner), `audio` (recording with timer)
- `RepeatStep` - dynamic repeating sections where users add/remove entries (modeled after ODK `repeat`)
- Cascading selects via `QuestionStep.choiceFilter` callback - filter options based on other step results (Country -> State -> City)
- `FormStackLocale` class for multi-language support with runtime language switching, `t()` and `tf()` translation methods, and JSON loading
- `QuestionStep.calculateCallback` for auto-computing values from collected results
- `QuestionStep.calculateExpression` for declarative calculate formulas
- Step view widget caching to preserve state during navigation
- All new types fully supported in JSON schema parser

### Fixed

## [2.1.1] - 2026-04-02

### Fixed
- Step view widget caching to prevent state loss during navigation (TextEditingController text, slider values, selected choices now preserved when navigating back)
- Controller and FocusNode memory leaks caused by widget recreation on every step change
- Cache cleared on form reset via `clearResult()` for clean restarts
- Step timestamps (`startTime`, `endTime`) reset properly on form clear

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
