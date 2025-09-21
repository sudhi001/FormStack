# 🚀 FormStack - Dynamic Form Builder for Flutter

[![pub package](https://img.shields.io/pub/v/formstack.svg)](https://pub.dev/packages/formstack)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)

> **The most powerful and flexible form builder for Flutter applications. Create dynamic, responsive forms with minimal code using JSON or Dart objects.**

## ✨ Why Choose FormStack?

- 🎯 **20+ Input Types** - From simple text fields to complex map location pickers
- 🎨 **Multiple Styles** - Beautiful, customizable UI components
- 📱 **Responsive Design** - Works perfectly on all screen sizes
- 🔧 **JSON or Dart** - Build forms using JSON files or Dart objects
- ⚡ **High Performance** - Optimized for smooth user experience
- 🛡️ **Built-in Validation** - Comprehensive validation with custom error messages
- 🧩 **Modular Architecture** - Easy to extend and customize
- 💾 **Memory Efficient** - No memory leaks, proper resource management

## 🎬 Quick Demo

```dart
import 'package:formstack/formstack.dart';

// Create a form in just a few lines!
FormStack.api().form(
  steps: [
    InstructionStep(
      title: "Welcome!",
      text: "Let's get started with your information",
    ),
    QuestionStep(
      title: "Your Name",
      inputType: InputType.name,
      id: GenericIdentifier(id: "name"),
    ),
    QuestionStep(
      title: "Email Address",
      inputType: InputType.email,
      id: GenericIdentifier(id: "email"),
    ),
    CompletionStep(
      title: "Thank You!",
      text: "Your information has been submitted",
    ),
  ],
).render();
```

## 📦 Installation

Add FormStack to your `pubspec.yaml`:

```yaml
dependencies:
  formstack: ^latest_version
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

### 1. Basic Form Setup

```dart
import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FormStack.api().form(
        steps: [
          QuestionStep(
            title: "What's your name?",
            inputType: InputType.name,
            id: GenericIdentifier(id: "name"),
          ),
          QuestionStep(
            title: "Enter your email",
            inputType: InputType.email,
            id: GenericIdentifier(id: "email"),
          ),
        ],
      ).render(),
    );
  }
}
```

### 2. Load from JSON

```dart
// Load form from JSON file
await FormStack.api().loadFromAsset('assets/my_form.json');

// Render the form
FormStack.api().render()
```

## 🎨 Available Input Types

### 📝 Text Inputs
- **Email** - Email validation with regex
- **Name** - Name validation (letters only)
- **Password** - Secure password input
- **Text** - Multi-line text input
- **Number** - Numeric input with validation

### 📅 Date & Time
- **Date** - Date picker
- **Time** - Time picker  
- **DateTime** - Combined date and time picker

### ✅ Choice Inputs
- **Single Choice** - Radio button selection
- **Multiple Choice** - Checkbox selection
- **Dropdown** - Traditional dropdown menu

### 🎯 Special Inputs
- **OTP** - One-time password input
- **Smile Rating** - 1-5 star rating slider
- **File Upload** - File picker with filters
- **Dynamic Key-Value** - Custom key-value pairs
- **HTML Editor** - Rich text editor
- **Map Location** - Interactive map picker
- **Avatar** - Circular image upload
- **Banner** - Rectangular image upload

## 🎨 Styling Options

### Component Styles
```dart
QuestionStep(
  title: "Styled Input",
  inputType: InputType.text,
  componentsStyle: ComponentsStyle.basic, // or ComponentsStyle.minimal
)
```

### Input Styles
```dart
QuestionStep(
  title: "Outlined Input",
  inputType: InputType.text,
  inputStyle: InputStyle.outline, // or InputStyle.underLined, InputStyle.basic
)
```

### Selection Types
```dart
QuestionStep(
  title: "Choose Option",
  inputType: InputType.singleChoice,
  selectionType: SelectionType.tick, // or SelectionType.arrow, SelectionType.toggle, SelectionType.dropdown
  options: [
    Options("option1", "Option 1"),
    Options("option2", "Option 2"),
  ],
)
```

## 📋 Form Components

### InstructionStep
Display information or instructions to users.

```dart
InstructionStep(
  title: "Welcome to Our App",
  text: "Please complete the following steps",
  cancellable: false,
)
```

### QuestionStep
Interactive input fields with validation.

```dart
QuestionStep(
  title: "Your Question",
  text: "Additional description",
  inputType: InputType.email,
  isOptional: false,
  id: GenericIdentifier(id: "unique_id"),
)
```

### CompletionStep
Success/completion screen with animations.

```dart
CompletionStep(
  title: "Form Completed!",
  text: "Thank you for your submission",
  onFinish: (result) {
    print("Form result: $result");
  },
)
```

### NestedStep
Multi-step forms with sub-forms.

```dart
NestedStep(
  title: "Personal Information",
  steps: [
    QuestionStep(/* ... */),
    QuestionStep(/* ... */),
  ],
)
```

## 🛡️ Validation

FormStack includes comprehensive validation:

```dart
// Built-in validations
ResultFormat.email("Please enter a valid email")
ResultFormat.password("Password must be at least 8 characters")
ResultFormat.notNull("This field is required")

// Custom validation
ResultFormat.custom("Invalid input", (value) => value.length > 5)

// Advanced validations
ResultFormat.phone("Please enter a valid phone number")
ResultFormat.creditCard("Invalid credit card number")
ResultFormat.url("Please enter a valid URL")
ResultFormat.ssn("Invalid Social Security Number")
ResultFormat.zipCode("Invalid ZIP code")
ResultFormat.age("Age must be between 0 and 150")
ResultFormat.percentage("Percentage must be between 0 and 100")
```

## 📱 Responsive Design

FormStack automatically adapts to different screen sizes:

```dart
QuestionStep(
  title: "Responsive Text",
  inputType: InputType.text,
  display: Display.large, // small, normal, medium, large, extraLarge
)
```

## 🔧 Advanced Features

### Form Progress Tracking
```dart
// Get form completion progress
double progress = FormStack.api().getFormProgress();
print("Form is ${(progress * 100).toInt()}% complete");

// Get detailed statistics
Map<String, dynamic> stats = FormStack.api().getFormStats();
print("Total steps: ${stats['totalSteps']}");
print("Completed: ${stats['completedSteps']}");
```

### Conditional Logic
```dart
QuestionStep(
  title: "Choose Type",
  inputType: InputType.singleChoice,
  options: [
    Options("personal", "Personal"),
    Options("business", "Business"),
  ],
  relevantConditions: [
    RelevantCondition(
      id: "show_business_fields",
      expression: "IN business",
    ),
  ],
)
```

### Custom Styling
```dart
QuestionStep(
  title: "Custom Styled",
  inputType: InputType.text,
  style: UIStyle(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    borderRadius: 12.0,
    borderColor: Colors.blue.shade300,
  ),
)
```

## 📄 JSON Configuration

Create forms using JSON for easy configuration:

```json
{
  "steps": [
    {
      "type": "InstructionStep",
      "title": "Welcome",
      "text": "Please complete this form",
      "cancellable": false
    },
    {
      "type": "QuestionStep",
      "title": "Your Name",
      "inputType": "name",
      "inputStyle": "outline",
      "componentsStyle": "basic",
      "isOptional": false,
      "id": "name"
    },
    {
      "type": "QuestionStep",
      "title": "Email",
      "inputType": "email",
      "inputStyle": "outline",
      "componentsStyle": "basic",
      "isOptional": false,
      "id": "email"
    },
    {
      "type": "CompletionStep",
      "title": "Thank You!",
      "text": "Your information has been submitted",
      "autoTrigger": true,
      "id": "completion"
    }
  ]
}
```

## 🎯 Real-World Examples

### User Registration Form
```dart
FormStack.api().form(
  steps: [
    InstructionStep(
      title: "Create Account",
      text: "Please provide your information to create an account",
    ),
    QuestionStep(
      title: "Full Name",
      inputType: InputType.name,
      id: GenericIdentifier(id: "full_name"),
    ),
    QuestionStep(
      title: "Email Address",
      inputType: InputType.email,
      id: GenericIdentifier(id: "email"),
    ),
    QuestionStep(
      title: "Password",
      inputType: InputType.password,
      id: GenericIdentifier(id: "password"),
    ),
    QuestionStep(
      title: "Phone Number",
      inputType: InputType.number,
      id: GenericIdentifier(id: "phone"),
    ),
    CompletionStep(
      title: "Account Created!",
      text: "Welcome to our platform",
      onFinish: (result) {
        // Handle registration
        print("User registered: $result");
      },
    ),
  ],
).render();
```

### Survey Form
```dart
FormStack.api().form(
  steps: [
    InstructionStep(
      title: "Customer Survey",
      text: "Help us improve our service",
    ),
    QuestionStep(
      title: "How satisfied are you?",
      inputType: InputType.smile,
      id: GenericIdentifier(id: "satisfaction"),
    ),
    QuestionStep(
      title: "What features do you use?",
      inputType: InputType.multipleChoice,
      selectionType: SelectionType.tick,
      options: [
        Options("feature1", "Feature 1"),
        Options("feature2", "Feature 2"),
        Options("feature3", "Feature 3"),
      ],
      id: GenericIdentifier(id: "features"),
    ),
    QuestionStep(
      title: "Additional Comments",
      inputType: InputType.text,
      numberOfLines: 3,
      id: GenericIdentifier(id: "comments"),
    ),
  ],
).render();
```

## 🏗️ Architecture

FormStack follows a modular architecture:

```
lib/
├── src/
│   ├── core/           # Core form logic
│   ├── ui/             # UI components
│   │   ├── views/      # Form views
│   │   └── input/      # Input field widgets
│   ├── result/         # Validation and result handling
│   ├── step/           # Step definitions
│   └── utils/          # Utility functions
```

## 🔧 Customization

### Custom Input Types
```dart
// Create custom input widgets by extending BaseStepView
class CustomInputWidget extends BaseStepView<QuestionStep> {
  // Implementation
}
```

### Custom Validation
```dart
// Create custom validation rules
ResultFormat.custom("Custom error", (value) {
  return value.contains("@") && value.length > 5;
})
```

## 📊 Performance

FormStack is optimized for performance:

- **Memory Efficient**: Proper disposal of controllers and resources
- **Lazy Loading**: Components load only when needed
- **Optimized Rebuilds**: Minimal widget rebuilds
- **Caching**: Form state caching for better performance

## 🧪 Testing

FormStack includes comprehensive testing utilities:

```dart
// Test form validation
test('email validation', () {
  expect('test@example.com'.isValidEmail(), true);
  expect('invalid-email'.isValidEmail(), false);
});

// Test form completion
test('form completion', () {
  FormStack.api().form(/* ... */);
  expect(FormStack.api().isFormCompleted(), false);
});
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup
```bash
git clone https://github.com/your-org/formstack.git
cd formstack
flutter pub get
flutter test
```

## 📚 Documentation

- [API Reference](https://pub.dev/documentation/formstack/latest/)
- [Examples](https://github.com/your-org/formstack/tree/main/example)
- [Migration Guide](MIGRATION.md)
- [FAQ](FAQ.md)

## 🆘 Support

- 📖 [Documentation](https://pub.dev/documentation/formstack/latest/)
- 🐛 [Issue Tracker](https://github.com/your-org/formstack/issues)
- 💬 [Discussions](https://github.com/your-org/formstack/discussions)
- 📧 [Email Support](mailto:support@formstack.dev)

## 📄 License

FormStack is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Community contributors
- All the developers who use FormStack

## 📈 Roadmap

- [ ] Form analytics and insights
- [ ] Auto-save functionality
- [ ] Multi-language support
- [ ] Advanced conditional logic
- [ ] Form templates
- [ ] Export/Import functionality
- [ ] Real-time collaboration

---

<div align="center">

**⭐ Star this repository if you find it helpful!**

[![GitHub stars](https://img.shields.io/github/stars/your-org/formstack?style=social)](https://github.com/your-org/formstack/stargazers)
[![Twitter Follow](https://img.shields.io/twitter/follow/formstack_dev?style=social)](https://twitter.com/formstack_dev)

Made with ❤️ by the FormStack team

</div>