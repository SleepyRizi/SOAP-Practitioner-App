import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Constants/app_colors.dart';
import '../../Models/assessment_model.dart';

class CheckupDetailsView extends StatefulWidget {
  const CheckupDetailsView({
    super.key,
    required this.assessment,
    this.onChanged,
    this.onNext, // 👈 add this here
  });

  final AssessmentModel assessment;
  final ValueChanged<AssessmentModel>? onChanged;
  final VoidCallback? onNext; // 👈 add this here

  @override
  State<CheckupDetailsView> createState() => _CheckupDetailsViewState();
}

class _CheckupDetailsViewState extends State<CheckupDetailsView>
    with AutomaticKeepAliveClientMixin {
  late PractitionerObjective _obj;
  final _spineOther = TextEditingController();
  final _gaitOther  = TextEditingController();
  final _romArea    = TextEditingController();
  final _palpArea1  = TextEditingController();
  final _palpArea2  = TextEditingController();


  String _romRestriction = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _obj = widget.assessment.practitionerObjective ?? _defaultObjective();

    _spineOther.text = _obj.spine.other;
    _gaitOther.text  = _obj.gait.other;
    _romArea.text    = _obj.rom.area;

    if (_obj.palpation.isNotEmpty) {
      _palpArea1.text = _obj.palpation[0].area;
      if (_obj.palpation.length > 1) _palpArea2.text = _obj.palpation[1].area;
    }
    _romRestriction = _obj.rom.restriction;
  }

  PractitionerObjective _defaultObjective() {
    Map<String, PostureChoice> make(Map<String, String> keys) =>
        keys.map((k, _) => MapEntry(k, const PostureChoice()));

    return PractitionerObjective(
      spine: PostureSection(items: make({
        'normal': '', 'leanForward': '', 'leanBackward': '',
      })),
      pelvis: PostureSection(items: make({
        'normal': '', 'tilt': '', 'twist': '', 'protract': '', 'retract': '',
      })),
      shoulder: PostureSection(items: make({
        'normal': '', 'leanLeft': '', 'leanRight': '', 'protract': '',
      })),
      gait: PostureSection(items: make({
        'normal': '', 'limp': '', 'cane': '', 'wheelchair': '',
      })),
      rom: const RangeOfMotion(),
      palpation: const [
        PalpationEntry(),
        PalpationEntry(),
      ],
    );
  }

  void _emit() {
    final updated = widget.assessment.copyWith(
      practitionerObjective: _obj.copyWith(
        spine: _obj.spine.copyWith(other: _spineOther.text),
        gait : _obj.gait.copyWith(other: _gaitOther.text),
        rom  : _obj.rom.copyWith(area: _romArea.text, restriction: _romRestriction),
        palpation: [
          (_obj.palpation.isNotEmpty ? _obj.palpation[0] : const PalpationEntry())
              .copyWith(area: _palpArea1.text),
          (_obj.palpation.length > 1 ? _obj.palpation[1] : const PalpationEntry())
              .copyWith(area: _palpArea2.text),
        ],
      ),
    );
    widget.onChanged?.call(updated);
    setState(() {});
  }

  @override
  void dispose() {
    _spineOther.dispose();
    _gaitOther.dispose();
    _romArea.dispose();
    _palpArea1.dispose();
    _palpArea2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for keep-alive
    final a = widget.assessment;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32), // ensure full scroll to end
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Patient Information'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _field('Patient Name', '${a.firstName} ${a.lastName}')),
              const SizedBox(width: 20),
              Expanded(child: _field('D.O.B', DateFormat('MM-dd-yyyy').format(a.dob))),
            ],
          ),
          const SizedBox(height: 30),

          _sectionTitle('Objective Information'),
          const SizedBox(height: 16),

          _subTitle('Posture Assessment'),
          const SizedBox(height: 12),

          // Spine
          _miniLabel('Spine'),
          const SizedBox(height: 10),
          _postureRow('Normal', _obj.spine, 'normal'),
          const SizedBox(height: 10),
          _postureRow('Lean Forward', _obj.spine, 'leanForward'),
          const SizedBox(height: 10),
          _postureRow('Lean Backward', _obj.spine, 'leanBackward'),
          const SizedBox(height: 10),
          _boxTextField(_spineOther, hint: 'Other', onChanged: (_) => _emit()),
          const SizedBox(height: 20),

          // Pelvis
          _miniLabel('Pelvis'),
          const SizedBox(height: 10),
          _postureRow('Normal', _obj.pelvis, 'normal'),
          const SizedBox(height: 10),
          _postureRow('Tilt', _obj.pelvis, 'tilt'),
          const SizedBox(height: 10),
          _postureRow('Twist', _obj.pelvis, 'twist'),
          const SizedBox(height: 10),
          _postureRow('Protract', _obj.pelvis, 'protract'),
          const SizedBox(height: 10),
          _postureRow('Retract', _obj.pelvis, 'retract'),
          const SizedBox(height: 20),

          // Shoulder
          _miniLabel('Shoulder'),
          const SizedBox(height: 10),
          _postureRow('Normal', _obj.shoulder, 'normal'),
          const SizedBox(height: 10),
          _postureRow('Lean Left', _obj.shoulder, 'leanLeft'),
          const SizedBox(height: 10),
          _postureRow('Lean Right', _obj.shoulder, 'leanRight'),
          const SizedBox(height: 10),
          _postureRow('Protract', _obj.shoulder, 'protract'),
          const SizedBox(height: 20),

          // Walking Gait
          _miniLabel('Walking Gait'),
          const SizedBox(height: 10),
          _postureRow('Normal', _obj.gait, 'normal'),
          const SizedBox(height: 10),
          _postureRow('Limp', _obj.gait, 'limp'),
          const SizedBox(height: 10),
          _postureRow('Walking Cane', _obj.gait, 'cane'),
          const SizedBox(height: 10),
          _postureRow('Wheelchair', _obj.gait, 'wheelchair'),
          const SizedBox(height: 10),
          _boxTextField(_gaitOther, hint: 'Other', onChanged: (_) => _emit()),
          const SizedBox(height: 24),

          // ROM
          _subTitle('Range of Motion'),
          const SizedBox(height: 12),
          _boxTextField(_romArea, hint: 'Area', onChanged: (_) => _emit()),
          const SizedBox(height: 12),
          _checkboxRow(
            options: const [
              'Full Range',
              'Slight Restriction',
              'Moderate Restriction',
              'Severe Restriction'
            ],
            value: _romRestriction,
            onChanged: (v) {
              _romRestriction = v;
              _emit();
            },
          ),
          const SizedBox(height: 24),

          // Palpation
          _subTitle('Palpation'),
          const SizedBox(height: 12),

          // Area #1
          _boxTextField(_palpArea1, hint: 'Area', onChanged: (_) => _emit()),
          const SizedBox(height: 10),
          _palpRow(
            title: 'Tension',
            value: _obj.palpation[0].tension,
            choices: const ['Mild', 'Moderate', 'Severe'],
            onChanged: (v) {
              _obj = _obj.copyWith(
                palpation: [
                  _obj.palpation[0].copyWith(tension: v),
                  _obj.palpation.length > 1 ? _obj.palpation[1] : const PalpationEntry(),
                ],
              );
              _emit();
            },
          ),
          _palpRow(
            title: 'Texture',
            value: _obj.palpation[0].texture,
            choices: const ['Pliable', 'Adhesive', 'Fibrotic'],
            onChanged: (v) {
              _obj = _obj.copyWith(
                palpation: [
                  _obj.palpation[0].copyWith(texture: v),
                  _obj.palpation.length > 1 ? _obj.palpation[1] : const PalpationEntry(),
                ],
              );
              _emit();
            },
          ),
          _palpRow(
            title: 'Tenderness',
            value: _obj.palpation[0].tenderness,
            choices: const ['Mild', 'Moderate', 'Severe'],
            onChanged: (v) {
              _obj = _obj.copyWith(
                palpation: [
                  _obj.palpation[0].copyWith(tenderness: v),
                  _obj.palpation.length > 1 ? _obj.palpation[1] : const PalpationEntry(),
                ],
              );
              _emit();
            },
          ),
          _palpRow(
            title: 'Temperature',
            value: _obj.palpation[0].temperature,
            choices: const ['Normal', 'Increased', 'Decreased'],
            onChanged: (v) {
              _obj = _obj.copyWith(
                palpation: [
                  _obj.palpation[0].copyWith(temperature: v),
                  _obj.palpation.length > 1 ? _obj.palpation[1] : const PalpationEntry(),
                ],
              );
              _emit();
            },
          ),

          const SizedBox(height: 16),

          // Area #2
          _boxTextField(_palpArea2, hint: 'Area', onChanged: (_) => _emit()),
          const SizedBox(height: 10),
          _palpRow(
            title: 'Tension',
            value: _obj.palpation[1].tension,
            choices: const ['Mild', 'Moderate', 'Severe'],
            onChanged: (v) {
              _obj = _obj.copyWith(
                palpation: [
                  _obj.palpation[0],
                  _obj.palpation[1].copyWith(tension: v),
                ],
              );
              _emit();
            },
          ),
          _palpRow(
            title: 'Texture',
            value: _obj.palpation[1].texture,
            choices: const ['Pliable', 'Adhesive', 'Fibrotic'],
            onChanged: (v) {
              _obj = _obj.copyWith(
                palpation: [
                  _obj.palpation[0],
                  _obj.palpation[1].copyWith(texture: v),
                ],
              );
              _emit();
            },
          ),
          _palpRow(
            title: 'Tenderness',
            value: _obj.palpation[1].tenderness,
            choices: const ['Mild', 'Moderate', 'Severe'],
            onChanged: (v) {
              _obj = _obj.copyWith(
                palpation: [
                  _obj.palpation[0],
                  _obj.palpation[1].copyWith(tenderness: v),
                ],
              );
              _emit();
            },
          ),
          _palpRow(
            title: 'Temperature',
            value: _obj.palpation[1].temperature,
            choices: const ['Normal', 'Increased', 'Decreased'],
            onChanged: (v) {
              _obj = _obj.copyWith(
                palpation: [
                  _obj.palpation[0],
                  _obj.palpation[1].copyWith(temperature: v),
                ],
              );
              _emit();
            },
          ),
          const SizedBox(height: 32),

          Center(
            child: GestureDetector(
              onTap: widget.onNext,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: ShapeDecoration(
                  color: const Color(0xFF2D5661),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Avenir',
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.41,
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  /* ─────────── UI helpers ─────────── */

  Widget _subTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontFamily: 'Avenir',
      fontSize: 20,
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
    ),
  );

  Widget _field(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _miniLabel(label),
      const SizedBox(height: 8),
      _box(value),
    ],
  );

  Widget _box(String value) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE0E0E0)),
      borderRadius: BorderRadius.circular(10),
    ),
    alignment: Alignment.centerLeft,
    child: Text(
      value,
      style: const TextStyle(
        fontFamily: 'Avenir',
        fontSize: 16,
        fontWeight: FontWeight.w300,
      ),
    ),
  );

  Widget _boxTextField(
      TextEditingController c, {
        required String hint,
        ValueChanged<String>? onChanged,
      }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(10),
        ),
        height: 52,
        alignment: Alignment.centerLeft,
        child: TextField(
          controller: c,
          onChanged: onChanged,
          decoration: InputDecoration.collapsed(
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

  Widget _postureRow(String label, PostureSection sec, String key) {
    final choice = sec.items[key] ?? const PostureChoice();

    void _set(PostureSection section, PostureChoice updated) {
      if (section == _obj.spine) {
        _obj = _obj.copyWith(
            spine: section.copyWith(items: {...section.items, key: updated}));
      } else if (section == _obj.pelvis) {
        _obj = _obj.copyWith(
            pelvis: section.copyWith(items: {...section.items, key: updated}));
      } else if (section == _obj.shoulder) {
        _obj = _obj.copyWith(
            shoulder:
            section.copyWith(items: {...section.items, key: updated}));
      } else if (section == _obj.gait) {
        _obj = _obj.copyWith(
            gait: section.copyWith(items: {...section.items, key: updated}));
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 200,
          child: InkWell(
            onTap: () {
              _set(sec, choice.copyWith(checked: !choice.checked));
              _emit();
            },
            child: Row(
              children: [
                Checkbox(
                  value: choice.checked,
                  onChanged: (v) {
                    _set(sec, choice.copyWith(checked: v ?? false));
                    _emit();
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Avenir',
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: ['Mild', 'Moderate', 'Severe'].map((e) {
              final sel = choice.severity == e;
              return ChoiceChip(
                labelPadding:
                const EdgeInsets.symmetric(horizontal: 24),
                label: Text(e),
                selected: sel,
                selectedColor: AppColors.primary,
                backgroundColor: const Color(0xFFFAFDFF),
                labelStyle: TextStyle(
                  color: sel ? Colors.white : const Color(0xFF696969),
                ),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: sel
                        ? Colors.transparent
                        : const Color(0xFFE0E0E0),
                  ),
                ),
                onSelected: (_) {
                  _set(sec, choice.copyWith(severity: e));
                  _emit();
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _checkboxRow({
    required List<String> options,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      children: options.map((opt) {
        final sel = value == opt;
        return InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => onChanged(opt),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: sel,
                onChanged: (_) => onChanged(opt),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (sel) return AppColors.primary;
                  return Colors.transparent;
                }),
                checkColor: Colors.white,
              ),
              Text(
                opt,
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

  Widget _palpRow({
    required String title,
    required List<String> choices,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Avenir',
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: choices.map((e) {
                final sel = value == e;
                return ChoiceChip(
                  labelPadding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 5),
                  label: Text(e),
                  selected: sel,
                  selectedColor: AppColors.primary,
                  backgroundColor: const Color(0xFFFAFDFF),
                  labelStyle: TextStyle(
                    color: sel ? Colors.white : const Color(0xFF696969),
                  ),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: sel
                          ? Colors.transparent
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  onSelected: (_) => onChanged(e),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Text _sectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontFamily: 'Avenir',
      fontSize: 24,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.41,
    ),
  );
}
