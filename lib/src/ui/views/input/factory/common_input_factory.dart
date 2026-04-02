import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/image_input_field.dart';
import 'package:formstack/src/ui/views/input/dynamic_key_value_field.dart';
import 'package:formstack/src/ui/views/input/html_input_field.dart';
import 'package:formstack/src/ui/views/input/map_input_field.dart';
import 'package:formstack/src/ui/views/input/otp_input_field.dart';

/// Common or generic components will be added here
// ignore: must_be_immutable
class CommonInputWidget {
  static OTPInputWidgetView otp(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      int count) {
    return OTPInputWidgetView(formStackForm, questionStep, text, resultFormat,
        title: title, count: count);
  }

  static DynamicKeyValueWidgetView dynamicKeyValueField(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      int maxCount) {
    return DynamicKeyValueWidgetView(
        formStackForm, questionStep, text, resultFormat,
        title: title, maxCount: maxCount);
  }

  static MapWidgetView map(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      double maxHeight) {
    return MapWidgetView(formStackForm, questionStep, text, resultFormat,
        title: title, maxHeight: maxHeight);
  }

  static ImageInputWidgetView banner(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return ImageInputWidgetView(
        false, formStackForm, questionStep, text, resultFormat,
        title: title);
  }

  static ImageInputWidgetView avatar(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return ImageInputWidgetView(
        true, formStackForm, questionStep, text, resultFormat,
        title: title);
  }

  static HTMLWidgetView htmlWidget(
      QuestionStep questionStep,
      FormStackForm formStackForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return HTMLWidgetView(formStackForm, questionStep, text, resultFormat,
        title: title);
  }
}
