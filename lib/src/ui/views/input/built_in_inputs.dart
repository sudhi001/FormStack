import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/factory/choice_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/common_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/date_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/smile_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/survey_input_factory.dart';
import 'package:formstack/src/ui/views/input/factory/text_input_factory.dart';

/// Registers the input widgets shipped with the library.
///
/// Every built-in resolves through [InputRegistry] exactly as an
/// application-defined input does. Before 3.0 they were dispatched by a
/// 35-arm `switch` inside [QuestionStep], which meant the built-ins and the
/// extension point had different shapes and only the latter could be
/// overridden uniformly.
///
/// Registration uses [InputRegistry.registerIfAbsent], so an application that
/// registers `'signature'` before the first form is built keeps its own
/// widget.
class BuiltInInputs {
  BuiltInInputs._();

  /// Registers every built-in input type that is not already registered.
  ///
  /// Called before each [QuestionStep] builds its view. Every call walks the
  /// full set rather than short-circuiting on a flag or a sentinel entry: a
  /// flag would go stale after [InputRegistry.reset], and a sentinel would be
  /// defeated by an application that happens to override that one type first.
  /// The walk is a few dozen map lookups against a cached view, which is not
  /// worth optimising away at the cost of being wrong.
  static void ensureRegistered() => _register(InputRegistry.instance);

  /// Resolves the validator for [step], defaulting to [fallback].
  ///
  /// Built-in defaults depend on the step — an OTP's length, a slider's range —
  /// so they are resolved here rather than through
  /// [InputRegistry.register]'s step-independent `defaultValidator`.
  static ResultFormat _validator(QuestionStep step, ResultFormat fallback) =>
      step.resultFormat ??= fallback;

  static void _register(InputRegistry r) {
    // --- Text ---
    r.registerIfAbsent(
      InputType.email.name,
      (c) => TextFieldWidgetView.email(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.email('Please enter a valid email.')),
        c.title,
      ),
    );
    r.registerIfAbsent(
      InputType.name.name,
      (c) => TextFieldWidgetView.name(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.name('Please enter a valid name.')),
        c.title,
      ),
    );
    r.registerIfAbsent(
      InputType.password.name,
      (c) => TextFieldWidgetView.password(
        c.step,
        c.form,
        c.text,
        _validator(
          c.step,
          ResultFormat.password('Please enter a valid password.'),
        ),
        c.title,
      ),
    );
    r.registerIfAbsent(
      InputType.text.name,
      (c) => TextFieldWidgetView.text(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.notBlank('Please enter a valid data.')),
        c.title,
        c.step.numberOfLines,
      ),
    );
    r.registerIfAbsent(
      InputType.number.name,
      (c) => TextFieldWidgetView.number(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.number('Please enter a valid number.')),
        c.title,
      ),
    );
    r.registerIfAbsent(
      InputType.file.name,
      (c) => TextFieldWidgetView.file(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.notNull('Please select a file.')),
        c.title,
        c.step.filter,
      ),
    );

    // --- Date and time ---
    r.registerIfAbsent(
      InputType.date.name,
      (c) => DateInputWidget.date(
        c.step,
        c.form,
        c.text,
        _validator(
          c.step,
          ResultFormat.date('Please enter a valid date.', 'dd-MM-yyyy'),
        ),
        c.title,
      ),
    );
    r.registerIfAbsent(
      InputType.time.name,
      (c) => DateInputWidget.time(
        c.step,
        c.form,
        c.text,
        _validator(
          c.step,
          ResultFormat.date('Please enter a valid time.', 'HH:mm:ss'),
        ),
        c.title,
      ),
    );
    r.registerIfAbsent(
      InputType.dateTime.name,
      (c) => DateInputWidget.dateTime(
        c.step,
        c.form,
        c.text,
        _validator(
          c.step,
          ResultFormat.date("Please enter a valid date.", "yyyy-MM-dd'T'HH:mm"),
        ),
        c.title,
      ),
    );

    // --- Choice ---
    r.registerIfAbsent(
      InputType.singleChoice.name,
      (c) => ChoiceInputWidget.single(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.singleChoice('Please select any.')),
        c.title,
        c.step.filteredOptions(c.form),
        c.step.selectionType ?? SelectionType.arrow,
        c.step.autoTrigger ?? false,
      ),
    );
    r.registerIfAbsent(
      InputType.dropdown.name,
      (c) => ChoiceInputWidget.dropdown(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.singleChoice('Please select any.')),
        c.title,
        c.step.filteredOptions(c.form),
        c.step.autoTrigger ?? false,
      ),
    );
    r.registerIfAbsent(
      InputType.multipleChoice.name,
      (c) => ChoiceInputWidget.multiple(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.multipleChoice('Please select any.')),
        c.title,
        c.step.selectionType ?? SelectionType.tick,
        c.step.filteredOptions(c.form),
      ),
    );
    r.registerIfAbsent(
      InputType.smile.name,
      (c) => SmileInputWidget.smile(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.smile('Please select.')),
        c.title,
      ),
    );
    r.registerIfAbsent(
      InputType.imageChoice.name,
      (c) => SurveyInputWidget.imageChoice(
        c.step,
        c.form,
        c.text,
        _validator(
          c.step,
          ResultFormat.singleChoice('Please select an option.'),
        ),
        c.title,
        c.step.options,
        true,
      ),
    );
    r.registerIfAbsent(
      InputType.ranking.name,
      (c) => SurveyInputWidget.ranking(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.notEmpty('Please rank the items.')),
        c.title,
        c.step.options,
      ),
    );
    r.registerIfAbsent(
      InputType.boolean.name,
      (c) => SurveyInputWidget.boolean(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.notNull('Please select Yes or No.')),
        c.title,
      ),
    );

    // --- Scales and survey instruments ---
    r.registerIfAbsent(
      InputType.slider.name,
      (c) => SurveyInputWidget.slider(
        c.step,
        c.form,
        c.text,
        _validator(
          c.step,
          ResultFormat.range(
            'Please select a value.',
            c.step.minValue ?? 0,
            c.step.maxValue ?? 100,
          ),
        ),
        c.title,
        c.step.minValue,
        c.step.maxValue,
        c.step.stepValue,
      ),
    );
    r.registerIfAbsent(
      InputType.rating.name,
      (c) => SurveyInputWidget.rating(
        c.step,
        c.form,
        c.text,
        _validator(
          c.step,
          ResultFormat.range(
            'Please select a rating.',
            1,
            c.step.ratingCount ?? 5,
          ),
        ),
        c.title,
        c.step.ratingCount,
      ),
    );
    r.registerIfAbsent(
      InputType.nps.name,
      (c) => SurveyInputWidget.nps(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.range('Please select a score.', 0, 10)),
        c.title,
      ),
    );
    r.registerIfAbsent(
      InputType.consent.name,
      (c) => SurveyInputWidget.consent(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.consent('You must agree to continue.')),
        c.title,
        c.step.consentText,
      ),
    );
    r.registerIfAbsent(
      InputType.signature.name,
      (c) => SurveyInputWidget.signature(
        c.step,
        c.form,
        c.text,
        _validator(
          c.step,
          ResultFormat.notNull('Please provide your signature.'),
        ),
        c.title,
      ),
    );

    // --- Formatted text ---
    r.registerIfAbsent(
      InputType.phone.name,
      (c) => SurveyInputWidget.phone(
        c.step,
        c.form,
        c.text,
        _validator(
          c.step,
          ResultFormat.phone('Please enter a valid phone number.'),
        ),
        c.title,
        c.step.phoneCountryCode,
      ),
    );
    r.registerIfAbsent(
      InputType.currency.name,
      (c) => SurveyInputWidget.currency(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.notBlank('Please enter an amount.')),
        c.title,
        c.step.currencySymbol,
      ),
    );
    r.registerIfAbsent(
      InputType.otp.name,
      (c) => CommonInputWidget.otp(
        c.step,
        c.form,
        c.text,
        _validator(
          c.step,
          ResultFormat.length('Please enter all fields', c.step.count),
        ),
        c.title,
        c.step.count,
      ),
    );

    // --- Composite and rich content ---
    r.registerIfAbsent(
      InputType.dynamicKeyValue.name,
      (c) => CommonInputWidget.dynamicKeyValueField(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.notEmpty('Please add any one')),
        c.title,
        c.step.maxCount,
      ),
    );
    r.registerIfAbsent(
      InputType.htmlEditor.name,
      (c) => CommonInputWidget.htmlWidget(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.notNull('Please enter any.')),
        c.title,
      ),
    );

    // --- Media ---
    r.registerIfAbsent(
      InputType.avatar.name,
      (c) => CommonInputWidget.avatar(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.notNull('Please update image.')),
        c.title,
      ),
    );
    r.registerIfAbsent(
      InputType.banner.name,
      (c) => CommonInputWidget.banner(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.notNull('Please update image.')),
        c.title,
      ),
    );
    r.registerIfAbsent(
      InputType.barcode.name,
      (c) => SurveyInputWidget.barcode(
        c.step,
        c.form,
        c.text,
        _validator(
          c.step,
          ResultFormat.notBlank('Please scan or enter a code.'),
        ),
        c.title,
      ),
    );
    r.registerIfAbsent(
      InputType.audio.name,
      (c) => SurveyInputWidget.audio(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.notNull('Please record audio.')),
        c.title,
      ),
    );

    // --- Data without a visible input ---
    r.registerIfAbsent(
      InputType.hidden.name,
      (c) => SurveyInputWidget.hidden(c.step, c.form, c.text, c.title),
    );
    r.registerIfAbsent(
      InputType.calculate.name,
      (c) => SurveyInputWidget.calculate(
        c.step,
        c.form,
        c.text,
        c.title,
        c.step.calculateCallback,
      ),
    );

    // --- Geography ---
    r.registerIfAbsent(
      InputType.mapLocation.name,
      (c) => CommonInputWidget.map(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.notNull('Please enter any.')),
        c.title,
        c.step.maxHeight ?? 600,
      ),
    );
    r.registerIfAbsent(
      InputType.geotrace.name,
      (c) => SurveyInputWidget.geotrace(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.notNull('Please trace a path.')),
        c.title,
      ),
    );
    r.registerIfAbsent(
      InputType.geoshape.name,
      (c) => SurveyInputWidget.geoshape(
        c.step,
        c.form,
        c.text,
        _validator(c.step, ResultFormat.notNull('Please draw a shape.')),
        c.title,
      ),
    );
  }
}
