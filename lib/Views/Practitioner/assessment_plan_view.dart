// lib/Views/Practitioner/assessment_plan_view.dart
import 'package:flutter/material.dart';
import '../../Models/assessment_model.dart';
import '../../Constants/app_colors.dart';

class AssessmentPlanView extends StatefulWidget {
  const AssessmentPlanView({
    super.key,
    required this.assessment,
    this.onChanged,
    this.onNext,
  });

  final AssessmentModel assessment;
  final ValueChanged<AssessmentModel>? onChanged;
  final VoidCallback? onNext;
  @override
  State<AssessmentPlanView> createState() => _AssessmentPlanViewState();
}

class _AssessmentPlanViewState extends State<AssessmentPlanView>
    with AutomaticKeepAliveClientMixin {
  // Options (per spec)
  final _areasRow1 = const ['Back', 'Neck', 'Shoulders', 'Feet', 'Hip Area', 'Abdominals'];
  final _areasRow2 = const ['Chest', 'Face', 'Arms', 'Legs'];

  final _techRow1 = const ['All', 'Swedish', 'Deep Tissue', 'Hot Stone', 'Intra-Oral', 'Shiatsu'];
  final _techRow2 = const ['Reflexology', 'Trigger Points', 'Myofascial Release', 'Medi-Cupping'];
  final _techRow3 = const ['Stretching', 'Hot Packs', 'TENS', 'ESWT'];

  List<String> get _allTechniques => [..._techRow1, ..._techRow2, ..._techRow3];
  List<String> get _techniquesWithoutAll =>
      _allTechniques.where((e) => e != 'All').toList(growable: false);

  final _durations = const <int>[15, 30, 45, 60];
  final _cadences = const ['Week', 'Two Weeks', 'Month'];

  late PractitionerPlan _plan;

  final _areasOtherCtrl = TextEditingController();
  final _techOtherCtrl  = TextEditingController();
  final _painCtrl       = TextEditingController();
  final _responseCtrl   = TextEditingController();
  final _recoCtrl       = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _plan = widget.assessment.practitionerPlan ?? const PractitionerPlan();
    _areasOtherCtrl.text = _plan.areasOther;
    _techOtherCtrl.text  = _plan.techniquesOther;
    _painCtrl.text       = _plan.painAfterSession == 0 ? '' : '${_plan.painAfterSession}';
    _responseCtrl.text   = _plan.clientResponse.isEmpty ? '' : _plan.clientResponse;
    _recoCtrl.text       = _plan.recommendations.isEmpty ? '' : _plan.recommendations;
  }

  @override
  void dispose() {
    _areasOtherCtrl.dispose();
    _techOtherCtrl.dispose();
    _painCtrl.dispose();
    _responseCtrl.dispose();
    _recoCtrl.dispose();
    super.dispose();
  }

  // ——— UI helpers ———
  InputBorder get _boxBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.border),
  );

  Widget _sectionTitle(String t) => Text(
    t,
    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, letterSpacing: -0.41),
  );

  Widget _label(String t) => Text(
    t,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: -0.41, height: 1.38),
  );

  // Plain checkbox + text (no container/card)
  Widget _plainCheck({
    required bool selected,
    required String label,
    required VoidCallback onToggle,
  }) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: selected,
            onChanged: (_) => onToggle(),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: AppColors.border),
            fillColor: MaterialStateProperty.resolveWith(
                  (s) => s.contains(MaterialState.selected) ? AppColors.primary : Colors.transparent,
            ),
            checkColor: Colors.white,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300, letterSpacing: -0.41),
          ),
        ],
      ),
    );
  }

  Widget _checksWrapStrings({
    required List<String> items,
    required List<String> selected,
    required void Function(String) onToggle,
  }) {
    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: items.map((e) {
        final sel = selected.contains(e);
        return _plainCheck(selected: sel, label: e, onToggle: () => onToggle(e));
      }).toList(),
    );
  }

  Widget _checksWrapInts({
    required List<int> items,
    required List<int> selected,
    required void Function(int) onToggle,
    bool showColon = false,
  }) {
    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: items.map((e) {
        final sel = selected.contains(e);
        return _plainCheck(
          selected: sel,
          label: showColon ? ': $e' : '$e',
          onToggle: () => onToggle(e),
        );
      }).toList(),
    );
  }

  // ——— state emit ———
  void _emit() {
    final parsed = int.tryParse(_painCtrl.text.trim());
    final pain = ((parsed ?? 0).clamp(0, 10)) as int;

    final updatedPlan = _plan.copyWith(
      areasOther: _areasOtherCtrl.text,
      techniquesOther: _techOtherCtrl.text,
      painAfterSession: pain,
      clientResponse: _responseCtrl.text,
      recommendations: _recoCtrl.text,
    );
    _plan = updatedPlan;

    widget.onChanged?.call(
      widget.assessment.copyWith(practitionerPlan: updatedPlan),
    );
    setState(() {});
  }

  // Togglers (explicit target so we don't rely on list identity)
  void _toggleArea(String v) {
    final s = _plan.areasTreated.toList();
    s.contains(v) ? s.remove(v) : s.add(v);
    _plan = _plan.copyWith(areasTreated: s);
    _emit();
  }

  void _toggleTechnique(String v) {
    final s = _plan.techniquesUsed.toList();

    if (v == 'All') {
      final allSelected = _techniquesWithoutAll.every(s.contains);
      if (allSelected && s.contains('All')) {
        // Unselect all
        s
          ..clear();
      } else {
        // Select every technique including 'All'
        s
          ..clear()
          ..addAll(_techniquesWithoutAll)
          ..add('All');
      }
    } else {
      // Toggle single technique
      s.contains(v) ? s.remove(v) : s.add(v);

      // Maintain 'All' consistency:
      final nowAllSelected = _techniquesWithoutAll.every(s.contains);
      if (nowAllSelected) {
        if (!s.contains('All')) s.add('All');
      } else {
        s.remove('All');
      }
    }

    _plan = _plan.copyWith(techniquesUsed: s);
    _emit();
  }

  void _toggleDuration(int v) {
    final s = _plan.followUpWith.toList();
    s.contains(v) ? s.remove(v) : s.add(v);
    _plan = _plan.copyWith(followUpWith: s);
    _emit();
  }

  void _toggleCadence(String v) {
    final s = _plan.sessionEvery.toList();
    s.contains(v) ? s.remove(v) : s.add(v);
    _plan = _plan.copyWith(sessionEvery: s);
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.clamp(0, 770).toDouble();
        final isNarrow = constraints.maxWidth < 640;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ——— Treatment Information ———
                  _sectionTitle('Treatment Information'),
                  const SizedBox(height: 15),

                  _label('Areas Treated'),
                  const SizedBox(height: 10),
                  _checksWrapStrings(
                    items: _areasRow1,
                    selected: _plan.areasTreated,
                    onToggle: _toggleArea,
                  ),
                  const SizedBox(height: 10),
                  _checksWrapStrings(
                    items: _areasRow2,
                    selected: _plan.areasTreated,
                    onToggle: _toggleArea,
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _areasOtherCtrl,
                    onChanged: (_) => _emit(),
                    decoration: InputDecoration(
                      hintText: 'Other',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w300,
                      ),
                      border: _boxBorder,
                      enabledBorder: _boxBorder,
                      focusedBorder: _boxBorder.copyWith(
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _label('Techniques Used'),
                  const SizedBox(height: 10),
                  _checksWrapStrings(
                    items: _techRow1,
                    selected: _plan.techniquesUsed,
                    onToggle: _toggleTechnique,
                  ),
                  const SizedBox(height: 10),
                  _checksWrapStrings(
                    items: _techRow2,
                    selected: _plan.techniquesUsed,
                    onToggle: _toggleTechnique,
                  ),
                  const SizedBox(height: 10),
                  _checksWrapStrings(
                    items: _techRow3,
                    selected: _plan.techniquesUsed,
                    onToggle: _toggleTechnique,
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _techOtherCtrl,
                    onChanged: (_) => _emit(),
                    decoration: InputDecoration(
                      hintText: 'Other',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w300,
                      ),
                      border: _boxBorder,
                      enabledBorder: _boxBorder,
                      focusedBorder: _boxBorder.copyWith(
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ——— Assessment Information ———
                  _sectionTitle('Assessment Information'),
                  const SizedBox(height: 15),

                  // Pain after session — heading above, field below
                  _label('Pain after session'),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: isNarrow ? double.infinity : (maxW * 0.5),
                      child: TextField(
                        controller: _painCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _emit(),
                        decoration: InputDecoration(
                          hintText: 'eg. 2',
                          hintStyle: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w300,
                          ),
                          border: _boxBorder,
                          enabledBorder: _boxBorder,
                          focusedBorder: _boxBorder.copyWith(
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                          suffixIcon: const Padding(
                            padding: EdgeInsets.only(right: 12, top: 14),
                            child: Text('/10', style: TextStyle(color: Colors.black)),
                          ),
                          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Small heading + text box with gray hint (no label inside)
                  _label('How did the client respond to massage treatment?'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _responseCtrl,
                    maxLines: 6,
                    onChanged: (_) => _emit(),
                    decoration: InputDecoration(
                      hintText: 'AI Narrated',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w300,
                      ),
                      border: _boxBorder,
                      enabledBorder: _boxBorder,
                      focusedBorder: _boxBorder.copyWith(
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                      ),
                      contentPadding: const EdgeInsets.all(15),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ——— Plan Information ———
                  _sectionTitle('Plan Information'),
                  const SizedBox(height: 15),

                  // Follow-up with | Session every — responsive
                  LayoutBuilder(
                    builder: (_, cc) {
                      final twoCol = cc.maxWidth >= 640;
                      final left = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Follow-up with'),
                          const SizedBox(height: 12),
                          _checksWrapInts(
                            items: _durations,
                            selected: _plan.followUpWith,
                            onToggle: _toggleDuration,
                            showColon: true,
                          ),
                        ],
                      );
                      final right = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Session every'),
                          const SizedBox(height: 12),
                          _checksWrapStrings(
                            items: _cadences,
                            selected: _plan.sessionEvery,
                            onToggle: _toggleCadence,
                          ),
                        ],
                      );

                      return twoCol
                          ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: left),
                          const SizedBox(width: 30),
                          Expanded(child: right),
                        ],
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          left,
                          const SizedBox(height: 16),
                          right,
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  // Heading + text box with gray hint
                  _label('Treatment plan and self-care recommendations:'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _recoCtrl,
                    maxLines: 6,
                    onChanged: (_) => _emit(),
                    decoration: InputDecoration(
                      hintText:
                      'Due to complex injury and multiple injured areas, recommend 60min session. '
                          'Continue with regular massage therapy sessions to address ongoing muscle tension '
                          'and improve range of motion.',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w300,
                      ),
                      border: _boxBorder,
                      enabledBorder: _boxBorder,
                      focusedBorder: _boxBorder.copyWith(
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                      ),
                      contentPadding: const EdgeInsets.all(15),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(width: 1, color: Colors.black),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: const Text('Back', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
                        ),
                      ),
                      const SizedBox(width: 19),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            _emit();
                            widget.onNext?.call();
                          },
                          child: const Text('Next',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
