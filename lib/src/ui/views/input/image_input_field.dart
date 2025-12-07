import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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
  FilePickerResult? _fileResult;
  String? _value;

  String? get value {
    if (formStep.result != null && formStep.result is String) {
      return formStep.result as String;
    }
    return _value;
  }

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    _value = value;

    return StatefulBuilder(builder: (context, setState) {
      return Container(
          constraints: BoxConstraints(
              minWidth: circular ? 150 : 250,
              maxWidth: circular ? 160 : 450,
              maxHeight: circular ? 200 : 200),
          child: Stack(
            children: [
              circular
                  ? Container(
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
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.white,
                          radius: 65,
                          child: _buildCircleImage()))
                  : Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 0.5,
                              color: Colors.grey,
                              spreadRadius: 1)
                        ],
                      ),
                      child: _buildSquareImage()),
              Positioned(
                  right: circular ? 0 : 7,
                  bottom: circular ? 7 : 7,
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

  void suffixButtonClick(StateSetter setState) async {
    try {
      if (formStep.filter?.isEmpty ?? true) {
        _fileResult = await FilePicker.platform.pickFiles();
      } else {
        _fileResult = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions:
                formStep.filter?.map((item) => item as String).toList());
      }
      if (_fileResult != null && _fileResult!.files.isNotEmpty) {
        final file = _fileResult!.files.first;
        if (kIsWeb) {
          final bytes = file.bytes;
          if (bytes != null) {
            _value = await _bytesToBase64String(bytes);
            formStep.result = _value;
          }
        } else {
          final path = file.path;
          if (path != null) {
            _value = await _fileToBase64String(File(path));
            formStep.result = _value;
          }
        }
        _fileResult = null;
      }
      setState(() {});
    } catch (e) {
      // Handle file picker errors gracefully
      if (kDebugMode) {
        print('Error picking file: $e');
      }
    }
  }

  Future<String> _bytesToBase64String(List<int> fileBytes) async {
    try {
      String base64String = base64Encode(fileBytes);
      return base64String;
    } catch (e) {
      if (kDebugMode) {
        print('Error encoding bytes to base64: $e');
      }
      rethrow;
    }
  }

  Future<String> _fileToBase64String(File file) async {
    try {
      List<int> fileBytes = await file.readAsBytes();
      return _bytesToBase64String(fileBytes);
    } catch (e) {
      if (kDebugMode) {
        print('Error reading file: $e');
      }
      rethrow;
    }
  }

  Uint8List _dataFromBase64String(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      if (kDebugMode) {
        print('Error decoding base64 string: $e');
      }
      return Uint8List(0);
    }
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) {
      return true;
    }
    return resultFormat.isValid(_value);
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
    return _value;
  }

  @override
  void clearFocus() {
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _fileResult = null;
    _value = null;
    super.dispose();
  }

  Widget _buildSquareImage() {
    return (_fileResult?.files.isNotEmpty ?? false)
        ? kIsWeb
            ? Image.memory(_fileResult!.files.first.bytes!,
                width: 400, height: 150, fit: BoxFit.cover)
            : Image.file(File(_fileResult!.files.first.path!),
                width: 400, height: 150, fit: BoxFit.cover)
        : _value != null
            ? Image.memory(_dataFromBase64String(_value!),
                width: 400, height: 150, fit: BoxFit.cover)
            : Lottie.asset(
                'packages/formstack/assets/lottiefiles/placeholder.json',
                height: 150,
                width: 400,
                fit: BoxFit.fitHeight);
  }

  Widget _buildCircleImage() {
    return (_fileResult?.files.isNotEmpty ?? false)
        ? kIsWeb
            ? ClipOval(
                child: Image.memory(_fileResult!.files.first.bytes!,
                    width: 150, height: 150, fit: BoxFit.cover))
            : ClipOval(
                child: Image.file(File(_fileResult!.files.first.path!),
                    width: 150, height: 150, fit: BoxFit.cover))
        : _value != null
            ? ClipOval(
                child: Image.memory(_dataFromBase64String(_value!),
                    width: 150, height: 150, fit: BoxFit.cover))
            : Lottie.asset('packages/formstack/assets/lottiefiles/avatar.json',
                height: 200, fit: BoxFit.fill);
  }
}
