import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

// Base class for demos that build a form and render it directly
abstract class FormDemoScreen extends StatefulWidget {
  const FormDemoScreen({super.key});
}

abstract class FormDemoScreenState<T extends FormDemoScreen> extends State<T> {
  String get formName;

  void buildForm(BuildContext context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      buildForm(context);
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(body: FormStack.api().render(name: formName));
    } catch (_) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}

// ---------------------------------------------------------------------------
// 1. ALL INPUT TYPES DEMO
// ---------------------------------------------------------------------------
class AllInputTypesDemo extends FormDemoScreen {
  const AllInputTypesDemo({super.key});

  @override
  State<AllInputTypesDemo> createState() => _AllInputTypesDemoState();
}

class _AllInputTypesDemoState extends FormDemoScreenState<AllInputTypesDemo> {
  @override
  String get formName => "all_inputs";

  @override
  void buildForm(BuildContext context) {
    FormStack.api().form(
      name: formName,
      initialLocation: LocationWrapper(0, 0),
      mapKey: MapKey("", "", ""),
      steps: [
        InstructionStep(
          id: GenericIdentifier(id: "intro"),
          title: "All Input Types",
          text: "Walk through all 20 input types supported by FormStack",
          cancellable: false,
          display: Display.medium,
        ),

        // --- Text inputs ---
        QuestionStep(
          title: "Email",
          text: "InputType.email with email keyboard and validation",
          inputType: InputType.email,
          inputStyle: InputStyle.outline,
          hint: "you@example.com",
          id: GenericIdentifier(id: "email"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Name",
          text: "InputType.name with letters-only filter and word capitalization",
          inputType: InputType.name,
          inputStyle: InputStyle.outline,
          hint: "John Doe",
          id: GenericIdentifier(id: "name"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Password",
          text:
              "InputType.password with secure entry (requires uppercase, lowercase, number, special char)",
          inputType: InputType.password,
          inputStyle: InputStyle.outline,
          hint: "SecureP@ss1",
          id: GenericIdentifier(id: "password"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Text (Multi-line)",
          text: "InputType.text with numberOfLines: 4 for longer input",
          inputType: InputType.text,
          numberOfLines: 4,
          inputStyle: InputStyle.outline,
          hint: "Write something...",
          id: GenericIdentifier(id: "text"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Number",
          text: "InputType.number with mask: ###-###-#### for phone formatting",
          inputType: InputType.number,
          inputStyle: InputStyle.outline,
          mask: "###-###-####",
          hint: "123-456-7890",
          id: GenericIdentifier(id: "number"),
          cancellable: true,
        ),

        // --- Date/Time inputs ---
        QuestionStep(
          title: "Date Picker",
          text: "InputType.date with native date picker",
          inputType: InputType.date,
          id: GenericIdentifier(id: "date"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Time Picker",
          text: "InputType.time with native time picker",
          inputType: InputType.time,
          id: GenericIdentifier(id: "time"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Date & Time",
          text: "InputType.dateTime combining both pickers",
          inputType: InputType.dateTime,
          id: GenericIdentifier(id: "datetime"),
          cancellable: true,
        ),

        // --- Choice inputs ---
        QuestionStep(
          title: "Single Choice (Tick)",
          text: "InputType.singleChoice with SelectionType.tick",
          inputType: InputType.singleChoice,
          selectionType: SelectionType.tick,
          componentsStyle: ComponentsStyle.basic,
          options: [
            Options("flutter", "Flutter",
                subTitle: "Cross-platform UI toolkit"),
            Options("react", "React Native",
                subTitle: "JavaScript framework by Meta"),
            Options("kotlin", "Kotlin Multiplatform",
                subTitle: "JetBrains solution"),
          ],
          id: GenericIdentifier(id: "single_choice"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Multiple Choice (Toggle)",
          text: "InputType.multipleChoice with SelectionType.toggle switches",
          inputType: InputType.multipleChoice,
          selectionType: SelectionType.toggle,
          options: [
            Options("dart", "Dart"),
            Options("kotlin", "Kotlin"),
            Options("swift", "Swift"),
            Options("typescript", "TypeScript"),
          ],
          id: GenericIdentifier(id: "multi_choice"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Dropdown",
          text: "InputType.dropdown with traditional dropdown menu",
          inputType: InputType.dropdown,
          componentsStyle: ComponentsStyle.basic,
          options: [
            Options("us", "United States"),
            Options("uk", "United Kingdom"),
            Options("ca", "Canada"),
            Options("au", "Australia"),
            Options("in", "India"),
          ],
          id: GenericIdentifier(id: "dropdown"),
          cancellable: true,
        ),

        // --- Special inputs ---
        QuestionStep(
          title: "OTP Input",
          text: "InputType.otp with count: 6 digits",
          inputType: InputType.otp,
          count: 6,
          inputStyle: InputStyle.outline,
          id: GenericIdentifier(id: "otp"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Smile Rating",
          text: "InputType.smile for satisfaction rating",
          inputType: InputType.smile,
          id: GenericIdentifier(id: "smile"),
          cancellable: true,
        ),
        QuestionStep(
          title: "File Upload",
          text: "InputType.file with filter for specific extensions",
          inputType: InputType.file,
          filter: ["pdf", "doc", "docx", "jpg", "png"],
          id: GenericIdentifier(id: "file"),
          cancellable: true,
          isOptional: true,
        ),
        QuestionStep(
          title: "Dynamic Key-Value",
          text: "InputType.dynamicKeyValue with maxCount: 5 pairs",
          inputType: InputType.dynamicKeyValue,
          maxCount: 5,
          id: GenericIdentifier(id: "keyvalue"),
          cancellable: true,
          isOptional: true,
        ),
        QuestionStep(
          title: "Avatar Upload",
          text: "InputType.avatar for circular profile picture",
          inputType: InputType.avatar,
          id: GenericIdentifier(id: "avatar"),
          cancellable: true,
          isOptional: true,
        ),
        QuestionStep(
          title: "Banner Upload",
          text: "InputType.banner for rectangular banner image",
          inputType: InputType.banner,
          id: GenericIdentifier(id: "banner"),
          cancellable: true,
          isOptional: true,
        ),

        CompletionStep(
          id: GenericIdentifier(id: "done"),
          title: "All Done!",
          text: "You explored all 20 input types",
          onFinish: (result) {
            debugPrint("All inputs result: $result");
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 2. STYLES & DISPLAY SIZES DEMO
// ---------------------------------------------------------------------------
class StylesAndDisplayDemo extends FormDemoScreen {
  const StylesAndDisplayDemo({super.key});

  @override
  State<StylesAndDisplayDemo> createState() => _StylesAndDisplayDemoState();
}

class _StylesAndDisplayDemoState
    extends FormDemoScreenState<StylesAndDisplayDemo> {
  @override
  String get formName => "styles";

  @override
  void buildForm(BuildContext context) {
    FormStack.api().form(
      name: formName,
      initialLocation: LocationWrapper(0, 0),
      mapKey: MapKey("", "", ""),
      steps: [
        InstructionStep(
          id: GenericIdentifier(id: "intro"),
          title: "Styles & Display Sizes",
          text:
              "See InputStyle, ComponentsStyle, Display size, and UIStyle in action",
          cancellable: false,
          display: Display.medium,
        ),

        // InputStyle variants
        QuestionStep(
          title: "InputStyle.basic",
          text: "No border, flat background",
          inputType: InputType.text,
          inputStyle: InputStyle.basic,
          hint: "Basic style input",
          id: GenericIdentifier(id: "style_basic"),
          cancellable: true,
        ),
        QuestionStep(
          title: "InputStyle.outline",
          text: "Full border around the field",
          inputType: InputType.text,
          inputStyle: InputStyle.outline,
          hint: "Outline style input",
          id: GenericIdentifier(id: "style_outline"),
          cancellable: true,
        ),
        QuestionStep(
          title: "InputStyle.underLined",
          text: "Bottom border only",
          inputType: InputType.text,
          inputStyle: InputStyle.underLined,
          hint: "Underlined style input",
          id: GenericIdentifier(id: "style_underlined"),
          cancellable: true,
        ),

        // ComponentsStyle variants
        QuestionStep(
          title: "ComponentsStyle.minimal",
          text: "Clean minimal list design",
          inputType: InputType.singleChoice,
          componentsStyle: ComponentsStyle.minimal,
          selectionType: SelectionType.tick,
          options: [
            Options("a", "Minimal Option A"),
            Options("b", "Minimal Option B"),
          ],
          id: GenericIdentifier(id: "comp_minimal"),
          cancellable: true,
        ),
        QuestionStep(
          title: "ComponentsStyle.basic",
          text: "Card-style list with rounded corners",
          inputType: InputType.singleChoice,
          componentsStyle: ComponentsStyle.basic,
          selectionType: SelectionType.tick,
          options: [
            Options("a", "Basic Option A"),
            Options("b", "Basic Option B"),
          ],
          id: GenericIdentifier(id: "comp_basic"),
          cancellable: true,
        ),

        // Display sizes
        QuestionStep(
          title: "Display.small",
          text: "Compact text for dense layouts",
          inputType: InputType.text,
          display: Display.small,
          inputStyle: InputStyle.outline,
          id: GenericIdentifier(id: "disp_small"),
          cancellable: true,
          isOptional: true,
        ),
        QuestionStep(
          title: "Display.normal",
          text: "Standard size for most use cases",
          inputType: InputType.text,
          display: Display.normal,
          inputStyle: InputStyle.outline,
          id: GenericIdentifier(id: "disp_normal"),
          cancellable: true,
          isOptional: true,
        ),
        QuestionStep(
          title: "Display.medium",
          text: "Larger headings for emphasis",
          inputType: InputType.text,
          display: Display.medium,
          inputStyle: InputStyle.outline,
          id: GenericIdentifier(id: "disp_medium"),
          cancellable: true,
          isOptional: true,
        ),
        QuestionStep(
          title: "Display.large",
          text: "Big text for hero sections",
          inputType: InputType.text,
          display: Display.large,
          inputStyle: InputStyle.outline,
          id: GenericIdentifier(id: "disp_large"),
          cancellable: true,
          isOptional: true,
        ),
        QuestionStep(
          title: "Display.extraLarge",
          text: "Maximum size for splash screens",
          inputType: InputType.text,
          display: Display.extraLarge,
          inputStyle: InputStyle.outline,
          id: GenericIdentifier(id: "disp_xlarge"),
          cancellable: true,
          isOptional: true,
        ),

        // Custom UIStyle
        QuestionStep(
          title: "Custom UIStyle",
          text: "Custom colors, border radius, and padding via UIStyle",
          inputType: InputType.text,
          inputStyle: InputStyle.outline,
          style: UIStyle(
            const Color(0xFF1B5E20),
            Colors.white,
            const Color(0xFF1B5E20),
            12.0,
            24.0,
          ),
          id: GenericIdentifier(id: "custom_style"),
          cancellable: true,
          isOptional: true,
          nextButtonText: "Styled Button",
        ),

        CompletionStep(
          id: GenericIdentifier(id: "done"),
          title: "Styles Demo Complete",
          text: "You explored all styling options",
          onFinish: (result) => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 3. SELECTION TYPES DEMO
// ---------------------------------------------------------------------------
class SelectionTypesDemo extends FormDemoScreen {
  const SelectionTypesDemo({super.key});

  @override
  State<SelectionTypesDemo> createState() => _SelectionTypesDemoState();
}

class _SelectionTypesDemoState
    extends FormDemoScreenState<SelectionTypesDemo> {
  @override
  String get formName => "selections";

  @override
  void buildForm(BuildContext context) {
    final options = [
      Options("pizza", "Pizza", subTitle: "Classic Italian"),
      Options("sushi", "Sushi", subTitle: "Japanese delicacy"),
      Options("tacos", "Tacos", subTitle: "Mexican favorite"),
      Options("curry", "Curry", subTitle: "Indian comfort food"),
    ];

    FormStack.api().form(
      name: formName,
      initialLocation: LocationWrapper(0, 0),
      mapKey: MapKey("", "", ""),
      steps: [
        InstructionStep(
          id: GenericIdentifier(id: "intro"),
          title: "Selection Types",
          text: "Four ways to display choice options",
          cancellable: false,
          display: Display.medium,
        ),
        QuestionStep(
          title: "Arrow Selection",
          text:
              "SelectionType.arrow - navigation arrows, ideal for drill-down menus",
          inputType: InputType.singleChoice,
          selectionType: SelectionType.arrow,
          autoTrigger: true,
          options: options,
          id: GenericIdentifier(id: "arrow"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Tick Selection",
          text:
              "SelectionType.tick - checkmark indicator, classic single-select",
          inputType: InputType.singleChoice,
          selectionType: SelectionType.tick,
          componentsStyle: ComponentsStyle.basic,
          options: options,
          id: GenericIdentifier(id: "tick"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Toggle Selection",
          text:
              "SelectionType.toggle - switch style, great for multi-select settings",
          inputType: InputType.multipleChoice,
          selectionType: SelectionType.toggle,
          options: options,
          id: GenericIdentifier(id: "toggle"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Dropdown Selection",
          text:
              "InputType.dropdown - traditional dropdown menu, saves vertical space",
          inputType: InputType.dropdown,
          componentsStyle: ComponentsStyle.basic,
          options: options,
          id: GenericIdentifier(id: "dropdown"),
          cancellable: true,
        ),
        CompletionStep(
          id: GenericIdentifier(id: "done"),
          title: "Selection Demo Complete",
          text: "All four selection styles demonstrated",
          onFinish: (result) => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 4. VALIDATION DEMO
// ---------------------------------------------------------------------------
class ValidationDemo extends FormDemoScreen {
  const ValidationDemo({super.key});

  @override
  State<ValidationDemo> createState() => _ValidationDemoState();
}

class _ValidationDemoState extends FormDemoScreenState<ValidationDemo> {
  @override
  String get formName => "validation";

  @override
  void buildForm(BuildContext context) {
    FormStack.api().form(
      name: formName,
      initialLocation: LocationWrapper(0, 0),
      mapKey: MapKey("", "", ""),
      steps: [
        InstructionStep(
          id: GenericIdentifier(id: "intro"),
          title: "Validation Demo",
          text: "FormStack supports 19+ built-in validators and custom ones",
          cancellable: false,
          display: Display.medium,
        ),
        QuestionStep(
          title: "Email Validation",
          text: "ResultFormat.email - validates email format with regex",
          inputType: InputType.email,
          inputStyle: InputStyle.outline,
          resultFormat:
              ResultFormat.email("Please enter a valid email address"),
          id: GenericIdentifier(id: "v_email"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Password Validation",
          text:
              "ResultFormat.password - requires uppercase, lowercase, number, special char, 8+ chars",
          inputType: InputType.password,
          inputStyle: InputStyle.outline,
          resultFormat: ResultFormat.password(
              "Must include A-Z, a-z, 0-9, special char"),
          id: GenericIdentifier(id: "v_password"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Phone Validation",
          text: "ResultFormat.phone - validates international phone format",
          inputType: InputType.number,
          inputStyle: InputStyle.outline,
          resultFormat:
              ResultFormat.phone("Enter valid phone (e.g. +1234567890)"),
          hint: "+1234567890",
          id: GenericIdentifier(id: "v_phone"),
          cancellable: true,
        ),
        QuestionStep(
          title: "URL Validation",
          text: "ResultFormat.url - validates web URLs",
          inputType: InputType.text,
          inputStyle: InputStyle.outline,
          resultFormat:
              ResultFormat.url("Enter a valid URL (https://example.com)"),
          hint: "https://example.com",
          id: GenericIdentifier(id: "v_url"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Age Validation",
          text: "ResultFormat.age - validates age between 0-150",
          inputType: InputType.number,
          inputStyle: InputStyle.outline,
          resultFormat: ResultFormat.age("Enter a valid age (0-150)"),
          hint: "25",
          id: GenericIdentifier(id: "v_age"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Percentage Validation",
          text: "ResultFormat.percentage - validates 0-100",
          inputType: InputType.number,
          inputStyle: InputStyle.outline,
          resultFormat:
              ResultFormat.percentage("Enter a valid percentage (0-100)"),
          hint: "85",
          id: GenericIdentifier(id: "v_percentage"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Zip Code Validation",
          text: "ResultFormat.zipCode - validates US zip codes",
          inputType: InputType.number,
          inputStyle: InputStyle.outline,
          resultFormat:
              ResultFormat.zipCode("Enter a valid zip code (e.g. 90210)"),
          hint: "90210",
          id: GenericIdentifier(id: "v_zip"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Custom Validation",
          text:
              "ResultFormat.custom - custom function: must start with 'hello'",
          inputType: InputType.text,
          inputStyle: InputStyle.outline,
          resultFormat: ResultFormat.custom(
            "Text must start with 'hello'",
            (input) => input.toLowerCase().startsWith('hello'),
          ),
          hint: "hello world",
          id: GenericIdentifier(id: "v_custom"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Optional Field",
          text: "isOptional: true - this field can be skipped",
          inputType: InputType.text,
          inputStyle: InputStyle.outline,
          isOptional: true,
          hint: "You can skip this",
          id: GenericIdentifier(id: "v_optional"),
          cancellable: true,
        ),
        CompletionStep(
          id: GenericIdentifier(id: "done"),
          title: "Validation Complete",
          text: "All validators demonstrated successfully",
          onFinish: (result) => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 5. CONDITIONAL NAVIGATION DEMO
// ---------------------------------------------------------------------------
class ConditionalNavDemo extends FormDemoScreen {
  const ConditionalNavDemo({super.key});

  @override
  State<ConditionalNavDemo> createState() => _ConditionalNavDemoState();
}

class _ConditionalNavDemoState
    extends FormDemoScreenState<ConditionalNavDemo> {
  @override
  String get formName => "cond_main";

  @override
  void buildForm(BuildContext context) {
    FormStack.api().form(
      name: formName,
      initialLocation: LocationWrapper(0, 0),
      mapKey: MapKey("", "", ""),
      steps: [
        InstructionStep(
          id: GenericIdentifier(id: "intro"),
          title: "Conditional Navigation",
          text:
              "Your choice determines which question comes next. Try different paths!",
          cancellable: false,
          display: Display.medium,
        ),
        QuestionStep(
          title: "What do you do?",
          text: "Select your role to see role-specific questions",
          inputType: InputType.singleChoice,
          selectionType: SelectionType.arrow,
          autoTrigger: true,
          options: [
            Options("developer", "Developer",
                subTitle: "Software engineering"),
            Options("designer", "Designer",
                subTitle: "UI/UX and visual design"),
            Options("manager", "Manager",
                subTitle: "Project management"),
          ],
          id: GenericIdentifier(id: "role"),
          cancellable: true,
          relevantConditions: [
            ExpressionRelevant(
              identifier: GenericIdentifier(id: "dev_q"),
              expression: "IN developer",
            ),
            ExpressionRelevant(
              identifier: GenericIdentifier(id: "design_q"),
              expression: "IN designer",
            ),
            ExpressionRelevant(
              identifier: GenericIdentifier(id: "mgr_q"),
              expression: "IN manager",
            ),
          ],
        ),

        // Developer path
        QuestionStep(
          title: "Favorite Language?",
          text:
              "You selected Developer - this question is developer-specific",
          inputType: InputType.singleChoice,
          selectionType: SelectionType.tick,
          componentsStyle: ComponentsStyle.basic,
          options: [
            Options("dart", "Dart"),
            Options("kotlin", "Kotlin"),
            Options("swift", "Swift"),
            Options("rust", "Rust"),
          ],
          id: GenericIdentifier(id: "dev_q"),
          cancellable: true,
          relevantConditions: [
            ExpressionRelevant(
              identifier: GenericIdentifier(id: "summary"),
              expression: "FOR_ALL",
            ),
          ],
        ),

        // Designer path
        QuestionStep(
          title: "Favorite Tool?",
          text:
              "You selected Designer - this question is designer-specific",
          inputType: InputType.singleChoice,
          selectionType: SelectionType.tick,
          componentsStyle: ComponentsStyle.basic,
          options: [
            Options("figma", "Figma"),
            Options("sketch", "Sketch"),
            Options("xd", "Adobe XD"),
          ],
          id: GenericIdentifier(id: "design_q"),
          cancellable: true,
          relevantConditions: [
            ExpressionRelevant(
              identifier: GenericIdentifier(id: "summary"),
              expression: "FOR_ALL",
            ),
          ],
        ),

        // Manager path
        QuestionStep(
          title: "Team Size?",
          text:
              "You selected Manager - this question is manager-specific",
          inputType: InputType.singleChoice,
          selectionType: SelectionType.tick,
          componentsStyle: ComponentsStyle.basic,
          options: [
            Options("small", "1-5 people"),
            Options("medium", "6-15 people"),
            Options("large", "16+ people"),
          ],
          id: GenericIdentifier(id: "mgr_q"),
          cancellable: true,
          relevantConditions: [
            ExpressionRelevant(
              identifier: GenericIdentifier(id: "summary"),
              expression: "FOR_ALL",
            ),
          ],
        ),

        // All paths converge
        QuestionStep(
          title: "Any feedback?",
          text:
              "All paths converge here - this step is shown regardless of role",
          inputType: InputType.text,
          inputStyle: InputStyle.outline,
          isOptional: true,
          id: GenericIdentifier(id: "summary"),
          cancellable: true,
        ),

        CompletionStep(
          id: GenericIdentifier(id: "done"),
          title: "Navigation Demo Complete",
          text: "You experienced conditional form routing",
          onFinish: (result) {
            debugPrint("Conditional nav result: $result");
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 6. NESTED STEPS DEMO
// ---------------------------------------------------------------------------
class NestedStepsDemo extends FormDemoScreen {
  const NestedStepsDemo({super.key});

  @override
  State<NestedStepsDemo> createState() => _NestedStepsDemoState();
}

class _NestedStepsDemoState extends FormDemoScreenState<NestedStepsDemo> {
  @override
  String get formName => "nested";

  @override
  void buildForm(BuildContext context) {
    FormStack.api().form(
      name: formName,
      initialLocation: LocationWrapper(0, 0),
      mapKey: MapKey("", "", ""),
      steps: [
        InstructionStep(
          id: GenericIdentifier(id: "intro"),
          title: "Nested Steps",
          text:
              "Multiple fields on one screen using NestedStep. All fields validate together.",
          cancellable: false,
          display: Display.medium,
        ),
        NestedStep(
          id: GenericIdentifier(id: "personal_info"),
          title: "Personal Information",
          text: "Fill in all fields below",
          verticalPadding: 10,
          validationExpression: "",
          cancellable: true,
          steps: [
            QuestionStep(
              title: "",
              inputType: InputType.name,
              inputStyle: InputStyle.outline,
              label: "First Name",
              id: GenericIdentifier(id: "first_name"),
              width: 400,
            ),
            QuestionStep(
              title: "",
              inputType: InputType.name,
              inputStyle: InputStyle.outline,
              label: "Last Name",
              id: GenericIdentifier(id: "last_name"),
              width: 400,
            ),
            QuestionStep(
              title: "",
              inputType: InputType.email,
              inputStyle: InputStyle.outline,
              label: "Email",
              id: GenericIdentifier(id: "nested_email"),
              width: 400,
            ),
            QuestionStep(
              title: "",
              inputType: InputType.number,
              inputStyle: InputStyle.outline,
              label: "Phone",
              id: GenericIdentifier(id: "nested_phone"),
              width: 400,
              isOptional: true,
            ),
          ],
        ),
        NestedStep(
          id: GenericIdentifier(id: "address_info"),
          title: "Address",
          text: "Enter your mailing address",
          verticalPadding: 10,
          validationExpression: "",
          cancellable: true,
          steps: [
            QuestionStep(
              title: "",
              inputType: InputType.text,
              inputStyle: InputStyle.outline,
              label: "Street Address",
              id: GenericIdentifier(id: "street"),
              width: 400,
            ),
            QuestionStep(
              title: "",
              inputType: InputType.text,
              inputStyle: InputStyle.outline,
              label: "City",
              id: GenericIdentifier(id: "city"),
              width: 400,
            ),
            QuestionStep(
              title: "",
              inputType: InputType.number,
              inputStyle: InputStyle.outline,
              label: "Zip Code",
              id: GenericIdentifier(id: "zip"),
              width: 400,
            ),
          ],
        ),
        CompletionStep(
          id: GenericIdentifier(id: "done"),
          title: "Nested Demo Complete",
          text: "Multi-field forms submitted successfully",
          onFinish: (result) {
            debugPrint("Nested result: $result");
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 7. API FEATURES DEMO (Pre-fill, Errors, Callbacks, Progress)
// ---------------------------------------------------------------------------
class APIFeaturesDemo extends FormDemoScreen {
  const APIFeaturesDemo({super.key});

  @override
  State<APIFeaturesDemo> createState() => _APIFeaturesDemoState();
}

class _APIFeaturesDemoState extends FormDemoScreenState<APIFeaturesDemo> {
  @override
  String get formName => "api_features";

  @override
  void buildForm(BuildContext context) {
    FormStack.api().form(
      name: formName,
      initialLocation: LocationWrapper(0, 0),
      mapKey: MapKey("", "", ""),
      steps: [
        InstructionStep(
          id: GenericIdentifier(id: "intro"),
          title: "API Features Demo",
          text:
              "This demo shows setResult (pre-fill), setError, addCompletionCallback, and onBeforeFinish",
          cancellable: false,
          display: Display.medium,
        ),
        QuestionStep(
          title: "Pre-filled Email",
          text: "This field was pre-filled using FormStack.api().setResult()",
          inputType: InputType.email,
          inputStyle: InputStyle.outline,
          id: GenericIdentifier(id: "prefill_email"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Pre-filled Name",
          text: "This was also pre-filled from code",
          inputType: InputType.name,
          inputStyle: InputStyle.outline,
          id: GenericIdentifier(id: "prefill_name"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Field with Preset Error",
          text:
              "This field has a preset error via setError() - it shows on first load",
          inputType: InputType.text,
          inputStyle: InputStyle.outline,
          id: GenericIdentifier(id: "error_field"),
          cancellable: true,
        ),
        QuestionStep(
          title: "Rate this demo",
          text: "Your rating triggers the onBeforeFinish callback",
          inputType: InputType.smile,
          id: GenericIdentifier(id: "rating"),
          cancellable: true,
        ),
        CompletionStep(
          id: GenericIdentifier(id: "done"),
          title: "Processing...",
          text: "onBeforeFinish is running an async operation",
          autoTrigger: false,
        ),
      ],
    );

    // Pre-fill data
    FormStack.api().setResult(
      {"prefill_email": "demo@formstack.dev", "prefill_name": "John"},
      formName: formName,
    );

    // Set a preset error
    FormStack.api().setError(
      GenericIdentifier(id: "error_field"),
      "This error was set via API before the form loaded",
      formName: formName,
    );

    // Add completion callback with onBeforeFinish
    FormStack.api().addCompletionCallback(
      GenericIdentifier(id: "done"),
      formName: formName,
      onFinish: (result) {
        debugPrint("API Features result: $result");
        final stats = FormStack.api().getFormStats(name: formName);
        debugPrint("Form stats: $stats");
        Navigator.of(context).pop();
      },
      onBeforeFinishCallback: (result) async {
        debugPrint("onBeforeFinish - simulating API call...");
        await Future.delayed(const Duration(seconds: 2));
        debugPrint("onBeforeFinish - API call complete");
        return true;
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 8. SURVEY COMPONENTS DEMO (New industry-standard inputs)
// ---------------------------------------------------------------------------
class SurveyComponentsDemo extends FormDemoScreen {
  const SurveyComponentsDemo({super.key});

  @override
  State<SurveyComponentsDemo> createState() => _SurveyComponentsDemoState();
}

class _SurveyComponentsDemoState
    extends FormDemoScreenState<SurveyComponentsDemo> {
  @override
  String get formName => "survey";

  @override
  void buildForm(BuildContext context) {
    FormStack.api().form(
      name: formName,
      initialLocation: LocationWrapper(0, 0),
      mapKey: MapKey("", "", ""),
      steps: [
        InstructionStep(
          id: GenericIdentifier(id: "intro"),
          title: "Survey Components",
          text:
              "Industry-standard inputs: slider, rating, NPS, consent, signature, ranking, phone, currency",
          cancellable: false,
          display: Display.medium,
        ),

        // Slider
        QuestionStep(
          title: "Satisfaction Level",
          text: "InputType.slider with min: 0, max: 100, step: 5",
          inputType: InputType.slider,
          minValue: 0,
          maxValue: 100,
          stepValue: 5,
          id: GenericIdentifier(id: "slider"),
          cancellable: true,
        ),

        // Star Rating
        QuestionStep(
          title: "Star Rating",
          text: "InputType.rating with ratingCount: 5 stars",
          inputType: InputType.rating,
          ratingCount: 5,
          id: GenericIdentifier(id: "rating"),
          cancellable: true,
        ),

        // NPS
        QuestionStep(
          title: "Net Promoter Score",
          text:
              "InputType.nps - How likely are you to recommend us? (0-10 scale)",
          inputType: InputType.nps,
          id: GenericIdentifier(id: "nps"),
          cancellable: true,
        ),

        // Phone
        QuestionStep(
          title: "Phone Number",
          text:
              "InputType.phone with country code picker (phoneCountryCode: +91)",
          inputType: InputType.phone,
          phoneCountryCode: "+91",
          id: GenericIdentifier(id: "phone"),
          cancellable: true,
        ),

        // Currency
        QuestionStep(
          title: "Budget Amount",
          text: "InputType.currency with currencySymbol: \$",
          inputType: InputType.currency,
          currencySymbol: "\$",
          id: GenericIdentifier(id: "currency"),
          cancellable: true,
        ),

        // Ranking
        QuestionStep(
          title: "Priority Ranking",
          text: "InputType.ranking - drag to reorder items by priority",
          inputType: InputType.ranking,
          options: [
            Options("perf", "Performance", subTitle: "Speed and efficiency"),
            Options("security", "Security", subTitle: "Data protection"),
            Options("ux", "User Experience", subTitle: "Design and usability"),
            Options("cost", "Cost", subTitle: "Budget and pricing"),
          ],
          id: GenericIdentifier(id: "ranking"),
          cancellable: true,
        ),

        // Consent
        QuestionStep(
          title: "Terms & Conditions",
          text: "InputType.consent - required checkbox agreement",
          inputType: InputType.consent,
          consentText:
              "I agree to the Terms of Service and Privacy Policy. I understand my data will be processed in accordance with applicable regulations.",
          id: GenericIdentifier(id: "consent"),
          cancellable: true,
        ),

        // Signature
        QuestionStep(
          title: "Digital Signature",
          text: "InputType.signature - draw your signature below",
          inputType: InputType.signature,
          id: GenericIdentifier(id: "signature"),
          cancellable: true,
        ),

        CompletionStep(
          id: GenericIdentifier(id: "done"),
          title: "Survey Complete",
          text: "All new survey components demonstrated",
          onFinish: (result) {
            debugPrint("Survey result: $result");
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 9. JSON LOAD DEMO
// ---------------------------------------------------------------------------
class JSONLoadDemo extends StatefulWidget {
  const JSONLoadDemo({super.key});

  @override
  State<JSONLoadDemo> createState() => _JSONLoadDemoState();
}

class _JSONLoadDemoState extends State<JSONLoadDemo> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadForms();
  }

  Future<void> _loadForms() async {
    FormStack.clearForms();
    await FormStack.api().loadFromAssets(
      ['assets/app.json', 'assets/full.json'],
      mapKey: MapKey("", "", ""),
      initialLocation: LocationWrapper(0, 0),
    );

    FormStack.api().addCompletionCallback(
      GenericIdentifier(id: "IS_COMPLETED"),
      onFinish: (result) {
        debugPrint("JSON form result: $result");
        if (mounted) Navigator.of(context).pop();
      },
      onBeforeFinishCallback: (result) async => true,
    );

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Loading JSON Forms...")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(body: FormStack.api().render());
  }
}
