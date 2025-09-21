# Frequently Asked Questions (FAQ)

## General Questions

### What is FormStack?
FormStack is a powerful Flutter library for creating dynamic, responsive forms. It supports 20+ input types, multiple styling options, and can be configured using JSON or Dart objects.

### Why should I use FormStack instead of building forms manually?
FormStack provides:
- **Pre-built components** for common input types
- **Built-in validation** with comprehensive error handling
- **Responsive design** that works on all screen sizes
- **JSON configuration** for easy form management
- **Memory efficient** with proper resource management
- **Extensible architecture** for custom components

### Is FormStack free to use?
Yes! FormStack is open-source and licensed under the MIT License, making it free for both personal and commercial use.

## Technical Questions

### How do I add FormStack to my Flutter project?
Add FormStack to your `pubspec.yaml`:
```yaml
dependencies:
  formstack: ^latest_version
```
Then run `flutter pub get`.

### Can I use FormStack with existing Flutter apps?
Absolutely! FormStack is designed to integrate seamlessly with existing Flutter applications. You can use it for specific forms or replace your entire form system.

### Does FormStack work with Flutter Web?
Yes! FormStack supports all Flutter platforms including Web, Android, iOS, Windows, macOS, and Linux.

### How do I customize the appearance of forms?
FormStack offers multiple customization options:
- **Component Styles**: `ComponentsStyle.basic` or `ComponentsStyle.minimal`
- **Input Styles**: `InputStyle.basic`, `InputStyle.outline`, or `InputStyle.underLined`
- **Selection Types**: `SelectionType.tick`, `SelectionType.arrow`, `SelectionType.toggle`, or `SelectionType.dropdown`
- **Display Sizes**: `Display.small`, `Display.normal`, `Display.medium`, `Display.large`, or `Display.extraLarge`

### Can I create custom input types?
Yes! You can create custom input types by extending `BaseStepView` and implementing your own input widget.

### How do I handle form validation?
FormStack includes comprehensive validation:
```dart
// Built-in validations
ResultFormat.email("Please enter a valid email")
ResultFormat.password("Password must be at least 8 characters")
ResultFormat.notNull("This field is required")

// Custom validation
ResultFormat.custom("Invalid input", (value) => value.length > 5)
```

### Can I load forms from JSON files?
Yes! FormStack supports loading forms from JSON files:
```dart
await FormStack.api().loadFromAsset('assets/my_form.json');
FormStack.api().render();
```

### How do I track form progress?
FormStack provides built-in progress tracking:
```dart
// Get completion percentage (0.0 to 1.0)
double progress = FormStack.api().getFormProgress();

// Get detailed statistics
Map<String, dynamic> stats = FormStack.api().getFormStats();
```

## Performance Questions

### Is FormStack memory efficient?
Yes! FormStack is designed with memory efficiency in mind:
- Proper disposal of controllers and resources
- Lazy loading of components
- Optimized widget rebuilds
- Form state caching

### Does FormStack affect app performance?
FormStack is optimized for performance and should not significantly impact your app's performance. It uses efficient rendering techniques and proper resource management.

### Can I use FormStack in large applications?
Absolutely! FormStack is designed to scale and can handle complex forms with many steps and input types.

## Integration Questions

### Can I integrate FormStack with state management solutions?
Yes! FormStack works with any state management solution (Provider, Bloc, Riverpod, etc.). You can access form data and integrate it with your app's state.

### How do I handle form submission?
Form submission is handled through completion callbacks:
```dart
CompletionStep(
  title: "Form Completed!",
  onFinish: (result) {
    // Handle form submission
    print("Form result: $result");
  },
)
```

### Can I use FormStack with backend APIs?
Yes! FormStack forms can easily integrate with backend APIs. You can send form data to your backend in the completion callback.

## Troubleshooting

### My form isn't rendering. What should I check?
1. Ensure FormStack is properly added to `pubspec.yaml`
2. Check that you're calling `FormStack.api().render()`
3. Verify that your form steps are properly configured
4. Check for any console errors

### Validation isn't working. How do I fix it?
1. Ensure you're using the correct `ResultFormat` for your input type
2. Check that validation rules are properly configured
3. Verify that form steps have proper IDs

### My custom styling isn't applying. What's wrong?
1. Check that you're using the correct style properties
2. Ensure styles are compatible with your input type
3. Verify that styles are applied to the correct components

### The form is too slow. How can I optimize it?
1. Use lazy loading for large forms
2. Implement form state caching
3. Optimize validation rules
4. Consider breaking large forms into smaller sections

## Advanced Questions

### Can I create nested forms?
Yes! FormStack supports nested forms using `NestedStep`:
```dart
NestedStep(
  title: "Personal Information",
  steps: [
    QuestionStep(/* ... */),
    QuestionStep(/* ... */),
  ],
)
```

### How do I implement conditional logic?
Use `RelevantCondition` to show/hide fields based on user input:
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

### Can I add animations to forms?
Yes! FormStack includes built-in animations and you can add custom animations using Flutter's animation framework.

### How do I handle file uploads?
FormStack supports file uploads with the `InputType.file`:
```dart
QuestionStep(
  title: "Upload File",
  inputType: InputType.file,
  filter: ["pdf", "doc", "jpg", "png"],
  id: GenericIdentifier(id: "file_upload"),
)
```

## Support Questions

### Where can I get help?
- 📖 [Documentation](https://pub.dev/documentation/formstack/latest/)
- 🐛 [Issue Tracker](https://github.com/your-org/formstack/issues)
- 💬 [Discussions](https://github.com/your-org/formstack/discussions)
- 📧 [Email Support](mailto:support@formstack.dev)

### How do I report bugs?
Use the [GitHub issue tracker](https://github.com/your-org/formstack/issues) and include:
- Description of the bug
- Steps to reproduce
- Expected vs actual behavior
- Flutter version and platform

### Can I request new features?
Yes! Use [GitHub discussions](https://github.com/your-org/formstack/discussions) to request new features. Please describe the use case and benefits.

### Is there a community?
Yes! Join our community on GitHub discussions and Twitter for updates, tips, and support.

---

**Still have questions?** Feel free to open an issue or start a discussion on GitHub!
