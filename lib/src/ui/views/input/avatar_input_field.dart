import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:formstack/src/result/result_format.dart';
import 'package:formstack/src/step/question_step.dart';
import 'package:formstack/src/ui/views/base_step_view.dart';
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class ImageInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;
  final bool circular;
  ImageInputWidgetView(this.circular, super.formKitForm, super.formStep,
      super.text, this.resultFormat,
      {super.key, super.title});

  final FocusNode _focusNode = FocusNode();
  FilePickerResult? fileResult;
  String? value;
  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (formStep.result != null) {
      value = formStep.result;
    }

    return StatefulBuilder(builder: (context, setState) {
      return Container(
          constraints: const BoxConstraints(
              minWidth: 150, maxWidth: 160, maxHeight: 200),
          child: Stack(
            children: [
              Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 0.5, color: Colors.grey, spreadRadius: 1)
                    ],
                  ),
                  child: CircleAvatar(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.white,
                      radius: 65,
                      child: (fileResult?.files.isNotEmpty ?? false)
                          ? ClipOval(
                              child: Image.file(
                                  File(fileResult!.files.first.path!),
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover))
                          : value != null
                              ? ClipOval(
                                  child: Image.memory(
                                      dataFromBase64String(value!),
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover))
                              : Lottie.asset(
                                  'packages/formstack/assets/lottiefiles/avatar.json',
                                  height: 200,
                                  fit: BoxFit.fill))),
              Positioned(
                  right: 0,
                  bottom: 7,
                  child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 0.5,
                              color: Colors.grey,
                              spreadRadius: 1)
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            suffixButtonClick(setState);
                          },
                        ),
                      )))
            ],
          ));
    });
  }

  void suffixButtonClick(setState) async {
    if (formStep.filter?.isEmpty ?? true) {
      fileResult = await FilePicker.platform.pickFiles();
    } else {
      fileResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions:
              formStep.filter?.map((item) => item as String).toList());
    }
    if (fileResult != null && fileResult!.files.isNotEmpty) {
      value = await fileToBase64String(File(fileResult!.files.first.path!));
    }
    setState(() {});
  }

  Future<String> fileToBase64String(File file) async {
    List<int> fileBytes = await file.readAsBytes();
    String base64String = base64Encode(fileBytes);
    return base64String;
  }

  Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) {
      return true;
    }
    return resultFormat.isValid(value);
  }

  @override
  String validationError() {
    _focusNode.requestFocus();
    return resultFormat.error();
  }

  @override
  void requestFocus() {
    _focusNode.requestFocus();
  }

  @override
  dynamic resultValue() {
    return value;
  }

  @override
  void clearFocus() {
    _focusNode.unfocus();
  }
}
