import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/audio_input_field.dart';
import 'package:formstack/src/ui/views/input/barcode_input_field.dart';
import 'package:formstack/src/ui/views/input/boolean_input_field.dart';
import 'package:formstack/src/ui/views/input/calculate_input_field.dart';
import 'package:formstack/src/ui/views/input/hidden_input_field.dart';
import 'package:formstack/src/ui/views/input/image_choice_input_field.dart';
import 'package:formstack/src/ui/views/input/geotrace_input_field.dart';
import 'package:formstack/src/ui/views/input/slider_input_field.dart';
import 'package:formstack/src/ui/views/input/rating_input_field.dart';
import 'package:formstack/src/ui/views/input/nps_input_field.dart';
import 'package:formstack/src/ui/views/input/consent_input_field.dart';
import 'package:formstack/src/ui/views/input/signature_input_field.dart';
import 'package:formstack/src/ui/views/input/ranking_input_field.dart';
import 'package:formstack/src/ui/views/input/phone_input_field.dart';
import 'package:formstack/src/ui/views/input/currency_input_field.dart';

/// Factory for survey and industry-standard input widgets
class SurveyInputWidget {
  /// Create slider input with min/max/step values
  static SliderInputWidgetView slider(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      num? minValue,
      num? maxValue,
      num? stepValue) {
    return SliderInputWidgetView(
        formStackForm, questionStep, text, resultFormat,
        title: title,
        minValue: minValue ?? 0,
        maxValue: maxValue ?? 100,
        stepValue: stepValue ?? 1);
  }

  /// Create star rating input with configurable max rating
  static RatingInputWidgetView rating(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      int? maxRating) {
    return RatingInputWidgetView(
        formStackForm, questionStep, text, resultFormat,
        title: title, maxRating: maxRating ?? 5);
  }

  /// Create NPS (Net Promoter Score) 0-10 scale input
  static NPSInputWidgetView nps(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return NPSInputWidgetView(formStackForm, questionStep, text, resultFormat,
        title: title);
  }

  /// Create consent checkbox input
  static ConsentInputWidgetView consent(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      String? consentText) {
    return ConsentInputWidgetView(
        formStackForm, questionStep, text, resultFormat,
        title: title,
        consentText: consentText ?? "I agree to the terms and conditions");
  }

  /// Create signature drawing input
  static SignatureInputWidgetView signature(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return SignatureInputWidgetView(
        formStackForm, questionStep, text, resultFormat,
        title: title);
  }

  /// Create ranking/sortable list input
  static RankingInputWidgetView ranking(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      List<Options>? options) {
    return RankingInputWidgetView(
        formStackForm, questionStep, text, resultFormat,
        title: title, options: options ?? []);
  }

  /// Create phone number input with country code picker
  static PhoneInputWidgetView phone(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      String? countryCode) {
    return PhoneInputWidgetView(formStackForm, questionStep, text, resultFormat,
        title: title, defaultCountryCode: countryCode ?? "+1");
  }

  /// Create currency/money input with symbol prefix
  static CurrencyInputWidgetView currency(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      String? currencySymbol) {
    return CurrencyInputWidgetView(
        formStackForm, questionStep, text, resultFormat,
        title: title, currencySymbol: currencySymbol ?? "\$");
  }

  /// Create boolean Yes/No input
  static BooleanInputWidgetView boolean(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return BooleanInputWidgetView(
        formStackForm, questionStep, text, resultFormat,
        title: title);
  }

  /// Create image choice grid input
  static ImageChoiceInputWidgetView imageChoice(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      List<Options>? options,
      bool singleSelection) {
    return ImageChoiceInputWidgetView(
        formStackForm, questionStep, text, resultFormat,
        title: title, options: options ?? [], singleSelection: singleSelection);
  }

  /// Create hidden data field (no UI, auto-advances)
  static HiddenInputWidgetView hidden(QuestionStep questionStep,
      FormStackForm formStackForm, String? text, String? title) {
    return HiddenInputWidgetView(formStackForm, questionStep, text,
        title: title);
  }

  /// Create calculated field with auto-computed value
  static CalculateInputWidgetView calculate(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      String? title,
      dynamic Function(Map<String, dynamic>)? calculateCallback) {
    return CalculateInputWidgetView(formStackForm, questionStep, text,
        title: title, calculateCallback: calculateCallback);
  }

  /// Create barcode/QR code scanner input
  static BarcodeInputWidgetView barcode(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return BarcodeInputWidgetView(
        formStackForm, questionStep, text, resultFormat,
        title: title);
  }

  /// Create audio recording input
  static AudioInputWidgetView audio(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return AudioInputWidgetView(formStackForm, questionStep, text, resultFormat,
        title: title);
  }

  /// Create geotrace (path/line on map) input
  static GeotraceInputWidgetView geotrace(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return GeotraceInputWidgetView(
        formStackForm, questionStep, text, resultFormat,
        title: title, isPolygon: false);
  }

  /// Create geoshape (polygon on map) input
  static GeotraceInputWidgetView geoshape(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return GeotraceInputWidgetView(
        formStackForm, questionStep, text, resultFormat,
        title: title, isPolygon: true);
  }
}
