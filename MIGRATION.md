# Migration Guide

This guide helps you migrate from other form solutions to FormStack or upgrade between FormStack versions.

## Migrating from Manual Forms

### Before (Manual Form)
```dart
class ManualForm extends StatefulWidget {
  @override
  _ManualFormState createState() => _ManualFormState();
}

class _ManualFormState extends State<ManualForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Handle form submission
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
```

### After (FormStack)
```dart
class FormStackForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FormStack.api().form(
      steps: [
        QuestionStep(
          title: "Name",
          inputType: InputType.name,
          id: GenericIdentifier(id: "name"),
        ),
        QuestionStep(
          title: "Email",
          inputType: InputType.email,
          id: GenericIdentifier(id: "email"),
        ),
        CompletionStep(
          title: "Thank You!",
          onFinish: (result) {
            // Handle form submission
            print("Form result: $result");
          },
        ),
      ],
    ).render();
  }
}
```

## Migrating from Other Form Libraries

### From flutter_form_builder

#### Before
```dart
FormBuilder(
  key: _formKey,
  child: Column(
    children: [
      FormBuilderTextField(
        name: 'name',
        decoration: InputDecoration(labelText: 'Name'),
        validator: FormBuilderValidators.required(),
      ),
      FormBuilderDropdown(
        name: 'country',
        decoration: InputDecoration(labelText: 'Country'),
        items: ['USA', 'Canada', 'Mexico']
            .map((country) => DropdownMenuItem(
                  value: country,
                  child: Text(country),
                ))
            .toList(),
      ),
    ],
  ),
)
```

#### After
```dart
FormStack.api().form(
  steps: [
    QuestionStep(
      title: "Name",
      inputType: InputType.name,
      id: GenericIdentifier(id: "name"),
    ),
    QuestionStep(
      title: "Country",
      inputType: InputType.dropdown,
      options: [
        Options("USA", "USA"),
        Options("Canada", "Canada"),
        Options("Mexico", "Mexico"),
      ],
      id: GenericIdentifier(id: "country"),
    ),
  ],
).render();
```

### From custom form widgets

#### Before
```dart
class CustomForm extends StatefulWidget {
  @override
  _CustomFormState createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  String? selectedValue;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: selectedValue,
          onChanged: (value) {
            setState(() {
              selectedValue = value;
            });
          },
          items: ['Option 1', 'Option 2', 'Option 3']
              .map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
        ),
        // ... more form fields
      ],
    );
  }
}
```

#### After
```dart
FormStack.api().form(
  steps: [
    QuestionStep(
      title: "Select Option",
      inputType: InputType.dropdown,
      options: [
        Options("option1", "Option 1"),
        Options("option2", "Option 2"),
        Options("option3", "Option 3"),
      ],
      id: GenericIdentifier(id: "selection"),
    ),
  ],
).render();
```

## Version Upgrades

### From v1.x to v2.x

#### Breaking Changes
- `FormKit` renamed to `FormStack`
- `FormKitForm` renamed to `FormStackForm`
- `FormKitView` renamed to `FormStackView`

#### Migration Steps
1. Update imports:
```dart
// Before
import 'package:formstack/formstack.dart';

// After
import 'package:formstack/formstack.dart';
```

2. Update class names:
```dart
// Before
FormKit.api().form(/* ... */)

// After
FormStack.api().form(/* ... */)
```

3. Update method calls:
```dart
// Before
FormKit.api().render()

// After
FormStack.api().render()
```

### From v2.x to v3.x

3.0 fixes a set of defects, opens the library for extension, and makes three
breaking changes to the step model. Forms built with `FormStack.api().form(...)`
or loaded from JSON need no changes.

#### Breaking changes

**1. `FormStep` is no longer a linked-list node**

A step described *what to ask* but was also a node in a `LinkedList`, which
meant one step definition could belong to only one form — sharing one threw at
runtime. Ordering now lives in the form.

```dart
// Before
final next = step.next;
final previous = step.previous;

// After
final next = form.stepAfter(step);
final previous = form.stepBefore(step);
```

**2. `FormStackForm.steps` is a `List`**

```dart
// Before
LinkedList<FormStep> steps = form.steps;

// After
List<FormStep> steps = form.steps;
```

**3. `FormStep` no longer takes a type parameter**

It was declared and never used.

```dart
// Before
class MyStep extends FormStep<MyStep> { }

// After
class MyStep extends FormStep { }
```

**4. The top-level `uuid` variable is no longer exported**

It was a mutable global with a very collidable name in every importer's scope.
Depend on `package:uuid` directly if you were using it.

#### Behaviour changes to check

These are bug fixes, but they change what your forms accept:

- **`ResultFormat.notEmpty` now works on text.** It previously only recognised
  `List`, so on a text field it could never pass. If you worked around that
  with `notBlank`, you can simplify — or leave it, both are correct.
- **`ResultFormat.notBlank` now trims.** `"   "` used to pass a not-blank
  check. Answers that are only whitespace are now rejected.
- **The form-level JSON `theme` now applies.** Every JSON step previously
  received a default `UIStyle` that blocked it, so a `"theme"` block was
  silently ignored. If you compensated by styling each step individually, your
  forms will look the same; if you had a `"theme"` you thought was broken, it
  works now.
- **Malformed form definitions throw.** A relevant condition with neither `id`
  nor `formName`, an option that is not an object, or an unknown validator name
  now raise a `FormatException` naming the problem, where they used to fail
  obscurely or silently do nothing.

#### If you subclass `BaseStepView`

Step views are `StatelessWidget`s that hold controllers, so the framework never
disposes them — the form does. If your view allocates a
`TextEditingController`, `FocusNode` or listener, override `dispose` and call
`super.dispose()`:

```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

This was always required; before 3.0 nothing called `dispose` at all, so
omitting it leaked silently. It is now enforced with `@mustCallSuper`.

#### What you gain

**Validators in JSON.** A JSON step can declare the full validator library,
which previously required dropping down to Dart:

```json
{
  "type": "QuestionStep",
  "id": "age",
  "inputType": "number",
  "validators": [
    {"type": "notBlank", "message": "Age is required"},
    {"type": "range", "message": "Must be 18-120", "min": 18, "max": 120}
  ]
}
```

**Custom input types, from Dart and JSON.** Register once, use anywhere:

```dart
InputRegistry.instance.register(
  'creditCardScanner',
  (ctx) => CardScannerView(ctx.form, ctx.step, ctx.text, ctx.resultFormat),
);
```

Registering an existing name overrides that built-in everywhere — the supported
way to replace, say, the signature pad without forking.

**Localizable validation.** `validate()` returns a stable code and the
constraint parameters, so messages no longer have to be matched as strings:

```dart
final outcome = ResultFormat.range("Must be 18-120", 18, 120).validate(5);
outcome.code;    // 'range'
outcome.params;  // {'min': 18, 'max': 120}
```

**Working `barcode` and `audio`.** Both were UI scaffolds with nothing behind
them. Register a capability and they capture for real:

```dart
DeviceCapabilities.instance
  ..barcodeScanner = MobileScannerAdapter()
  ..audioRecorder = RecordAdapter();
```

**A theme that applies.** `FormStackTheme`'s fields used to be inert. Wrap a
subtree in `FormStackThemeScope` to set content width, padding and radius.

#### Update the dependency

```yaml
dependencies:
  formstack: ^3.0.0
```

3.0 requires Dart 3.10 / Flutter 3.38.2. The old `">=1.17.0"` constraint was
never accurate — the package already used APIs from Flutter 3.27.

### From v3.0 to v3.1

No breaking changes. Step views moved into the widget tree, which fixes the
root cause behind 3.0's disposal work.

**If you wrote a custom input**, nothing changes to compile — but check one
thing: your view is now rebuilt when the user navigates back to its step, so it
must restore what it shows from `formStep.result` rather than relying on its
own fields surviving.

```dart
@override
Widget? buildWInputWidget(BuildContext context, QuestionStep formStep) {
  // Restore once, from the model.
  if (!_restored) {
    _restored = true;
    _controller.text = formStep.result?.toString() ?? '';
  }
  return TextField(controller: _controller);
}
```

Previously a view cache hid this: an input that failed to restore kept working
until the cache evicted it. If you had set `maxCachedViews: 0`, you were already
seeing the difference.

**Deprecated, and now no-ops:** `FormStackForm.maxCachedViews`,
`clearViewCache()` and `disposeViews()`. Nothing is retained to bound, clear or
dispose. Remove the calls at your convenience; they are removed in 4.0.

## Common Migration Patterns

### State Management Integration

#### Before (Manual State)
```dart
class FormWidget extends StatefulWidget {
  @override
  _FormWidgetState createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final _formData = <String, dynamic>{};
  
  void _updateField(String key, dynamic value) {
    setState(() {
      _formData[key] = value;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          onChanged: (value) => _updateField('name', value),
          // ... other properties
        ),
        // ... more fields
      ],
    );
  }
}
```

#### After (FormStack)
```dart
class FormWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FormStack.api().form(
      steps: [
        QuestionStep(
          title: "Name",
          inputType: InputType.name,
          id: GenericIdentifier(id: "name"),
        ),
        // ... more steps
      ],
    ).render();
  }
}
```

### Validation Migration

#### Before (Manual Validation)
```dart
String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  if (!value.contains('@')) {
    return 'Please enter a valid email';
  }
  return null;
}

String? _validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  return null;
}
```

#### After (FormStack Validation)
```dart
QuestionStep(
  title: "Email",
  inputType: InputType.email,
  resultFormat: ResultFormat.email("Please enter a valid email"),
  id: GenericIdentifier(id: "email"),
),

QuestionStep(
  title: "Password",
  inputType: InputType.password,
  resultFormat: ResultFormat.password("Password must be at least 8 characters"),
  id: GenericIdentifier(id: "password"),
),
```

## Best Practices

### 1. Gradual Migration
- Start with simple forms
- Migrate one form at a time
- Test thoroughly after each migration

### 2. Data Structure
- Map your existing form data to FormStack's structure
- Use consistent naming conventions
- Maintain backward compatibility during transition

### 3. Testing
- Write tests for migrated forms
- Test all validation scenarios
- Verify form submission handling

### 4. Performance
- Take advantage of FormStack's optimizations
- Use lazy loading for large forms
- Implement proper error handling

## Troubleshooting

### Common Issues

#### Forms not rendering
- Check that FormStack is properly imported
- Verify that `render()` is called
- Ensure form steps are properly configured

#### Validation not working
- Verify that `ResultFormat` is correctly applied
- Check that form steps have proper IDs
- Ensure validation rules are compatible

#### Styling issues
- Check that style properties are correctly applied
- Verify compatibility between styles and input types
- Test on different screen sizes

### Getting Help
- Check the [FAQ](FAQ.md) for common solutions
- Open an issue on GitHub for bugs
- Use GitHub discussions for questions

---

**Need help with migration?** Feel free to open an issue or start a discussion on GitHub!
