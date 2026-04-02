import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

// ignore: must_be_immutable
class SignatureInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;

  SignatureInputWidgetView(
      super.formStackForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title});

  final List<List<Offset>> _strokes = [];
  String? _signatureBase64;

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    return Container(
      constraints: const BoxConstraints(
          minWidth: 300, maxWidth: 500, minHeight: 150, maxHeight: 200),
      child: StatefulBuilder(builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GestureDetector(
                  onPanStart: formStep.disabled
                      ? null
                      : (details) {
                          setState(() {
                            _strokes.add([details.localPosition]);
                          });
                        },
                  onPanUpdate: formStep.disabled
                      ? null
                      : (details) {
                          setState(() {
                            if (_strokes.isNotEmpty) {
                              _strokes.last.add(details.localPosition);
                            }
                          });
                        },
                  onPanEnd: formStep.disabled
                      ? null
                      : (details) {
                          _captureSignature();
                        },
                  child: CustomPaint(
                    painter: _SignaturePainter(_strokes),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: formStep.disabled
                    ? null
                    : () {
                        setState(() {
                          _strokes.clear();
                          _signatureBase64 = null;
                          formStep.result = null;
                        });
                      },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text("Clear"),
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _captureSignature() async {
    if (_strokes.isEmpty) return;
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final painter = _SignaturePainter(_strokes);
      painter.paint(canvas, const Size(500, 150));
      final picture = recorder.endRecording();
      final image = await picture.toImage(500, 150);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        _signatureBase64 = base64Encode(byteData.buffer.asUint8List());
        formStep.result = _signatureBase64;
      }
    } catch (_) {
      // Signature capture may fail on some platforms
    }
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) return true;
    return resultFormat.isValid(_signatureBase64);
  }

  @override
  String validationError() => resultFormat.error();

  @override
  void requestFocus() {}

  @override
  dynamic resultValue() => _signatureBase64;

  @override
  void clearFocus() {}
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  _SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path();
      path.moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
