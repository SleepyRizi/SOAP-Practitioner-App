// lib/Views/Practitioner/remarks_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Constants/app_colors.dart';
import '../../Models/assessment_model.dart';
import '../../Services/auth_service.dart';
import '../../Services/firestore_service.dart';
import '../Success/success_view.dart';

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

class _RemarksViewState extends State<RemarksView>
    with AutomaticKeepAliveClientMixin {
  PractitionerRemarks _remarks = const PractitionerRemarks();

  // Single Practitioner Note controller (ONE big field)
  final TextEditingController _noteLongCtrl = TextEditingController();

  // Expansion state per section
  final Map<String, bool> _expanded = {};

  // ─────────────────────────────────────────────────────────────
  // Static data: Sections -> { muscle: associatedNote }
  static const Map<String, List<MapEntry<String, String>>> _muscleData = {
    'Face': [
      MapEntry('Frontalis', 'Facial Tension'),
      MapEntry('Buccinator', 'Cheek Muscle'),
      MapEntry('Orbicularis oris', 'Mouth Control'),
      MapEntry('Orbicularis oculi', 'Eye Squinting'),
      MapEntry('Occipitofrontalis', 'Scalp Movement'),
      MapEntry('Zygomaticus major', 'Smiling'),
      MapEntry('Temporalis', 'Jaw Closing'),
      MapEntry('Masseter', 'Jaw Chewing'),
      MapEntry('Platysma', 'Neck/Facial Tension'),
      MapEntry('Mentalis', 'Chin Muscle'),
    ],
    'Neck': [
      MapEntry('Sternocleidomastoid', 'Neck rotation'),
      MapEntry('Trapezius (Upper)', 'Shoulder elevation'),
      MapEntry('Semispinalis Capitis', 'Head extension'),
      MapEntry('Levator Scapulae', 'Neck/Shoulder pain'),
      MapEntry('Scalenes', 'Anterior neck'),
      MapEntry('Longus Colli', 'Deep neck flexion'),
    ],
    'Shoulder/Back': [
      MapEntry('Supraspinatus', 'Abduction'),
      MapEntry('Infraspinatus', 'External rotation'),
      MapEntry('Teres Minor', 'External rotation'),
      MapEntry('Subscapularis', 'Internal rotation'),
      MapEntry('Deltoid', 'Shoulder abduction'),
      MapEntry('Pectoralis Major', 'Chest'),
      MapEntry('Pectoralis Minor', 'Under pec major'),
      MapEntry('Teres Major', 'Internal rotation'),
      MapEntry('Latissimus Dorsi', 'Back width'),
      MapEntry('Rhomboid Major', 'Scapular retraction'),
      MapEntry('Rhomboid Minor', 'Scapular retraction'),
    ],
    'Thorax/Back': [
      MapEntry('Longissimus Thoracis', 'Spinal extension'),
      MapEntry('Iliocostalis Lumborum', 'Spinal extension'),
      MapEntry('Spinalis Thoracis', 'Spinal extension'),
      MapEntry('Serratus Anterior', 'Scapular protraction'),
      MapEntry('Serratus Posterior Inferior', 'Respiration'),
      MapEntry('Quadratus Lumborum (QL)', 'Low back pain'),
      MapEntry('Diaphragm', 'Breathing'),
    ],
    'Arm': [
      MapEntry('Biceps Brachii', 'Elbow flexion'),
      MapEntry('Triceps Brachii', 'Elbow extension'),
      MapEntry('Brachialis', 'Pure elbow flexion'),
    ],
    'Forearm': [
      MapEntry('Palmaris Longus', 'Wrist flexion'),
      MapEntry('Flexor Carpi Radialis', 'Wrist flexion'),
      MapEntry('Flexor Carpi Ulnaris', 'Wrist flexion'),
      MapEntry('Flexor Digitorum Superficialis', 'Finger flexion'),
      MapEntry('Pronator Teres', 'Forearm pronation'),
      MapEntry('Brachioradialis', 'Elbow flexion'),
      MapEntry('Extensor Carpi Radialis', 'Wrist extension'),
      MapEntry('Extensor Carpi Ulnaris', 'Wrist extension'),
      MapEntry('Extensor Digitorum', 'Finger extension'),
      MapEntry('Extensor Digiti Minimi', '5th finger extension'),
    ],
    'Hand': [
      MapEntry('Thenar Eminence', 'Thumb movement'),
      MapEntry('Hypothenar Eminence', 'Little finger movement'),
      MapEntry('Lumbricals', 'Finger flexion'),
      MapEntry('Interossei', 'Finger abduction/adduction'),
    ],
    'Hip/Pelvis': [
      MapEntry('Piriformis', 'Sciatica relief'),
      MapEntry('Iliopsoas', 'Hip flexion'),
      MapEntry('Gluteus Maximus', 'Hip extension'),
      MapEntry('Gluteus Medius', 'Hip abduction'),
      MapEntry('Tensor Fasciae Latae (TFL)', 'IT band tension'),
    ],
    'Thigh': [
      MapEntry('Rectus Femoris', '(Quadriceps) – Knee extension/hip flexion'),
      MapEntry('Vastus Lateralis', '(Quadriceps) – Knee extension'),
      MapEntry('Vastus Medialis', '(Quadriceps) – Knee extension'),
      MapEntry('Vastus Intermedius', '(Quadriceps) – Knee extension'),
      MapEntry('Sartorius', 'Cross-legged sitting'),
    ],
    'Leg': [
      MapEntry('Adductor Longus', 'Hip adduction'),
      MapEntry('Adductor Magnus', 'Hip adduction'),
      MapEntry('Gracilis', 'Hip adduction'),
      MapEntry('Biceps Femoris', 'Hamstring'),
      MapEntry('Semimembranosus', 'Hamstring'),
      MapEntry('Semitendinosus', 'Hamstring'),
    ],
    'Foot': [
      MapEntry('Tibialis Anterior', 'Dorsiflexion'),
      MapEntry('Extensor Digitorum Longus', 'Toe extension'),
      MapEntry('Extensor Hallucis Longus', 'Big toe extension'),
      MapEntry('Gastrocnemius', 'Plantarflexion'),
      MapEntry('Soleus', 'Plantarflexion'),
      MapEntry('Flexor Digitorum Longus', 'Toe flexion'),
      MapEntry('Flexor Hallucis Longus', 'Big toe flexion'),
      MapEntry('Tibialis Posterior', 'Arch support'),
      MapEntry('Fibularis Longus', 'Ankle eversion'),
      MapEntry('Fibularis Brevis', 'Ankle eversion'),
      MapEntry('Flexor Hallucis Brevis', 'Big toe flexor'),
      MapEntry('Extensor Hallucis Brevis', 'Big toe extensor'),
      MapEntry('Plantaris', 'Posterior knee'),
    ],
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _remarks = widget.assessment.practitionerRemarks ?? const PractitionerRemarks();
    _noteLongCtrl.text = _remarks.noteLong ?? '';

    bool first = true;
    for (final sec in _muscleData.keys) {
      _expanded[sec] = first; // open first only
      first = false;
    }
  }

  @override
  void dispose() {
    _noteLongCtrl.dispose();
    super.dispose();
  }

  void _emit(PractitionerRemarks next) {
    _remarks = next;
    widget.onChanged?.call(
      widget.assessment.copyWith(practitionerRemarks: _remarks),
    );
    if (mounted) setState(() {});
  }

  void _toggleMuscle(String section, String muscle) {
    final current = Map<String, List<String>>.from(_remarks.musclesBySection ?? {});
    final list = List<String>.from(current[section] ?? const []);
    if (list.contains(muscle)) {
      list.remove(muscle);
    } else {
      list.add(muscle);
    }
    current[section] = list;
    _emit(_remarks.copyWith(musclesBySection: current));
  }

  bool _isSelected(String section, String muscle) {
    final m = _remarks.musclesBySection ?? const {};
    final list = m[section];
    return list != null && list.contains(muscle);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Additional Information'),
          const SizedBox(height: 12),
          _checkboxLine(
            items: [
              _CheckItem('N/A', _remarks.na ?? false, (v) => _emit(_remarks.copyWith(na: v))),
              _CheckItem('Initial Appointment', _remarks.initialAppointment ?? false,
                      (v) => _emit(_remarks.copyWith(initialAppointment: v))),
              _CheckItem('Final Appointment', _remarks.finalAppointment ?? false,
                      (v) => _emit(_remarks.copyWith(finalAppointment: v))),
            ],
          ),
          const SizedBox(height: 24),

          _subTitle('Practitioner Note:'),
          const SizedBox(height: 10),

          // SINGLE large text field (no restorationId, no explicit keys)
          _textArea(
            controller: _noteLongCtrl,
            hint: 'Enter text here',
            onChanged: (v) => _emit(_remarks.copyWith(noteLong: v)),
          ),

          const SizedBox(height: 28),
          _sectionTitle('Muscles Addressed During the Session'),
          const SizedBox(height: 14),

          // Expansion list of sections
          ..._muscleData.keys.map((section) {
            final selected = (_remarks.musclesBySection ?? const {})[section] ?? const [];
            final hasAny = selected.isNotEmpty;
            final isExpanded = _expanded[section] ?? false;

            final collapsedSummary = hasAny
                ? selected.take(3).join(', ') + (selected.length > 3 ? '…' : '')
                : null;

            return _ExpansionContainer(
              // No PageStorageKey/GlobalKey; we manage expansion ourselves
              title: section,
              highlighted: hasAny,
              expanded: isExpanded,
              subtitle: (!isExpanded) ? collapsedSummary : null,
              onToggle: () {
                setState(() => _expanded[section] = !(_expanded[section] ?? false));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _muscleCheckboxWrap(
                    section: section,
                    entries: _muscleData[section]!,
                  ),
                  const SizedBox(height: 12),
                  _notesHeader(),
                  const SizedBox(height: 6),
                  _readonlyNotesBox(section: section),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 24),

          // Submit button (full width)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5661),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                await Future.delayed(const Duration(milliseconds: 50));

                final fs  = Get.find<FirestoreService>();
                final uid = Get.find<AuthService>().currentUser!.uid;

                // save remarks first
                await fs.updateAssessment(
                  widget.assessment.referral,
                  widget.assessment.id,
                  {'practitionerRemarks': _remarks.toJson()},
                );

                // then complete
                await fs.completeAssessment(
                  widget.assessment.referral,
                  widget.assessment.id,
                  practitionerUid: uid,
                );

                Get.to(() => const SuccessView());
              },



              child: const Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Avenir',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ─────────── UI helpers ─────────── */

  Widget _sectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontFamily: 'Avenir',
      fontSize: 24,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.41,
    ),
  );

  Widget _subTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontFamily: 'Avenir',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.41,
    ),
  );

  Widget _miniLabel(String t) => Text(
    t,
    style: const TextStyle(
      fontFamily: 'Avenir',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.2,
      color: AppColors.primary,
    ),
  );

  Widget _textArea({
    required TextEditingController controller,
    required String hint,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: 8,
        minLines: 6,
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Avenir',
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Color(0xFF696969),
          ),
        ),
      ),
    );
  }

  // A single line of checkboxes (wraps on small widths)
  Widget _checkboxLine({required List<_CheckItem> items}) {
    return Wrap(
      spacing: 20,
      runSpacing: 8,
      children: items.map((ci) {
        return InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => ci.onChanged(!ci.value),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: ci.value,
                onChanged: (v) => ci.onChanged(v ?? false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return AppColors.primary;
                  }
                  return Colors.transparent;
                }),
                checkColor: Colors.white,
              ),
              Text(
                ci.label,
                style: const TextStyle(
                  fontFamily: 'Avenir',
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Wrap of muscle checkboxes
  Widget _muscleCheckboxWrap({
    required String section,
    required List<MapEntry<String, String>> entries,
  }) {
    return Wrap(
      spacing: 20,
      runSpacing: 12,
      children: entries.map((e) {
        final sel = _isSelected(section, e.key);
        return InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => _toggleMuscle(section, e.key),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: sel,
                onChanged: (_) => _toggleMuscle(section, e.key),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (sel) return AppColors.primary;
                  return Colors.transparent;
                }),
                checkColor: Colors.white,
              ),
              Text(
                e.key,
                style: const TextStyle(
                  fontFamily: 'Avenir',
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // "i  Note" header
  Widget _notesHeader() {
    return Row(
      children: const [
        Icon(Icons.info_outline, size: 18, color: Color(0xFF2D5661)),
        SizedBox(width: 6),
        Text(
          'Note',
          style: TextStyle(
            color: Color(0xFF2D5661),
            fontSize: 16,
            fontFamily: 'Avenir',
            fontWeight: FontWeight.w500,
            height: 1.38,
            letterSpacing: -0.41,
          ),
        ),
      ],
    );
  }

  // Read-only rows for selected muscles
  Widget _readonlyNotesBox({required String section}) {
    final selected = (_remarks.musclesBySection ?? const {})[section] ?? const <String>[];
    final lookup = {for (final e in _muscleData[section]!) e.key: e.value};

    if (selected.isEmpty) {
      return _noteRow(left: '—', right: '');
    }

    return Column(
      children: selected.map((m) {
        final right = lookup[m] ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _noteRow(left: m, right: right),
        );
      }).toList(),
    );
  }

  // A single Figma-style note row
  Widget _noteRow({required String left, required String right}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: const TextStyle(
                color: Color(0xFF696969),
                fontSize: 16,
                fontFamily: 'Avenir',
                fontWeight: FontWeight.w300,
                height: 1.38,
                letterSpacing: -0.41,
              ),
            ),
          ),
          Text(
            right,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Avenir',
              fontWeight: FontWeight.w500,
              height: 1.38,
              letterSpacing: -0.41,
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────────── Support widgets & models ───────────────────────────── */

class _CheckItem {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  _CheckItem(this.label, this.value, this.onChanged);
}

class _ExpansionContainer extends StatelessWidget {
  const _ExpansionContainer({
    required this.title,
    required this.child,
    this.subtitle,
    this.highlighted = false,
    this.expanded = false,
    this.onToggle,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool highlighted;
  final bool expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final Color bg = highlighted ? const Color(0xFFFAFDFF) : Colors.white;
    final Color border =
    highlighted ? AppColors.primaryOpacity(0.25) : const Color(0xFFE0E0E0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: ExpansionTile(
          key: ValueKey('exp_${title}_tile'), // simple ValueKey (not GlobalKey)
          initiallyExpanded: expanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(15, 0, 15, 16),
          onExpansionChanged: (_) => onToggle?.call(),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Avenir',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.41,
                  color: Colors.black,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontFamily: 'Avenir',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF696969),
                  ),
                ),
              ],
            ],
          ),
          children: [child],
        ),
      ),
    );
  }
}
