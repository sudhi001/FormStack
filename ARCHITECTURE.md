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

This is the subtlest part of the codebase and the source of its worst historical
bug, so it is worth stating plainly.

Step views are `StatelessWidget`s that hold mutable state — controllers, focus
nodes, notifiers. That is not the Flutter idiom, and it has a consequence: the
framework will never call `dispose()` on them, because `StatelessWidget` has no
disposal lifecycle. Anything those views allocate leaks unless something else
releases it.

The ownership rule is therefore explicit:

- `FormStackForm` owns the cached step views. It disposes a view when it evicts
  it from the cache (`maxCachedViews`, default 12) and when `disposeViews()` is
  called.
- `FormStackView` — a real `StatefulWidget` — calls `disposeViews()` from its
  own `dispose()`. This is the only thing tying view lifetime to the widget
  tree.
- `BaseStepView.dispose()` is `@mustCallSuper` and idempotent. Container views
  such as `NestedStepView` cascade disposal to their children.

Any new step view that allocates a disposable must override `dispose()` and call
`super.dispose()`. `test/widget/lifecycle_test.dart` guards the chain.

The long-term fix is to make step views stateful and let the framework own this;
see *Known debt* below.

## Navigation

Order is a property of the form, not of the step. `FormStackForm.steps` is a
plain `List`, and `stepAfter` / `stepBefore` resolve neighbours through a
position index rebuilt only when the list length changes.

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

1. **Step views should be stateful.** The `StatelessWidget`-with-mutable-state
   pattern is why the manual disposal chain above exists at all. Converting
   `BaseStepView` to a `StatefulWidget` whose `State` holds the controllers
   would let the framework own lifetime, delete `maxCachedViews`, and remove
   every `// ignore: must_be_immutable`. It touches every input widget.
2. **`InputType` is a closed enum with a 35-arm switch.** `InputRegistry`
   routes around it, but the built-ins should migrate onto the registry so the
   switch disappears and every input type is uniform.
3. **Heavy transitive dependencies.** `google_maps_flutter`, `location`,
   `webview_flutter` and `file_picker` are unconditional dependencies, so an
   application using FormStack purely for text and choice inputs still inherits
   map and camera SDKs, their permission declarations and their iOS privacy
   manifests. These should move behind provider interfaces resolved through
   `InputRegistry`, shipped as separate packages (`formstack_maps`,
   `formstack_media`). This is the largest single improvement available to
   consumers, and the pattern is already proven by `DeviceCapabilities` —
   `barcode` and `audio` reach their platform dependency through a port rather
   than a direct import.
4. **`FormStack` is doing several jobs** — instance registry, form builder,
   statistics, persistence facade. The persistence and statistics APIs would sit
   better on `FormStackForm`.
5. **Public API documentation is incomplete.** ~460 public members are
   undocumented, nearly all of them on the internal input widget classes.
   `public_member_api_docs` is enabled at `info` so the backlog is visible in
   every analysis run without gating changes.
6. **`cacheExtent` / `onReorder` deprecations** are left in place deliberately:
   migrating raises the minimum Flutter to 3.41, far above the supported floor.
   Revisit when the floor moves.

## Testing

133 tests, 51% line coverage.

- `test/unit` — validators, navigation and branching, JSON parsing and its
  failure modes, the registries, persistence and statistics.
- `test/integration` — parses the form definitions the example app ships, so
  real-world usage of cross-form navigation and nested steps stays covered.
- `test/widget` — rendering, navigation, accessibility semantics, the disposal
  chain, and a smoke test that builds every built-in input type. That smoke
  test has already caught a 6px overflow in the signature pad; it is cheap
  insurance against a widget that compiles but cannot lay out.

The disposal test is the one to keep honest: it was verified to fail when the
`disposeViews()` call is removed.

CI runs formatting, analysis with warnings fatal, the suite on Linux, macOS and
Windows, the suite again on the oldest supported Flutter, an example build, and
`pub publish --dry-run` with a `pana` score threshold.
