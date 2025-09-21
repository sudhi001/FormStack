import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

class ComprehensiveDemo extends StatelessWidget {
  const ComprehensiveDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FormStack Comprehensive Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDemoCard(
              context,
              'All Input Types Demo',
              'Demonstrates all 20 input types with different styles',
              Icons.input,
              () => _showAllInputTypesDemo(context),
            ),
            const SizedBox(height: 16),
            _buildDemoCard(
              context,
              'Component Styles Demo',
              'Shows different component styles and themes',
              Icons.style,
              () => _showComponentStylesDemo(context),
            ),
            const SizedBox(height: 16),
            _buildDemoCard(
              context,
              'Selection Types Demo',
              'Demonstrates all selection types for choices',
              Icons.checklist,
              () => _showSelectionTypesDemo(context),
            ),
            const SizedBox(height: 16),
            _buildDemoCard(
              context,
              'Validation & Error Demo',
              'Shows validation, error handling, and custom messages',
              Icons.error_outline,
              () => _showValidationDemo(context),
            ),
            const SizedBox(height: 16),
            _buildDemoCard(
              context,
              'Advanced Features Demo',
              'Nested steps, conditional logic, and complex forms',
              Icons.account_tree,
              () => _showAdvancedFeaturesDemo(context),
            ),
            const SizedBox(height: 16),
            _buildDemoCard(
              context,
              'Responsive Design Demo',
              'Different display sizes and responsive layouts',
              Icons.phone_android,
              () => _showResponsiveDemo(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showAllInputTypesDemo(BuildContext context) {
    FormStack.api().form(
      name: "all_input_types",
      initialLocation: LocationWrapper(0, 0),
      mapKey: MapKey("", "", ""),
      steps: [
        InstructionStep(
          id: GenericIdentifier(id: "intro"),
          title: "All Input Types Demo",
          text:
              "This form demonstrates all 20 available input types in FormStack",
          cancellable: false,
        ),

        // Text Input Types
        QuestionStep(
          title: "Email Input",
          text: "Enter your email address",
          inputType: InputType.email,
          inputStyle: InputStyle.outline,
          id: GenericIdentifier(id: "email"),
        ),

        QuestionStep(
          title: "Name Input",
          text: "Enter your full name",
          inputType: InputType.name,
          inputStyle: InputStyle.outline,
          id: GenericIdentifier(id: "name"),
        ),

        QuestionStep(
          title: "Password Input",
          text: "Enter a secure password",
          inputType: InputType.password,
          inputStyle: InputStyle.outline,
          id: GenericIdentifier(id: "password"),
        ),

        QuestionStep(
          title: "Number Input",
          text: "Enter a number",
          inputType: InputType.number,
          inputStyle: InputStyle.outline,
          id: GenericIdentifier(id: "number"),
        ),

        QuestionStep(
          title: "Multi-line Text",
          text: "Enter a detailed description",
          inputType: InputType.text,
          numberOfLines: 3,
          inputStyle: InputStyle.outline,
          id: GenericIdentifier(id: "multiline_text"),
        ),

        // Date/Time Input Types
        QuestionStep(
          title: "Date Picker",
          text: "Select a date",
          inputType: InputType.date,
          id: GenericIdentifier(id: "date"),
        ),

        QuestionStep(
          title: "Time Picker",
          text: "Select a time",
          inputType: InputType.time,
          id: GenericIdentifier(id: "time"),
        ),

        QuestionStep(
          title: "Date & Time Picker",
          text: "Select date and time",
          inputType: InputType.dateTime,
          id: GenericIdentifier(id: "datetime"),
        ),

        // Choice Input Types
        QuestionStep(
          title: "Single Choice (Radio)",
          text: "Choose one option",
          inputType: InputType.singleChoice,
          selectionType: SelectionType.tick,
          options: [
            Options("option1", "Option 1", subTitle: "First choice"),
            Options("option2", "Option 2", subTitle: "Second choice"),
            Options("option3", "Option 3", subTitle: "Third choice"),
          ],
          id: GenericIdentifier(id: "single_choice"),
        ),

        QuestionStep(
          title: "Multiple Choice (Checkbox)",
          text: "Choose multiple options",
          inputType: InputType.multipleChoice,
          selectionType: SelectionType.tick,
          options: [
            Options("check1", "Checkbox 1"),
            Options("check2", "Checkbox 2"),
            Options("check3", "Checkbox 3"),
          ],
          id: GenericIdentifier(id: "multiple_choice"),
        ),

        QuestionStep(
          title: "Dropdown Selection",
          text: "Select from dropdown",
          inputType: InputType.dropdown,
          options: [
            Options("dropdown1", "Dropdown Option 1"),
            Options("dropdown2", "Dropdown Option 2"),
            Options("dropdown3", "Dropdown Option 3"),
          ],
          id: GenericIdentifier(id: "dropdown"),
        ),

        QuestionStep(
          title: "Toggle Selection",
          text: "Toggle options on/off",
          inputType: InputType.multipleChoice,
          selectionType: SelectionType.toggle,
          options: [
            Options("toggle1", "Toggle 1"),
            Options("toggle2", "Toggle 2"),
            Options("toggle3", "Toggle 3"),
          ],
          id: GenericIdentifier(id: "toggle"),
        ),

        QuestionStep(
          title: "Arrow Selection",
          text: "Navigate with arrows",
          inputType: InputType.singleChoice,
          selectionType: SelectionType.arrow,
          options: [
            Options("arrow1", "Arrow Option 1"),
            Options("arrow2", "Arrow Option 2"),
            Options("arrow3", "Arrow Option 3"),
          ],
          id: GenericIdentifier(id: "arrow"),
        ),

        // Special Input Types
        QuestionStep(
          title: "OTP Input",
          text: "Enter 6-digit OTP",
          inputType: InputType.otp,
          count: 6,
          id: GenericIdentifier(id: "otp"),
        ),

        QuestionStep(
          title: "Smile Rating",
          text: "Rate your experience",
          inputType: InputType.smile,
          id: GenericIdentifier(id: "smile"),
        ),

        QuestionStep(
          title: "File Upload",
          text: "Upload a file",
          inputType: InputType.file,
          filter: ["pdf", "doc", "docx", "jpg", "png"],
          id: GenericIdentifier(id: "file"),
        ),

        QuestionStep(
          title: "Dynamic Key-Value",
          text: "Add custom key-value pairs",
          inputType: InputType.dynamicKeyValue,
          maxCount: 5,
          id: GenericIdentifier(id: "keyvalue"),
        ),

        QuestionStep(
          title: "Rich Text Editor",
          text: "Write formatted text",
          inputType: InputType.htmlEditor,
          id: GenericIdentifier(id: "html"),
        ),

        QuestionStep(
          title: "Map Location",
          text: "Select location on map",
          inputType: InputType.mapLocation,
          id: GenericIdentifier(id: "map"),
        ),

        QuestionStep(
          title: "Avatar Upload",
          text: "Upload profile picture",
          inputType: InputType.avatar,
          id: GenericIdentifier(id: "avatar"),
        ),

        QuestionStep(
          title: "Banner Upload",
          text: "Upload banner image",
          inputType: InputType.banner,
          id: GenericIdentifier(id: "banner"),
        ),

        CompletionStep(
          id: GenericIdentifier(id: "completed"),
          title: "Demo Completed!",
          text: "You've seen all input types in action",
          onFinish: (result) {
            debugPrint("All Input Types Demo Result: $result");
            Navigator.pop(context);
          },
        ),
      ],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: FormStack.api().render(name: "all_input_types"),
        ),
      ),
    );
  }

  void _showComponentStylesDemo(BuildContext context) {
    FormStack.api().form(
      name: "component_styles",
      initialLocation: LocationWrapper(0, 0),
      mapKey: MapKey("", "", ""),
      steps: [
        InstructionStep(
          id: GenericIdentifier(id: "intro"),
          title: "Component Styles Demo",
          text: "Different component styles and themes",
          cancellable: false,
        ),

        // Basic Style
        QuestionStep(
          title: "Basic Style",
          text: "Minimal design with basic styling",
          inputType: InputType.text,
          componentsStyle: ComponentsStyle.basic,
          inputStyle: InputStyle.basic,
          id: GenericIdentifier(id: "basic"),
        ),

        // Outline Style
        QuestionStep(
          title: "Outline Style",
          text: "Text field with outline border",
          inputType: InputType.text,
          componentsStyle: ComponentsStyle.basic,
          inputStyle: InputStyle.outline,
          id: GenericIdentifier(id: "outline"),
        ),

        // Underlined Style
        QuestionStep(
          title: "Underlined Style",
          text: "Text field with underlined border",
          inputType: InputType.text,
          componentsStyle: ComponentsStyle.basic,
          inputStyle: InputStyle.underLined,
          id: GenericIdentifier(id: "underlined"),
        ),

        // Minimal Style
        QuestionStep(
          title: "Minimal Style",
          text: "Clean minimal design",
          inputType: InputType.text,
          componentsStyle: ComponentsStyle.minimal,
          inputStyle: InputStyle.basic,
          id: GenericIdentifier(id: "minimal"),
        ),

        CompletionStep(
          id: GenericIdentifier(id: "completed"),
          title: "Styles Demo Completed!",
          text: "You've seen different component styles",
          onFinish: (result) {
            debugPrint("Component Styles Demo Result: $result");
            Navigator.pop(context);
          },
        ),
      ],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: FormStack.api().render(name: "component_styles"),
        ),
      ),
    );
  }

  void _showSelectionTypesDemo(BuildContext context) {
    FormStack.api().form(
      name: "selection_types",
      initialLocation: LocationWrapper(0, 0),
      mapKey: MapKey("", "", ""),
      steps: [
        InstructionStep(
          id: GenericIdentifier(id: "intro"),
          title: "Selection Types Demo",
          text: "Different ways to display choice options",
          cancellable: false,
        ),
        QuestionStep(
          title: "Tick Selection",
          text: "Options with checkmarks",
          inputType: InputType.singleChoice,
          selectionType: SelectionType.tick,
          options: [
            Options("tick1", "Tick Option 1"),
            Options("tick2", "Tick Option 2"),
            Options("tick3", "Tick Option 3"),
          ],
          id: GenericIdentifier(id: "tick"),
        ),
        QuestionStep(
          title: "Arrow Selection",
          text: "Options with navigation arrows",
          inputType: InputType.singleChoice,
          selectionType: SelectionType.arrow,
          options: [
            Options("arrow1", "Arrow Option 1"),
            Options("arrow2", "Arrow Option 2"),
            Options("arrow3", "Arrow Option 3"),
          ],
          id: GenericIdentifier(id: "arrow"),
        ),
        QuestionStep(
          title: "Toggle Selection",
          text: "Switch-style toggles",
          inputType: InputType.multipleChoice,
          selectionType: SelectionType.toggle,
          options: [
            Options("toggle1", "Toggle Option 1"),
            Options("toggle2", "Toggle Option 2"),
            Options("toggle3", "Toggle Option 3"),
          ],
          id: GenericIdentifier(id: "toggle"),
        ),
        QuestionStep(
          title: "Dropdown Selection",
          text: "Traditional dropdown menu",
          inputType: InputType.dropdown,
          selectionType: SelectionType.dropdown,
          options: [
            Options("dropdown1", "Dropdown Option 1"),
            Options("dropdown2", "Dropdown Option 2"),
            Options("dropdown3", "Dropdown Option 3"),
          ],
          id: GenericIdentifier(id: "dropdown"),
        ),
        CompletionStep(
          id: GenericIdentifier(id: "completed"),
          title: "Selection Types Demo Completed!",
          text: "You've seen all selection types",
          onFinish: (result) {
            debugPrint("Selection Types Demo Result: $result");
            Navigator.pop(context);
          },
        ),
      ],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: FormStack.api().render(name: "selection_types"),
        ),
      ),
    );
  }

  void _showValidationDemo(BuildContext context) {
    FormStack.api().form(
      name: "validation_demo",
      initialLocation: LocationWrapper(0, 0),
      mapKey: MapKey("", "", ""),
      steps: [
        InstructionStep(
          id: GenericIdentifier(id: "intro"),
          title: "Validation & Error Demo",
          text: "Form validation and error handling",
          cancellable: false,
        ),
        QuestionStep(
          title: "Required Email",
          text: "This field is required and must be a valid email",
          inputType: InputType.email,
          isOptional: false,
          id: GenericIdentifier(id: "required_email"),
        ),
        QuestionStep(
          title: "Optional Field",
          text: "This field is optional",
          inputType: InputType.text,
          isOptional: true,
          id: GenericIdentifier(id: "optional_field"),
        ),
        QuestionStep(
          title: "Length Limited Text",
          text: "Enter text (max 10 characters)",
          inputType: InputType.text,
          lengthLimit: 10,
          id: GenericIdentifier(id: "length_limited"),
        ),
        QuestionStep(
          title: "Required Choice",
          text: "You must select an option",
          inputType: InputType.singleChoice,
          isOptional: false,
          options: [
            Options("choice1", "Choice 1"),
            Options("choice2", "Choice 2"),
            Options("choice3", "Choice 3"),
          ],
          id: GenericIdentifier(id: "required_choice"),
        ),
        CompletionStep(
          id: GenericIdentifier(id: "completed"),
          title: "Validation Demo Completed!",
          text: "You've seen validation in action",
          onFinish: (result) {
            debugPrint("Validation Demo Result: $result");
            Navigator.pop(context);
          },
        ),
      ],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: FormStack.api().render(name: "validation_demo"),
        ),
      ),
    );
  }

  void _showAdvancedFeaturesDemo(BuildContext context) {
    FormStack.api().form(
      name: "advanced_features",
      initialLocation: LocationWrapper(0, 0),
      mapKey: MapKey("", "", ""),
      steps: [
        InstructionStep(
          id: GenericIdentifier(id: "intro"),
          title: "Advanced Features Demo",
          text: "Nested steps, conditional logic, and complex forms",
          cancellable: false,
        ),
        QuestionStep(
          title: "Choose Form Type",
          text: "Select the type of form you want to see",
          inputType: InputType.singleChoice,
          selectionType: SelectionType.tick,
          options: [
            Options("nested", "Nested Form",
                subTitle: "Multi-step nested form"),
            Options("conditional", "Conditional Logic",
                subTitle: "Dynamic form based on choices"),
            Options("complex", "Complex Form",
                subTitle: "Multiple input types"),
          ],
          id: GenericIdentifier(id: "form_type"),
        ),
        QuestionStep(
          title: "Nested Form Example",
          text: "This would show a nested form with multiple steps",
          inputType: InputType.text,
          numberOfLines: 2,
          id: GenericIdentifier(id: "nested_info"),
        ),
        CompletionStep(
          id: GenericIdentifier(id: "completed"),
          title: "Advanced Features Demo Completed!",
          text: "You've seen advanced features in action",
          onFinish: (result) {
            debugPrint("Advanced Features Demo Result: $result");
            Navigator.pop(context);
          },
        ),
      ],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: FormStack.api().render(name: "advanced_features"),
        ),
      ),
    );
  }

  void _showResponsiveDemo(BuildContext context) {
    FormStack.api().form(
      name: "responsive_demo",
      initialLocation: LocationWrapper(0, 0),
      mapKey: MapKey("", "", ""),
      steps: [
        InstructionStep(
          id: GenericIdentifier(id: "intro"),
          title: "Responsive Design Demo",
          text: "Different display sizes and responsive layouts",
          cancellable: false,
        ),
        QuestionStep(
          title: "Small Display",
          text: "Compact design for small screens",
          inputType: InputType.text,
          display: Display.small,
          id: GenericIdentifier(id: "small_display"),
        ),
        QuestionStep(
          title: "Normal Display",
          text: "Standard size for normal screens",
          inputType: InputType.text,
          display: Display.normal,
          id: GenericIdentifier(id: "normal_display"),
        ),
        QuestionStep(
          title: "Medium Display",
          text: "Larger text for medium screens",
          inputType: InputType.text,
          display: Display.medium,
          id: GenericIdentifier(id: "medium_display"),
        ),
        QuestionStep(
          title: "Large Display",
          text: "Big text for large screens",
          inputType: InputType.text,
          display: Display.large,
          id: GenericIdentifier(id: "large_display"),
        ),
        QuestionStep(
          title: "Extra Large Display",
          text: "Very large text for extra large screens",
          inputType: InputType.text,
          display: Display.extraLarge,
          id: GenericIdentifier(id: "extra_large_display"),
        ),
        CompletionStep(
          id: GenericIdentifier(id: "completed"),
          title: "Responsive Demo Completed!",
          text: "You've seen responsive design in action",
          onFinish: (result) {
            debugPrint("Responsive Demo Result: $result");
            Navigator.pop(context);
          },
        ),
      ],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: FormStack.api().render(name: "responsive_demo"),
        ),
      ),
    );
  }
}
