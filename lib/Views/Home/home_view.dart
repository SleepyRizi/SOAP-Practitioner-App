import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Models/assessment_model.dart';
import '../../Services/auth_service.dart';
import '../../Services/firestore_service.dart';
import '../../routes/app_pages.dart';
import '../Common/bottom_bar.dart';

/*──────────────────── Entry ────────────────────*/

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth   = Get.find<AuthService>();
    final fs     = Get.find<FirestoreService>();
    final uid    = auth.currentUser!.uid;

    final scrW   = MediaQuery.of(context).size.width;
    final isTab  = scrW > 600;
    final nowStr = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());
    final titleSz= isTab ? 42.5 : 34.0;     // 15 % smaller than original

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFDFF),

        /* ───────── Header ───────── */
        appBar: AppBar(
          toolbarHeight: isTab ? 100 : 86,
          backgroundColor: const Color(0xFFFAFDFF),
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 32,
          title: Text(
            'Dashboard',
            style: TextStyle(
              fontFamily : 'Cormorant Garamond',
              fontSize   : titleSz,
              fontWeight : FontWeight.w600,
              color      : Colors.black,
            ),
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Text(
                  nowStr,
                  style: TextStyle(
                    fontFamily : 'Avenir',
                    fontSize   : isTab ? 20 : 16,
                    fontWeight : FontWeight.w300,
                    color      : const Color(0xFF696969),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () async {
                await auth.logout();
                Get.offAllNamed(Routes.welcome);
              },
            ),
          ],
        ),

        /* ───────── Body (streams) ───────── */
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _DashboardStreams(uid: uid, isTablet: isTab),
        ),

        /* ───────── Bottom bar ───────── */
        bottomNavigationBar: const AppBottomBar(current: BottomTab.home),

      ),
    );
  }
}

/*──────────────── Streams wrapper ──────────────*/

class _DashboardStreams extends StatelessWidget {
  const _DashboardStreams({required this.uid, required this.isTablet});
  final String uid;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final fs = Get.find<FirestoreService>();

    return StreamBuilder<List<AssessmentModel>>(
      stream: fs.streamTodaysPatients(),
      builder: (_, sToday) {
        return StreamBuilder<List<AssessmentModel>>(
          stream: fs.streamPendingForms(uid),
          builder: (_, sPend) {
            if (sToday.connectionState == ConnectionState.waiting ||
                sPend.connectionState  == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final today   = sToday.data ?? [];
            final pending = sPend.data ?? [];
            final hasData = today.isNotEmpty || pending.isNotEmpty;

            return Column(
              children: [
                const SizedBox(height: 14),
                Expanded(
                  child: _DashboardCard(
                    today   : today,
                    pending : pending,
                    showTabs: hasData,
                    isTablet: isTablet,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/*──────────────── Dashboard Card ───────────────*/

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.today,
    required this.pending,
    required this.showTabs,
    required this.isTablet,
  });

  final List<AssessmentModel> today;
  final List<AssessmentModel> pending;
  final bool showTabs;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.78;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          padding: const EdgeInsets.all(30),
          child: showTabs
              ? Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width
                      .clamp(0, 480)         // <=480 px or screen
                      .toDouble(),
                  child: const _PillRow(),
                ),
              ),
              const SizedBox(height: 22),
              Expanded(
                child: TabBarView(
                  children: [
                    _PatientList(list: today,   label: 'Start',    outlined: false),
                    _PatientList(list: pending, label: 'Complete', outlined: true),
                  ],
                ),
              ),
            ],
          )
              : const _EmptyCard(),
        ),
      ),
    );
  }
}


/*──────────────── Pills row – stateless & crash-safe ─────────────*/
class _PillRow extends StatelessWidget {
  const _PillRow({super.key});

  @override
  Widget build(BuildContext context) {
    final TabController ctrl = DefaultTabController.of(context);

    Widget pill(String text, int index) {
      final selected = ctrl.index == index;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () => ctrl.animateTo(index),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF2D5661) : Colors.transparent,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              text,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextStyle(
                fontFamily: 'Avenir',
                fontSize: 20,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w300,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(90),
          ),
          child: Row(
            children: [
              pill("Today's Patients", 0),
              pill('Pending forms', 1),
            ],
          ),
        );
      },
    );
  }
}

/*──────────────── Patient list & row ───────────*/


class _PatientList extends StatelessWidget {
  const _PatientList({
    required this.list,
    required this.label,
    required this.outlined,
  });

  final List<AssessmentModel> list;
  final String label;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) return const _EmptyCard();

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (_, i) {
        final a = list[i];

        /* 1️⃣  “Start” goes to the read-only Patient-detail (AssessmentView)
               → we pass the assessment-document ID with **parameters**         */
        if (label == 'Start') {
          return _PatientRow(
            data     : a,
            label    : label,
            outlined : outlined,
            onTap: () => Get.toNamed(
              Routes.patientDetail,
              parameters: {
                'assessmentId': a.id,     // ← fix: was 'id'
                'referral'    : a.referral,
              },
            ),
          );
        }

        /* 2️⃣  “Complete” opens the same new AssessmentView (Practitioner tab) */
        return _PatientRow(
          data     : a,
          label    : label,
          outlined : outlined,
          onTap    : () => Get.toNamed(
            Routes.patientDetail,               // 👈 new screen (AssessmentView)
            parameters: {
              'assessmentId': a.id,
              'referral'    : a.referral,
              'tab'         : 'practitioner',  // 👈 select main Practitioner tab
              'prac'        : '0',             // 👈 sub-tab: 0 Objective, 1 Plan, 2 Remarks
            },
          ),
        );

      },
    );
  }
}





/*──────────────── Patient row – balanced gaps ─────────────────*/

class _PatientRow extends StatelessWidget {
  const _PatientRow({
    required this.data,
    required this.label,
    required this.outlined,
    required this.onTap,
  });

  final AssessmentModel data;
  final String label;
  final bool outlined;
  final VoidCallback onTap;

  Color _dot(int p) =>
      p >= 7 ? const Color(0xFFFF5656)
          : p >= 4 ? const Color(0xFFFFB915)
          : const Color(0xFF15B9FF);

  @override
  Widget build(BuildContext context) {
    final scrW   = MediaQuery.of(context).size.width;
    final tablet = scrW >= 560;                       // single-row threshold

    final name = SizedBox(
      width: 135,
      child: Text(
        '${data.firstName} ${data.lastName}',
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily : 'Avenir',
          fontSize   : 16,
          fontWeight : FontWeight.w800,
        ),
      ),
    );

    final time = _MetaCol(
      width: 70,
      title: 'Time',
      value: DateFormat('h:mm a').format(data.createdAt),
    );

    final area = _MetaCol(
      width: tablet ? 130 : 100,
      title: 'Area',
      value: data.chiefComplaint,
    );

    final pain = _MetaCol(
      width: 52,
      title: 'Pain',
      value: '${data.currentPain}/10',
      dotColor: _dot(data.currentPain),
    );

    final chip = GestureDetector(
      onTap: onTap,                               // ← navigate!
      child: _ActionChip(label: label, outlined: outlined),
    );

    // ── Tablets & big phones: one tidy row ──
    // ── Tablets & big phones: one tidy row ──
    if (tablet) {
      // slightly tighter gaps for narrow tablet widths
      final gap = scrW < 640 ? 20.0 : 32.0;

      // a slightly smaller area column on tight widths
      final areaWidth = scrW < 640 ? 110.0 : 130.0;

      final area = _MetaCol(
        width: areaWidth,
        title: 'Area',
        value: data.chiefComplaint,
      );

      // make the trailing chip shrink if space is tight
      final trailing = Flexible(
        fit: FlexFit.loose,
        child: Align(
          alignment: Alignment.centerRight,
          child: FittedBox(
            // scales down the chip only if needed
            child: GestureDetector(
              onTap: onTap,
              child: _ActionChip(label: label, outlined: outlined),
            ),
          ),
        ),
      );

      return _wrapContainer(
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            name,
            SizedBox(width: gap),
            time,
            SizedBox(width: gap),
            area,
            SizedBox(width: gap),
            pain,
            const Spacer(),
            trailing, // 👈 shrinkable chip
          ],
        ),
      );
    }


    // ── Small phones: Wrap with 16-px gaps ──
    return _wrapContainer(
      Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [name, time, area, pain, chip],
      ),
    );
  }

  Widget _wrapContainer(Widget child) => Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE0E0E0)),
    ),
    child: child,
  );
}


/*──────────────── Meta column widget ─────────────────*/

class _MetaCol extends StatelessWidget {
  const _MetaCol({
    required this.width,
    required this.title,
    required this.value,
    this.dotColor,
  });

  final double width;
  final String title;
  final String value;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dotColor != null)
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(right: 4, top: 2),
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily : 'Avenir',
                  fontSize   : 14,
                  fontWeight : FontWeight.w800,
                  color      : Color(0xFF696969),
                ),
              ),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily : 'Avenir',
                  fontSize   : 16,
                  fontWeight : FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}



/*──────────────── Meta block (fixed width) ─────────────────*/

class _MetaBlock extends StatelessWidget {
  const _MetaBlock(
      this.title,
      this.value, {
        required this.width,
        this.dotColor,
      });

  final String title;
  final String value;
  final double width;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dotColor != null)
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(right: 4, top: 2),
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily : 'Avenir',
                  fontSize   : 14,
                  fontWeight : FontWeight.w800,
                  color      : Color(0xFF696969),
                ),
              ),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily : 'Avenir',
                  fontSize   : 16,
                  fontWeight : FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Meta extends StatelessWidget {
  const _Meta(this.title, this.value, {this.dotColor});
  final String title;
  final String value;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (dotColor != null)
        Container(width: 14, height: 14, margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily : 'Avenir',
              fontSize   : 14,
              fontWeight : FontWeight.w800,
              color      : Color(0xFF696969),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily : 'Avenir',
              fontSize   : 16,
              fontWeight : FontWeight.w300,
            ),
          ),
        ],
      ),
    ],
  );
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.outlined});
  final String label;
  final bool outlined;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      color: outlined ? Colors.transparent : const Color(0xFF2D5661),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: const Color(0xFF2D5661)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily : 'Avenir',
            fontSize   : 16,
            fontWeight : FontWeight.w500,
            color      : outlined ? const Color(0xFF2D5661) : Colors.white,
          ),
        ),
        const SizedBox(width: 5),
        const Icon(Icons.arrow_forward, size: 22, color: Colors.white),
      ],
    ),
  );
}

/*──────────────── Empty card & bottom bar ───────*/

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/expert.png', width: 220),
        const SizedBox(height: 40),
        const Text(
          'Looks like there are no patients yet!',
          style: TextStyle(
            fontFamily : 'Avenir',
            fontSize   : 30,
            fontWeight : FontWeight.w500,
            letterSpacing: -0.41,
          ),
        ),
      ],
    ),
  );
}

