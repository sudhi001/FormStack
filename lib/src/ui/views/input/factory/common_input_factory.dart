import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/input/avatar_input_field.dart';
import 'package:formstack/src/ui/views/input/dynamic_key_value_field.dart';
import 'package:formstack/src/ui/views/input/htm_field.dart';
import 'package:formstack/src/ui/views/input/mapview_field.dart';
import 'package:formstack/src/ui/views/input/otp_input_field.dart';

/// Common or geric componets will add here (Later)
// ignore: must_be_immutable
class CommonInputWidget {
  static OTPInputWidgetView otp(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      int count) {
    return OTPInputWidgetView(formKitForm, questionStep, text, resultFormat,
        title: title, count: count);
  }

  static DynamicKeyValueWidgetView dynamicKeyValueField(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      int maxCount) {
    return DynamicKeyValueWidgetView(
        formKitForm, questionStep, text, resultFormat,
        title: title, maxCount: maxCount);
  }

  static MapWidgetView map(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title,
      double maxHeight) {
    return MapWidgetView(formKitForm, questionStep, text, resultFormat,
        title: title, maxHeight: maxHeight);
  }

  static ImageInputWidgetView avatar(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return ImageInputWidgetView(
        true, formKitForm, questionStep, text, resultFormat,
        title: title);
  }

  static HTMLWidgetView htmlWidget(
      QuestionStep questionStep,
      FormStackForm formKitForm,
      String? text,
      ResultFormat resultFormat,
      String? title) {
    return HTMLWidgetView(formKitForm, questionStep, text, resultFormat,
        title: title);
  }
}
