import 'package:flutter/material.dart';
import 'package:formstack/formstack.dart';
import 'package:formstack/src/ui/views/consent_step_view.dart';
import 'package:formstack/src/utils/alignment.dart';

/// Predefined consent section types (modeled after Apple ResearchKit).
enum ConsentSectionType {
  /// Overview of the study or form purpose.
  overview,

  /// What data will be gathered.
  dataGathering,

  /// How privacy is handled.
  privacy,

  /// How the data will be used.
  dataUse,

  /// Expected time commitment.
  timeCommitment,

  /// Tasks the participant will be asked to perform.
  studyTasks,

  /// How to withdraw from the study.
  withdrawing,

  /// Custom section with user-defined content.
  custom,
}

/// A single section within a [ConsentStep] document.
class ConsentSection {
  /// The type of this section.
  final ConsentSectionType type;

  /// Title displayed for this section.
  final String title;

  /// Summary text shown in the visual walkthrough.
  final String summary;

  /// Full content shown when "Learn More" is tapped.
  final String? content;

  /// Optional icon for this section.
  final IconData? icon;

  /// Creates a [ConsentSection].
  ConsentSection({
    required this.type,
    required this.title,
    required this.summary,
    this.content,
    this.icon,
  });

  /// Creates a [ConsentSection] from a JSON map.
  factory ConsentSection.from(Map<String, dynamic> json) {
    return ConsentSection(
      type: ConsentSectionType.values.firstWhere((e) => e.name == json["type"],
          orElse: () => ConsentSectionType.custom),
      title: json["title"] ?? "",
      summary: json["summary"] ?? "",
      content: json["content"],
    );
  }

  /// Default icon for each section type.
  IconData get defaultIcon {
    switch (type) {
      case ConsentSectionType.overview:
        return Icons.info_outline;
      case ConsentSectionType.dataGathering:
        return Icons.storage_outlined;
      case ConsentSectionType.privacy:
        return Icons.shield_outlined;
      case ConsentSectionType.dataUse:
        return Icons.analytics_outlined;
      case ConsentSectionType.timeCommitment:
        return Icons.timer_outlined;
      case ConsentSectionType.studyTasks:
        return Icons.task_outlined;
      case ConsentSectionType.withdrawing:
        return Icons.exit_to_app_outlined;
      case ConsentSectionType.custom:
        return Icons.article_outlined;
    }
  }
}

/// A structured consent document step with visual section walkthrough.
///
/// Displays consent sections with icons, requires agreement checkbox,
/// and optionally collects a signature.
///
/// ```dart
/// ConsentStep(
///   id: GenericIdentifier(id: "consent"),
///   title: "Informed Consent",
///   text: "Please review and agree to participate",
///   requiresSignature: true,
///   sections: [
///     ConsentSection(
///       type: ConsentSectionType.overview,
///       title: "About This Study",
///       summary: "This study examines...",
///       content: "Full details about the study...",
///     ),
///     ConsentSection(
///       type: ConsentSectionType.privacy,
///       title: "Your Privacy",
///       summary: "Your data is encrypted and anonymized.",
///     ),
///   ],
/// )
/// ```
class ConsentStep extends FormStep {
  static const String tag = "ConsentStep";

  /// The sections that make up this consent document.
  final List<ConsentSection> sections;

  /// Whether a signature is required.
  final bool requiresSignature;

  /// Agreement text displayed next to the checkbox.
  final String agreementText;

  Function(Map<String, dynamic>)? onFinish;

  /// Creates a [ConsentStep].
  ConsentStep({
    super.id,
    super.title = "Consent",
    super.text,
    super.display = Display.normal,
    super.isOptional = false,
    super.style,
    super.relevantConditions,
    super.nextButtonText = "Agree",
    super.backButtonText,
    super.titleIconMaxWidth,
    super.titleIconAnimationFile,
    super.titleIconImagePath,
    super.cancelButtonText,
    super.crossAxisAlignmentContent,
    super.cancellable,
    this.sections = const [],
    this.requiresSignature = false,
    this.agreementText = "I have read and agree to the terms above",
    this.onFinish,
  }) : super();

  @override
  FormStepView buildView(FormStackForm formStackForm) {
    formStackForm.onFinish = onFinish;
    return ConsentStepViewWidget(formStackForm, this, text, title: title);
  }

  /// Creates a [ConsentStep] from a JSON map.
  factory ConsentStep.from(Map<String, dynamic>? element,
      List<RelevantCondition> relevantConditions) {
    List<ConsentSection> sections = [];
    if (element?["sections"] != null) {
      for (var s in element!["sections"]) {
        sections.add(ConsentSection.from(s));
      }
    }
    return ConsentStep(
      display: element?["display"] != null
          ? Display.values.firstWhere((e) => e.name == element?["display"])
          : Display.normal,
      crossAxisAlignmentContent: crossAlignmentFromString(
              element?["crossAxisAlignmentContent"] ?? "center") ??
          CrossAxisAlignment.center,
      style: UIStyle.from(element?["style"]),
      cancellable: element?["cancellable"],
      relevantConditions: relevantConditions,
      backButtonText: element?["backButtonText"],
      cancelButtonText: element?["cancelButtonText"],
      isOptional: element?["isOptional"],
      nextButtonText: element?["nextButtonText"] ?? "Agree",
      text: element?["text"],
      title: element?["title"],
      titleIconAnimationFile: element?["titleIconAnimationFile"],
      titleIconImagePath: element?["titleIconImagePath"],
      titleIconMaxWidth: element?["titleIconMaxWidth"],
      sections: sections,
      requiresSignature: element?["requiresSignature"] ?? false,
      agreementText: element?["agreementText"] ??
          "I have read and agree to the terms above",
      id: GenericIdentifier(id: element?["id"]),
    );
  }
}
