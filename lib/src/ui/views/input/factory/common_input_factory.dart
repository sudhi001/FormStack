import 'package:formstack/formstack.dart';
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
}
