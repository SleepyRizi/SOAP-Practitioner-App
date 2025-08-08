// lib/Views/Practitioner/assessment_plan_view.dart
import 'package:flutter/material.dart';
import '../../Models/assessment_model.dart';

class AssessmentPlanView extends StatelessWidget {
  const AssessmentPlanView({
    super.key,
    required this.assessment,
    this.onChanged,
  });

  final AssessmentModel assessment;
  final ValueChanged<AssessmentModel>? onChanged;

  @override
  Widget build(BuildContext context) {
    // TODO: add your Assessment / Plan fields here
    return const Center(
      child: Text(
        'Assessment / Plan — coming next',
        style: TextStyle(color: Color(0xFF696969)),
      ),
    );
  }
}
