import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

// ignore: must_be_immutable
class SignatureInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;

  SignatureInputWidgetView(
    super.formStackForm,
    super.formStep,
    super.text,
    this.resultFormat, {
    super.key,
    super.title,
  });

  final List<List<Offset>> _strokes = [];
  String? _signatureBase64;
  bool _restored = false;

  /// Recovers a previously captured signature from the step.
  ///
  /// Only the rendered PNG is stored, not the strokes, so returning to this
  /// step shows the captured image rather than a redrawn path. Without this
  /// the signature was silently lost whenever the view was rebuilt.
  void _restore() {
    if (_restored) return;
    _restored = true;
    final saved = formStep.result;
    if (saved is String && saved.isNotEmpty) _signatureBase64 = saved;
  }

  /// The signature captured before this view was built, if any.
  String? get previousSignature => _strokes.isEmpty ? _signatureBase64 : null;

  /// Decoded form of [previousSignature], held so the build path does not
  /// decode on every frame and hand [Image.memory] a fresh cache key.
  Uint8List? _previousBytes;

  Uint8List? get _previousImage {
    final encoded = previousSignature;
    if (encoded == null) return null;
    return _previousBytes ??= base64Decode(encoded);
  }

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    _restore();
    return Container(
      // No maxHeight: the pad (150) plus its spacing and Clear button needs
      // ~206px, so a 200px cap overflowed by 6px on every build. The step
      // content already scrolls, so the column is free to size itself.
      constraints: const BoxConstraints(
        minWidth: 300,
        maxWidth: 500,
        minHeight: 150,
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: FormStackTheme.borderColor(context),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: FormStackTheme.canvasBackgroundColor(context),
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
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // A signature restored from the step is shown as the
                        // captured image: only the PNG is stored, not the
                        // strokes that produced it.
                        if (_previousImage != null)
                          Image.memory(
                            _previousImage!,
                            fit: BoxFit.contain,
                            // A stored signature can be truncated or not an
                            // image at all; show an empty pad rather than
                            // failing the whole step.
                            errorBuilder: (context, error, stack) =>
                                const SizedBox.shrink(),
                          ),
                        CustomPaint(
                          painter: _SignaturePainter(
                            _strokes,
                            FormStackTheme.canvasStrokeColor(context),
                          ),
                          size: Size.infinite,
                        ),
                      ],
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
                            _previousBytes = null;
                            formStep.result = null;
                          });
                        },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text("Clear"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _captureSignature() async {
    if (_strokes.isEmpty) return;
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final painter = _SignaturePainter(_strokes, Colors.black);
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
  final Color strokeColor;
  _SignaturePainter(this.strokes, this.strokeColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
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
