import 'dart:convert';

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
  ImageInputWidgetView(
    this.circular,
    super.formStackForm,
    super.formStep,
    super.text,
    this.resultFormat, {
    super.key,
    super.title,
  });

  final FocusNode _focusNode = FocusNode();
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

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          constraints: BoxConstraints(
            minWidth: circular ? 150 : 250,
            maxWidth: circular ? 160 : 450,
            maxHeight: circular ? 200 : 200,
          ),
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
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.white,
                        radius: 65,
                        child: _buildCircleImage(),
                      ),
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 0.5,
                            color: Colors.grey,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: _buildSquareImage(),
                    ),
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
                        spreadRadius: 1,
                      ),
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
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void suffixButtonClick(StateSetter setState) async {
    try {
      final hasFilter = !(formStep.filter?.isEmpty ?? true);
      final file = hasFilter
          ? await FilePicker.pickFile(
              type: FileType.custom,
              allowedExtensions: formStep.filter!
                  .map((item) => item as String)
                  .toList(),
            )
          : await FilePicker.pickFile();
      if (file == null) return;

      // readAsBytes is implemented on every platform, so this no longer needs
      // to branch on kIsWeb and reach for dart:io on native.
      _value = await _bytesToBase64String(await file.readAsBytes());
      formStep.result = _value;
      setState(() {});
    } catch (e, stack) {
      // A cancelled or failed pick must not take the form down with it.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: e,
          stack: stack,
          library: 'formstack',
          context: ErrorDescription(
            'picking an image for step ${formStep.id?.id}',
          ),
        ),
      );
    }
  }

  Future<String> _bytesToBase64String(List<int> fileBytes) async {
    try {
      final String base64String = base64Encode(fileBytes);
      return base64String;
    } catch (e) {
      debugPrint('formstack: failed to base64-encode picked image: $e');
      rethrow;
    }
  }

  /// The most recently decoded image, keyed by the base64 it came from.
  ///
  /// [Image.memory] keys its cache entry on the `Uint8List` instance, so
  /// decoding afresh on every build produced a new key each time: Flutter
  /// re-decoded the image, cached it again, and evicted other entries. Holding
  /// the decoded bytes keeps one cache entry per image.
  String? _decodedFrom;
  Uint8List? _decodedBytes;

  Uint8List _dataFromBase64String(String base64String) {
    if (_decodedFrom == base64String && _decodedBytes != null) {
      return _decodedBytes!;
    }
    try {
      _decodedFrom = base64String;
      return _decodedBytes = base64Decode(base64String);
    } catch (e) {
      debugPrint('formstack: failed to decode base64 image: $e');
      _decodedFrom = null;
      return _decodedBytes = Uint8List(0);
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
    _decodedBytes = null;
    _decodedFrom = null;
    _value = null;
    super.dispose();
  }

  // The picked file is base64-encoded into [_value] as soon as it is chosen,
  // so preview always renders from [_value]; there is no separate
  // just-picked-file branch to keep in sync.
  Widget _buildSquareImage() {
    return _value != null
        ? Image.memory(
            _dataFromBase64String(_value!),
            errorBuilder: (context, error, stack) => const SizedBox.shrink(),
            width: 400,
            height: 150,
            fit: BoxFit.cover,
            cacheWidth: 800,
            cacheHeight: 300,
          )
        : Lottie.asset(
            'packages/formstack/assets/lottiefiles/placeholder.json',
            height: 150,
            width: 400,
            fit: BoxFit.fitHeight,
          );
  }

  Widget _buildCircleImage() {
    return _value != null
        ? ClipOval(
            child: Image.memory(
              _dataFromBase64String(_value!),
              errorBuilder: (context, error, stack) => const SizedBox.shrink(),
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              cacheWidth: 300,
              cacheHeight: 300,
            ),
          )
        : ClipOval(
            child: Lottie.asset(
              'packages/formstack/assets/lottiefiles/placeholder.json',
              height: 150,
              width: 150,
              fit: BoxFit.fitHeight,
            ),
          );
  }
}
