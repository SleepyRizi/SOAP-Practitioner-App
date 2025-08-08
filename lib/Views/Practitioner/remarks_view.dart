// lib/Views/Practitioner/remarks_view.dart
import 'package:flutter/material.dart';
import '../../Models/assessment_model.dart';

class RemarksView extends StatefulWidget {
  const RemarksView({
    super.key,
    required this.assessment,
    this.onChanged,
  });

  final AssessmentModel assessment;
  final ValueChanged<AssessmentModel>? onChanged;

  @override
  State<RemarksView> createState() => _RemarksViewState();
}

class _RemarksViewState extends State<RemarksView> {
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _notes = TextEditingController(
      text: widget.assessment.practitionerRemarks?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: TextField(
        controller: _notes,
        maxLines: 12,
        decoration: const InputDecoration(
          labelText: 'Remarks / Notes',
          border: OutlineInputBorder(),
        ),
        onChanged: (v) {
          widget.onChanged?.call(
            widget.assessment.copyWith(
              practitionerRemarks: PractitionerRemarks(notes: v),
            ),
          );
        },
      ),
    );
  }
}
