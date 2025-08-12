import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Models/assessment_model.dart';
import '../../Services/auth_service.dart';
import '../../Services/firestore_service.dart';
import '../Common/bottom_bar.dart';
import '../../routes/app_pages.dart';

class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fs   = Get.find<FirestoreService>();
    final uid  = Get.find<AuthService>().currentUser!.uid;
    final now  = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());
    final scrW = MediaQuery.of(context).size.width;
    final isTab= scrW > 600;
    final titleSz = isTab ? 42.5 : 34.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFDFF),

      appBar: AppBar(
        toolbarHeight: isTab ? 100 : 86,
        backgroundColor: const Color(0xFFFAFDFF),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 32,
        title: Text(
          'List of Patients',
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
                now,
                style: TextStyle(
                  fontFamily : 'Avenir',
                  fontSize   : isTab ? 20 : 16,
                  fontWeight : FontWeight.w300,
                  color      : const Color(0xFF696969),
                ),
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        child: Column(
          children: [
            // Search + Filters row
            Row(
              children: [
                // Search pill
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(148),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 20, color: Color(0xFF696969)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: 'Search by Name, Referral No.',
                              hintStyle: TextStyle(
                                color: Color(0xFF696969),
                                fontFamily: 'Avenir',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Filters pill (placeholder)
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    // TODO: open filters bottom sheet if needed
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 11),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text(
                      'Filters',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w500,
                        height: 1.38,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card with list / empty state
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width.clamp(0, 770).toDouble(),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    padding: const EdgeInsets.all(30),
                    child: StreamBuilder<List<AssessmentModel>>(
                      // Choose one:
                      // 1) All completed: fs.streamCompletedAssessments()
                      // 2) Only mine:     fs.streamCompletedAssessments(practitionerUid: uid)
                      stream:  fs.streamCompletedAssessments(practitionerUid: uid),
                      builder: (_, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final all = snap.data ?? [];

                        // client-side search
                        final q = _searchCtrl.text.trim().toLowerCase();
                        final list = q.isEmpty
                            ? all
                            : all.where((a) {
                          final name = ('${a.firstName} ${a.lastName}').toLowerCase();
                          final ref  = a.referral.toLowerCase();
                          return name.contains(q) || ref.contains(q);
                        }).toList();

                        if (list.isEmpty) {
                          return _EmptyUsersCard(); // expert.png + text
                        }

                        return ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 20),
                          itemBuilder: (_, i) {
                            final a = list[i];
                            return _CompletedRow(
                              data: a,
                              onTap: () {
                                // View the assessment (Patient tab by default)
                                Get.toNamed(
                                  Routes.patientDetail,
                                  parameters: {
                                    'assessmentId': a.id,
                                    'referral'    : a.referral,
                                    'tab'         : 'patient',
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const AppBottomBar(current: BottomTab.users),
    );
  }
}

/*───────────── Empty state ─────────────*/
class _EmptyUsersCard extends StatelessWidget {
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

/*───────────── Completed row (Figma-ish) ─────────────*/
class _CompletedRow extends StatelessWidget {
  const _CompletedRow({required this.data, required this.onTap});
  final AssessmentModel data;
  final VoidCallback onTap;

  Color _dot(int p) =>
      p >= 7 ? const Color(0xFFFF5656)
          : p >= 4 ? const Color(0xFFFFB915)
          : const Color(0xFF15B9FF);

  @override
  Widget build(BuildContext context) {
    final scrW   = MediaQuery.of(context).size.width;
    final tablet = scrW >= 560;

    final lastCheck = (data.analysisUpdatedAt ?? data.createdAt);
    final lastStr   = DateFormat('MM/dd/yy').format(lastCheck);

    final name = SizedBox(
      width: 135,
      child: Text(
        ' ${data.firstName} ${data.lastName}',
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontFamily: 'Avenir',
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    final last = _MetaCol(width: 110, title: 'Last Check-Up', value: lastStr);
    final area = _MetaCol(width: tablet ? 110 : 100, title: 'Area', value: data.chiefComplaint);
    final pain = _MetaCol(
      width: 52,
      title: 'Pain',
      value: '${data.currentPain}/10',
      dotColor: _dot(data.currentPain),
    );

    // trailing: small pill with just arrow (per Figma)
    final trailing = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: ShapeDecoration(
          color: const Color(0xFF2D5661),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
        child: const Icon(Icons.arrow_forward, size: 22, color: Colors.white),
      ),
    );

    // outlined container for a “selected” look is optional; here we keep all white
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: tablet
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          name,
          const SizedBox(width: 20),
          last,
          const SizedBox(width: 20),
          area,
          const SizedBox(width: 20),
          pain,
          const Spacer(),
          Flexible(
            fit: FlexFit.loose,
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(child: trailing),
            ),
          ),
        ],
      )
          : Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [name, last, area, pain, trailing],
      ),
    );
  }
}

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
                  color: Color(0xFF696969),
                  fontSize: 14,
                  fontFamily: 'Avenir',
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Avenir',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
