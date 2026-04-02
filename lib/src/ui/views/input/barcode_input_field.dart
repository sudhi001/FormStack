import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formstack/formstack.dart';

/// Barcode/QR code input field.
/// Shows a text field with a scan button. On platforms with camera access,
/// the scan button opens a scanner. The scanned value populates the field.
///
/// Note: Actual camera scanning requires the `mobile_scanner` package
/// to be added by the consuming app. This widget provides the UI scaffold
/// and falls back to manual text entry.
// ignore: must_be_immutable
class BarcodeInputWidgetView extends BaseStepView<QuestionStep> {
  final ResultFormat resultFormat;

  BarcodeInputWidgetView(
      super.formStackForm, super.formStep, super.text, this.resultFormat,
      {super.key, super.title});

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasRestoredResult = false;

  @override
  Widget buildWInputWidget(BuildContext context, QuestionStep formStep) {
    if (!_hasRestoredResult) {
      _hasRestoredResult = true;
      if (formStep.result is String) {
        _controller.text = formStep.result as String;
      }
    }

    return Container(
      constraints: BoxConstraints(minWidth: 200, maxWidth: 500),
      child: StatefulBuilder(builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Scan button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: formStep.disabled
                    ? null
                    : () {
                        _showScanDialog(context, setState);
                      },
                icon: const Icon(Icons.qr_code_scanner, size: 28),
                label: Text(
                    _controller.text.isEmpty ? "Tap to Scan" : "Scan Again"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Manual entry fallback
            TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !formStep.disabled,
              onChanged: (value) {
                formStep.result = value;
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z0-9\-._~:/?#\[\]@!$&()*+,;=%]')),
              ],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: formStep.hint ?? "Or enter code manually",
                labelText: formStep.label ?? "Barcode / QR Code",
                prefixIcon: const Icon(Icons.qr_code),
              ),
            ),
            if (_controller.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Scanned: ${_controller.text}",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.green.shade700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  void _showScanDialog(BuildContext context, StateSetter setState) {
    // Show a dialog prompting for manual entry or external scanner
    // In a real implementation, this would launch mobile_scanner
    showDialog(
      context: context,
      builder: (ctx) {
        final scanController = TextEditingController();
        return AlertDialog(
          title: const Text("Scan Barcode"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white54, size: 48),
                      SizedBox(height: 8),
                      Text("Camera scanner placeholder",
                          style:
                              TextStyle(color: Colors.white54, fontSize: 12)),
                      Text("Add mobile_scanner package for live scanning",
                          style:
                              TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: scanController,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Enter code manually",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                if (scanController.text.isNotEmpty) {
                  setState(() {
                    _controller.text = scanController.text;
                    formStep.result = scanController.text;
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  bool isValid() {
    if (formStep.isOptional ?? false) return true;
    return resultFormat.isValid(_controller.text);
  }

  @override
  String validationError() => resultFormat.error();

  @override
  void requestFocus() => _focusNode.requestFocus();

  @override
  dynamic resultValue() => _controller.text;

  @override
  void clearFocus() => _focusNode.unfocus();
}
