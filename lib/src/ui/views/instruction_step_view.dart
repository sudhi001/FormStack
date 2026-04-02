import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';

// ignore: must_be_immutable
class InstructionStepView extends BaseStepView<InstructionStep> {
  InstructionStepView(super.formStackForm, super.formStep, super.text,
      {super.key, super.title, cancellable});

  @override
  Widget? buildWInputWidget(BuildContext context, InstructionStep formStep) {
    final hasInstructions =
        formStep.instructions != null && formStep.instructions!.isNotEmpty;
    final hasVideo = formStep.videoUrl != null;

    if (!hasInstructions && !hasVideo) return null;

    return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasVideo) ...[
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_outline,
                          size: 48, color: Colors.white.withValues(alpha: 0.8)),
                      const SizedBox(height: 8),
                      Text("Video: ${formStep.videoUrl}",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (hasInstructions)
              ListView.builder(
                shrinkWrap: true,
                cacheExtent: 300,
                itemBuilder: (context, index) {
                  DynamicData instruction = formStep.instructions![index];
                  return Center(
                      child: ListTile(
                          title: Text(instruction.title),
                          trailing: instruction.trailing == null
                              ? null
                              : Text(instruction.trailing ?? ""),
                          leading: instruction.leading == null
                              ? null
                              : Text(instruction.leading ?? "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium),
                          subtitle: instruction.subTitle == null
                              ? null
                              : Text(instruction.subTitle ?? "")));
                },
                itemCount: formStep.instructions?.length ?? 0,
              ),
          ],
        ));
  }

  @override
  bool isValid() {
    return true;
  }

  @override
  String validationError() {
    return "";
  }

  @override
  resultValue() {
    return DateTime.now().toUtc();
  }

  @override
  void requestFocus() {}
  @override
  void clearFocus() {}
}
