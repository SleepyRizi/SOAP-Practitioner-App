// ignore_for_file: use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Models/assessment_model.dart';
import '../../Services/auth_service.dart';
import '../../Services/firestore_service.dart';
import '../../constants/app_colors.dart'; // AppColors.primary
import '../Practitioner/checkup_details_view.dart';
import '../Practitioner/assessment_plan_view.dart';
import '../Practitioner/remarks_view.dart';

/* ─────────────────────────  Assessment view  ───────────────────────── */
class AssessmentView extends StatefulWidget {
  const AssessmentView({super.key});

  @override
  State<AssessmentView> createState() => _AssessmentViewState();
}

class _AssessmentViewState extends State<AssessmentView>
    with TickerProviderStateMixin {
  late TabController _tabs;
  late TabController _pracTabs;

  @override
  void initState() {
    super.initState();

    // read params: ?tab=practitioner&prac=1  (0=Objective, 1=Plan, 2=Remarks)
    final p = Get.parameters;
    final mainIndex = (p['tab'] == 'practitioner') ? 1 : 0;
    final subRaw    = int.tryParse(p['prac'] ?? '0') ?? 0;
    final subIndex  = subRaw < 0 ? 0 : (subRaw > 2 ? 2 : subRaw);

    _tabs     = TabController(length: 2, vsync: this, initialIndex: mainIndex);
    _pracTabs = TabController(length: 3, vsync: this, initialIndex: subIndex);
  }


  @override
  void dispose() {
    _tabs.dispose();
    _pracTabs.dispose();
    super.dispose();
  }

  /* shared white-box decoration (matches patient app) */
  BoxDecoration get _boxDeco => BoxDecoration(
    color: Colors.white,
    border: Border.all(color: const Color(0xFFE0E0E0)),
    borderRadius: BorderRadius.circular(10),
  );

  @override
  Widget build(BuildContext context) {
    /* ───── arguments forwarded from HomeView ───── */
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    final params = Get.parameters;

    final String? referral = params['referral'] ?? args?['referral'] as String?;
    final String? assessmentId = params['assessmentId'] ??
        args?['assessmentId'] as String? ??
        params['id'];

    if (referral == null || assessmentId == null) {
      return const Scaffold(
        body: Center(child: Text('Missing referral or assessment id')),
      );
    }

    return FutureBuilder<AssessmentModel?>(
      future: Get.find<FirestoreService>().getAssessment(referral, assessmentId),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final a = snap.data!;
        final vw = MediaQuery.of(context).size.width;
        final maxCardW = vw.clamp(0, 770).toDouble(); // 770 on tablets

        return Scaffold(
          backgroundColor: const Color(0xFFFAFDFF),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFAFDFF),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            title: const Text(
              'Patient Overview & Practitioner Form',
              style: TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Center(
                  child: Text(
                    DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
                    style: const TextStyle(
                      fontFamily: 'Avenir',
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF696969),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* left-aligned pills */
                Align(
                  alignment: Alignment.centerLeft,
                  child: _PillRow(tabCtrl: _tabs),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      /* ───────────── Patient tab ───────────── */
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            // ── Card 1: Patient + Subjective info ──
                            Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: maxCardW),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    side: const BorderSide(
                                        color: Color(0xFFE0E0E0)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(30),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        /* ─ Patient info ─ */
                                        _label('Patient Information'),
                                        const SizedBox(height: 20),
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _field(
                                                'Patient Name',
                                                '${a.firstName} ${a.lastName}',
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: _field(
                                                'D.O.B',
                                                DateFormat('MM-dd-yyyy')
                                                    .format(a.dob),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _field(
                                                'Date of Treatment',
                                                DateFormat('EEEE d MMM')
                                                    .format(a.createdAt),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: _field(
                                                'Referral Number',
                                                a.referral,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        _field(
                                          'Referral Chief Complaint',
                                          a.chiefComplaint,
                                        ),

                                        const SizedBox(height: 40),

                                        /* ─ Subjective info ─ */
                                        _label('Subjective Information'),
                                        const SizedBox(height: 20),
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _field(
                                                'When did this pain start?',
                                                a.painSince,
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: _field(
                                                'Since onset, symptoms have been getting',
                                                a.progression,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _field(
                                                'Current Pain',
                                                '${a.currentPain} /10',
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: _rangeField(
                                                'Pain range during past 3 days',
                                                best: a.atBest,
                                                worst: a.atWorst,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _field(
                                                'Specific incident that caused this pain?',
                                                a.incidents.join(', '),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: _field(
                                                'This pain prevents participation in',
                                                a.prevents.join(', '),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _field(
                                                'Others practitioners seen about this issue',
                                                a.practitioners.join(', '),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: _field(
                                                'What makes this pain feel worse?',
                                                a.worseFactor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _field(
                                                'What makes this pain feel better?',
                                                a.betterFactor,
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: _field(
                                                'Additional subjective information (if applicable)',
                                                a.additional.isEmpty
                                                    ? '—'
                                                    : a.additional,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _field(
                                                'Time pattern of pain',
                                                a.timePattern.join(', '),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            const Expanded(child: SizedBox()),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Card 2: Sensation & Primary Area ──
                            Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: maxCardW),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    side: const BorderSide(
                                        color: Color(0xFFE0E0E0)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(30),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _label('Sensation of pain'),
                                        const SizedBox(height: 15),

                                        _box(a.sensations.isEmpty
                                            ? '—'
                                            : a.sensations.join(', ')),
                                        const SizedBox(height: 24),

                                        _miniSectionTitle(
                                            'Primary Area of Pain'),
                                        const SizedBox(height: 12),
                                        _BodyMap(a.bodyPoints),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /* ───────────── Practitioner tab ───────────── */
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PracUnderlineTabs(tabCtrl: _pracTabs),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                BoxConstraints(maxWidth: maxCardW),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    side: const BorderSide(
                                        color: Color(0xFFE0E0E0)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(30),
                                    child: TabBarView(
                                      controller: _pracTabs,
                                      children: [
                                        CheckupDetailsView(
                                          key: const PageStorageKey('prac-checkup'),
                                          assessment: a,
                                          onChanged: _saveAssessment,
                                          onNext: () => _pracTabs.animateTo(1), // ✅ go to Assessment / Plan
                                        ),
                                        AssessmentPlanView(
                                          key: const PageStorageKey('prac-plan'),
                                          assessment: a,
                                          onChanged: _saveAssessment,
                                          // ⬇️ add onNext here
                                          onNext: () => _pracTabs.animateTo(2), // ✅ go to Remarks
                                        ),
                                        RemarksView(
                                          key: const PageStorageKey(
                                              'prac-remarks'),
                                          assessment: a,
                                          onChanged: _saveAssessment,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /* ─── helpers ─── */
  Future<void> _saveAssessment(AssessmentModel updated) async {
    final fs  = Get.find<FirestoreService>();
    final uid = Get.find<AuthService>().currentUser!.uid;

    await fs.updateAssessment(
      updated.referral,
      updated.id,
      {
        ...updated.toJson(),
        'status': 'incomplete',      // any practitioner edit → pending
        'practitionerUid': uid,      // who touched it
      },
    );
  }




  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'Avenir',
      fontSize: 24,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.4,
    ),
  );

  Widget _miniLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'Avenir',
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: Color(0xFF696969),
      letterSpacing: -0.2,
    ),
  );

  Widget _miniSectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'Avenir',
      fontSize: 16,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
    ),
  );

  // BoxDecoration get _boxDeco => BoxDecoration(
  //   color: Colors.white,
  //   border: Border.all(color: const Color(0xFFE0E0E0)),
  //   borderRadius: BorderRadius.circular(10),
  // );

  Widget _box(String value) => Container(
    padding: const EdgeInsets.all(15),
    decoration: _boxDeco,
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

  Widget _field(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _miniLabel(label),
      const SizedBox(height: 8),
      _box(value),
    ],
  );

  Widget _rangeField(String label, {required int best, required int worst}) {
    Widget boxWithCaption(String caption, String value) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: _boxDeco,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Avenir',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            caption,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Avenir',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF696969),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _miniLabel(label),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: boxWithCaption('At Best', '$best')),
            const SizedBox(width: 16),
            Expanded(child: boxWithCaption('At Worst', '$worst')),
          ],
        ),
      ],
    );
  }
}

/* ─────────────────  Pill row (Patient / Practitioner)  ───────────────── */
class _PillRow extends StatelessWidget {
  const _PillRow({required this.tabCtrl});
  final TabController tabCtrl;

  @override
  Widget build(BuildContext context) {
    Widget pill(String txt, int idx) {
      final sel = tabCtrl.index == idx;
      return Expanded(
        child: GestureDetector(
          onTap: () => tabCtrl.animateTo(idx),
          child: Container(
            alignment: Alignment.center,
            padding:
            const EdgeInsets.symmetric(horizontal: 30, vertical: 11),
            decoration: BoxDecoration(
              color: sel ? const Color(0xFF2D5661) : Colors.transparent,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              txt,
              style: TextStyle(
                fontFamily: 'Avenir',
                fontSize: 20,
                fontWeight: sel ? FontWeight.w500 : FontWeight.w300,
                color: sel ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      );
    }

    final maxW = MediaQuery.of(context).size.width.clamp(0, 480).toDouble();

    return AnimatedBuilder(
      animation: tabCtrl,
      builder: (_, __) {
        return Container(
          width: maxW,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(90),
            color: Colors.white,
          ),
          child: Row(children: [pill('Patient', 0), pill('Practitioner', 1)]),
        );
      },
    );
  }
}

/* ─────────── Figma-style underline tabs for Practitioner ─────────── */
class _PracUnderlineTabs extends StatelessWidget {
  const _PracUnderlineTabs({required this.tabCtrl});
  final TabController tabCtrl;

  @override
  Widget build(BuildContext context) {
    Widget item(String text, int index) {
      final active = tabCtrl.index == index;
      return Expanded(
        child: InkWell(
          onTap: () => tabCtrl.animateTo(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontSize: 16,
                    fontWeight: active ? FontWeight.w500 : FontWeight.w300,
                    color: active ? Colors.black : const Color(0xFF696969),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary
                        : const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final maxW = MediaQuery.of(context).size.width.clamp(0, 770).toDouble();

    return AnimatedBuilder(
      animation: tabCtrl,
      builder: (_, __) {
        return SizedBox(
          width: maxW,
          child: Row(
            children: [
              item('Objective Information', 0),
              const SizedBox(width: 26),
              item('Assessment / Plan', 1),
              const SizedBox(width: 26),
              item('Remarks', 2),
            ],
          ),
        );
      },
    );
  }
}

/* ───────────────────────────  Body-map preview  ───────────────────────── */
class _BodyMap extends StatelessWidget {
  const _BodyMap(this.points);
  final List<String> points;

  @override
  Widget build(BuildContext context) {
    // original 710 × 524  ⇒ aspect‐ratio ≈ 1.355
    return AspectRatio(
      aspectRatio: 710 / 524,
      child: LayoutBuilder(builder: (ctx, box) {
        final halfW = box.maxWidth / 2;
        final h = box.maxHeight;

        Widget layer(String side) {
          final pts = points.where((p) => p.startsWith(side));
          return Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.25,
                  child: Image.asset(
                    'assets/images/body_$side.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              ...pts.map((p) {
                final sp = p.split('-');
                final x = int.parse(sp[1]) / 100 * halfW;
                final y = int.parse(sp[2]) / 100 * h;
                return Positioned(
                  left: x - 8,
                  top: y - 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ],
          );
        }

        return Row(
          children: [
            SizedBox(width: halfW, height: h, child: layer('front')),
            SizedBox(width: halfW, height: h, child: layer('back')),
          ],
        );
      }),
    );
  }
}
