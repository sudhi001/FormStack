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

#### New Features
- Additional input types (OTP, HTML Editor, Map Location)
- Enhanced validation options
- Performance improvements
- Better memory management

#### Migration Steps
1. Update dependencies:
```yaml
dependencies:
  formstack: ^3.0.0
```

2. Update validation calls:
```dart
// Before
ResultFormat.email("Invalid email")

// After (same API, enhanced validation)
ResultFormat.email("Invalid email")
```

3. Take advantage of new features:
```dart
// New input types
QuestionStep(
  title: "Enter OTP",
  inputType: InputType.otp,
  count: 6,
  id: GenericIdentifier(id: "otp"),
)

QuestionStep(
  title: "Rich Text",
  inputType: InputType.htmlEditor,
  id: GenericIdentifier(id: "rich_text"),
)
```

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
