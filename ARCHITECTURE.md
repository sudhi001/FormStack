# FormStack Architecture

This document describes how FormStack is put together, why the boundaries fall
where they do, and what is deliberately still outstanding. It is aimed at
contributors and at teams deciding whether to build on the library.

## Layers

FormStack separates *what a form asks* from *how it is rendered* and *where the
answers go*. Four layers, each depending only on the one above it:

```
  Definition        FormStep + subclasses, ResultFormat, RelevantCondition
      |             pure data; no BuildContext, no widgets
      v
  Orchestration     FormStackForm — ordering, branching, result aggregation
      |             knows about steps; knows nothing about specific widgets
      v
  Presentation      FormStepView / BaseStepView + input widgets
      |             renders one step; calls back into the form to navigate
      v
  Integration       FormPersistence, ExternalDataProvider, FormStackLocale
                    application-supplied ports, injected not imported
```

The definition layer is the one to keep clean. A `QuestionStep` is a value
description — a title, an input type, a validator — and can be built on a
server, serialized, diffed, and tested without a Flutter binding.

## Extension points

Three registries make the library open for extension without modification.
Each is a process-wide singleton with `register` / `unregister` / `reset`.

| Registry | Extends | Reached from |
|---|---|---|
| `InputRegistry` | input widgets | `InputType.custom` + `customInputType`, or JSON `inputType` |
| `StepRegistry` | step types | JSON `type` |
| `ValidatorRegistry` | validators | `ResultFormat.fromJson`, JSON `validators` |

Every built-in input is registered through `InputRegistry` too, by
`BuiltInInputs.ensureRegistered()`, so the library's own widgets and an
application's resolve by exactly the same path. There is no separate `switch`
for the built-ins to fall out of step with.

Registering a name that already exists overrides it. That is the supported way
to replace a built-in — swapping the signature pad for one that meets a
particular regulatory requirement, say — without forking:

```dart
InputRegistry.instance.register('signature', (ctx) => CompliantSignaturePad(ctx));
```

The library registers its own step types with `registerIfAbsent`, so an
application override installed first is never clobbered, and the built-ins
survive a `reset()` in tests.

### Device capabilities

`DeviceCapabilities` is a fourth, narrower extension point. `InputRegistry`
replaces a whole widget; a capability replaces only the part FormStack cannot
implement without a heavy dependency — scanning a barcode, recording audio —
while keeping the library's layout, validation and result handling.

Both inputs degrade rather than fail when no capability is registered:
`barcode` falls back to manual entry, `audio` records a duration marker. That
keeps the dependency footprint honest — an application collecting text and
choices inherits no camera or microphone SDK — without making the input types
unusable.

## Step lifecycle and view ownership

Step views hold mutable state — controllers, focus nodes, notifiers — as fields
on the widget rather than in a `State`. That is not the Flutter idiom, and it is
deliberate: it keeps `isValid`, `resultValue` and `buildWInputWidget` readable
as plain methods on one object instead of split across a widget/state pair.

`FormStepView` is a `StatefulWidget` whose `State` exists purely to own
lifetime: it builds through `buildWithFrom` and calls `dispose()` when the view
leaves the tree. So the framework releases the controllers at the right moment
while the ergonomics stay.

Two details make this work:

- **Subtrees are keyed by step.** Consecutive steps commonly use the same view
  class. Without a differing key Flutter reconciles them onto a single element,
  reuses the `State`, and never disposes the outgoing view.
- **There is no view cache.** `FormStackForm` holds a reference to the view for
  the step on screen and nothing else. A cache and framework ownership cannot
  coexist: a retained view would be reused after disposal.

The consequence is that **a view is rebuilt when the user navigates back to its
step**, so every input must restore what it shows from `formStep.result`. The
answer is written back before every navigation, so the model is the source of
truth. `test/widget/state_roundtrip_test.dart` asserts this for every input
type; it is the test that makes the absent cache safe.

Any new step view that allocates a disposable must override `dispose()` and
call `super.dispose()`, and must tolerate being called twice.

## Navigation

Order is a property of the form, not of the step. `FormStackForm.steps` is a
plain `List`, and `stepAfter` / `stepBefore` resolve neighbours through a
position index rebuilt only when the list length changes.

Conditions are `<OPERATOR> <operand>`, and the operand is everything after the
first space — splitting on every space truncated any value containing one. The
evaluator is chosen by the answer's runtime type: numbers compare numerically,
selections compare by `Options.key`, dates parse `dd-MM-yyyy`, and everything
else compares its `toString()`. The catch-all previously returned `true` for
any condition, which meant a boolean question always took its first branch.

Branching is by `RelevantCondition`. On `nextStep`, each condition on the
current step is evaluated against the step's result; the first match wins and
the branch is recorded in `relevantStack` so that back-navigation retraces the
path actually taken rather than declaration order. A condition carrying a
`formName` transfers to another form and pushes the current one onto
`previousFormStackForm`.

Steps are no longer linked-list nodes, which means one step definition can be
shared between forms — previously that threw, because a `LinkedListEntry` can
belong to only one list.

## Validation

`ResultFormat` is a strategy object: `isValid` plus `error`. Everything else is
composition — `ResultFormat.compose` chains validators and reports the first
failure.

`validate()` returns a `ValidationResult` carrying a stable `code` and the
constraint `params`, which is what makes messages localizable: map the code
through a catalogue and interpolate the params, falling back to the built-in
message. The default implementation is written in terms of `isValid`/`error`, so
custom validators written against the old interface keep working and gain
`validate()` for free.

Patterns are compiled once. Validators run on every keystroke, so building a
`RegExp` inside `isValid` was measurable.

## Results

`generateResult()` flattens answers into `Map<String, dynamic>` keyed by step
id. `getTaskResult()` additionally returns per-step timestamps, durations and
optionality as a `TaskResult` — the shape ResearchKit consumers expect — and
`exportAsJson()` serializes it.

## Known debt

Recorded here rather than left implicit. Roughly in priority order.

1. **Heavy transitive dependencies.** `dio` and `rxdart` are gone — they backed
   a single file and were replaced by `http` and a `Timer`. What remains is
   harder: `google_maps_flutter`, `location`,
   `webview_flutter` and `file_picker` are unconditional dependencies, so an
   application using FormStack purely for text and choice inputs still inherits
   map and camera SDKs, their permission declarations and their iOS privacy
   manifests. These should move behind provider interfaces resolved through
   `InputRegistry`, shipped as separate packages (`formstack_maps`,
   `formstack_media`). This is the largest single improvement available to
   consumers, and the pattern is already proven by `DeviceCapabilities` —
   `barcode` and `audio` reach their platform dependency through a port rather
   than a direct import.

   Note the sequencing constraint: the example app is shipped inside the
   published archive, so it cannot hold a path dependency on an unpublished
   sibling package. `formstack_maps` has to be published *before* the core can
   drop the dependency and the example can reference it. That is why this is
   two releases rather than one commit.
2. **`FormStack` is doing several jobs** — instance registry, form builder,
   statistics, persistence facade. The persistence and statistics APIs would sit
   better on `FormStackForm`.
3. **Implementation classes read as public API.** The published surface — every
   symbol the barrel exports — is fully documented. The ~280 findings that
   remain are on classes under `lib/src` that are *not* exported (the Google
   Places DTOs, the input widget views, the map widgets), so they never reach
   the published API docs. `public_member_api_docs` cannot distinguish the two,
   so it stays at `info`. The deeper issue is that these classes are `public` in
   the Dart sense at all; a stricter `src` boundary would remove the ambiguity.
4. **`cacheExtent` / `onReorder` deprecations** are left in place deliberately:
   migrating raises the minimum Flutter to 3.41, far above the supported floor.
   Revisit when the floor moves.

## Memory

Three shapes in this codebase make leaks easy to write and hard to see, so each
has a rule and a test in `test/unit/resource_hygiene_test.dart`.

**Step views hold controllers as fields.** They are released by
`FormStepView`'s `State` when the view leaves the tree, which only happens if
the subclass overrides `dispose()`. The test asserts that every file declaring
a `TextEditingController`, `FocusNode`, `AnimationController`,
`ScrollController`, `ValueNotifier` or `OverlayEntry` field also declares a
`dispose()` that releases it.

**Dialog builders re-run.** A `TextEditingController` constructed inside a
`showDialog` builder is never disposed *and* is reallocated on every rebuild of
the dialog route, so the leak is per rebuild rather than per dialog. Use
`DialogTextField`, which ties the controller to an element the framework
disposes. The test forbids constructing one inside a dialog.

**Platform-backed controllers must not be built in `build()`.** A
`WebViewController` created in a build path spawns another native web view and
another network load on every rebuild. It belongs in a `State`.

Two adjacent rules, same file:

- **Decoded image bytes are held, not re-decoded.** `Image.memory` keys its
  cache entry on the `Uint8List` instance, so decoding base64 afresh each build
  hands it a new key: Flutter re-decodes the image, caches it again, and evicts
  other entries. Both image inputs hold the decoded bytes.
- **Post-frame callbacks check `isDisposed`.** A view can be disposed before
  the frame it scheduled work for — an auto-advancing step, or a fast tap — and
  focusing a disposed `FocusNode` throws. This became reachable in 3.1, where
  disposal is prompt rather than deferred to a cache eviction.

### Retention that is deliberate

`FormStack` keeps its instances in a static map, and each holds its forms,
their steps, and every answer collected. Nothing evicts them: a form stays
addressable by name for the life of the process.

That is the API's shape — `FormStack.api().render()` resolves a form by name
from anywhere — but it means answers persist after the form is finished,
including image and signature inputs, which store base64 and can be megabytes
each. An application that collects images across many forms should call
`FormStack.clearForms(name: ...)` when a submission completes.

## Strictness

The package builds with `strict-casts`, `strict-inference` and
`strict-raw-types` all enabled, and analysis is clean at warning level. That
matters most at the JSON boundary: without `strict-casts`, `json['count']`
flows into an `int` parameter as an implicit downcast, so a malformed field
compiles and then throws somewhere else entirely.

`JsonReader` is the boundary. Every JSON factory reads through it, so a wrong
type is a `FormatException` naming the field and the step rather than a cast
error deeper in a widget. It coerces the shapes JSON authors actually write —
`"6"` for a number, `4` for a string — and rejects the ones that are mistakes.

## Testing

256 tests, 67% line coverage.

- `test/unit` — validators, navigation and branching, JSON parsing and its
  failure modes, the registries, persistence and statistics.
- `test/integration` — parses the form definitions the example app ships, and
  exercises the extension-point combination its Extension Points screen
  demonstrates. The example is what users copy from, so it is worth keeping
  honest.
- `test/widget` — rendering, navigation, accessibility semantics, the disposal
  chain, and a smoke test that builds every built-in input type. That smoke
  test has already caught a 6px overflow in the signature pad; it is cheap
  insurance against a widget that compiles but cannot lay out.

The disposal test is the one to keep honest: it was verified to fail when the
`disposeViews()` call is removed.

The five files without coverage — the Google Maps widgets, the map input, the
web view and the HTML editor — are backed by platform views that a widget test
cannot instantiate. Covering them needs an integration test on a device, not a
better unit test.

CI runs formatting, analysis with warnings fatal, the suite on Linux, macOS and
Windows, the suite again on the oldest supported Flutter, an example build, and
`pub publish --dry-run` with a `pana` score threshold.
